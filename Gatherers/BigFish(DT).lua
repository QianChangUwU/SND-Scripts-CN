--[=====[
[[SND Metadata]]
author: 'Minnu (https://ko-fi.com/minnuverse) || 汉化: QianChang (https://github.com/QianChangUwU)'
version: 3.0.0
description: 鱼王（7.0）- 自动钓取已追踪的 7.0 鱼王。
plugin_dependencies:
- MissFisher
- Lifestream
- vnavmesh
configs:
  RetryCooldownSeconds:
    description: 钓鱼失败后，重试同一条鱼前的等待秒数。
    default: 10
    min: 10
    max: 600
  CaughtCooldownSeconds:
    description: |
      本次窗口已捕获的鱼，再次尝试前的等待秒数。
      应大于该鱼的时间/天气窗口时长，避免窗口仍开放时被重新选中反复钓取。
    default: 3600
    min: 60
    max: 7200
  ForceQuitDelaySeconds:
    description: |
      鱼窗关闭后，强制退出钓鱼前的继续等待秒数。
      给正在进行的咬钩/捕获留出完成时间，而非窗口一关就立即打断。
    default: 15
    min: 0
    max: 120
  SwimBaitPrepSeconds:
    description: |
      对于 swimBait = true 的鱼，在真正窗口开启前多少秒提前就位并开始钓鱼。
      这样 MissFisher 可以自动处理游饵的准备阶段。
      仅在没有其他鱼窗开放时生效。
    default: 600
    min: 0
    max: 1800
  MissFisherPresetCommand:
    description: |
      启动 MissFisher 预设的命令模板，用于指定鱼种。
      使用 {name} 作为鱼名（或预设覆盖名）的占位符。
      默认为 "/mf preset {name}"，即启动匹配的预设。
      运行前请确保已在 MissFisher 中通过 "/mf sync" 同步预设。
    default: "/mf preset {name}"
  MissFisherStopCommand:
    description: |
      发送给 MissFisher 停止钓鱼的命令。
      默认为 "/mf stop"。如果你的 MissFisher 版本使用不同命令，请修改此项。
    default: "/mf stop"
  UseIdleTeleport:
    description: |
      启用后，当没有鱼窗可用时，会使用 Teleport("auto") 传送一次。
      请在 Lifestream 中配置 auto 传送目标。
    default: true
  EnabledFish:
    description: |
      限制轮换的鱼名列表。
      输入精确的鱼名后按回车，每行一条。
      非空时覆盖 DisabledFish，仅尝试列表中的鱼。
      留空则运行完整轮换。
    default: []
  DisabledFish:
    description: |
      完全跳过的鱼名列表。
      输入精确的鱼名后按回车，每行一条。
      钓到鱼后可手动将其从轮换中移除。
    default: []

[[End Metadata]]
--]=====]

--========================== 使用前提 ============================--
-- 使用本脚本前，请确保已完成以下准备：
-- 1. 已安装 MissFisher 插件，并执行 /mf sync 同步鱼名预设
-- 2. 已安装 Lifestream 插件（用于传送），并在 Lifestream 中配置好空闲自动传送目标
-- 3. 已安装 vnavmesh 插件（用于自动寻路）
-- 4. 当前职业为捕鱼人（Fisher），或已保存名为 "Fisher" 的兵装库预设
-- 5. 背包中已备齐所需鱼饵（脚本会自动检查，缺饵时会跳过对应鱼种）
-- 6. MissFisher 中已为每条鱼同步了对应的预设（preset）
--    脚本通过 /mf preset <鱼名> 命令启动钓鱼，请确保预设名称与鱼名一致
-- 7. 如启用了空闲传送（UseIdleTeleport），请在 Lifestream 中设置 auto 目标
--================================================================--

--========================== 依赖导入 ============================--

import("System")
import("System.Numerics")

--=========================== 变量定义 ==========================--

-------------------
--    通用配置    --
-------------------

RetryCooldownSeconds       = Config.Get("RetryCooldownSeconds")
CaughtCooldownSeconds      = Config.Get("CaughtCooldownSeconds")
MissFisherPresetCommand    = Config.Get("MissFisherPresetCommand")
MissFisherStopCommand      = Config.Get("MissFisherStopCommand")
UseIdleTeleport            = Config.Get("UseIdleTeleport")
ForceQuitDelaySeconds      = Config.Get("ForceQuitDelaySeconds")
SwimBaitPrepSeconds        = Config.Get("SwimBaitPrepSeconds")
LogPrefix                  = "[BigFish]"

local idleHoldoff          = 60

local lastAttempt          = {}
local disabledFish         = {}
local enabledFish          = {}
local baitItemIds          = {}
local missingBaitLog       = {}
local unknownFishLog       = {}
local invalidTimeLog       = {}
local invalidNameLog       = {}
local invalidWeatherLog    = {}
local invalidCoordinateLog = {}
local fishDataNames        = nil

local loggedIdle           = false
local idleTeleported       = false
local loggedIdleBusy       = false
local fishingStarted       = false
local missFisherActive     = false
local catchDetected        = false
local catchMessage         = nil
local forcedQuit           = false
local windowClosedAt       = nil
local windowOpenedAt       = false
local baitChecksReady      = false

--============================ 常量定义 ===========================--

------------------
--    动作 ID    --
------------------

CharacterAction            = {
    Actions = {
        quitFishing = 299,
    },
    GeneralActions = {
        mount    = 9,
        dismount = 23,
    }
}

---------------------
--    状态条件    --
---------------------

CharacterCondition         = {
    mounted      = 4,
    gathering    = 6,
    fishing      = 43,
    betweenAreas = 45,
}

-------------------
--    天气名称    --
-------------------

WeatherName                = {
    [1]   = "碧空",
    [2]   = "晴朗",
    [3]   = "阴云",
    [4]   = "薄雾",
    [5]   = "微风",
    [6]   = "强风",
    [7]   = "小雨",
    [8]   = "暴雨",
    [9]   = "打雷",
    [10]  = "雷雨",
    [11]  = "扬沙",
    [15]  = "小雪",
    [49]  = "灵风",
    [50]  = "灵电",
    [149] = "磁暴",
}

EorzeaWeatherRates         = {
    [1189] = { { 1, 15 }, { 2, 55 }, { 3, 70 }, { 4, 85 }, { 7, 100 } },             -- 亚克特尔树海
    [1188] = { { 1, 25 }, { 2, 60 }, { 3, 75 }, { 4, 85 }, { 7, 95 }, { 8, 100 } },  -- 克扎玛乌卡湿地
    [1192] = { { 7, 10 }, { 4, 20 }, { 3, 40 }, { 2, 100 } },                        -- 活着的记忆
    [1185] = { { 1, 40 }, { 2, 80 }, { 3, 85 }, { 4, 95 }, { 7, 100 } },             -- 图莱尤拉
    [1191] = { { 2, 5 }, { 3, 25 }, { 4, 40 }, { 7, 45 }, { 10, 50 }, { 50, 100 } }, -- 遗产之地
    [1190] = { { 1, 5 }, { 2, 50 }, { 3, 70 }, { 11, 85 }, { 6, 100 } },             -- 夏劳尼荒野
    [1187] = { { 1, 20 }, { 2, 50 }, { 3, 70 }, { 4, 80 }, { 5, 90 }, { 15, 100 } }, -- 奥阔帕恰山
    [1186] = { { 2, 100 } },                                                         -- 九号解决方案
}

----------------------------
--    状态管理    --
----------------------------

CharacterState             = {}

-----------------
--    鱼饵 ID    --
-----------------

BaitItemIds                = {
    ["深红沙蚕"] = 43850,
    ["黄金幼虫"] = 43849,
    ["蜜蜂饵"] = 43852,
    ["白蠕虫"] = 43854,
    ["嘭嘭拟饵"] = 43855,
    ["蜻蜓"] = 43857,
    ["红蛆"] = 43858,
    ["幽灵钳"] = 43859,
}

--------------------
--    大鱼数据    --
--------------------

FishData                   = {
    {
        name = "细枝王",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "玛穆克",
        spotName = "甜水泉",
        time = "16:00-18:00",
        weather = "薄雾",
        previousWeather = "小雨",
        bait = "红蛆",
        swimBait = true,
        x = 35.0,
        y = 32.7,
        radius = 1000,
        worldX = 653.68,
        worldY = -179.30,
        worldZ = 652.96,
        fishX = 663.30,
        fishY = -181.52,
        fishZ = 654.16,
    },
    {
        name = "咬鹃杀手",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "红豹村",
        spotName = "蓝咬鹃天坑",
        time = "0:00-24:00",
        weather = "阴云, 薄雾",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 19.1,
        y = 8.8,
        radius = 800,
        worldX = -54.94,
        worldY = 7.92,
        worldZ = -545.20,
        fishX = -52.66,
        fishY = 8.06,
        fishZ = -558.52,
    },
    {
        name = "苍天鱿鱼",
        expansion = "Dawntrail",
        zone = "夏劳尼荒野",
        zoneId = 1190,
        aetheryte = "胡萨塔伊驿镇",
        spotName = "佐戈海峡东侧",
        time = "18:00-24:00",
        weather = "强风",
        previousWeather = "碧空, 晴朗",
        bait = "蜻蜓",
        swimBait = false,
        x = 33.1,
        y = 38.2,
        radius = 1000,
        worldX = 483.57,
        worldY = 16.83,
        worldZ = 648.66,
        fishX = 491.44,
        fishY = 13.32,
        fishZ = 663.55,
    },
    {
        name = "涩水凯门鳄",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "玛穆克",
        spotName = "涩水天坑",
        time = "16:00-18:00",
        weather = "碧空",
        previousWeather = "薄雾",
        bait = "红蛆",
        swimBait = true,
        x = 25.5,
        y = 39.0,
        radius = 800,
        worldX = 200.18,
        worldY = -149.74,
        worldZ = 823.89,
        fishX = 209.39,
        fishY = -151.05,
        fishZ = 842.45,
    },
    {
        name = "屋底镰鳍鲳鲹",
        expansion = "Dawntrail",
        zone = "图莱尤拉",
        zoneId = 1185,
        aetheryte = "船头小屋",
        spotName = "船头小屋",
        time = "5:00-7:00",
        weather = "",
        previousWeather = "",
        bait = "幽灵钳",
        swimBait = false,
        x = 10.7,
        y = 15.3,
        radius = 1000,
        worldX = -157.30,
        worldY = -15.00,
        worldZ = 371.47,
        fishX = -152.05,
        fishY = -15.00,
        fishZ = 372.92,
    },
    {
        name = "锅盖蟹",
        expansion = "Dawntrail",
        zone = "克扎玛乌卡湿地",
        zoneId = 1188,
        aetheryte = "哈努聚落",
        spotName = "哈努水边",
        time = "16:00-20:00",
        weather = "阴云, 薄雾",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 22.9,
        y = 12.9,
        radius = 1200,
        worldX = 72.31,
        worldY = 0.47,
        worldZ = -428.35,
        fishX = 63.18,
        fishY = -0.40,
        fishZ = -428.09,
    },
    {
        name = "船路矛丽鱼",
        expansion = "Dawntrail",
        zone = "克扎玛乌卡湿地",
        zoneId = 1188,
        aetheryte = "哈努聚落",
        spotName = "露草河岸",
        time = "6:00-8:00",
        weather = "小雨",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 37.9,
        y = 33.3,
        radius = 600,
        worldX = 793.78,
        worldY = 114.62,
        worldZ = 558.97,
        fishX = 802.58,
        fishY = 114.62,
        fishZ = 566.75,
    },
    {
        name = "迎风粗纹松鲷",
        expansion = "Dawntrail",
        zone = "活着的记忆",
        zoneId = 1192,
        aetheryte = "地场节点·风",
        spotName = "地场节点·风",
        time = "2:00-4:00",
        weather = "小雨",
        previousWeather = "薄雾",
        bait = "红蛆",
        swimBait = true,
        x = 16.2,
        y = 13.2,
        radius = 600,
        worldX = -182.92,
        worldY = 31.82,
        worldZ = -376.60,
        fishX = -190.89,
        fishY = 31.20,
        fishZ = -383.58,
    },
    {
        name = "海心枯叶",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "红豹村",
        spotName = "红豹村蓄水池",
        time = "10:00-12:00",
        weather = "",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 13.7,
        y = 12.7,
        radius = 500,
        worldX = -438.47,
        worldY = 18.05,
        worldZ = -391.69,
    },
    {
        name = "希望鲤鱼",
        expansion = "Dawntrail",
        zone = "活着的记忆",
        zoneId = 1192,
        aetheryte = "地场节点·火",
        spotName = "原型亚历山德里亚",
        time = "22:00-24:00",
        weather = "阴云",
        previousWeather = "小雨",
        bait = "红蛆",
        swimBait = true,
        x = 38.5,
        y = 31.6,
        radius = 500,
        worldX = 814.81,
        worldY = 8.57,
        worldZ = 487.09,
        fishX = 822.63,
        fishY = 7.68,
        fishZ = 495.99,
    },
    {
        name = "锹鼻鲶",
        expansion = "Dawntrail",
        zone = "克扎玛乌卡湿地",
        zoneId = 1188,
        aetheryte = "朋友的灯火",
        spotName = "虹彩水底",
        time = "4:00-6:00",
        weather = "阴云",
        previousWeather = "小雨",
        bait = "嘭嘭拟饵",
        swimBait = true,
        x = 25.8,
        y = 31.6,
        radius = 800,
        worldX = 150.32,
        worldY = 115.40,
        worldZ = 528.67,
        fishX = 169.07,
        fishY = 109.77,
        fishZ = 525.83,
    },
    {
        name = "巨蛇头鳢",
        expansion = "Dawntrail",
        zone = "活着的记忆",
        zoneId = 1192,
        aetheryte = "地场节点·风",
        spotName = "亩鼠水泉",
        time = "4:00-6:00",
        weather = "小雨",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 12.6,
        y = 11.5,
        radius = 300,
        worldX = -433.48,
        worldY = -5.00,
        worldZ = -524.62,
        fishX = -436.41,
        fishY = -5.27,
        fishZ = -514.38,
    },
    {
        name = "凤尾鲯鲭",
        expansion = "Dawntrail",
        zone = "活着的记忆",
        zoneId = 1192,
        aetheryte = "地场节点·忆",
        spotName = "运河镇南侧",
        time = "8:00-12:00",
        weather = "晴朗",
        previousWeather = "小雨",
        bait = "幽灵钳",
        swimBait = false,
        x = 14.3,
        y = 34.8,
        radius = 1050,
        worldX = -354.26,
        worldY = 0.05,
        worldZ = 540.32,
        fishX = -368.37,
        fishY = 0.04,
        fishZ = 550.58,
    },
    {
        name = "滑稽女王",
        expansion = "Dawntrail",
        zone = "活着的记忆",
        zoneId = 1192,
        aetheryte = "地场节点·风",
        spotName = "易知区",
        time = "16:00-18:00",
        weather = "晴朗",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 7.2,
        y = 14.3,
        radius = 400,
        worldX = -728.20,
        worldY = -6.18,
        worldZ = -344.54,
        fishX = -718.79,
        fishY = -6.18,
        fishZ = -334.48,
    },
    {
        name = "遗产石斑鱼",
        expansion = "Dawntrail",
        zone = "遗产之地",
        zoneId = 1191,
        aetheryte = "雷转质矿场",
        spotName = "亚历山德里亚废墟",
        time = "12:00-16:00",
        weather = "晴朗",
        previousWeather = "薄雾",
        bait = "嘭嘭拟饵",
        swimBait = false,
        x = 6.8,
        y = 34.0,
        radius = 1000,
        worldX = -674.07,
        worldY = -14.00,
        worldZ = 611.24,
        fishX = -678.18,
        fishY = -14.00,
        fishZ = 623.29,
    },
    {
        name = "灰达尤南丽鱼",
        expansion = "Dawntrail",
        zone = "夏劳尼荒野",
        zoneId = 1190,
        aetheryte = "美花黑泽恩",
        spotName = "尼葵瑞皮河",
        time = "4:00-8:00",
        weather = "碧空, 晴朗",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 29.8,
        y = 7.4,
        radius = 600,
        worldX = 420.92,
        worldY = -17.70,
        worldZ = -708.28,
    },
    {
        name = "财神蛙",
        expansion = "Dawntrail",
        zone = "图莱尤拉",
        zoneId = 1185,
        aetheryte = "翼镜街",
        spotName = "休喙泉",
        time = "0:00-24:00",
        weather = "薄雾",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 9.7,
        y = 10.5,
        radius = 300,
        worldX = -201.72,
        worldY = 40.09,
        worldZ = -5.67,
        fishX = -207.17,
        fishY = 39.59,
        fishZ = -13.90,
    },
    {
        name = "余痕丽鱼",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "红豹村",
        spotName = "钓神基富天坑",
        time = "0:00-24:00",
        weather = "碧空",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 8.2,
        y = 11.9,
        radius = 600,
        worldX = -589.46,
        worldY = 1.47,
        worldZ = -399.71,
        fishX = -594.79,
        fishY = -0.17,
        fishZ = -411.32,
    },
    {
        name = "黑尖陶乐鲶",
        expansion = "Dawntrail",
        zone = "克扎玛乌卡湿地",
        zoneId = 1188,
        aetheryte = "朋友的灯火",
        spotName = "活船水路上游",
        time = "13:00-15:00",
        weather = "薄雾",
        previousWeather = "阴云",
        bait = "黄金幼虫",
        swimBait = true,
        x = 14.5,
        y = 28.6,
        radius = 2000,
        worldX = -185.08,
        worldY = 110.73,
        worldZ = 236.09,
        fishX = -173.81,
        fishY = 109.20,
        fishZ = 224.51,
    },
    {
        name = "铁黑骨舌鱼",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "红豹村",
        spotName = "赤血天坑",
        time = "16:00-18:00",
        weather = "小雨",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 31.8,
        y = 6.8,
        radius = 1800,
        worldX = 500.56,
        worldY = 3.64,
        worldZ = -531.60,
        fishX = 501.90,
        fishY = 0.07,
        fishZ = -543.01,
    },
    {
        name = "王亲钝口螈",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "玛穆克",
        spotName = "白烬天坑",
        time = "0:00-4:00",
        weather = "阴云",
        previousWeather = "晴朗",
        bait = "黄金幼虫",
        swimBait = true,
        x = 33.3,
        y = 16.6,
        radius = 800,
        worldX = 638.16,
        worldY = 11.20,
        worldZ = -255.69,
        fishX = 651.56,
        fishY = 10.17,
        fishZ = -259.10,
    },
    {
        name = "抓月虾",
        expansion = "Dawntrail",
        zone = "奥阔帕恰山",
        zoneId = 1187,
        aetheryte = "沃拉的回响",
        spotName = "沉星浮泪的池",
        time = "12:00-14:00",
        weather = "",
        previousWeather = "",
        bait = "白蠕虫",
        swimBait = false,
        x = 20.4,
        y = 27.6,
        radius = 400,
        worldX = -57.21,
        worldY = 7.75,
        worldZ = 304.67,
    },
    {
        name = "不完美的碟子",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "玛穆克",
        spotName = "抱拥天坑",
        time = "16:00-21:00",
        weather = "小雨",
        previousWeather = "碧空",
        bait = "红蛆",
        swimBait = true,
        x = 19.7,
        y = 32.0,
        radius = 1800,
        worldX = -111.17,
        worldY = -215.02,
        worldZ = 516.58,
        fishX = -113.27,
        fishY = -215.02,
        fishZ = 518.04,
    },
    {
        name = "战地巨雀鳝",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "红豹村",
        spotName = "战地天坑",
        time = "20:00-22:00",
        weather = "小雨",
        previousWeather = "",
        bait = "蜜蜂饵",
        swimBait = true,
        x = 21.7,
        y = 20.3,
        radius = 800,
        worldX = 37.80,
        worldY = -185.69,
        worldZ = -113.19,
        fishX = 31.04,
        fishY = -190.70,
        fishZ = -100.08,
    },
    {
        name = "麻瘩玛塔蛇颈龟",
        expansion = "Dawntrail",
        zone = "克扎玛乌卡湿地",
        zoneId = 1188,
        aetheryte = "土陶郡",
        spotName = "水没羽毛树林",
        time = "12:00-14:00",
        weather = "碧空",
        previousWeather = "",
        bait = "黄金幼虫",
        swimBait = true,
        x = 10.6,
        y = 12.4,
        radius = 1500,
        worldX = -543.71,
        worldY = 1.10,
        worldZ = -490.80,
        fishX = -524.67,
        fishY = -0.40,
        fishZ = -488.98,
    },
    {
        name = "奥雷奥雷奥雷",
        expansion = "Dawntrail",
        zone = "奥阔帕恰山",
        zoneId = 1187,
        aetheryte = "沃拉的回响",
        spotName = "其瓦固盐池",
        time = "0:00-2:00",
        weather = "小雪",
        previousWeather = "阴云",
        bait = "白蠕虫",
        swimBait = true,
        x = 20.0,
        y = 37.0,
        radius = 600,
        worldX = -75.05,
        worldY = 0.06,
        worldZ = 773.93,
        fishX = -78.47,
        fishY = -3.54,
        fishZ = 762.22,
    },
    {
        name = "像素鳅",
        expansion = "Dawntrail",
        zone = "九号解决方案",
        zoneId = 1186,
        aetheryte = "居住区域",
        spotName = "居住区域",
        time = "0:00-4:00",
        weather = "",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 6.5,
        y = 18.7,
        radius = 1800,
        worldX = -347.14,
        worldY = 14.03,
        worldZ = 154.19,
        fishX = -342.89,
        fishY = 13.73,
        fishZ = 161.06,
    },
    {
        name = "深奥的代言人",
        expansion = "Dawntrail",
        zone = "奥阔帕恰山",
        zoneId = 1187,
        aetheryte = "瓦丘恩佩洛",
        spotName = "卡瓦胡湖",
        time = "12:00-16:00",
        weather = "薄雾",
        previousWeather = "晴朗",
        bait = "红蛆",
        swimBait = false,
        x = 6.3,
        y = 20.3,
        radius = 1000,
        worldX = -674.72,
        worldY = 49.89,
        worldZ = 56.95,
        fishX = -683.81,
        fishY = 48.19,
        fishZ = 46.45,
    },
    {
        name = "海牛灾星",
        expansion = "Dawntrail",
        zone = "克扎玛乌卡湿地",
        zoneId = 1188,
        aetheryte = "哈努聚落",
        spotName = "水果岸边",
        time = "8:00-12:00",
        weather = "小雨",
        previousWeather = "阴云",
        bait = "黄金幼虫",
        swimBait = true,
        x = 40.0,
        y = 15.1,
        radius = 600,
        worldX = 925.54,
        worldY = 5.93,
        worldZ = -318.99,
        fishX = 931.25,
        fishY = 6.06,
        fishZ = -319.51,
    },
    {
        name = "富裕钱包",
        expansion = "Dawntrail",
        zone = "图莱尤拉",
        zoneId = 1185,
        aetheryte = "海岸鸟群市场",
        spotName = "满潮港",
        time = "16:00-18:00",
        weather = "小雨",
        previousWeather = "阴云",
        bait = "幽灵钳",
        swimBait = true,
        x = 16.9,
        y = 15.2,
        radius = 1800,
        worldX = 145.86,
        worldY = -17.96,
        worldZ = 155.21,
        fishX = 160.38,
        fishY = -17.96,
        fishZ = 171.30,
    },
    {
        name = "长河牙签鱼",
        expansion = "Dawntrail",
        zone = "克扎玛乌卡湿地",
        zoneId = 1188,
        aetheryte = "水果码头",
        spotName = "活船水路下游",
        time = "0:00-4:00",
        weather = "阴云",
        previousWeather = "晴朗",
        bait = "红蛆",
        swimBait = false,
        x = 29.2,
        y = 12.0,
        radius = 600,
        worldX = 366.41,
        worldY = 1.77,
        worldZ = -498.61,
        fishX = 367.97,
        fishY = -0.34,
        fishZ = -489.50,
    },
    {
        name = "小腿鲶",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "红豹村",
        spotName = "足尖小坑",
        time = "0:00-2:00",
        weather = "薄雾",
        previousWeather = "",
        bait = "红蛆",
        swimBait = true,
        x = 8.0,
        y = 27.2,
        radius = 400,
        worldX = -669.03,
        worldY = -185.73,
        worldZ = 289.21,
    },
    {
        name = "明亮红铜鲨",
        expansion = "Dawntrail",
        zone = "活着的记忆",
        zoneId = 1192,
        aetheryte = "地场节点·忆",
        spotName = "运河镇北侧",
        time = "8:00-13:00",
        weather = "薄雾",
        previousWeather = "阴云",
        bait = "幽灵钳",
        swimBait = false,
        x = 9.5,
        y = 28.1,
        radius = 1050,
        worldX = -643.74,
        worldY = 1.10,
        worldZ = 335.84,
        fishX = -637.27,
        fishY = 1.10,
        fishZ = 328.49,
    },
    {
        name = "玉米荚鲦鱼",
        expansion = "Dawntrail",
        zone = "克扎玛乌卡湿地",
        zoneId = 1188,
        aetheryte = "朋友的灯火",
        spotName = "大舌头瀑布潭",
        time = "4:00-6:00",
        weather = "小雨",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 22.7,
        y = 21.1,
        radius = 800,
        worldX = 22.59,
        worldY = 25.12,
        worldZ = -35.49,
        fishX = 23.89,
        fishY = 24.74,
        fishZ = -24.26,
    },
    {
        name = "南瓜芽太阳鱼",
        expansion = "Dawntrail",
        zone = "遗产之地",
        zoneId = 1191,
        aetheryte = "边郊镇",
        spotName = "边郊镇壕沟",
        time = "20:00-24:00",
        weather = "雷雨",
        previousWeather = "",
        bait = "红蛆",
        swimBait = true,
        x = 19.8,
        y = 8.9,
        radius = 1400,
        worldX = -144.75,
        worldY = 22.30,
        worldZ = -770.15,
    },
    {
        name = "星尘睡鱼",
        expansion = "Dawntrail",
        zone = "亚克特尔树海",
        zoneId = 1189,
        aetheryte = "玛穆克",
        spotName = "冥境天坑",
        time = "20:00-24:00",
        weather = "",
        previousWeather = "",
        bait = "深红沙蚕",
        swimBait = true,
        x = 36.9,
        y = 25.9,
        radius = 800,
        worldX = 769.11,
        worldY = -81.86,
        worldZ = 200.56,
        fishX = 780.83,
        fishY = -84.30,
        fishZ = 197.59,
    },
    {
        name = "雷光鲽鱼",
        expansion = "Dawntrail",
        zone = "遗产之地",
        zoneId = 1191,
        aetheryte = "雷转质矿场",
        spotName = "带雷危险水域",
        time = "0:00-24:00",
        weather = "小雨",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 21.5,
        y = 32.3,
        radius = 1800,
        worldX = -12.44,
        worldY = 49.44,
        worldZ = 541.99,
        fishX = -9.01,
        fishY = 49.09,
        fishZ = 531.90,
    },
    {
        name = "雷流鳟",
        expansion = "Dawntrail",
        zone = "遗产之地",
        zoneId = 1191,
        aetheryte = "雷转质矿场",
        spotName = "终流地",
        time = "9:00-11:00",
        weather = "",
        previousWeather = "",
        bait = "红蛆",
        swimBait = false,
        x = 13.1,
        y = 17.4,
        radius = 1500,
        worldX = -468.89,
        worldY = 37.00,
        worldZ = -148.98,
        fishX = -472.96,
        fishY = 37.90,
        fishZ = -138.44,
    },
    {
        name = "得卡特",
        expansion = "Dawntrail",
        zone = "夏劳尼荒野",
        zoneId = 1190,
        aetheryte = "美花黑泽恩",
        spotName = "特利湖",
        time = "20:00-24:00",
        weather = "扬沙",
        previousWeather = "晴朗",
        bait = "嘭嘭拟饵",
        swimBait = true,
        x = 31.5,
        y = 13.8,
        radius = 1000,
        worldX = 363.59,
        worldY = -17.35,
        worldZ = -430.24,
        fishX = 374.19,
        fishY = -18.16,
        fishZ = -430.24,
    },
    {
        name = "深坑徨灵",
        expansion = "Dawntrail",
        zone = "夏劳尼荒野",
        zoneId = 1190,
        aetheryte = "胡萨塔伊驿镇",
        spotName = "佐戈海峡西侧",
        time = "6:00-8:00",
        weather = "阴云",
        previousWeather = "强风",
        bait = "蜻蜓",
        swimBait = true,
        x = 16.1,
        y = 38.2,
        radius = 1000,
        worldX = -164.92,
        worldY = -27.46,
        worldZ = 643.97,
        fishX = -168.57,
        fishY = -31.44,
        fishZ = 655.41,
    },
}

--=========================== 函数定义 ===========================--

-------------------
--    辅助函数    --
-------------------

function Wait(time)
    yield(string.format("/wait %g", time))
end

function GetPlayerPosition()
    if Player and Player.Entity and Player.Entity.Position then
        return Player.Entity.Position
    end

    if Entity and Entity.Player and Entity.Player.Position then
        return Entity.Player.Position
    end

    return nil
end

function GetDistance(pos1, pos2)
    if not pos1 or not pos2 then
        Dalamud.LogDebug(string.format("%s [GetDistance] 一个或两个位置为 nil，返回 math.huge", LogPrefix))
        return math.huge
    end

    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
    Dalamud.LogDebug(string.format("%s [GetDistance] 位置1: (%.2f, %.2f, %.2f), 位置2: (%.2f, %.2f, %.2f), 距离: %.2f",
        LogPrefix, pos1.X, pos1.Y, pos1.Z, pos2.X, pos2.Y, pos2.Z, distance))
    return distance
end

function MoveTo(x, y, z, stopDistance, fly)
    fly = fly or false
    stopDistance = stopDistance or 0.0
    local destination = Vector3(x, y, z)
    local arrivalTolerance = 1.0

    local playerPos = GetPlayerPosition()
    if not playerPos then
        Dalamud.LogDebug(string.format("%s MoveTo: 玩家位置不可用。", LogPrefix))
        return false
    end

    if GetDistance(playerPos, destination) <= math.max(stopDistance, arrivalTolerance) then
        Dalamud.LogDebug(string.format("%s MoveTo: 已在目标位置。", LogPrefix))
        return true
    end

    if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        IPC.vnavmesh.Stop()
        Wait(0.5)
    end

    if not IPC.vnavmesh.PathfindAndMoveTo(destination, fly) then
        Dalamud.LogDebug(string.format("%s MoveTo: PathfindAndMoveTo 启动寻路失败。", LogPrefix))
        return false
    end

    local startTime = os.time()
    local maxSeconds = 120

    while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        Wait(0.1)

        if stopDistance > 0 then
            local currentPos = GetPlayerPosition()
            if currentPos and GetDistance(currentPos, destination) <= stopDistance then
                IPC.vnavmesh.Stop()
                break
            end
        end

        if (os.time() - startTime) > maxSeconds then
            IPC.vnavmesh.Stop()
            Dalamud.LogDebug(string.format("%s MoveTo: 超时，停止寻路。", LogPrefix))
            return false
        end
    end

    local finalPos = GetPlayerPosition()
    if not finalPos then
        Dalamud.LogDebug(string.format("%s MoveTo: 寻路后玩家位置不可用。", LogPrefix))
        return false
    end

    local okDist = (stopDistance > 0) and stopDistance or arrivalTolerance
    local finalDist = GetDistance(finalPos, destination)
    Dalamud.LogDebug(string.format("%s MoveTo: 完成，距离=%.2f。", LogPrefix, finalDist))
    return finalDist <= okDist
end

function GetEorzeaTime(unixSeconds)
    unixSeconds = unixSeconds or os.time()
    local eorzeaTotalMinutes = math.floor(unixSeconds * 3600 / 175 / 60)
    local hour = math.floor(eorzeaTotalMinutes / 60) % 24
    local minute = eorzeaTotalMinutes % 60
    Dalamud.LogDebug(string.format("%s GetEorzeaTime(%d) -> %02d:%02d", LogPrefix, unixSeconds, hour, minute))
    return hour, minute
end

function GetWeatherForecastTarget(unixSeconds)
    local bell = unixSeconds // 175
    local increment = (bell + 8 - (bell % 8)) % 24
    local totalDays = unixSeconds // 4200

    local calcBase = (totalDays * 100 + increment) & 0xFFFFFFFF
    local step1 = ((calcBase << 11) & 0xFFFFFFFF) ~ calcBase
    local step2 = (step1 >> 8) ~ step1

    return step2 % 100
end

function GetCurrentWeatherId(territoryId, unixSeconds)
    unixSeconds = unixSeconds or os.time()
    local rates = EorzeaWeatherRates[territoryId]
    if not rates then
        Dalamud.LogDebug(string.format("%s GetCurrentWeatherId: 区域 %d 没有天气概率数据", LogPrefix, territoryId))
        return nil
    end

    local target = GetWeatherForecastTarget(unixSeconds)
    for _, entry in ipairs(rates) do
        local weatherId, cumulativeChance = entry[1], entry[2]
        if target < cumulativeChance then
            return weatherId
        end
    end

    return nil
end

function GetCurrentWeatherName(territoryId, unixSeconds)
    local weatherId = GetCurrentWeatherId(territoryId, unixSeconds)
    return weatherId and WeatherName[weatherId] or nil
end

function GetPreviousWeatherName(territoryId, unixSeconds)
    unixSeconds = unixSeconds or os.time()
    return GetCurrentWeatherName(territoryId, unixSeconds - 1400)
end

-------------------
--    工具函数    --
-------------------

function OnChatMessage()
    local message = TriggerData and TriggerData.message

    if type(message) ~= "string" or not SelectedFish or not fishingStarted then
        return
    end

    local selectedFishName = GetFishName(SelectedFish)
    if selectedFishName and message:find(selectedFishName, 1, true) then
        catchDetected = true
        catchMessage = message
        Dalamud.Log(string.format("%s 检测到聊天消息匹配 %s: %s", LogPrefix, selectedFishName, message))
    end
end

function ConfigListAt(list, index)
    if not list then return nil end
    if list[0] ~= nil then
        return list[index]
    end
    return list[index + 1]
end

function BuildFishNameSet(configKey)
    local set = {}
    local config = Config.Get(configKey)

    if config and config.Count then
        for i = 0, config.Count - 1 do
            local fishName = ConfigListAt(config, i)
            if fishName and fishName ~= "" then
                set[fishName] = true
            end
        end
    elseif type(config) == "table" then
        for _, fishName in ipairs(config) do
            if fishName and fishName ~= "" then
                set[fishName] = true
            end
        end
    elseif type(config) == "string" and config ~= "" then
        for fishName in config:gmatch("[^\r\n,]+") do
            local trimmed = fishName:gsub("^%s+", ""):gsub("%s+$", "")
            if trimmed ~= "" then
                set[trimmed] = true
            end
        end
    end

    return set
end

function BuildDisabledFishSet()
    disabledFish = BuildFishNameSet("DisabledFish")
    ValidateFishNameSet("DisabledFish", disabledFish)
end

function BuildEnabledFishSet()
    enabledFish = BuildFishNameSet("EnabledFish")
    ValidateFishNameSet("EnabledFish", enabledFish)
end

function BuildBaitItemIdMap()
    baitItemIds = BaitItemIds
    baitChecksReady = true
    Dalamud.Log(string.format("%s 已加载鱼饵物品ID映射表。", LogPrefix))
end

function HasRequiredBait(fish)
    if not baitChecksReady then
        return true
    end

    if not fish.bait or fish.bait == "" then
        return true
    end

    local baitItemId = baitItemIds[fish.bait]
    local fishKey = GetFishStateKey(fish)
    local fishLabel = GetFishLogLabel(fish)
    if not baitItemId then
        if not missingBaitLog[fishKey] then
            Dalamud.Log(string.format("%s 跳过 %s: 无法解析鱼饵 '%s' 的物品ID。", LogPrefix, fishLabel, fish.bait))
            missingBaitLog[fishKey] = true
        end
        return false
    end

    local baitCount = Inventory.GetItemCount(baitItemId)
    if baitCount == 0 then
        baitCount = Inventory.GetHqItemCount(baitItemId)
        if baitCount == 0 then
            baitCount = Inventory.GetCollectableItemCount(baitItemId, 1)
        end
    end

    if baitCount <= 0 then
        if not missingBaitLog[fishKey] then
            Dalamud.Log(string.format("%s 跳过 %s: 背包中没有鱼饵 '%s'。", LogPrefix, fishLabel, fish.bait))
            missingBaitLog[fishKey] = true
        end
        return false
    end

    missingBaitLog[fishKey] = nil
    return true
end

function GetFishDataNames()
    if not fishDataNames then
        fishDataNames = {}
        for _, fish in ipairs(FishData) do
            local fishName = GetFishName(fish)
            if fishName then
                fishDataNames[fishName] = true
            else
                local logKey = GetFishLogKey(fish, "missing-name")
                if not invalidNameLog[logKey] then
                    Dalamud.Log(string.format("%s 警告: 遇到无效名称的 FishData 条目 - 配置名称验证将跳过此项直到修复。", LogPrefix))
                    invalidNameLog[logKey] = true
                end
            end
        end
    end
    return fishDataNames
end

function ValidateFishNameSet(configKey, set)
    local validNames = GetFishDataNames()
    for fishName in pairs(set) do
        if not validNames[fishName] then
            local logKey = configKey .. ":" .. fishName
            if not unknownFishLog[logKey] then
                Dalamud.Log(string.format("%s 警告: '%s' 在 %s 中不匹配任何 DT 大鱼。请检查拼写。", LogPrefix, fishName, configKey))
                unknownFishLog[logKey] = true
            end
        end
    end
end

function IsMissFisherRunning()
    return missFisherActive
end

function StartMissFisher()
    local fishName = SelectedFish and (SelectedFish.preset or GetFishName(SelectedFish)) or nil
    if not fishName then
        Dalamud.Log(string.format("%s 无法启动 MissFisher: 没有可用的鱼名。", LogPrefix))
        return
    end
    local command = MissFisherPresetCommand:gsub("{name}", fishName)
    Dalamud.Log(string.format("%s 启动 MissFisher: %s", LogPrefix, command))
    Engines.Run(command)
    missFisherActive = true
end

function StopMissFisher()
    Dalamud.Log(string.format("%s 停止 MissFisher: %s", LogPrefix, MissFisherStopCommand))
    Engines.Run(MissFisherStopCommand)
    missFisherActive = false
end

function GetFishName(fish)
    if fish and type(fish.name) == "string" and fish.name ~= "" then
        return fish.name
    end
    return nil
end

function GetFishLogLabel(fish)
    local fishName = GetFishName(fish)
    if fishName then
        return fishName
    end
    if fish and fish.name ~= nil then
        return tostring(fish.name)
    end
    return "<未命名鱼类>"
end

function GetFishStateKey(fish)
    return GetFishName(fish) or GetFishLogLabel(fish)
end

function GetFishLogKey(fish, suffix)
    return GetFishLogLabel(fish) .. ":" .. suffix
end

function HasValidFishName(fish)
    local fishName = GetFishName(fish)
    if fishName then
        return true
    end

    local logKey = GetFishLogKey(fish, "missing-name")
    if not invalidNameLog[logKey] then
        Dalamud.Log(string.format("%s 警告: %s 没有有效的字符串名称 - 跳过此鱼直到修复。", LogPrefix, GetFishLogLabel(fish)))
        invalidNameLog[logKey] = true
    end
    return false
end

function GetMissingRequiredCoordinateFields(fish)
    local missing = {}

    if not fish then
        table.insert(missing, "worldX")
        table.insert(missing, "worldY")
        table.insert(missing, "worldZ")
        return missing
    end

    if fish.worldX == nil then
        table.insert(missing, "worldX")
    end
    if fish.worldY == nil then
        table.insert(missing, "worldY")
    end
    if fish.worldZ == nil then
        table.insert(missing, "worldZ")
    end

    return missing
end

function HasRequiredCoordinates(fish)
    local missing = GetMissingRequiredCoordinateFields(fish)
    return #missing == 0
end

function WarnInvalidCoordinatesOnce(fish)
    local missing = GetMissingRequiredCoordinateFields(fish)
    if #missing == 0 then
        return
    end

    local logKey = GetFishLogKey(fish, "missing-coordinates")
    if not invalidCoordinateLog[logKey] then
        Dalamud.Log(string.format("%s 警告: %s 缺少必要坐标 (%s) - 跳过直到修复。", LogPrefix, GetFishLogLabel(fish),
            table.concat(missing, ", ")))
        invalidCoordinateLog[logKey] = true
    end
end

function GetWeatherRequirement(fish, fieldName)
    if not fish then
        return false, nil
    end

    local value = fish[fieldName]
    if value == nil or value == "" then
        return true, nil
    end

    if type(value) ~= "string" then
        local fishLabel = GetFishLogLabel(fish)
        local logKey = GetFishLogKey(fish, fieldName .. "-non-string")
        if not invalidWeatherLog[logKey] then
            Dalamud.Log(string.format("%s 警告: %s 的 %s 要求不是字符串类型 (%s) - 跳过此鱼直到修复。", LogPrefix, fishLabel, fieldName,
                type(value)))
            invalidWeatherLog[logKey] = true
        end
        return false, nil
    end

    return true, value
end

function ParseFishTimeWindow(fish)
    if not fish then
        return false, nil, nil
    end

    if fish.time == nil then
        local fishLabel = GetFishLogLabel(fish)
        local logKey = GetFishLogKey(fish, "missing")
        if not invalidTimeLog[logKey] then
            Dalamud.Log(string.format("%s 警告: %s 缺少时间窗口 - 跳过此鱼直到修复。应为 'H:MM-H:MM' 或 'Always'。", LogPrefix, fishLabel))
            invalidTimeLog[logKey] = true
        end
        return false, nil, nil
    end

    if fish.time == "Always" then
        return true, nil, nil
    end

    if type(fish.time) ~= "string" then
        local fishLabel = GetFishLogLabel(fish)
        local logKey = GetFishLogKey(fish, "non-string")
        if not invalidTimeLog[logKey] then
            Dalamud.Log(string.format("%s 警告: %s 的时间窗口不是字符串类型 (%s) - 跳过此鱼直到修复。应为 'H:MM-H:MM' 或 'Always'。", LogPrefix,
                fishLabel, type(fish.time)))
            invalidTimeLog[logKey] = true
        end
        return false, nil, nil
    end

    local startHour, startMinute, endHour, endMinute = fish.time:match("^(%d+):(%d+)%-(%d+):(%d+)$")
    if not startHour then
        local fishLabel = GetFishLogLabel(fish)
        local logKey = GetFishLogKey(fish, "malformed")
        if not invalidTimeLog[logKey] then
            Dalamud.Log(string.format("%s 警告: %s 的时间窗口 '%s' 无法解析 - 跳过此鱼直到修复。应为 'H:MM-H:MM' 或 'Always'。", LogPrefix,
                fishLabel, fish.time))
            invalidTimeLog[logKey] = true
        end
        return false, nil, nil
    end

    startHour = tonumber(startHour)
    startMinute = tonumber(startMinute)
    endHour = tonumber(endHour)
    endMinute = tonumber(endMinute)

    local startValid = startHour and startMinute
        and startHour >= 0 and startHour < 24
        and startMinute >= 0 and startMinute < 60
    local endValid = endHour and endMinute
        and endHour >= 0 and endHour <= 24
        and endMinute >= 0 and endMinute < 60
        and (endHour < 24 or endMinute == 0)
    if not startValid or not endValid then
        local fishLabel = GetFishLogLabel(fish)
        local logKey = GetFishLogKey(fish, "out-of-range")
        if not invalidTimeLog[logKey] then
            Dalamud.Log(string.format("%s 警告: %s 的时间窗口 '%s' 超出范围 - 跳过此鱼直到修复。应为 0:00-23:59，24:00 仅允许作为结束时间。", LogPrefix,
                fishLabel, fish.time))
            invalidTimeLog[logKey] = true
        end
        return false, nil, nil
    end

    local startMinutes = startHour * 60 + startMinute
    local endMinutes = endHour * 60 + endMinute
    if startMinutes == endMinutes then
        local fishLabel = GetFishLogLabel(fish)
        local logKey = GetFishLogKey(fish, "zero-width")
        if not invalidTimeLog[logKey] then
            Dalamud.Log(string.format("%s 警告: %s 的时间窗口 '%s' 宽度为零 - 跳过此鱼直到修复。", LogPrefix, fishLabel, fish.time))
            invalidTimeLog[logKey] = true
        end
        return false, nil, nil
    end

    return true, startMinutes, endMinutes
end

function IsFishRuntimeValid(fish)
    if not HasValidFishName(fish) then
        return false
    end

    if not HasRequiredCoordinates(fish) then
        WarnInvalidCoordinatesOnce(fish)
        return false
    end

    local hasValidTimeWindow = ParseFishTimeWindow(fish)
    if not hasValidTimeWindow then
        return false
    end

    local hasValidWeather = GetWeatherRequirement(fish, "weather")
    if not hasValidWeather then
        return false
    end

    local hasValidPreviousWeather = GetWeatherRequirement(fish, "previousWeather")
    if not hasValidPreviousWeather then
        return false
    end

    return true
end

function IsFishUp(fish, unixSeconds)
    unixSeconds = unixSeconds or os.time()

    if not IsFishRuntimeValid(fish) then
        return false
    end

    local _, startMinutes, endMinutes = ParseFishTimeWindow(fish)
    if startMinutes then
        local hour, minute = GetEorzeaTime(unixSeconds)
        local currentMinutes = hour * 60 + minute

        if endMinutes > startMinutes then
            if currentMinutes < startMinutes or currentMinutes >= endMinutes then
                return false
            end
        else
            if currentMinutes < startMinutes and currentMinutes >= endMinutes then
                return false
            end
        end
    end

    local _, weatherRequirement = GetWeatherRequirement(fish, "weather")
    if weatherRequirement then
        local currentWeather = GetCurrentWeatherName(fish.zoneId, unixSeconds)
        if not currentWeather or not string.find(weatherRequirement, currentWeather, 1, true) then
            return false
        end
    end

    local _, previousWeatherRequirement = GetWeatherRequirement(fish, "previousWeather")
    if previousWeatherRequirement then
        local priorWeather = GetPreviousWeatherName(fish.zoneId, unixSeconds)
        if not priorWeather or not string.find(previousWeatherRequirement, priorWeather, 1, true) then
            return false
        end
    end

    return true
end

function GetSecondsUntilFishWindowStart(fish, unixSeconds)
    unixSeconds = unixSeconds or os.time()

    local hasValidTimeWindow, startMinutes, endMinutes = ParseFishTimeWindow(fish)
    if not hasValidTimeWindow then
        return nil
    end

    if not startMinutes then
        return nil
    end

    local hour, minute = GetEorzeaTime(unixSeconds)
    local currentMinutes = hour * 60 + minute

    if endMinutes > startMinutes then
        if currentMinutes < startMinutes then
            return math.ceil((startMinutes - currentMinutes) * 175 / 60)
        end
        if currentMinutes >= endMinutes then
            return math.ceil(((24 * 60) - currentMinutes + startMinutes) * 175 / 60)
        end
        return 0
    end

    if currentMinutes >= startMinutes or currentMinutes < endMinutes then
        return 0
    end

    return math.ceil((startMinutes - currentMinutes) * 175 / 60)
end

function IsFishReady(fish, unixSeconds)
    unixSeconds = unixSeconds or os.time()
    if IsFishUp(fish, unixSeconds) then
        return true
    end
    if fish.swimBait then
        local secondsUntilStart = GetSecondsUntilFishWindowStart(fish, unixSeconds)
        if secondsUntilStart and secondsUntilStart <= SwimBaitPrepSeconds then
            return IsFishUp(fish, unixSeconds + secondsUntilStart)
        end
        return IsFishUp(fish, unixSeconds + SwimBaitPrepSeconds)
    end
    return false
end

-------------------
--    钓鱼逻辑    --
-------------------

function IsFishAllowed(fish)
    if next(enabledFish) ~= nil then
        return enabledFish[GetFishName(fish)] == true
    end
    return not disabledFish[GetFishName(fish)]
end

function IsFishSelectable(fish)
    if not IsFishRuntimeValid(fish) then
        return false
    end

    local cooldownUntil = lastAttempt[GetFishStateKey(fish)]
    return IsFishAllowed(fish)
        and HasRequiredBait(fish)
        and (not cooldownUntil or os.time() >= cooldownUntil)
end

function HasUpcomingSelectableFish(secondsAhead)
    if secondsAhead <= 0 then
        return false
    end

    local futureTime = os.time() + secondsAhead
    for _, fish in ipairs(FishData) do
        if IsFishSelectable(fish) and IsFishReady(fish, futureTime) then
            return true
        end
    end
    return false
end

function SelectNextFish()
    for _, fish in ipairs(FishData) do
        if IsFishSelectable(fish) and IsFishUp(fish) then
            return fish
        end
    end

    for _, fish in ipairs(FishData) do
        if fish.swimBait and IsFishSelectable(fish) and IsFishReady(fish) then
            return fish
        end
    end

    return nil
end

function TeleportToIdleOnce()
    if not UseIdleTeleport then
        return
    end

    if idleTeleported then
        return
    end

    if HasUpcomingSelectableFish(idleHoldoff) then
        if not loggedIdleBusy then
            Dalamud.Log(string.format("%s 跳过空闲传送: 鱼窗或游饵准备即将开始。", LogPrefix))
            loggedIdleBusy = true
        end
        return
    end

    if not (Player and Player.Available and not Player.IsBusy)
        or Svc.Condition[CharacterCondition.fishing]
        or Svc.Condition[CharacterCondition.gathering]
        or IPC.Lifestream.IsBusy()
    then
        if not loggedIdleBusy then
            Dalamud.Log(string.format("%s 推迟空闲传送: 玩家忙碌或不可用。", LogPrefix))
            loggedIdleBusy = true
        end
        return
    end

    idleTeleported = true
    loggedIdleBusy = false
    Dalamud.Log(string.format("%s 返回 Lifestream 自动空闲位置。", LogPrefix))
    IPC.Lifestream.ExecuteCommand("auto")
end

function CharacterState.selectFish()
    BuildDisabledFishSet()
    BuildEnabledFishSet()

    local fish = SelectNextFish()

    if not fish then
        if not loggedIdle then
            Dalamud.Log(string.format("%s 当前没有鱼窗开放。等待中...", LogPrefix))
            loggedIdle = true
        end
        TeleportToIdleOnce()
        return
    end

    loggedIdle = false
    idleTeleported = false
    loggedIdleBusy = false
    SelectedFish = fish
    Dalamud.Log(string.format("%s 已选择鱼类: %s (%s, 鱼饵: %s)", LogPrefix, GetFishLogLabel(SelectedFish),
        tostring(SelectedFish.spotName), tostring(SelectedFish.bait)))
    State = CharacterState.teleportToZone
    Dalamud.Log(string.format("%s 状态切换 -> 传送至区域", LogPrefix))
    Wait(0.3)
end

function CharacterState.teleportToZone()
    if not IsFishReady(SelectedFish) then
        Dalamud.Log(string.format("%s 的窗口在到达前已关闭。", LogPrefix, GetFishLogLabel(SelectedFish)))
        State = CharacterState.selectFish
        Dalamud.Log(string.format("%s 状态切换 -> 选择鱼类", LogPrefix))
        return
    end

    if Svc.ClientState.TerritoryType ~= SelectedFish.zoneId then
        local aetheryteName = SelectedFish.aetheryte
        if not aetheryteName or aetheryteName == "" then
            local territoryData = Excel.GetRow("TerritoryType", SelectedFish.zoneId)
            aetheryteName = territoryData and territoryData.Aetheryte and territoryData.Aetheryte.PlaceName and
                tostring(territoryData.Aetheryte.PlaceName.Name) or nil
        end
        if aetheryteName then
            IPC.Lifestream.ExecuteCommand(aetheryteName)
            Wait(0.1)
            repeat
                Wait(0.1)
            until not IPC.Lifestream.IsBusy() and (Player and Player.Available and not Player.IsBusy)

            local teleportStart = os.time()
            repeat
                Wait(0.1)
            until not (Player.Entity and Player.Entity.IsCasting) or (os.time() - teleportStart) >= 300
            Wait(0.1)

            repeat
                Wait(0.1)
            until (not Svc.Condition[CharacterCondition.betweenAreas] and Player and Player.Available and not Player.IsBusy) or (os.time() - teleportStart) >= 300
            Wait(0.1)
            Wait(0.3)
        end
        return
    end

    if not (Player and Player.Available and not Player.IsBusy) then
        return
    end

    State = CharacterState.travelToSpot
    Dalamud.Log(string.format("%s 状态切换 -> 前往钓点", LogPrefix))
    Wait(0.3)
end

function CharacterState.travelToSpot()
    if not IsFishReady(SelectedFish) then
        Dalamud.Log(string.format("%s 的窗口在到达前已关闭。", LogPrefix, GetFishLogLabel(SelectedFish)))
        State = CharacterState.selectFish
        Dalamud.Log(string.format("%s 状态切换 -> 选择鱼类", LogPrefix))
        return
    end

    if Svc.ClientState.TerritoryType ~= SelectedFish.zoneId then
        State = CharacterState.teleportToZone
        Dalamud.Log(string.format("%s 状态切换 -> 传送至区域", LogPrefix))
        return
    end

    while not IPC.vnavmesh.IsReady() do
        Wait(0.1)
    end

    local arrived

    if not Player.CanMount then
        Dalamud.Log(string.format("%s 步行前往 %s (%.1f, %.1f)", LogPrefix, SelectedFish.spotName, SelectedFish.worldX,
            SelectedFish.worldZ))
        arrived = MoveTo(SelectedFish.worldX, SelectedFish.worldY, SelectedFish.worldZ)
        Wait(0.3)
    else
        if not Svc.Condition[CharacterCondition.mounted] then
            local mountStart = os.time()
            repeat
                Actions.ExecuteGeneralAction(CharacterAction.GeneralActions.mount)
                Wait(1)
            until Svc.Condition[CharacterCondition.mounted] or (os.time() - mountStart) > 10
        end
        Wait(0.3)
        local fly = Player.CanFly
        Dalamud.Log(string.format("%s %s 前往 %s (%.1f, %.1f)", LogPrefix, fly and "飞行" or "骑乘", SelectedFish.spotName,
            SelectedFish.worldX, SelectedFish.worldZ))
        MoveTo(SelectedFish.worldX, SelectedFish.worldY, SelectedFish.worldZ, 0, fly)

        while Svc.Condition[CharacterCondition.mounted] do
            Actions.ExecuteGeneralAction(CharacterAction.GeneralActions.dismount)
            Wait(1)
        end

        local landedPos = GetPlayerPosition()
        arrived = landedPos and
            GetDistance(landedPos, Vector3(SelectedFish.worldX, SelectedFish.worldY, SelectedFish.worldZ)) <= 1.0
        Wait(0.3)
    end

    if not arrived then
        Dalamud.Log(string.format("%s 未能到达 %s 的钓点。冷却后稍后重试。", LogPrefix, GetFishLogLabel(SelectedFish)))
        lastAttempt[GetFishStateKey(SelectedFish)] = os.time() + RetryCooldownSeconds
        State = CharacterState.selectFish
        Dalamud.Log(string.format("%s 状态切换 -> 选择鱼类", LogPrefix))
        return
    end

    local fishX = SelectedFish.fishX or SelectedFish.worldX
    local fishY = SelectedFish.fishY or SelectedFish.worldY
    local fishZ = SelectedFish.fishZ or SelectedFish.worldZ
    if fishX ~= SelectedFish.worldX or fishZ ~= SelectedFish.worldZ then
        Dalamud.Log(string.format("%s 步行前往抛竿位置 (%.1f, %.1f)", LogPrefix, fishX, fishZ))
        local fishArrived = MoveTo(fishX, fishY, fishZ)
        Wait(0.3)

        if not fishArrived then
            Dalamud.Log(string.format("%s 未能到达 %s 的抛竿位置。冷却后稍后重试。", LogPrefix, GetFishLogLabel(SelectedFish)))
            lastAttempt[GetFishStateKey(SelectedFish)] = os.time() + RetryCooldownSeconds
            State = CharacterState.selectFish
            Dalamud.Log(string.format("%s 状态切换 -> 选择鱼类", LogPrefix))
            return
        end
    end

    State = CharacterState.fishing
    Dalamud.Log(string.format("%s 状态切换 -> 钓鱼中", LogPrefix))
    Wait(0.3)
end

function CharacterState.fishing()
    if not fishingStarted then
        if not IsFishReady(SelectedFish) then
            Dalamud.Log(string.format("%s 的窗口在开始钓鱼前已关闭。", LogPrefix, GetFishLogLabel(SelectedFish)))
            StopMissFisher()
            State = CharacterState.selectFish
            Dalamud.Log(string.format("%s 状态切换 -> 选择鱼类", LogPrefix))
            return
        end

        if not (Player and Player.Available and not Player.IsBusy) then
            return
        end

        Dalamud.Log(string.format("%s 为 %s 启动 MissFisher", LogPrefix, GetFishLogLabel(SelectedFish)))
        catchDetected = false
        catchMessage = nil
        forcedQuit = false
        windowClosedAt = nil
        windowOpenedAt = IsFishUp(SelectedFish)
        StartMissFisher()
        Wait(1)
        local mfStartedAt = os.time()
        while not Svc.Condition[CharacterCondition.fishing] and (os.time() - mfStartedAt) < 15 do
            if not IsMissFisherRunning() then
                StartMissFisher()
            end
            Wait(4)
        end

        if Svc.Condition[CharacterCondition.fishing] then
            fishingStarted = true
        else
            Dalamud.Log(string.format("%s MissFisher 未能为 %s 启动钓鱼。强制退出以恢复。", LogPrefix, GetFishLogLabel(SelectedFish)))
            StopMissFisher()
            Actions.ExecuteAction(CharacterAction.Actions.quitFishing, ActionType.Action)
            Wait(0.3)
        end
        return
    end

    if IsFishUp(SelectedFish) then
        windowOpenedAt = true
        windowClosedAt = nil
    elseif windowOpenedAt then
        if Svc.Condition[CharacterCondition.fishing] or Svc.Condition[CharacterCondition.gathering] then
            if not windowClosedAt then
                windowClosedAt = os.time()
                Dalamud.Log(string.format("%s 的窗口在钓鱼时关闭。%.0f 秒后强制退出。", LogPrefix, GetFishLogLabel(SelectedFish),
                    ForceQuitDelaySeconds))
            end

            if os.time() - windowClosedAt >= ForceQuitDelaySeconds then
                forcedQuit = true
                Actions.ExecuteAction(CharacterAction.Actions.quitFishing, ActionType.Action)
                Wait(0.3)
            end
            return
        end
    end

    if Svc.Condition[CharacterCondition.fishing] or Svc.Condition[CharacterCondition.gathering] then
        Wait(1)
        return
    end

    if catchDetected then
        Dalamud.Log(string.format("%s 确认捕获 %s。", LogPrefix, GetFishLogLabel(SelectedFish)))
        if catchMessage then
            Dalamud.Log(string.format("%s 捕获消息: %s", LogPrefix, catchMessage))
        end
    elseif forcedQuit then
        Dalamud.Log(string.format("%s 的窗口已关闭，结束本次尝试。", LogPrefix, GetFishLogLabel(SelectedFish)))
    else
        Dalamud.Log(string.format("%s 本次尝试结束，未确认捕获。", LogPrefix, GetFishLogLabel(SelectedFish)))
    end

    local cooldownSeconds = catchDetected and CaughtCooldownSeconds or RetryCooldownSeconds
    lastAttempt[GetFishStateKey(SelectedFish)] = os.time() + cooldownSeconds
    StopMissFisher()
    fishingStarted = false
    catchDetected = false
    catchMessage = nil
    forcedQuit = false
    windowClosedAt = nil
    windowOpenedAt = false
    State = CharacterState.selectFish
    Dalamud.Log(string.format("%s 状态切换 -> 选择鱼类", LogPrefix))
    Wait(0.3)
end

--=========================== 执行入口 ===========================--

for _, fish in ipairs(FishData) do
    IsFishRuntimeValid(fish)
end

BuildBaitItemIdMap()

if not (Player and Player.Job and Player.Job.Id == 18) then
    Dalamud.Log(string.format("%s 切换至捕鱼人。", LogPrefix))
    Engines.Run("/gs change Fisher")
    Wait(1)
end

State = CharacterState.selectFish
Dalamud.Log(string.format("%s 状态切换 -> 选择鱼类", LogPrefix))

while true do
    State()
    Wait(1)
end

--============================== 结束 ==============================--

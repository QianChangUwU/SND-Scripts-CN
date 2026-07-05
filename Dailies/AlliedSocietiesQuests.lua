--[=====[
[[SND Metadata]]
author: 'pot0to (https://ko-fi.com/pot0to) || Maintainer: Minnu (https://ko-fi.com/minnuverse) || 汉化: QianChang (https://github.com/QianChangUwU)'
version: 2.1.4
description: 蛮族日常任务 - 自动领取并完成指定蛮族的日常任务
plugin_dependencies:
- Questionable
- vnavmesh
- Lifestream
- TextAdvance
configs:
  ManualQuestPickup:
    default: false
    description: 勾选后手动从NPC处接取任务；否则由 Questionable 自动处理任务接取。
  FirstAlliedSociety:
    description: 第一个要接取任务的蛮族。
    is_choice: true
    choices:
        - "无"
        - "尤卡巨人族"
        - "辉鳞族"
        - "佩鲁佩鲁族"
        - "奥密克戎族"
        - "兔兔族"
        - "悌阳象族"
        - "矮人族"
        - "奇塔利族"
        - "仙子族"
        - "鲶鱼精族"
        - "阿难陀族"
        - "甲人族"
        - "莫古力族"
        - "骨颌族"
        - "瓦努族"
        - "鸟人族（中立）"
        - "鸟人族（承认）"
        - "鸟人族（友好）"
        - "鸟人族（信赖）"
        - "鸟人族（尊敬）"
        - "鸟人族（名誉）"
        - "鱼人族（中立）"
        - "鱼人族（承认）"
        - "鱼人族（友好）"
        - "地灵族（中立）"
        - "地灵族（承认）"
        - "地灵族（友好）"
        - "妖精族（中立）"
        - "妖精族（承认）"
        - "妖精族（友好）"
        - "蜥蜴人族（中立）"
        - "蜥蜴人族（承认）"
        - "蜥蜴人族（友好）"
  FirstClass:
    description: 第一个蛮族使用的职业/特职。
  SecondAlliedSociety:
    description: 第二个要接取任务的蛮族。
    is_choice: true
    choices:
        - "无"
        - "尤卡巨人族"
        - "辉鳞族"
        - "佩鲁佩鲁族"
        - "奥密克戎族"
        - "兔兔族"
        - "悌阳象族"
        - "矮人族"
        - "奇塔利族"
        - "仙子族"
        - "鲶鱼精族"
        - "阿难陀族"
        - "甲人族"
        - "莫古力族"
        - "骨颌族"
        - "瓦努族"
        - "鸟人族（中立）"
        - "鸟人族（承认）"
        - "鸟人族（友好）"
        - "鸟人族（信赖）"
        - "鸟人族（尊敬）"
        - "鸟人族（名誉）"
        - "鱼人族（中立）"
        - "鱼人族（承认）"
        - "鱼人族（友好）"
        - "地灵族（中立）"
        - "地灵族（承认）"
        - "地灵族（友好）"
        - "妖精族（中立）"
        - "妖精族（承认）"
        - "妖精族（友好）"
        - "蜥蜴人族（中立）"
        - "蜥蜴人族（承认）"
        - "蜥蜴人族（友好）"
  SecondClass:
    description: 第二个蛮族使用的职业/特职。
  ThirdAlliedSociety:
    description: 第三个要接取任务的蛮族。
    is_choice: true
    choices:
        - "无"
        - "尤卡巨人族"
        - "辉鳞族"
        - "佩鲁佩鲁族"
        - "奥密克戎族"
        - "兔兔族"
        - "悌阳象族"
        - "矮人族"
        - "奇塔利族"
        - "仙子族"
        - "鲶鱼精族"
        - "阿难陀族"
        - "甲人族"
        - "莫古力族"
        - "骨颌族"
        - "瓦努族"
        - "鸟人族（中立）"
        - "鸟人族（承认）"
        - "鸟人族（友好）"
        - "鸟人族（信赖）"
        - "鸟人族（尊敬）"
        - "鸟人族（名誉）"
        - "鱼人族（中立）"
        - "鱼人族（承认）"
        - "鱼人族（友好）"
        - "地灵族（中立）"
        - "地灵族（承认）"
        - "地灵族（友好）"
        - "妖精族（中立）"
        - "妖精族（承认）"
        - "妖精族（友好）"
        - "蜥蜴人族（中立）"
        - "蜥蜴人族（承认）"
        - "蜥蜴人族（友好）"
  ThirdClass:
    description: 第三个蛮族使用的职业/特职。
  FourthAlliedSociety:
    description: 第四个要接取任务的蛮族。
    is_choice: true
    choices:
        - "无"
        - "尤卡巨人族"
        - "辉鳞族"
        - "佩鲁佩鲁族"
        - "奥密克戎族"
        - "兔兔族"
        - "悌阳象族"
        - "矮人族"
        - "奇塔利族"
        - "仙子族"
        - "鲶鱼精族"
        - "阿难陀族"
        - "甲人族"
        - "莫古力族"
        - "骨颌族"
        - "瓦努族"
        - "鸟人族（中立）"
        - "鸟人族（承认）"
        - "鸟人族（友好）"
        - "鸟人族（信赖）"
        - "鸟人族（尊敬）"
        - "鸟人族（名誉）"
        - "鱼人族（中立）"
        - "鱼人族（承认）"
        - "鱼人族（友好）"
        - "地灵族（中立）"
        - "地灵族（承认）"
        - "地灵族（友好）"
        - "妖精族（中立）"
        - "妖精族（承认）"
        - "妖精族（友好）"
        - "蜥蜴人族（中立）"
        - "蜥蜴人族（承认）"
        - "蜥蜴人族（友好）"
  FourthClass:
    description: 第四个蛮族使用的职业/特职。

[[End Metadata]]
--]=====]

--[[
********************************************************************************
*                              蛮族日常任务脚本                                *
*                               版本 2.1.3                                     *
********************************************************************************
作者: pot0to (https://ko-fi.com/pot0to)
维护: Minnu

自动前往指定的蛮族据点，接取 3 个日常任务，完成后前往下一个蛮族据点。

    -> 2.1.4    修复 Questionable 接取任务超时问题
                1. 超时计时器仅在 Questionable 未运行时计数（运行中视为正在处理）
                2. 移除 vnavmesh.Stop() 避免打断 Questionable 自身寻路
                3. 移除施法取消避免打断 Questionable 传送
                4. 超时阈值从15秒提升至30秒（仅计停止时间）
                5. 轮询间隔从0.1秒提升至0.5秒减少开销
    -> 2.1.3    修复 Questionable 任务接取问题，增强日志输出
    -> 2.1.2    为 2.0 蛮族添加等级专属任务发布者支持
    -> 2.1.1    修复 ManualQuestPickup 关闭时无法接取任务的问题
    -> 2.1.0    多语言支持 (credit: Valgrifer)
    -> 2.0.3    7.35 版本添加尤卡巨人族
    -> 2.0.2    添加手动接取任务选项
                添加蛮族下拉选择菜单
    -> 2.0.1    适配 7.3 版本
    -> 2.0.0    适配 SND v2
    -> 0.2.1    修复辉鳞族名称，从预设中移除主线任务
    -> 0.2.0    7.25 版本添加辉鳞族 (credit: Leonhart)
    -> 0.1.3    修复"悌阳象族"名称
                完成一组任务后添加 /qst stop
                更新鲶鱼精族水晶为朵洛衣楼
                添加为不同蛮族切换职业的功能
                首个可用版本

********************************************************************************
*                               所需插件                                       *
********************************************************************************
1. Vnavmesh（寻路）
2. Questionable（任务自动完成）
3. Lifestream（传送）
4. TextAdvance（自动推进对话框）

********************************************************************************
*            以下为代码部分：除非你知道自己在做什么，否则请勿修改              *
********************************************************************************
--]]

import("System.Numerics")

ToDoList = {}
ManualQuestPickup = Config.Get("ManualQuestPickup")

local societyConfigKeys = {
    { societyKey = "FirstAlliedSociety",  classKey = "FirstClass"  },
    { societyKey = "SecondAlliedSociety", classKey = "SecondClass" },
    { societyKey = "ThirdAlliedSociety",  classKey = "ThirdClass"  },
    { societyKey = "FourthAlliedSociety", classKey = "FourthClass" }
}

for _, entry in ipairs(societyConfigKeys) do
    local society = Config.Get(entry.societyKey)
    local class   = Config.Get(entry.classKey)

    if type(society) == "string" then
        society = society:gsub("^%s+", ""):gsub("%s+$", "")
    end
    if type(class) == "string" then
        class = class:gsub("^%s+", ""):gsub("%s+$", "")
    end

    if society and class and society ~= "" and society ~= "无" and class ~= "" then
        table.insert(ToDoList, { alliedSocietyName = society, class = class })
    end
end

function GetAttribute(sheetName, id, property)
    local sheet = Excel.GetSheet(sheetName)
    if not sheet then
        return nil
    end

    local row = sheet:GetRow(id)
    if not row then
        return nil
    end

    return row:GetProperty(property) or nil
end

function GetNPCName(id)
    return GetAttribute("ENpcResident", id, "Singular")
end

function GetPlaceName(id)
    return GetAttribute("PlaceName", id, "Name")
end

AlliedSocietiesTable = {
    amaljaa_neutral = {
        alliedSocietyName = "蜥蜴人族",
        configName        = "蜥蜴人族（中立）",
        questGiver        = GetNPCName(1005550), -- "Fibubb Gah"
        mainQuests        = { first = 1217, last = 1221 },
        dailyQuests       = { first = 1222, last = 1231 },
        x                 = 103.12,
        y                 = 15.05,
        z                 = -359.51,
        zoneId            = 146,
        aetheryteName     = GetPlaceName(313), -- "小阿拉米格"
        expac             = "重生之境"
    },
    amaljaa_recognized = {
        alliedSocietyName = "蜥蜴人族",
        configName        = "蜥蜴人族（承认）",
        questGiver        = GetNPCName(1005551), -- "Narujj Boh"
        mainQuests        = { first = 1217, last = 1221 },
        dailyQuests       = { first = 1232, last = 1241 },
        x                 = 96.38,
        y                 = 15.29,
        z                 = -353.32,
        zoneId            = 146,
        aetheryteName     = GetPlaceName(313), -- "小阿拉米格"
        expac             = "重生之境"
    },
    amaljaa_friendly = {
        alliedSocietyName = "蜥蜴人族",
        configName        = "蜥蜴人族（友好）",
        questGiver        = GetNPCName(1005552), -- "Yadovv Gah"
        mainQuests        = { first = 1217, last = 1221 },
        dailyQuests       = { first = 1242, last = 1251, blackList = { [1245] = true, [1250] = true } },
        x                 = 89.26,
        y                 = 15.23,
        z                 = -355.76,
        zoneId            = 146,
        aetheryteName     = GetPlaceName(313), -- "小阿拉米格"
        expac             = "重生之境"
    },
    sylphs_neutral = {
        alliedSocietyName = "妖精族",
        configName        = "妖精族（中立）",
        questGiver        = GetNPCName(1005561), -- "Tonaxia"
        mainQuests        = { first = 1252, last = 1256 },
        dailyQuests       = { first = 1257, last = 1266, blackList = { [1264] = true } },
        x                 = 46.41,
        y                 = 6.07,
        z                 = 252.91,
        zoneId            = 152,
        aetheryteName     = GetPlaceName(107), -- "霍桑山寨"
        expac             = "重生之境"
    },
    sylphs_recognized = {
        alliedSocietyName = "妖精族",
        configName        = "妖精族（承认）",
        questGiver        = GetNPCName(1005562), -- "Ponnixia"
        mainQuests        = { first = 1252, last = 1256 },
        dailyQuests       = { first = 1267, last = 1276 },
        x                 = 35.69,
        y                 = -5.11,
        z                 = 249.86,
        zoneId            = 152,
        aetheryteName     = GetPlaceName(107), -- "霍桑山寨"
        expac             = "重生之境"
    },
    sylphs_friendly = {
        alliedSocietyName = "妖精族",
        configName        = "妖精族（友好）",
        questGiver        = GetNPCName(1005563), -- "Moxia"
        mainQuests        = { first = 1252, last = 1256 },
        dailyQuests       = { first = 1277, last = 1286, blackList = { [1284] = true } },
        x                 = 47.18,
        y                 = 6.07,
        z                 = 250.81,
        zoneId            = 152,
        aetheryteName     = GetPlaceName(107), -- "霍桑山寨"
        expac             = "重生之境"
    },
    kobolds_neutral = {
        alliedSocietyName = "地灵族",
        configName        = "地灵族（中立）",
        questGiver        = GetNPCName(1005928), -- "789th Order Dustman Bo Zu"
        mainQuests        = { first = 1320, last = 1324 },
        dailyQuests       = { first = 1325, last = 1334 },
        x                 = 11.13,
        y                 = 16.16,
        z                 = -187.70,
        zoneId            = 180,
        aetheryteName     = GetPlaceName(237), -- "瞭望阵营地"
        expac             = "重生之境"
    },
    kobolds_recognized = {
        alliedSocietyName = "地灵族",
        configName        = "地灵族（承认）",
        questGiver        = GetNPCName(1005929), -- "789th Order Craftsman Bo Gu"
        mainQuests        = { first = 1320, last = 1324 },
        dailyQuests       = { first = 1335, last = 1344, blackList = { [1336] = true } },
        x                 = 18.71,
        y                 = 16.16,
        z                 = -184.34,
        zoneId            = 180,
        aetheryteName     = GetPlaceName(237), -- "瞭望阵营地"
        expac             = "重生之境"
    },
    kobolds_friendly = {
        alliedSocietyName = "地灵族",
        configName        = "地灵族（友好）",
        questGiver        = GetNPCName(1005930), -- "789th Order Dustman Bo Bu"
        mainQuests        = { first = 1320, last = 1324 },
        dailyQuests       = { first = 1364, last = 1373, blackList = { [1364] = true, [1372] = true } },
        x                 = 12.24,
        y                 = 16.16,
        z                 = -179.64,
        zoneId            = 180,
        aetheryteName     = GetPlaceName(237), -- "瞭望阵营地"
        expac             = "重生之境"
    },
    sahagin_neutral = {
        alliedSocietyName = "鱼人族",
        configName        = "鱼人族（中立）",
        questGiver        = GetNPCName(1005938), -- "Fyuu"
        mainQuests        = { first = 1374, last = 1378 },
        dailyQuests       = { first = 1379, last = 1388, blackList = { [1379] = true } },
        x                 = -221.98,
        y                 = -40.86,
        z                 = 35.61,
        zoneId            = 138,
        aetheryteName     = GetPlaceName(223), -- "小麦酒港"
        expac             = "重生之境"
    },
    sahagin_recognized = {
        alliedSocietyName = "鱼人族",
        configName        = "鱼人族（承认）",
        questGiver        = GetNPCName(1005939), -- "Houu"
        mainQuests        = { first = 1374, last = 1378 },
        dailyQuests       = { first = 1390, last = 1399, blackList = { [1396] = true } },
        x                 = -244.53,
        y                 = -41.46,
        z                 = 52.75,
        zoneId            = 138,
        aetheryteName     = GetPlaceName(223), -- "小麦酒港"
        expac             = "重生之境"
    },
    sahagin_friendly = {
        alliedSocietyName = "鱼人族",
        configName        = "鱼人族（友好）",
        questGiver        = GetNPCName(1005940), -- "Seww"
        mainQuests        = { first = 1374, last = 1378 },
        dailyQuests       = { first = 1400, last = 1409, blackList = { [1409] = true } },
        x                 = -229.13,
        y                 = -40.48,
        z                 = 55.17,
        zoneId            = 138,
        aetheryteName     = GetPlaceName(223), -- "小麦酒港"
        expac             = "重生之境"
    },
    ixal_neutral = {
        alliedSocietyName = "鸟人族",
        configName        = "鸟人族（中立）",
        questGiver        = GetNPCName(1009211), -- "Yazel Ahuatan the Able"
        mainQuests        = { first = 1486, last = 1493 },
        dailyQuests       = { first = 1494, last = 1497 },
        x                 = 155.02,
        y                 = -9.35,
        z                 = 79.24,
        zoneId            = 154,
        aetheryteName     = GetPlaceName(140), -- "秋瓜浮村"
        expac             = "重生之境"
    },
    ixal_recognized = {
        alliedSocietyName = "鸟人族",
        configName        = "鸟人族（承认）",
        questGiver        = GetNPCName(1009212), -- "Methuli Cattlan the Hard"
        mainQuests        = { first = 1486, last = 1493 },
        dailyQuests       = { first = 1504, last = 1508 },
        x                 = 153.60,
        y                 = -9.94,
        z                 = 80.95,
        zoneId            = 154,
        aetheryteName     = GetPlaceName(140), -- "秋瓜浮村"
        expac             = "重生之境"
    },
    ixal_friendly = {
        alliedSocietyName = "鸟人族",
        configName        = "鸟人族（友好）",
        questGiver        = GetNPCName(1009213), -- "Rozol Cattlan the Prudent"
        mainQuests        = { first = 1486, last = 1493 },
        dailyQuests       = { first = 1514, last = 1518 },
        x                 = 162.86,
        y                 = -4.69,
        z                 = 63.50,
        zoneId            = 154,
        aetheryteName     = GetPlaceName(140), -- "秋瓜浮村"
        expac             = "重生之境"
    },
    ixal_trusted = {
        alliedSocietyName = "鸟人族",
        configName        = "鸟人族（信赖）",
        questGiver        = GetNPCName(1009214), -- "Tazel Meyean the Lettered"
        mainQuests        = { first = 1486, last = 1493 },
        dailyQuests       = { first = 1498, last = 1503 },
        x                 = 161.57,
        y                 = -6.53,
        z                 = 70.51,
        zoneId            = 154,
        aetheryteName     = GetPlaceName(140), -- "秋瓜浮村"
        expac             = "重生之境"
    },
    ixal_respected = {
        alliedSocietyName = "鸟人族",
        configName        = "鸟人族（尊敬）",
        questGiver        = GetNPCName(1009215), -- "Duzal Meyean the Steady"
        mainQuests        = { first = 1486, last = 1493 },
        dailyQuests       = { first = 1509, last = 1513 },
        x                 = 166.90,
        y                 = -13.60,
        z                 = 106.83,
        zoneId            = 154,
        aetheryteName     = GetPlaceName(140), -- "秋瓜浮村"
        expac             = "重生之境"
    },
    ixal_honored = {
        alliedSocietyName = "鸟人族",
        configName        = "鸟人族（名誉）",
        questGiver        = GetNPCName(1009216), -- "Jezul Ahuatan the Second"
        mainQuests        = { first = 1486, last = 1493 },
        dailyQuests       = { first = 1519, last = 1523 },
        x                 = 161.42,
        y                 = -22.79,
        z                 = 115.27,
        zoneId            = 154,
        aetheryteName     = GetPlaceName(140), -- "秋瓜浮村"
        expac             = "重生之境"
    },
    vanuvanu = {
        alliedSocietyName = "瓦努族",
        questGiver        = GetNPCName(1016089), -- "Muna Vanu"
        mainQuests        = { first = 2164, last = 2225 },
        dailyQuests       = { first = 2171, last = 2200 },
        x                 = -796.3722,
        y                 = -133.27,
        z                 = -404.35,
        zoneId            = 401,
        aetheryteName     = GetPlaceName(2123), -- "尊杜集落"
        expac             = "苍穹之禁城"
    },
    vath = {
        alliedSocietyName = "骨颌族",
        questGiver        = GetNPCName(1016803), -- "Vath Keeneye"
        mainQuests        = { first = 2255, last = 2260 },
        dailyQuests       = { first = 2261, last = 2280 },
        x                 = 58.80,
        y                 = -48.00,
        z                 = -171.64,
        zoneId            = 398,
        aetheryteName     = GetPlaceName(2018), -- "尾羽集落"
        expac             = "苍穹之禁城"
    },
    moogles = {
        alliedSocietyName = "莫古力族",
        questGiver        = GetNPCName(1017171), -- "Mogek the Marvelous"
        mainQuests        = { first = 2320, last = 2327 },
        dailyQuests       = { first = 2290, last = 2319 },
        x                 = -335.28,
        y                 = 58.94,
        z                 = 316.30,
        zoneId            = 400,
        aetheryteName     = GetPlaceName(2046), -- "天极白垩宫"
        expac             = "苍穹之禁城"
    },
    kojin = {
        alliedSocietyName = "甲人族",
        questGiver        = GetNPCName(1024217), -- "Zukin"
        mainQuests        = { first = 2973, last = 2978 },
        dailyQuests       = { first = 2979, last = 3002 },
        x                 = 391.22,
        y                 = -119.59,
        z                 = -234.92,
        zoneId            = 613,
        aetheryteName     = GetPlaceName(2512), -- "碧玉水附近"
        expac             = "红莲之狂潮"
    },
    ananta = {
        alliedSocietyName = "阿难陀族",
        questGiver        = GetNPCName(1024773), -- "Eshana"
        mainQuests        = { first = 3036, last = 3041 },
        dailyQuests       = { first = 3043, last = 3069 },
        x                 = -26.91,
        y                 = 56.12,
        z                 = 233.53,
        zoneId            = 612,
        aetheryteName     = GetPlaceName(2634), -- "对等石"
        expac             = "红莲之狂潮"
    },
    namazu = {
        alliedSocietyName = "鲶鱼精族",
        questGiver        = GetNPCName(1025602), -- "Seigetsu the Enlightened"
        mainQuests        = { first = 3096, last = 3102 },
        dailyQuests       = { first = 3103, last = 3129 },
        x                 = -777.72,
        y                 = 127.81,
        z                 = 98.76,
        zoneId            = 622,
        aetheryteName     = GetPlaceName(2850), -- "朵洛衣楼"
        expac             = "红莲之狂潮"
    },
    pixies = {
        alliedSocietyName = "仙子族",
        questGiver        = GetNPCName(1031809), -- "Uin Nee"
        mainQuests        = { first = 3683, last = 3688 },
        dailyQuests       = { first = 3689, last = 3716 },
        x                 = -453.69,
        y                 = 71.21,
        z                 = 573.54,
        zoneId            = 816,
        aetheryteName     = GetPlaceName(3147), -- "群花馆"
        expac             = "暗影之逆焰"
    },
    qitari = {
        alliedSocietyName = "奇塔利族",
        questGiver        = GetNPCName(1032643), -- "Qhoterl Pasol"
        mainQuests        = { first = 3794, last = 3805 },
        dailyQuests       = { first = 3806, last = 3833 },
        x                 = 786.83,
        y                 = -45.82,
        z                 = -214.51,
        zoneId            = 817,
        aetheryteName     = GetPlaceName(3179), -- "法诺村"
        expac             = "暗影之逆焰"
    },
    dwarves = {
        alliedSocietyName = "矮人族",
        questGiver        = GetNPCName(1033712), -- "Regitt"
        mainQuests        = { first = 3896, last = 3901 },
        dailyQuests       = { first = 3902, last = 3929 },
        x                 = -615.48,
        y                 = 65.60,
        z                 = -423.82,
        zoneId            = 813,
        aetheryteName     = GetPlaceName(3057), -- "奥斯塔尔严命城"
        expac             = "暗影之逆焰"
    },
    arkasodara = {
        alliedSocietyName = "悌阳象族",
        questGiver        = GetNPCName(1042257), -- "Maru"
        mainQuests        = { first = 4545, last = 4550 },
        dailyQuests       = { first = 4551, last = 4578 },
        x                 = -68.21,
        y                 = 39.99,
        z                 = 323.31,
        zoneId            = 957,
        aetheryteName     = GetPlaceName(3880), -- "新港"
        expac             = "晓月之终途"
    },
    loporrits = {
        alliedSocietyName = "兔兔族",
        questGiver        = GetNPCName(1044403), -- "Managingway"
        mainQuests        = { first = 4681, last = 4686 },
        dailyQuests       = { first = 4687, last = 4714 },
        x                 = -201.27,
        y                 = -49.15,
        z                 = -273.8,
        zoneId            = 959,
        aetheryteName     = GetPlaceName(3966), -- "最佳威兔洞"
        expac             = "晓月之终途"
    },
    omicrons = {
        alliedSocietyName = "奥密克戎族",
        questGiver        = GetNPCName(1041898), -- "Stigma-4"
        mainQuests        = { first = 4601, last = 4606 },
        dailyQuests       = { first = 4607, last = 4634 },
        x                 = 315.84,
        y                 = 481.99,
        z                 = 152.08,
        zoneId            = 960,
        aetheryteName     = GetPlaceName(3983), -- "奥密克戎基地"
        expac             = "晓月之终途"
    },
    pelupelu = {
        alliedSocietyName = "佩鲁佩鲁族",
        questGiver        = GetNPCName(1051643), -- "Yubli"
        mainQuests        = { first = 5193, last = 5198 },
        dailyQuests       = { first = 5199, last = 5226 },
        x                 = 770.89954,
        y                 = 12.846571,
        z                 = -261.0889,
        zoneId            = 1188,
        aetheryteName     = GetPlaceName(4595), -- "水果码头"
        expac             = "金曦之遗辉"
    },
    mamoolja = {
        alliedSocietyName = "辉鳞族",
        questGiver        = GetNPCName(1052560), -- "Kageel Ja"
        mainQuests        = { first = 5255, last = 5260 },
        dailyQuests       = { first = 5261, last = 5288 },
        x                 = 589.3,
        y                 = -142.9,
        z                 = 730.5,
        zoneId            = 1189,
        aetheryteName     = GetPlaceName(4625), -- "玛穆克"
        expac             = "金曦之遗辉"
    },
    yokhuy = {
        alliedSocietyName = "尤卡巨人族",
        questGiver        = GetNPCName(1054635), -- "Vuyargur"
        mainQuests        = { first = 5330, last = 5335 },
        dailyQuests       = { first = 5336, last = 5363 },
        x                 = 495.40,
        y                 = 142.24,
        z                 = 784.53,
        zoneId            = 1187,
        aetheryteName     = GetPlaceName(4562), -- "沃拉的回响"
        expac             = "金曦之遗辉"
    }
}

CharacterCondition = {
    mounted          =  4,
    casting          = 27,
    betweenAreas     = 45
}

function GetAlliedSocietyTable(selectedName)
    for _, alliedSociety in pairs(AlliedSocietiesTable) do
        if alliedSociety.configName == selectedName then
            return alliedSociety
        end
    end

    for _, alliedSociety in pairs(AlliedSocietiesTable) do
        if alliedSociety.alliedSocietyName == selectedName then
            return alliedSociety
        end
    end

    return nil
end

function GetAcceptedAlliedSocietyQuests(alliedSocietyName)
    local accepted = {}
    local allAcceptedQuests = Quests.GetAcceptedQuests()
    local count = allAcceptedQuests.Count - 1

    for i = 1, count do
        local allAcceptedQuestId = allAcceptedQuests[i]
        local row = Excel.GetRow("Quest", allAcceptedQuestId)

        if row and row.BeastTribe and row.BeastTribe.Name then
            -- 使用模糊匹配，兼容不同语言客户端的蛮族名称格式（如"蜥蜴人族：灰党"包含"蜥蜴人族"）
            local tribeName = row.BeastTribe.Name:lower()
            local searchName = alliedSocietyName:lower()
            if tribeName:find(searchName, 1, true) then
                table.insert(accepted, allAcceptedQuestId)
            end
        end
    end

    return accepted
end

function HasPlugin(name)
    for plugin in luanet.each(Svc.PluginInterface.InstalledPlugins) do
        if plugin.InternalName == name and plugin.IsLoaded then
            Dalamud.Log(string.format("[蛮族日常] 已找到插件 '%s'。", name))
            return true
        end
    end

    Dalamud.Log(string.format("[蛮族日常] 未在已安装插件列表中找到 '%s'。", name))
    return false
end

if HasPlugin("Lifestream") then
    TeleportCommand = "/li tp"
elseif HasPlugin("Teleporter") then
    TeleportCommand = "/tp"
else
    Dalamud.Log("[蛮族日常] 请安装 Teleporter 或 Lifestream 插件")
    yield("/snd stop all")
    return
end

function TeleportTo(aetheryteName)
    yield(TeleportCommand .. " " .. aetheryteName)
    yield("/wait 1")
    while Svc.Condition[CharacterCondition.casting] do
        yield("/wait 1")
    end
    yield("/wait 1")
    while Svc.Condition[CharacterCondition.betweenAreas] do
        yield("/wait 1")
    end
    yield("/wait 1")
end

yield("/at y")
for _, alliedSociety in ipairs(ToDoList) do
    local alliedSocietyTable = GetAlliedSocietyTable(alliedSociety.alliedSocietyName)
    if alliedSocietyTable ~= nil then
        repeat
            yield("/wait 1")
        until not Player.IsBusy

        if Svc.ClientState.TerritoryType ~= alliedSocietyTable.zoneId then
            TeleportTo(alliedSocietyTable.aetheryteName)
        end

        while not Svc.Condition[CharacterCondition.mounted] do
            Actions.ExecuteGeneralAction(9) -- '/gaction "mount roulette"'
            yield("/wait 4")
        end

        local destination = Vector3(alliedSocietyTable.x, alliedSocietyTable.y, alliedSocietyTable.z)
        IPC.vnavmesh.PathfindAndMoveTo(destination, true)

        repeat
            yield("/wait 1")
        until not IPC.vnavmesh.IsRunning() and not IPC.vnavmesh.PathfindInProgress()

        yield("/gs change " .. alliedSociety.class)
        yield("/wait 3")

        if ManualQuestPickup then
            for i = 1, 3 do
                local acceptedNow = #GetAcceptedAlliedSocietyQuests(alliedSocietyTable.alliedSocietyName)

                if acceptedNow >= 3 then
                    break
                end

                yield("/target " .. alliedSocietyTable.questGiver)
                yield("/interact")

                local menuStart = os.time()
                local menuOpened = false
                local menuTimeout = 10

                repeat
                    local addon = Addons.GetAddon("SelectIconString")
                    if addon and addon.Ready then
                        menuOpened = true
                        break
                    end

                    if os.time() - menuStart > menuTimeout then
                        Dalamud.Log(string.format("[蛮族日常] 等待 '%s' 的任务窗口超时。", alliedSocietyTable.questGiver))
                        break
                    end

                    yield("/wait 1")
                until false

                if not menuOpened then
                    Dalamud.Log(string.format("[蛮族日常] 跳过第 %d/3 次手动接取 '%s'。", i, alliedSocietyTable.alliedSocietyName))
                    break
                end

                yield("/callback SelectIconString true 0")
                local busyStart   = os.time()
                local busyTimeout = 10

                repeat
                    if not Player.IsBusy then
                        break
                    end

                    if os.time() - busyStart > busyTimeout then
                        Dalamud.Log(string.format("[蛮族日常] 等待 '%s' 第 %d/3 次手动接取完成超时。", alliedSocietyTable.alliedSocietyName, i))
                        break
                    end

                    yield("/wait 1")
                until false

                acceptedNow = #GetAcceptedAlliedSocietyQuests(alliedSocietyTable.alliedSocietyName)
                Dalamud.Log(string.format("[蛮族日常] 已通过NPC接取 %d/3 个任务。", acceptedNow))
            end
        else
            local timeout
            local quests = {}
            local blackList = alliedSocietyTable.dailyQuests.blackList or {}
            local acceptedCount = 0
            local blacklistedCount = 0

            for questId = alliedSocietyTable.dailyQuests.first, alliedSocietyTable.dailyQuests.last do
                if acceptedCount >= 3 then
                    break
                end

                if not IPC.Questionable.IsQuestLocked(tostring(questId)) then
                    if blackList[questId] then
                        blacklistedCount = blacklistedCount + 1
                    else
                        IPC.Questionable.ClearQuestPriority()
                        IPC.Questionable.AddQuestPriority(tostring(questId))
                        timeout = os.time()

                        repeat
                            if Quests.IsQuestAccepted(questId) then
                                break
                            end

                            if not IPC.Questionable.IsRunning() then
                                -- Questionable 未运行：检查是否卡住
                                if os.time() - timeout > 30 then
                                    Dalamud.Log("[蛮族日常] Questionable 已停止超过30秒，可能卡住，正在重载...")
                                    yield("/qst reload")
                                    timeout = os.time()
                                else
                                    yield("/qst start")
                                end
                            else
                                -- Questionable 正在运行（寻路、传送、等待加载等），重置超时计时器
                                timeout = os.time()
                            end

                            yield("/wait 0.5")
                        until Quests.IsQuestAccepted(questId)

                        yield("/qst stop")
                        IPC.Questionable.ClearQuestPriority()

                        if Quests.IsQuestAccepted(questId) then
                            table.insert(quests, questId)
                            acceptedCount = acceptedCount + 1
                            Dalamud.Log(string.format("[蛮族日常] 已通过 Questionable 接取 %d/3 个任务。", acceptedCount))
                        end
                    end
                end
            end

            for _, questId in ipairs(quests) do
                IPC.Questionable.AddQuestPriority(tostring(questId))
            end

            if acceptedCount < 3 and blacklistedCount > 0 then
                Dalamud.Log(string.format("[蛮族日常] %s | 可接取任务: %d/3 | 黑名单任务: %d", alliedSocietyTable.alliedSocietyName, acceptedCount, blacklistedCount))
            else
                Dalamud.Log(string.format("[蛮族日常] %s | 可接取任务: %d/3", alliedSocietyTable.alliedSocietyName, acceptedCount))
            end
        end

        repeat
            if not IPC.Questionable.IsRunning() then
                yield("/qst start")
            end
            yield("/wait 1.2")
        until #GetAcceptedAlliedSocietyQuests(alliedSocietyTable.alliedSocietyName) == 0

        yield("/qst stop")
        IPC.Questionable.ClearQuestPriority()
    else
        Dalamud.Log(string.format("[蛮族日常] 未在数据表中找到蛮族 '%s'。", alliedSociety.alliedSocietyName))
    end
end

yield("/echo [蛮族日常] 蛮族日常任务脚本执行完毕！")
Dalamud.Log("[蛮族日常] 蛮族日常任务脚本执行完毕！")

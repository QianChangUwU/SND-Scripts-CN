--[=====[
[[SND Metadata]]
author: 'QianChang'
version: 1.2.0
description: "交互点顺序寻路交互脚本 - 按顺序自动寻路到指定可交互对象并交互"
plugin_dependencies:
- vnavmesh
configs:
  交互点1名称:
    description: "可交互对象的名字（支持部分匹配），留空则跳过此交互点"
    default: ""
    section: "交互点1"
  交互点1交互距离:
    description: "到这个距离（yalms）内就尝试交互"
    default: 3
    min: 1
    max: 50
    section: "交互点1"
  交互点1交互后等待:
    description: "交互完成后等待的秒数"
    default: 4
    min: 0
    max: 30
    section: "交互点1"
  交互点2名称:
    description: "可交互对象的名字（支持部分匹配），留空则跳过此交互点"
    default: ""
    section: "交互点2"
  交互点2交互距离:
    description: "到这个距离（yalms）内就尝试交互"
    default: 3
    min: 1
    max: 50
    section: "交互点2"
  交互点2交互后等待:
    description: "交互完成后等待的秒数"
    default: 4
    min: 0
    max: 30
    section: "交互点2"
  交互点3名称:
    description: "可交互对象的名字（支持部分匹配），留空则跳过此交互点"
    default: ""
    section: "交互点3"
  交互点3交互距离:
    description: "到这个距离（yalms）内就尝试交互"
    default: 3
    min: 1
    max: 50
    section: "交互点3"
  交互点3交互后等待:
    description: "交互完成后等待的秒数"
    default: 4
    min: 0
    max: 30
    section: "交互点3"
  交互点4名称:
    description: "可交互对象的名字（支持部分匹配），留空则跳过此交互点"
    default: ""
    section: "交互点4"
  交互点4交互距离:
    description: "到这个距离（yalms）内就尝试交互"
    default: 3
    min: 1
    max: 50
    section: "交互点4"
  交互点4交互后等待:
    description: "交互完成后等待的秒数"
    default: 4
    min: 0
    max: 30
    section: "交互点4"
  PathfindTimeout:
    description: "寻路超时时间（秒）"
    default: 120
    min: 10
    max: 600
    section: "全局设置"
  InteractTimeout:
    description: "交互尝试超时时间（秒）"
    default: 30
    min: 5
    max: 120
    section: "全局设置"
  StopWaitTime:
    description: "寻路停止后等待时间（秒）"
    default: 0.5
    min: 0.1
    max: 5
    section: "全局设置"
  Loop:
    description: "完成所有交互点后是否循环"
    default: false
    section: "全局设置"
  LoopInterval:
    description: "循环间隔时间（秒）"
    default: 5
    min: 1
    max: 60
    section: "全局设置"
[[End Metadata]]
--]=====]

--[[
********************************************************************************
*                      交互点顺序寻路交互脚本                                  *
*                                                                              *
*  功能：                                                                      *
*    1. 按预设顺序检测周围是否有对应名字的可交互对象                            *
*    2. 自动寻路（vnavmesh，全程步行）到可交互对象位置                          *
*    3. 到达后自动选中并交互                                                    *
*    4. 可选：交互后自动处理弹出的对话框（如 SelectYesno 等）                    *
*    5. 完成当前交互点后，继续前往下一个交互点                                  *
*                                                                              *
*  依赖插件：                                                                   *
*    - vnavmesh  (寻路)  https://puni.sh/api/repository/veyn                   *
*    - TextAdvance (可选，用于自动跳过对话)                                      *
*                                                                              *
*  使用方法：                                                                   *
*    1. 将此文件作为 Lua 宏导入 SND                                             *
*    2. 在 SND 设置页面的「Macro Configuration」中配置每个交互点                 *
*       - 支持 10 个交互点，每个有名称、距离、回调窗口、回调值、等待秒数         *
*       - 名称留空的交互点会自动跳过                                            *
*    3. 运行宏                                                                  *
*                                                                              *
********************************************************************************
]]

import("System.Numerics")

--#region 读取设置

--- 支持的最大交互点数量
MAX_POINTS = 10

--- 交互点列表（从 SND 设置页面读取）
InteractionPoints = {}

--- 全局配置（从 SND 设置页面读取）
Settings = {
  pathfindTimeout = 120,
  interactTimeout = 30,
  stopWaitTime = 0.5,
  loop = false,
  loopInterval = 5,
}

--- 去除字符串首尾空白
--- @param s string
--- @return string
function StringTrim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- 从 SND 配置中逐个读取交互点
function LoadInteractionPoints()
  InteractionPoints = {}

  for i = 1, MAX_POINTS do
    local name = StringTrim(Config.GetString(string.format("交互点%d名称", i), ""))
    if name ~= "" then
      local point = {
        name = name,
        interactDistance = Config.GetInt(string.format("交互点%d交互距离", i), 3),
        callbackAddon = StringTrim(Config.GetString(string.format("交互点%d回调窗口", i), "")),
        callbackValues = StringTrim(Config.GetString(string.format("交互点%d回调值", i), "")),
        waitAfter = Config.GetInt(string.format("交互点%d交互后等待", i), 1),
      }
      if point.callbackAddon == "" then point.callbackAddon = nil end
      if point.callbackValues == "" then point.callbackValues = nil end
      table.insert(InteractionPoints, point)
    end
  end

  Log(string.format("已加载 %d 个交互点", #InteractionPoints))
  for i, p in ipairs(InteractionPoints) do
    Log(string.format("  [%d] %s (距离=%d, 回调=%s, 等待=%d)", i, p.name, p.interactDistance, p.callbackAddon or "无",
      p.waitAfter))
  end
end

--- 加载全局设置
function LoadSettings()
  Settings.pathfindTimeout = Config.GetInt("PathfindTimeout", 120)
  Settings.interactTimeout = Config.GetInt("InteractTimeout", 30)
  Settings.stopWaitTime = Config.GetFloat("StopWaitTime", 0.5)
  Settings.loop = Config.GetBool("Loop", false)
  Settings.loopInterval = Config.GetInt("LoopInterval", 5)
end

--#endregion 读取设置

--#region 数据定义

--- 玩家状态条件枚举
CharacterCondition = {
  dead = 2,
  mounted = 4,
  inCombat = 26,
  casting = 27,
  occupiedInEvent = 31,
  occupiedInQuestEvent = 32,
  occupied = 33,
  boundByDuty34 = 34,
  occupiedMateriaExtractionAndRepair = 39,
  betweenAreas = 45,
  jumping48 = 48,
  jumping61 = 61,
  occupiedSummoningBell = 50,
  betweenAreasForDuty = 51,
  flying = 77,
}

--#endregion 数据定义

--#region 辅助函数

--- 等待指定秒数
--- @param time number 秒数
function Wait(time)
  yield(string.format("/wait %g", time))
end

--- 获取玩家位置
--- @return Vector3?
function GetPlayerPosition()
  if Player and Player.Entity and Player.Entity.Position then
    return Player.Entity.Position
  end
  if Entity and Entity.Player and Entity.Player.Position then
    return Entity.Player.Position
  end
  return nil
end

--- 计算两点之间的距离
--- @param pos1 Vector3
--- @param pos2 Vector3
--- @return number
function GetDistance(pos1, pos2)
  if not pos1 or not pos2 then return math.huge end
  local dx = pos1.X - pos2.X
  local dy = pos1.Y - pos2.Y
  local dz = pos1.Z - pos2.Z
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--- 打印日志（全部输出到 echo）
--- @param msg string 消息内容
function Log(msg)
  Dalamud.Log("[交互序列] " .. tostring(msg))
  yield("/echo [交互序列] " .. tostring(msg))
end

--- 检查玩家是否处于忙碌状态
--- @return boolean
function IsPlayerBusy()
  return Svc.Condition[CharacterCondition.occupied]
      or Svc.Condition[CharacterCondition.occupiedInEvent]
      or Svc.Condition[CharacterCondition.occupiedInQuestEvent]
      or (Player and Player.IsBusy)
end

--- 停止寻路
function StopNavigation()
  if IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress() then
    IPC.vnavmesh.Stop()
    Wait(Settings.stopWaitTime)
  end
end

--- 获取当前目标名字
--- @return string
function GetTargetName()
  if Svc.Targets.Target == nil then
    return ""
  end
  return Svc.Targets.Target.Name.TextValue
end

--#endregion 辅助函数

--#region 核心功能

--- 在周围对象中按名字搜索可交互对象
--- @param name string 对象名称（支持部分匹配）
--- @return EntityWrapper? 找到的对象, number 距离
function FindInteractableByName(name)
  local closestObj = nil
  local closestDist = math.huge

  for i = 0, Svc.Objects.Length - 1 do
    local obj = Svc.Objects[i]
    if obj ~= nil then
      local objName = obj.Name.TextValue
      if objName and objName:lower():find(name:lower(), 1, true) then
        local isTargetable = obj.IsTargetable
        if isTargetable then
          local playerPos = GetPlayerPosition()
          if playerPos then
            local dist = GetDistance(playerPos, obj.Position)
            if dist < closestDist then
              closestDist = dist
              closestObj = obj
            end
          end
        end
      end
    end
  end

  if not closestObj then
    local entity = Entity.GetEntityByName(name)
    if entity and entity.IsTargetable then
      closestObj = entity
      local playerPos = GetPlayerPosition()
      if playerPos then
        closestDist = GetDistance(playerPos, entity.Position)
      end
    end
  end

  return closestObj, closestDist
end

--- 寻路到目标对象附近（动态追踪，全程步行）
--- @param point table 交互点配置
--- @return boolean 是否成功到达
function MoveToInteractable(point)
  local name = point.name
  local interactDist = point.interactDistance or 3
  local startTime = os.time()

  while true do
    if (os.time() - startTime) > Settings.pathfindTimeout then
      Log(string.format("寻找/寻路到 [%s] 超时", name))
      return false
    end

    local obj, dist = FindInteractableByName(name)

    if obj then
      if dist <= interactDist then
        StopNavigation()
        Log(string.format("已到达 [%s] 附近，距离: %.2f", name, dist))
        return true
      else
        if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
          Log(string.format("正在步行前往 [%s]，距离: %.2f", name, dist))
          IPC.vnavmesh.PathfindAndMoveTo(obj.Position, false)
        else
          local currentPos = GetPlayerPosition()
          if currentPos and GetDistance(currentPos, obj.Position) <= interactDist then
            StopNavigation()
            return true
          end
        end
      end
    else
      if not (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()) then
        Log(string.format("未找到 [%s]，等待刷新...", name))
      end
    end

    Wait(0.5)
  end
end

--- 与当前目标交互
--- @param point table 交互点配置
--- @return boolean 是否交互成功
function InteractWithTarget(point)
  local name = point.name
  local interactDist = point.interactDistance or 3
  local startTime = os.time()

  while true do
    if (os.time() - startTime) > Settings.interactTimeout then
      Log(string.format("交互 [%s] 超时", name))
      return false
    end

    if IsPlayerBusy() then
      Log(string.format("与 [%s] 交互成功（玩家忙碌中）", name))
      return true
    end

    local obj, dist = FindInteractableByName(name)

    if not obj then
      Log(string.format("交互时未找到 [%s]", name))
      Wait(1)
    elseif dist > interactDist then
      Log(string.format("[%s] 距离 %.2f 过远，重新靠近", name, dist))
      if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
        IPC.vnavmesh.PathfindAndMoveTo(obj.Position, false)
      end
      Wait(0.5)
    else
      StopNavigation()

      if GetTargetName():lower():find(name:lower(), 1, true) then
        -- 已选中正确目标
      else
        Log(string.format("选中目标 [%s]", name))
        yield("/target \"" .. name .. "\"")
        Wait(0.5)
      end

      if GetTargetName():lower():find(name:lower(), 1, true) then
        if not IsPlayerBusy() then
          Log(string.format("与 [%s] 交互", name))
          yield("/interact")
          Wait(1)
        end
      else
        Log(string.format("无法选中 [%s]，重试...", name))
        Wait(1)
      end
    end
  end
end

--- 处理交互后的对话框回调
--- @param point table 交互点配置
function HandleCallback(point)
  if not point.callbackAddon then return end

  local cbStart = os.time()
  local cbTimeout = 15

  Log(string.format("等待对话框 [%s] 出现...", point.callbackAddon))
  while true do
    local addon = Addons.GetAddon(point.callbackAddon)
    if addon and addon.Ready then
      break
    end
    if (os.time() - cbStart) > cbTimeout then
      Log(string.format("对话框 [%s] 未出现，跳过", point.callbackAddon))
      return
    end
    Wait(0.3)
  end

  local valuesStr = point.callbackValues or ""
  Log(string.format("执行回调 [%s] 值: %s", point.callbackAddon, valuesStr))
  local cmd = string.format("/callback %s true %s", point.callbackAddon, valuesStr)
  yield(cmd)
  Wait(1)
end

--- 处理单个交互点的完整流程
--- @param point table 交互点配置
--- @return boolean 是否成功完成
function ProcessInteractionPoint(point)
  Log(string.format("===== 开始处理交互点: %s =====", point.name))

  Log(string.format("正在前往 [%s]...", point.name))
  local arrived = MoveToInteractable(point)
  if not arrived then
    Log(string.format("无法到达 [%s]", point.name))
    return false
  end

  local interacted = InteractWithTarget(point)
  if not interacted then
    Log(string.format("与 [%s] 交互失败", point.name))
    return false
  end

  HandleCallback(point)

  local waitAfter = point.waitAfter or 1
  Log(string.format("交互完成，等待 %d 秒...", waitAfter))
  Wait(waitAfter)

  Log(string.format("===== 交互点 [%s] 处理完成 =====", point.name))
  return true
end

--#endregion 核心功能

--#region 主循环

--- 主函数
function Main()
  LoadSettings()
  LoadInteractionPoints()

  if #InteractionPoints == 0 then
    Log("错误: 未配置任何交互点，请在 SND 设置页面配置交互点名称")
    return
  end

  Log("脚本启动")

  if not IPC.vnavmesh or not IPC.vnavmesh.IsReady then
    Log("错误: vnavmesh 插件未安装或未就绪")
    return
  end

  while true do
    local allSuccess = true

    for i, point in ipairs(InteractionPoints) do
      Log(string.format("处理第 %d/%d 个交互点: %s", i, #InteractionPoints, point.name))

      local success = ProcessInteractionPoint(point)
      if not success then
        allSuccess = false
        Log(string.format("交互点 [%s] 处理失败，继续下一个", point.name))
      end
    end

    if allSuccess then
      Log("所有交互点处理完成！")
    else
      Log("部分交互点处理失败")
    end

    if not Settings.loop then
      break
    end

    Log(string.format("等待 %d 秒后开始下一轮...", Settings.loopInterval))
    Wait(Settings.loopInterval)
  end

  Log("脚本结束")
end

-- 执行主函数
Main()

--#endregion 主循环

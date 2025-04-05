--[[

********************************************************************************
*                                  自动挖宝助手                                *
********************************************************************************

您必须从背包中一张已打开的藏宝图开始。此脚本将自动将你传送到正确的区域，
飞行至目的地，挖掘藏宝图，杀死敌人，打开箱子。它不会为你处理魔纹。

********************************************************************************
*                               版本号: 1.1.1 CN-1.00                          *
********************************************************************************

作者: pot0to (https://ko-fi.com/pot0to)
汉化: QianChang 联系方式:2318933089(QQ) 主页(https://github.com/QianChangUwU)
        
    ->  1.1.1   修复了传送前往龙堡内陆低地相关的一些等待时间
                增加了通过田园郡前往龙堡内陆低地的功能
                第一个版本

********************************************************************************
*                                    必要插件                                  *
********************************************************************************

需要以下插件才能正常工作：

    -> Something Need Doing [Expanded Edition] : (核心插件)   https://puni.sh/api/repository/croizat
    -> Globetrotter :   寻找藏宝图地点
    -> VNavmesh :       (用于规划路线和移动)    https://puni.sh/api/repository/veyn
    -> RotationSolver Reborn :  (用于打自动循环)  https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
    -> Lifestream :  (用于更改实例[ChangeInstance][Exchange]（看不懂）) https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json
********************************************************************************
*                                    可选插件                                  *
********************************************************************************

此插件是可选的，除非您在设置中启用了它，否则不需要：

    -> Teleporter :  传送到伊修加德/天穹街，如果你不在那的话

]]

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]
MountToUse                          = "随机飞行坐骑"       --在FATE之间飞行时使用的坐骑
--#endregion Settings

--[[
********************************************************************************
*           这里是代码：除非你知道你在做什么不然不要动它                        *
********************************************************************************
]]

--#region Data
CharacterCondition = {
    dead=2,
    mounted=4,
    inCombat=26,
    casting=27,
    occupied31=31,
    occupied=33,
    boundByDuty34=34,
    betweenAreas=45,
    jumping48=48,
    betweenAreas51=51,
    jumping61=61,
    mounting57=57,
    mounting64=64,
    beingmoved70=70,
    beingmoved75=75,
    flying=77
}

-- #region Movement

function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[TreasureHuntHelper] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while not IsPlayerAvailable() or GetCharacterCondition(CharacterCondition.betweenAreas) or GetCharacterCondition(CharacterCondition.betweenAreas51) do
        LogInfo("[TreasureHuntHelper] Teleporting...")
        yield("/wait 1")
    end
    LogInfo("[TreasureHuntHelper] Finished teleporting")
    yield("/wait 1")
end

function TeleportToFlag()
    local aetheryteName = GetAetheryteName(GetAetherytesInZone(GetFlagZone())[0])
    TeleportTo(aetheryteName)
end

function GoToMapLocation()
    local flagZone = GetFlagZone()
    if not IsInZone(flagZone) then
        if flagZone == 399 then
            if not IsInZone(478) then
                TeleportTo("田园郡")
            else
                if GetTargetName() ~= "aetheryte" then
                    yield("/target aetheryte")
                end
                if GetTargetName() ~= "aetheryte" or GetDistanceToTarget() > 7 then
                    if not PathIsRunning() and not PathfindInProgress() then
                        PathfindAndMoveTo(71, 211, -19)
                    end
                else
                    yield("/vnav stop")
                    yield("/li Western Hinterlands")
                    yield("/wait 3")
                    while LifestreamIsBusy() do
                        yield("/wait 1")
                    end
                    yield("/wait 3")
                    while GetCharacterCondition(CharacterCondition.betweenAreas) or GetCharacterCondition(CharacterCondition.betweenAreas51) do
                        LogInfo("[TreasureHuntHelper] Between areas...")
                        yield("/wait 1")
                    end
                    yield("/wait 1")
                end
            end
        else
            TeleportToFlag()
        end
        return
    end

    if not GetCharacterCondition(CharacterCondition.mounted) then
        if MountToUse == "随机飞行坐骑" then
            yield('/gaction "随机飞行坐骑"')
        else
            yield('/mount "' .. MountToUse)
        end
        return
    end
    
    if not PathfindInProgress() and not PathIsRunning() then
        yield("/vnav flyflag")
    end
end

--#endregion  Movement

DidMap = false
function Main()
    if IsAddonVisible("_TextError") and GetNodeText("_TextError", 1) == "你没有藏宝图." then
        yield("/echo 你没有藏宝图.")
        StopFlag = true
        return
    end

    if GetCharacterCondition(CharacterCondition.inCombat) and not HasTarget() then
        yield("/battletarget")
        return
    elseif DidMap and not GetCharacterCondition(CharacterCondition.boundByDuty34) then -- if combat is over
        StopFlag = true
        return
    end

    yield("/tmap")
    repeat
        yield("/wait 1")
    until IsAddonVisible("AreaMap")

    if not IsInZone(GetFlagZone()) or GetDistanceToPoint(GetFlagXCoord(), GetPlayerRawYPos(), GetFlagYCoord()) > 15 then
        GoToMapLocation()
        return
    elseif PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        yield("/mount")
        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end
        yield("/wait 1")
        return
    end

    if not GetCharacterCondition(CharacterCondition.inCombat) and (not HasTarget() or GetTargetName() ~= "宝箱") then
        yield("/generalaction 挖掘")
        yield("/target 宝箱")
        return
    end

    if GetDistanceToPoint(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()) > 3.5 then
        PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        return
    end

    if IsAddonVisible("SelectYesno") then
        yield("/echo see yesno")
        yield("/callback SelectYesno true 0") -- yes open the coffer
        HasOpenMap = false
    end

    if not GetCharacterCondition(CharacterCondition.inCombat) then
        yield("/interact")
        return
    end

    if GetCharacterCondition(CharacterCondition.boundByDuty34) then
        LogInfo("[TreasureHuntHelper] DidMap = true")
        DidMap = true
    end
    
    yield("/rotation manual")
    yield("/battletarget")
end

HasOpenMap = true
StopFlag = false
repeat
    if not (IsPlayerCasting() or
        GetCharacterCondition(CharacterCondition.betweenAreas) or
        GetCharacterCondition(CharacterCondition.jumping48) or
        GetCharacterCondition(CharacterCondition.betweenAreas51) or
        GetCharacterCondition(CharacterCondition.jumping61) or
        GetCharacterCondition(CharacterCondition.mounting57) or
        GetCharacterCondition(CharacterCondition.mounting64) or
        GetCharacterCondition(CharacterCondition.beingmoved70) or
        GetCharacterCondition(CharacterCondition.beingmoved75) or
        LifestreamIsBusy())
    then
        Main()
        yield("/wait 0.1")
    end
until StopFlag
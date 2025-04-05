--[[
********************************************************************************
*                             Wondrous Tails Doer                              *
*                                Version 0.2.1                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)

Description: Picks up a Wondrous Tails journal from Khloe, then attempts each duty

For dungeons:
- Attempts dungeon Unsynced if duty is at least 20 levels below you
- Attempts dungeon with Duty Support if duty is within 20 levels of you and Duty
Support is available

For EX Trials:
- Attempts any duty unsynced if it is 20 levels below you and skips any that are
within 20 levels
- Note: Not all EX trials have BossMod support, but this script will attempt
each one once anyways
- Some EX trials are blacklisted due to mechanics that cannot be done solo
(Byakko tank buster, Tsukuyomi meteors, etc.)

Alliance Raids/PVP/Treasure Maps/Palace of the Dead
- Skips them all


    -> 0.2.0    Fixes for ex trials
                Update for patch 7.1

********************************************************************************
*                               Required Plugins                               *
********************************************************************************
1. Autoduty
2. Rotation Solver Reborn
3. BossModReborn (BMR) or Veyn's BossMod (VBM)

********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]

DodgingPlugin                       = "VBM"

WonderousTailsDuties = {
    { -- type 0: extreme trials
        { instanceId=20010, dutyId=297, dutyName="迦楼罗歼殛战", minLevel=50 },
        { instanceId=20009, dutyId=296, dutyName="泰坦歼殛战", minLevel=50 },
        { instanceId=20008, dutyId=295, dutyName="伊弗利特歼殛战", minLevel=50 },
        { instanceId=20012, dutyId=364, dutyName="莫古力贤王歼殛战", minLevel=50 },
        { instanceId=20018, dutyId=359, dutyName="利维亚桑歼殛战", minLevel=50 },
        { instanceId=20023, dutyId=375, dutyName="拉姆歼殛战", minLevel=50 },
        { instanceId=20025, dutyId=378, dutyName="希瓦歼殛战", minLevel=50 },
        { instanceId=20013, dutyId=348, dutyName="究极神兵假想作战", minLevel=50 },
        { instanceId=20034, dutyId=447, dutyName="俾斯麦歼殛战", minLevel=60 },
        { instanceId=20032, dutyId=446, dutyName="罗波那歼殛战", minLevel=60 },
        { instanceId=20036, dutyId=448, dutyName="圆桌骑士幻想歼灭战", minLevel=60 },
        { instanceId=20038, dutyId=524, dutyName="萨菲洛特歼殛战", minLevel=60 },
        { instanceId=20040, dutyId=566, dutyName="尼德霍格传奇征龙战", minLevel=60 },
        { instanceId=20042, dutyId=577, dutyName="索菲娅歼殛战", minLevel=60 },
        { instanceId=20044, dutyId=638, dutyName="祖尔宛歼殛战", minLevel=60 },
        { instanceId=20049, dutyId=720, dutyName="吉祥天女歼殛战", minLevel=70 },
        { instanceId=20056, dutyId=779, dutyName="月读幽夜歼灭战", minLevel=70 },
        { instanceId=20058, dutyId=811, dutyName="朱雀诗魂战", minLevel=70 },
        { instanceId=20054, dutyId=762, dutyName="火龙上位狩猎战", minLevel=70 },
        { instanceId=20061, dutyId=825, dutyName="青龙诗魂战", minLevel=70 },
        { instanceId=20063, dutyId=858, dutyName="缇坦妮雅歼殛战", minLevel=80 },
        { instanceId=20065, dutyId=848, dutyName="无瑕灵君歼殛战", minLevel=80 },
        { instanceId=20067, dutyId=885, dutyName="哈迪斯孤念歼灭战", minLevel=80 },
        { instanceId=20069, dutyId=912, dutyName="红宝石神兵狂想作战", minLevel=80 },
        { instanceId=20070, dutyId=913, dutyName="博兹雅堡垒追忆战", minLevel=80 },
        { instanceId=20072, dutyId=923, dutyName="光之战士幻耀歼灭战", minLevel=80 },
        { instanceId=20074, dutyId=935, dutyName="绿宝石神兵狂想作战", minLevel=80 },
        { instanceId=20076, dutyId=951, dutyName="钻石神兵狂想作战", minLevel=80 },
        { instanceId=20078, dutyId=996, dutyName="海德林晖光歼灭战", minLevel=90 },
        { instanceId=20081, dutyId=993, dutyName="佐迪亚克暝暗歼灭战", minLevel=90 },
        { instanceId=20083, dutyId=998, dutyName="终极之战", minLevel=90 },
        { instanceId=20085, dutyId=1072, dutyName="巴尔巴莉希娅歼殛战", minLevel=90 },
        { instanceId=20087, dutyId=1096, dutyName="卢比坎特歼殛战", minLevel=90 },
        { instanceId=20090, dutyId=1141, dutyName="高贝扎歼殛战", minLevel=90 },
        { instanceId=20092, dutyId=1169, dutyName="泽罗姆斯歼殛战", minLevel=90 }
    },
    { -- type 1: expansion cap dungeons
        { dutyName="100级迷宫", dutyId=1199, minLevel=100 } --Alexandria
    },
    2,
    3,
    { -- type 4: normal raids
        { dutyName="巴哈姆特大迷宫 邂逅之章", dutyId=241, minLevel=50 },
        { dutyName="巴哈姆特大迷宫 入侵之章", dutyId=355, minLevel=50 },
        { dutyName="巴哈姆特大迷宫 真源之章", dutyId=193, minLevel=50 },
        { dutyName="亚历山大机神城 启动之章", dutyId=442, minLevel=60 },
        { dutyName="亚历山大机神城 律动之章", dutyId=520, minLevel=60 },
        { dutyName="亚历山大机神城 天动之章", dutyId=580, minLevel=60 },
        { dutyName="欧米茄时空狭缝 德尔塔幻境", dutyId=693, minLevel=70 },
        { dutyName="欧米茄时空狭缝 西格玛幻境", dutyId=748, minLevel=70 },
        { dutyName="欧米茄时空狭缝 阿尔法幻境", dutyId=798, minLevel=70 },
        { dutyName="伊甸希望乐园 觉醒之章", dutyId=849, minLevel=80 },
        { dutyName="伊甸希望乐园 共鸣之章", dutyId=903, minLevel=80 },
        { dutyName="伊甸希望乐园 再生之章", dutyId=942, minLevel=80 },
    },
    { -- type 5: leveling dungeons
        { dutyName="1-49级迷宫", dutyId=172, minLevel=15 }, --The Aurum Vale
        { dutyName="51-79级迷宫", dutyId=434, minLevel=51 }, --The Dusk Vigil
        { dutyName="81-99级迷宫", dutyId=952, minLevel=81 }, --The Tower of Zot
    },
    { -- type 6: expansion cap dungeons
        { dutyName="50或60级迷宫", dutyId=362, minLevel=50 }, --Brayflox Longstop (Hard)
        { dutyName="70或80级迷宫", dutyId=1146, minLevel=70 }, --Ala Mhigo
        { dutyName="90级迷宫", dutyId=973, minLevel=90 }, --The Dead Ends
        
    },
    { -- type 7: ex trials
        {
            { instanceId=20008, dutyId=295, dutyName="Trials (Lv. 50-60)", minLevel=50 }, -- 伊弗利特讨伐战
            { instanceId=20049, dutyId=720, dutyName="Trials (Lv. 70-100)", minLevel=70 }
        }
    },
    { -- type 8: alliance raids

    },
    { -- type 9: normal raids
        { dutyName="Normal Raids (Lv. 50-60)", dutyId=241, minLevel=50 },
        { dutyName="Normal Raids (Lv. 70-80)", dutyId=693, minLevel=70 },
    },
    Blacklisted= {
        { -- 0
            { instanceId=20052, dutyId=758, dutyName="白虎诗魂战", minLevel=70 }, -- 不能单挑
            { instanceId=20047, dutyId=677, dutyName="须佐之男歼殛战", minLevel=70 }, -- 不能单挑
            { instanceId=20056, dutyId=779, dutyName="月读幽夜歼灭战", minLevel=70 } -- 不能单挑
        },
        {}, -- 1
        {}, -- 2
        { -- 3
            { dutyName="魔纹" }
        },
        { -- 4
            { dutyName="团队任务 (重生之境)", dutyId=174 },
            { dutyName="团队任务 (苍穹之禁城)", dutyId=508 },
            { dutyName="团队任务 (红莲之狂潮)", dutyId=734 },
            { dutyName="团队任务 (暗影之逆焰)", dutyId=882 },
            { dutyName="团队任务 (晓月之终途)", dutyId=1054 },
            { dutyName="Asphodelos= First to Fourth Circles", dutyId=1002 },
            { dutyName="Abyssos= Fifth to Eighth Circles", dutyId=1081 },
            { dutyName="Anabaseios= Ninth to Twelfth Circles", dutyId=1147 }
        }
    }
}

Khloe = {
    x = -19.346453,
    y = 210.99998,
    z = 0.086749226,
    name = "库洛·阿里亚珀"
}

-- Region: Functions ---------------------------------------------------------------------------------

function SearchWonderousTailsTable(type, data, text)
    if type == 0 then -- ex trials are indexed by instance#
        for _, duty in ipairs(WonderousTailsDuties[type+1]) do
            if duty.instanceId == data then
                return duty
            end
        end
    elseif type == 1 or type == 5 or type == 6 or type == 7 then -- dungeons, level range ex trials
        for _, duty in ipairs(WonderousTailsDuties[type+1]) do
            if duty.dutyName == text then
                return duty
            end
        end
    elseif type == 4 or type == 8 then -- normal raids
        for _, duty in ipairs(WonderousTailsDuties[type+1]) do
            if duty.dutyName == text then
                return duty
            end
        end
    end
end

-- Region: Main ---------------------------------------------------------------------------------

CurrentLevel = GetLevel()

-- Pick up a journal if you need one
if not HasWeeklyBingoJournal() or IsWeeklyBingoExpired() or WeeklyBingoNumPlacedStickers() == 9 then
    if not IsInZone(478) then
        yield("/tp 田园郡")
        yield("/wait 1")
    end
    while not (IsInZone(478) and IsPlayerAvailable()) do
        yield("/wait 1")
    end
    PathfindAndMoveTo(Khloe.x, Khloe.y, Khloe.z)
    while(GetDistanceToPoint(Khloe.x, Khloe.y, Khloe.z) > 5) do
        yield("/wait 1")
    end
    yield("/target "..Khloe.name)
    yield("/wait 1")
    yield("/interact")
    while not IsAddonVisible("SelectString") do
        yield("/click Talk Click")
        yield("/wait 1")
    end
    if IsAddonVisible("SelectString") then
        if not HasWeeklyBingoJournal() then
            yield("/callback SelectString true 0")
        elseif IsWeeklyBingoExpired() then
            yield("/callback SelectString true 1")
        elseif WeeklyBingoNumPlacedStickers() == 9 then
            yield("/callback SelectString true 0")
        end
        
    end
    while GetCharacterCondition(32) do
        yield("/click Talk Click")
        yield("/wait 1")
    end
    yield("/wait 1")
end

-- skip 13: Shadowbringers raids (not doable solo unsynced)
-- skip 14: Endwalker raids (not doable solo unsynced)
-- skip 15: PVP
for i = 0, 12 do
    if GetWeeklyBingoTaskStatus(i) == 0 then
        local key = GetWeeklyBingoOrderDataKey(i)
        local type = GetWeeklyBingoOrderDataType(key)
        local data = GetWeeklyBingoOrderDataData(key)
        local text = GetWeeklyBingoOrderDataText(key)
        LogInfo("[WondrousTails] Wonderous Tails #"..(i+1).." Key: "..key)
        LogInfo("[WondrousTails] Wonderous Tails #"..(i+1).." Type: "..type)
        LogInfo("[WondrousTails] Wonderous Tails #"..(i+1).." Data: "..data)
        LogInfo("[WondrousTails] Wonderous Tails #"..(i+1).." Text: "..text)

        local duty = SearchWonderousTailsTable(type, data, text)
        if duty == nil then
            yield("/echo duty is nil")
        end
        local dutyMode = "Support"
        if duty ~= nil then
            if CurrentLevel < duty.minLevel then
                yield("/echo [WonderousTails] 由于等级过低，无法进入："..duty.dutyName.." .")
                duty.dutyId = nil
            elseif type == 0 then -- trials
                yield("/autoduty cfg Unsynced true")
                dutyMode = "Trial"
            elseif type == 4 then -- raids
                yield("/autoduty cfg Unsynced true")
                dutyMode = "Raid"
            elseif CurrentLevel - duty.minLevel <= 20 then
                -- yield("/autoduty cfg dutyModeEnum 1") -- TODO: test this when it gets released
                -- yield("/autoduty cfg Unsynced false")
                dutyMode = "Support"
            else
                -- yield("/autoduty cfg dutyModeEnum 8")
                yield("/autoduty cfg Unsynced true")
                dutyMode = "Regular"
            end

            if duty.dutyId ~= nil then
                yield("/echo Queuing duty TerritoryId#"..duty.dutyId.." for Wonderous Tails #"..(i+1))
                yield("/autoduty run "..dutyMode.." "..duty.dutyId.." 1 true")
                if DodgingPlugin == "BMR" then
                    yield("/bmrai on")
                elseif DodgingPlugin == "VBM" then
                    yield("/vbmai on")
                end
                yield("/rotation auto")
                yield("/wait 10")
                while GetCharacterCondition(34) or GetCharacterCondition(51) or GetCharacterCondition(56) do -- wait for duty to be finished
                    if GetCharacterCondition(2) and i > 4 then -- dead, not a dungeon
                        yield("/echo Died to "..duty.dutyName..". Skipping.")
                        repeat
                            yield("/wait 1")
                        until not GetCharacterCondition(2)
                        LeaveDuty()
                        break
                    end
                    yield("/wait 1")
                end
                yield("/wait 10")
            else
                if duty.dutyName ~= nil then
                    yield("/echo Wonderous Tails Script does not support Wonderous Tails entry #"..(i+1).." "..duty.dutyName)
                    LogInfo("[WonderousTails] Wonderous Tails Script does not support Wonderous Tails entry #"..(i+1).." "..duty.dutyName)
                else
                    yield("/echo Wonderous Tails Script does not support Wonderous Tails entry #"..(i+1))
                    LogInfo("[WonderousTails] Wonderous Tails Script does not support Wonderous Tails entry #"..(i+1))
                end
            end
        end
    end

    -- if GetWeeklyBingoTaskStatus(i) == 1
    --    and (not StopPlacingStickersAt7 or WeeklyBingoNumPlacedStickers() < 7)
    -- then
    --     if not IsAddonVisible("WeeklyBingo") then
    --         yield("/callback WeeklyBingo true 2 "..i)
    --         yield("/wait 1")
    --     end
    -- end
end

yield("/echo Completed all Wonderous Tails entries it is capable of.<se.3>")
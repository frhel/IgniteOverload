local version = "0.5.2"

local RED = "|cFFFF4477";
local YELLOW = "|cFFFFFFAA";
local BLUE = "|cFF22AAFF";

local mageList = {};
local timerRunning = 0;
local timeFreq = 2
local lastThreatMage = nil
local lastTarget = nil

-- Define chat commands
SLASH_PHRASE1 = "/iol";
SLASH_PHRASE2 = "/igniteoverload";
SlashCmdList["PHRASE"] = function(msg)
    -- lowercase everything to make it easier to work with
    msg = msg:lower()

    if msg == "" then
        SELECTED_CHAT_FRAME:AddMessage(BLUE .. "[IgniteOverload] Type " .. YELLOW .. "/iol on" .. BLUE .. " or " .. YELLOW .. "/iol off " .. BLUE .."to turn IgniteOverload on/off")
        return
    end
end

function UpdateMageList()
    for i = 1,40 do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
        if not (name == nil) then
            if (fileName == "MAGE") then
                table.insert(mageList, name)
            end
        end
    end
end

function CheckMageThreat()
    if #mageList > 0 then
        for i = 1,#mageList do
            if (UnitIsEnemy("player", "target")) then 
                currTarget = UnitGUID("target")
                if not (currTarget == lastTarget) then 
                    lastTarget = currTarget
                    lastThreatMage = nil
                end
                local _,_,threatpct,_,_ = UnitDetailedThreatSituation(mageList[i], "target")
                if not (threatpct == nil) then
                    if not (mageList[i] == lastThreatMage) then
                        if threatpct > 80 then
                            lastThreatMage = mageList[i]
                            message1 = RED .. "|||||||"
                            message2 = BLUE .. "|Hplayer:" .. mageList[i] .. "|h<" .. mageList[i] .. ">|h" .. RED .. " IS ABOVE 80% THREAT ON YOUR TARGET!"
                            message3 = RED .. "|||||||"
                            SELECTED_CHAT_FRAME:AddMessage(message1)
                            SELECTED_CHAT_FRAME:AddMessage(message2)
                            SELECTED_CHAT_FRAME:AddMessage(message3)
                        end
                    end
                elseif threatpct < 80 and mageList[i] == lastThreatMage then
                    lastThreatMage = nil
                end
            end
        end
    end
end

local f = CreateFrame("Frame")

f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then -- player has entered combat
        UpdateMageList()
        timerRunning = 1;
    end
    if event == "PLAYER_REGEN_ENABLED" then -- player has left combat
        timerRunning = 0;
    end
end)

local t = timeFreq
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(self, elapsed)
     t = t - elapsed
     if t <= 0 and timerRunning == 1 then
        CheckMageThreat()
        t = timeFreq;
     end
end)
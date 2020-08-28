local version = "0.1.3"

local RED = "|cFFFF0000";
local YELLOW = "|cFFFFFF66";
local BLUE = "|cFF22AAFF";
local GREEN = "|cFF11EE22";

local IOL = IOL or {}

local mageList = {}
local timerRunning = 0
local timeFreq = 2
local lastThreatMage = ""
local lastTarget = ""
local flashWarningText = false
local threatMsg = ""
local warningTextFont = "Fonts\\FRIZQT__.TTF"

-- saved vars
local threatThreshold = 90
local warningTextSize = 4
local addonRunning = 1
local warningText = 1
local verboseWarning = 0
local verboseRaidWarning = 0
local verbosePartyWarning = 0
local screenFlash = 1
local sound = 0

local iolStatusText
local screenFlashStatusText
local textWarningStatusText
local soundStatusText
local verboseStatusText
local verboseRaidWarningStatusText
local verbosePartyStatusText

function setStatusSwitchFlavorText()
    if addonRunning == 1 then iolStatusText = GREEN .. "[ON]" else iolStatusText = RED .. "[OFF]" end
    if screenFlash == 1 then screenFlashStatusText = GREEN .. "[ON]" else screenFlashStatusText = RED .. "[OFF]" end
    if warningText == 1 then textWarningStatusText = GREEN .. "[ON]" else textWarningStatusText = RED .. "[OFF]" end
    if sound == 1 then soundStatusText = GREEN .. "[ON]" else soundStatusText = RED .. "[OFF]" end
    if verboseWarning == 1 then verboseStatusText = GREEN .. "[ON]" else verboseStatusText = RED .. "[OFF]" end
    if verboseRaidWarning == 1 then verboseRaidWarningStatusText = GREEN .. "[ON]" else verboseRaidWarningStatusText = RED .. "[OFF]" end
    if verbosePartyWarning == 1 then verbosePartyStatusText = GREEN .. "[ON]" else verbosePartyStatusText = RED .. "[OFF]" end
    
end
setStatusSwitchFlavorText()

-- Creating the frame which we use to display the screen text warnings
local f1 = CreateFrame("Frame",nil,UIParent)
f1:SetWidth(1) 
f1:SetHeight(1) 
f1:SetAlpha(0);
f1:SetPoint("CENTER",0,0)
f1.text = f1:CreateFontString(nil,"ARTWORK") 
f1.text:SetFont(warningTextFont, warningTextSize*10, "OUTLINE")
f1.text:SetPoint("CENTER",0,0)
f1:Hide()

-- Define chat commands
SLASH_IOLPHRASE1 = "/iol";
SLASH_IOLPHRASE2 = "/igniteoverload";
SlashCmdList["IOLPHRASE"] = function(msg)
    -- lowercase everything to make it easier to work with
    msg = msg:lower()

    if msg == "help" then
        setStatusSwitchFlavorText()
        SELECTED_CHAT_FRAME:AddMessage(RED .. "[IgniteOverload] " .. iolStatusText .. BLUE .. " Type " .. YELLOW .. " /iol " .. BLUE .. "to enable/disable IgniteOverload")
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. screenFlashStatusText .. BLUE .. " Type " .. YELLOW .. " /iol screenflash " .. BLUE .. "to enable/disable flash screen on overaggro")
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. textWarningStatusText .. BLUE .. " Type " .. YELLOW .. " /iol textwarning " .. BLUE .. "to enable/disable warning text in middle of screen")
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. soundStatusText .. BLUE .. " Type " .. YELLOW .. " /iol sound " .. BLUE .. "to enable/disable sound warning. Type " .. YELLOW .. "/iol soundpreview" .. BLUE .. " to preview the warning sound")
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .. " Type " .. YELLOW .. " /iol raidchat " .. verboseStatusText .. BLUE .. " <> " .. YELLOW .. " /iol partychat " .. verbosePartyStatusText .. BLUE .. " <> " .. YELLOW .. " /iol raidwarning " .. verboseRaidWarningStatusText .. BLUE .. " <> to enable text warnings in raid chat, party chat and raid warnings respectively")
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .. "Threat threshold set at " .. GREEN .. threatThreshold .. BLUE .. "%. Type " .. YELLOW .. "/iol threat 1-130 " .. BLUE .. "to set threat threshold")        
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .. "Warning text size set at " .. GREEN .. warningTextSize .. BLUE ..". Type " .. YELLOW .. "/iol textsize 1-6 " .. BLUE .. "to set text size")
        return
    elseif msg == "" then
        if addonRunning == 1 then addonRunning = 0 else addonRunning = 1 end
        setStatusSwitchFlavorText()
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .."has been switched " .. iolStatusText .. BLUE .. ". Type " .. YELLOW .. "/iol help" .. BLUE .. " to see more options")
        return
    elseif msg == "screenflash" then
        if screenFlash == 1 then screenFlash = 0 else screenFlash = 1 end
        setStatusSwitchFlavorText()
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .."Screen flash alert has been switched " .. screenFlashStatusText)
        print(screenFlash)
        return
    elseif msg == "textwarning" then
        if warningText == 1 then warningText = 0 else warningText = 1 end
        setStatusSwitchFlavorText()
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .."Screen text warning has been switched " .. textWarningStatusText)
        return
    elseif msg == "sound" then
        if sound == 1 then sound = 0 else sound = 1 end
        setStatusSwitchFlavorText()
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .."Sound warning has been switched " .. soundStatusText)
        return
    elseif msg == "raidchat" then
        if verboseWarning == 1 then verboseWarning = 0 else verboseWarning = 1 end
        setStatusSwitchFlavorText()
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .."Raid chat alert has been switched " .. verboseStatusText)
        return
    elseif msg == "raidwarning" then
        if verboseRaidWarning == 1 then verboseRaidWarning = 0 else verboseRaidWarning = 1 end
        setStatusSwitchFlavorText()
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .."Raid warning alert has been switched " .. verboseRaidWarningStatusText)
        return
    elseif msg == "partychat" then
        if verbosePartyWarning == 1 then verbosePartyWarning = 0 else verbosePartyWarning = 1 end
        setStatusSwitchFlavorText()
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .."Party chat alert has been switched " .. verbosePartyStatusText)
        return
    elseif msg == "soundpreview" then
        PlaySoundFile("Interface/AddOns/IgniteOverload/dps_very_very_slowly.mp3", "Master")
        SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .."Playing warning sound preview...")
        return
    else
        local splitMsg = {}
        for word in msg:gmatch "%w+" do table.insert(splitMsg, word) end
        if table.getn(splitMsg) > 1 then 
            -- Set Threat Threshold
            tempNumVal = tonumber(splitMsg[2]);
            if splitMsg[1] == "threat" and type(tempNumVal) == "number" and tempNumVal > 0 and tempNumVal <= 130 then
                threatThreshold = tempNumVal
                SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .."Threat threshold set to " .. YELLOW .. threatThreshold .. "%")
            elseif splitMsg[1] == "textsize" and type(tempNumVal) == "number" and tempNumVal >= 1 and tempNumVal <= 6 then
                warningTextSize = tempNumVal                
                f1.text:SetFont(warningTextFont, warningTextSize*10, "OUTLINE")
                SELECTED_CHAT_FRAME:AddMessage(RED  .. "[IgniteOverload] " .. BLUE .."Screen warning text size set to " .. YELLOW .. warningTextSize)
                
            end
            return
        end
    end
end

function UpdateMageList()
    -- Loop through all raid members and extract the mages 40 is the max possible index value.
    for i = 1,40 do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
        if not (name == nil) then
            if (fileName == "MAGE") then
                table.insert(mageList, name)
            end
        end
    end
end


function UpdateTarget()
    currTarget = UnitGUID("target")
    if not (currTarget == lastTarget) then 
        lastTarget = currTarget
        lastThreatMage = ""
    end
end

function TriggerThreatWarning(player)
    lastThreatMage = player

    if verboseWarning == 1 then
        verboseMsg = "<.><.> " .. player .." is above ".. threatThreshold .. "% threat on " .. UnitName("target")
        SendChatMessage(verboseMsg, "RAID")
    end
    if verbosePartyWarning == 1 then
        verboseMsg = "<.><.> " .. player .." is above ".. threatThreshold .. "% threat on " .. UnitName("target")
        SendChatMessage(verboseMsg, "PARTY")
    end
    if verboseRaidWarning == 1 then
        verboseMsg = "<.><.> " .. player .." is above ".. threatThreshold .. "% threat on " .. UnitName("target")
        SendChatMessage(verboseMsg, "RAID_WARNING")
    end

    if screenFlash == 1 then IOL:FlashScreen() end

    if warningText == 1 then
        threatMsg = BLUE .. "<" .. player .. "> " .. RED .. "is above " .. BLUE .. threatThreshold .."%" .. RED .. " threat limit"
        flashWarningText = true
    end

    if sound == 1 then PlaySoundFile("Interface/AddOns/IgniteOverload/dps_very_very_slowly.mp3", "Master") end
end

-- Loop through the threat values of each mage in the raid and do something with that information
function CheckMageThreat()
    if #mageList > 0 then
        for i = 1,#mageList do
            if (UnitIsEnemy("player", "target")) then                 
                local _,_,threatpct,_,_ = UnitDetailedThreatSituation(mageList[i], "target")
                if not (threatpct == nil) then
                    UpdateTarget();
                    if not (mageList[i] == lastThreatMage) then
                        if threatpct >= threatThreshold then
                            TriggerThreatWarning(mageList[i]);
                        elseif threatpct < threatThreshold and mageList[i] == lastThreatMage then
                            lastThreatMage = ""
                        end
                    end
                end
            end
        end
    end
end

local f = CreateFrame("Frame")

f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("ADDON_LOADED") -- Fired when saved variables are loaded
f:RegisterEvent("PLAYER_LOGOUT") -- Fired when about to log out

f:SetScript("OnEvent", function(self, event, message, ...)
    if event == "PLAYER_REGEN_DISABLED" then -- player has entered combat
        if (addonRunning == 1) then
            UpdateMageList()
            timerRunning = 1
        end
    elseif event == "PLAYER_REGEN_ENABLED" then -- player has left combat
        mageList = {}
        timerRunning = 0;
    elseif event == "ADDON_LOADED" and message == "IgniteOverload" then
        print(RED .. "Ignite Overload v" .. version .. " loaded - " .. BLUE .. "/iol" .. RED .. " or " .. BLUE .. "/igniteoverload")
        if IOLDB then
            threatThreshold = IOLDB["threatThreshold"]
            warningTextSize = IOLDB["warningTextSize"]
            addonRunning = IOLDB["addonRunning"]
            warningText = IOLDB["warningText"]
            verboseWarning= IOLDB["verboseWarning"]
            screenFlash = IOLDB["screenFlash"]
            sound = IOLDB["sound"]
		end
    elseif event == "PLAYER_LOGOUT" then
        IOLDB = {};
		IOLDB["threatThreshold"] = threatThreshold
        IOLDB["warningTextSize"] = warningTextSize
        IOLDB["addonRunning"] = addonRunning
        IOLDB["warningText"] = warningText
        IOLDB["verboseWarning"] = verboseWarning
        IOLDB["screenFlash"] = screenFlash
        IOLDB["sound"] = sound
    end
    return
end)

local t = timeFreq
local f = CreateFrame("Frame")
local f1Elapsed = 0;
local f1Alpha = 1;
f:SetScript("OnUpdate", function(self, elapsed)
     t = t - elapsed
     if t <= 0 and timerRunning == 1 then
        CheckMageThreat()
        t = timeFreq;
     end
     if flashWarningText then
        if f1Elapsed == 0 then
            f1.text:SetText(threatMsg)
            f1:SetAlpha(1)
            f1:Show()
        end
        f1Elapsed = f1Elapsed + elapsed
        if f1Elapsed > 0 and f1Elapsed < 6 then
            if f1Elapsed > 2 then
                f1:SetAlpha(1 / ((f1Elapsed - 2) *10))
            end
        end
        if f1Elapsed > 6 then
            flashWarningText = false;
            f1:Hide()
            f1Elapsed = 0;
        end

     end
end)

function IOL:FlashScreen()
	if not self.FlashFrame then
		local flasher = CreateFrame("Frame", "IOLFlashFrame")
		flasher:SetToplevel(true)
		flasher:SetFrameStrata("FULLSCREEN_DIALOG")
		flasher:SetAllPoints(UIParent)
		flasher:EnableMouse(false)
		flasher:Hide()
		flasher.texture = flasher:CreateTexture(nil, "BACKGROUND")
		flasher.texture:SetTexture("Interface\\FullScreenTextures\\OutOfControl")
		flasher.texture:SetAllPoints(UIParent)
		flasher.texture:SetBlendMode("ADD")
		flasher:SetScript("OnShow", function(self)
			self.elapsed = 0
			self:SetAlpha(0)
		end)
		flasher:SetScript("OnUpdate", function(self, elapsed)
			elapsed = self.elapsed + elapsed
			if elapsed < 5.2 then
				local alpha = elapsed % 1.3
				if alpha < 0.15 then
					self:SetAlpha(alpha / 0.15)
				elseif alpha < 0.9 then
					self:SetAlpha(1 - (alpha - 0.15) / 0.6)
				else
					self:SetAlpha(0)
				end
			else
				self:Hide()
			end
			self.elapsed = elapsed
		end)
		self.FlashFrame = flasher
	end
	self.FlashFrame:Show()
end

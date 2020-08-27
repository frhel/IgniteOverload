local version = "0.5.2"

local RED = "|cFFFF0000";
local YELLOW = "|cFFFFFFAA";
local BLUE = "|cFF22AAFF";

local IOL = IOL or {}

local mageList = {}
local timerRunning = 0
local timeFreq = 2
local lastThreatMage = ""
local lastTarget = ""
local flashWarningText = false;
local threatMsg = "";

-- saved vars
local threatThreshold = 80
local warningTextSize = 40
local addonRunning = 1
local warningText = 1
local verboseWarningText = 0
local screenFlash = 1

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

-- This UpdateTarget function serves no purpose at the moment. Want to use this later to maybe figure out 
-- if the owner of the current ignite stack and the one who is overaggroing are the same person
function UpdateTarget()
    currTarget = UnitGUID("target")
    if not (currTarget == lastTarget) then 
        lastTarget = currTarget
        lastThreatMage = ""
    end
end

function TriggerThreatWarning(player)
    lastThreatMage = player

    if verboseWarningText == 1 then
        message1 = RED .. ">> " .. BLUE .. "|Hplayer:" .. player .. "|h<" .. player .. ">|h" .. RED .. " IS ABOVE THREAT LIMIT <<"
        SELECTED_CHAT_FRAME:AddMessage(message1)
    end

    if screenFlash == 1 then
        IOL:FlashScreen();
    end

    if warningText == 1 then
        threatMsg = BLUE .. "<" .. lastThreatMage .. "> " .. RED .. "is above threat limit"
        flashWarningText = true
    end
end

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

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then -- player has entered combat
        if (addonRunning) then
            UpdateMageList()
            timerRunning = 1;
        end
    end
    if event == "PLAYER_REGEN_ENABLED" then -- player has left combat
        timerRunning = 0;
    end
end)

local f1 = CreateFrame("Frame",nil,UIParent)
f1:SetWidth(1) 
f1:SetHeight(1) 
f1:SetAlpha(.90);
f1:SetPoint("CENTER",0,0)
f1.text = f1:CreateFontString(nil,"ARTWORK") 
f1.text:SetFont("Fonts\\ARIALN.ttf", warningTextSize, "OUTLINE")
f1.text:SetPoint("CENTER",0,0)
f1:Hide()

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
		flasher.texture:SetTexture("Interface\\FullScreenTextures\\LowHealth")
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

-- TODO: Custom message to send to player on click
-- TODO: Set up local storage for custome message and settings

local version = "0.5.2"
local kwdArr = {};
local playSoundOption = "off";
local monitoring = false;
local bossMonitoring = false;
local bossArr = {" azu", " kaz", " eme", " leth", " yso", " tae"};

local RED = "|cFFFF4477";
local YELLOW = "|cFFFFFFAA";
local BLUE = "|cFF22AAFF";

local defaultChatID = DEFAULT_CHAT_FRAME:GetID();

-- Define chat commands
SLASH_PHRASE1 = "/co";
SLASH_PHRASE2 = "/chatobserver";
SlashCmdList["PHRASE"] = function(msg)
	-- lowercase everything to make it easier to work with
	msg = msg:lower()
	-- If no param given for command print options list
	if msg == "" then 		
		local bossMonitoringStatus = RED .. "[OFF]"
		local soundStatus = RED .. "[OFF]"
		if bossMonitoring == true then
			bossMonitoringStatus = BLUE .. "[ON]"
		end
		if playSoundOption == "on" then
			soundStatus = BLUE .. "[ON]"
		end 

		SELECTED_CHAT_FRAME:AddMessage(RED .. " >>> Type " .. YELLOW .. "/co start" .. RED .. " or " .. YELLOW .. "/co stop " .. RED .."to start/stop monitoring for keywords from watchlist")
		SELECTED_CHAT_FRAME:AddMessage(RED .. " >>> Type " .. YELLOW .. "/co add <keyword> " .. RED .."to add one or more words to watchlist (fx /co add UBRS or /co add UBRS Strat Scholo Dm)")
		SELECTED_CHAT_FRAME:AddMessage(RED .. " >>> Type " .. YELLOW .. "/co remove <keyword> " .. RED .."to remove word from watchlist (fx /co remove UBRS)")
		SELECTED_CHAT_FRAME:AddMessage(RED .. " >>> Type " .. YELLOW .. "/co clear " .. RED .."to clear watchlist")
		SELECTED_CHAT_FRAME:AddMessage(RED .. " >>> Type " .. YELLOW .. "/co list " .. RED .."to list keywords in watchlist")
		SELECTED_CHAT_FRAME:AddMessage(RED .. " >>> " .. soundStatus .. RED .. " Type " .. YELLOW .. "/co sound on" .. RED .. " or " .. YELLOW .. "/co sound off " .. RED .." to turn notification sound on/off")
		SELECTED_CHAT_FRAME:AddMessage(RED .. " >>> " .. bossMonitoringStatus .. RED .. " Type " .. YELLOW .. "/co wb" .. RED .. " to start/stop monitoring chatter about world raid bosses")
		return
	end

	if msg == "clear" then 
		kwdArr = {}
		SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Watchlist has been cleared")
		if monitoring == true then
			monitoring = false
			SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Monitoring has been turned" .. YELLOW .. " off")
		end
		return;
	end

	if msg == "list" then
		local outStr = "";
		if #kwdArr == 0 then
			SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Watchlist is " .. YELLOW .. "empty")
		else
			for i = 1,#kwdArr do
				if i == #kwdArr then
					outStr = outStr .. YELLOW .. kwdArr[i]
				else
					outStr = outStr .. YELLOW .. kwdArr[i] .. RED .. ", "
				end
			end
			SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Current watchlist: " .. YELLOW .. outStr)
		end
		return
	end

	if msg == "start" then
		if #kwdArr == 0 then
			SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Watchlist is " .. YELLOW .. "empty. " .. RED .. "Monitoring not started")
		else
			monitoring = true
			SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Monitoring has been turned" .. YELLOW .. " on")
		end
		return
	end

	if msg == "stop" then
		monitoring = false
		SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Monitoring has been turned" .. YELLOW .. " off")
		return
	end

	if msg == "sound" then
		SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Type " .. YELLOW .. "/co sound on" .. RED .. " or " .. YELLOW .. "/co sound off " .. RED .." to turn notification sound on/off")
		return
	end

	if msg == "add" then
		SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Type " .. YELLOW .. "/co add <keyword> " .. RED .."to add word to watchlist (fx /co add UBRS)")
		return
	end

	if msg == "remove" then
		SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Type " .. YELLOW .. "/co remove <keyword> " .. RED .."to remove word from watchlist (fx /co remove UBRS)")
		return
	end
	
	if msg == "wb" then
		if bossMonitoring == true then
			bossMonitoring = false
			SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Monitoring for world raid bosses has been turned " .. YELLOW .. " off")
		elseif bossMonitoring == false then			
			SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Monitoring for world raid bosses has been turned " .. YELLOW .. " on")
			bossMonitoring = true
		end
		return
	end


	-- Handle everything else as a split string with index 1 as command and index 2 as param
	local splitMsg = {}
	for word in msg:gmatch "%w+" do table.insert(splitMsg, word) end
	if table.getn(splitMsg) > 1 then 
		-- Turn sound on/off
		if splitMsg[1] == "sound" then
			if splitMsg[2] == "on" then 
				playSoundOption = "on" 
				SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Sound" .. YELLOW .. " enabled " .. RED .."for all alerts")
				return
			elseif splitMsg[2] == "off" then
				playSoundOption = "off"
				SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Sound" .. YELLOW .. " disabled " .. RED .."for all alerts")
				return
			else
				SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Type " .. YELLOW .. "/co sound on" .. RED .. " or " .. YELLOW .. "/co sound off " .. RED .." to turn notification sound on/off")
				return
			end 
		end

		-- Add / Remove Keywords to match
		if splitMsg[1] == "add" then
			local outStr = ""
			for i = 2,#splitMsg do
				table.insert(kwdArr, splitMsg[i])
				outStr = outStr .. YELLOW .. splitMsg[i]
				if i < #splitMsg then
					outStr = outStr .. RED .. ", "
				end 
			end
			SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Added keyword(s) " .. outStr .. RED .. " to watchlist")
			if monitoring == false then
				monitoring = true
				SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Monitoring has been turned" .. YELLOW .. " on")
			end
			return
		end

		if splitMsg[1] == "remove" then
			for i = #kwdArr,1,-1 do
				if kwdArr[i] == splitMsg[2] then
					table.remove(kwdArr, i)
					SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Removed " .. YELLOW .. splitMsg[2] .. RED .. " from watchlist")
					return
				end 
			end
			SELECTED_CHAT_FRAME:AddMessage(RED .. " [ChatObserver] Keyword " .. YELLOW .. splitMsg[2] .. RED .. " not found in watchlist")
			return
		end
	end
end

local f = CreateFrame("Frame")

f:RegisterEvent("ADDON_LOADED") -- Fired when saved variables are loaded
f:RegisterEvent("PLAYER_LOGOUT") -- Fired when about to log out
f:RegisterEvent("CHAT_MSG_CHANNEL")

f:SetScript("OnEvent", function(self, event, message, sender, lang, channel, player2, flags, chanID, chanIndex, chanBaseName, _, lineID, guid, ...)
	if event == "ADDON_LOADED" and message == "ChatObserver" then
		print(RED .. "ChatObserver " .. version .. " loaded >>> " .. BLUE .. "Type /co or /chatobserver for more options.")
		if CODB then
			playSoundOption = CODB["playSoundOption"]
			bossMonitoring = CODB["bossMonitoring"]
		end
		return
	elseif event == "PLAYER_LOGOUT" then
		CODB = {};
		CODB["playSoundOption"] = playSoundOption
		CODB["bossMonitoring"] = bossMonitoring
		return
	end

	if event == "CHAT_MSG_CHANNEL" then
		local tempArr = {};
		if monitoring == true then
			if #kwdArr > 0 then
				for i = 1,#kwdArr do
					table.insert(tempArr, kwdArr[i])
				end
			end
		end

		if bossMonitoring == true then
			for i = 1,#bossArr do
				table.insert(tempArr, bossArr[i])
			end
		end

		if #tempArr == 0 then
			return
		end


		
		for i = 1,#tempArr do
			if chanID == 24 or 1 or 2 then
				local senderSplit =  string.match(sender, "^(.*)-")
				if senderSplit ~= nil then
					sender = senderSplit
				end
				local _, class = GetPlayerInfoByGUID(guid)
				local _,_,_, classColor = GetClassColor(class)
				local msgStr = RED .. " **[ChatObserver] Match** " .. YELLOW .. "|c" .. classColor .."|Hplayer:" .. sender .. "|h<" .. sender .. ">|h " .. BLUE .. message
				
				-- Add special case for 'st' as it's a common pairing of letters in normal words, not always meaning Sunken Temple.
				-- Really cant be arse rewriting the whole matching section of the addon just because of this
				if tempArr[i] == "st" then
					tempArr[i] = " st "
				end

				if message:lower():match(tempArr[i]) then
					print(msgStr)
					if SELECTED_CHAT_FRAME:GetID() ~= defaultChatID then
						SELECTED_CHAT_FRAME:AddMessage(msgStr)
					end			
					if playSoundOption == "on" then
						PlaySoundFile("sound/doodad/pvp_rune_speedcustom0.ogg", "Master")
					end
					return
				end
			end
		end
	end
end)
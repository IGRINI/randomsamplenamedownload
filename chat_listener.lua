--[[
#### AUTHOR: BMD ####

	Thanks BMD!
]]

function print_d(text)
	CustomGameEventManager:Send_ServerToAllClients("DebugMessage", { msg = text})
end


function OnPlayerSay(player, text)
	if text == "-killlimit" or text == "-kl"then
		Say(nil, "Radiant Kills:[" .._G.Kills[DOTA_TEAM_GOODGUYS] ..  "/".. _G.killLimit .. "] Dire Kills:[" .. _G.Kills[DOTA_TEAM_BADGUYS] .. "/" .. _G.killLimit .."]", false) 
	end

	if text == "-debug_playerinfo" then
		PrintPlayerInfo()
	end
	
	if text == "-check_modifiers" then
		CheckModifiers(player)
	end

	if text == "-check_skills" then
		CheckSkills(player)
	end

	if text == "-is_cheats" then
		if GameRules:IsCheatMode() then print_d(" Cheats is enabled!") else print_d(" Cheats is disabled!")end
	end
	
	if text == "-get_gold" then 
		CheckPlayersSaveGold(player)
	end

	if text == "-test" then
		local hero = player:GetAssignedHero() 
		print(PlayerResource:GetPlayerName(player:GetPlayerID()))
	end

end

function GetTotalPr(playerid)
	local streak = PlayerResource:GetStreak(playerid)
	local gold_per_streak = 250;
	local gold_per_level  = 100;
	local minute = GameRules:GetGameTime() / 60
	if 		minute < 10 then
		gold_per_streak = 250 + (RandomInt(-1, 1)) * RandomInt(0, 50)
	elseif 	minute < 20 then
		gold_per_streak = 600 + (RandomInt(-1, 1)) * RandomInt(0, 70)
	elseif 	minute < 30 then	
		gold_per_streak = 1000 + (RandomInt(-1, 1)) * RandomInt(0, 90)
	elseif 	minute < 50 then
		gold_per_streak = 3000 + (RandomInt(-1, 1)) * RandomInt(0, 120)
	elseif 	minute > 50 then
		gold_per_streak = 5000 + (RandomInt(-1, 1)) * RandomInt(0, 150)
	end

	print("GOLD PER STREAKS:", gold_per_streak*streak)
	_G.tPlayers[playerid] = _G.tPlayers[playerid] or {}
	_G.tPlayers[playerid].filter_gold = _G.tPlayers[playerid].filter_gold or 0
	print("FILTER GOLD:", _G.tPlayers[playerid].filter_gold)
	print("BOOKS GOLD:", _G.tPlayers[playerid].books);
	local total_gold = _G.tPlayers[playerid].filter_gold + gold_per_streak*streak
	print("TOTAL GOLD = ", total_gold)
	local hero_name = "#npc_dota_hero_meepo"
	print(hero_name .. " blah")

	
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function CheckPlayersSaveGold(player)
	-- my id 73911256
	if not PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 73911256 then 
		return 
	end

	print_d("Check players gold:")
	for i,x in pairs(tPlayers) do
		if x then
			if x.gold then
				print_d(" |-> playerid[" .. i .. "] save gold [" .. x.gold .. "]")
			end
		end
	end
end

function CheckModifiers(player)
	if not player then return end
	local hero = player:GetAssignedHero() 
	if not hero then end
	print_d("hero '" .. hero:GetUnitName() .. "'' modifiers:")
	for i = 0, hero:GetModifierCount()-1 do
		print_d(" |-> " .. hero:GetModifierNameByIndex(i))
	end

end

function CheckSkills(player)
	if not player then return end
	local hero = player:GetAssignedHero() 
	if not hero then end

	print_d("hero '" .. hero:GetUnitName() .. "' skills:")
	local ability 
	for i = 0, hero:GetAbilityCount() - 1 do
		ability = hero:GetAbilityByIndex(i)
		if ability then
			print_d(" |-> " .. ability:GetName() .. " cd = " .. ability:GetCooldownTimeRemaining() )
		end
	end
end

function PrintPlayerInfo()
	local radiant = _G.tHeroesRadiant
	local dire = _G.tHeroesDire

	print_d("Radiant Players:")
	for i, x in pairs(radiant) do
		if x then
			print_d(" |-> playerid:" .. x:GetPlayerOwnerID() .. " hero_name = '" .. x:GetUnitName() .. "'' hero level = " .. x:GetLevel() .. " Gold = " .. x:GetGold() .. " steamid:" .. PlayerResource:GetSteamAccountID(x:GetPlayerOwnerID())	)
			if x.medical_tractates then print_d(" |-> playerid:" .. x:GetPlayerOwnerID() .. " medical tractates = " .. x.medical_tractates ) end
		end
	end

	print_d("Dire Players:")
	for i, x in pairs(dire) do
		if x then
			print_d(" |-> playerid:" .. x:GetPlayerOwnerID() .. " hero_name = " .. x:GetUnitName() .. " hero level = " .. x:GetLevel() .. " Gold = " .. x:GetGold() .. " steamid:" .. PlayerResource:GetSteamAccountID(x:GetPlayerOwnerID())	 )
			if x.medical_tractates then print_d(" |-> playerid:" .. x:GetPlayerOwnerID() .. " medical tractates = " .. x.medical_tractates ) end
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


if PlayerSay == nil then
	print ( '[PlayerSay] creating PlayerSay' )
	PlayerSay = {}
	PlayerSay.__index = PlayerSay

	PlayerSay.teamChatCallback = nil;
	PlayerSay.allChatCallback = nil;
	
	Convars:RegisterCommand('player_say', function(...)
		local arg = {...}
		table.remove(arg,1)
		local sayType = tonumber(arg[1])
		table.remove(arg,1)

		local cmdPlayer = Convars:GetCommandClient()
		local text = table.concat(arg, " ")

		OnPlayerSay(cmdPlayer, text)

		if (sayType == 4) then
			-- Student messages
		elseif (sayType == 3) then
			-- Coach messages
		elseif (sayType == 2) and PlayerSay.teamChatCallback then
			local status, ret = pcall(PlayerSay.teamChatCallback, cmdPlayer, text)
			if not status then
				print('[PlayerSay] TeamChat callback failure: ' .. ret)
			end
		elseif PlayerSay.allChatCallback then
			local status, ret = pcall(PlayerSay.allChatCallback, cmdPlayer, text)
			if not status then
				print('[PlayerSay] AllChat callback failure: ' .. ret)
			end
		end

		
	end, 'player say', 0)
end

function PlayerSay:TeamChatHandler(fun)
	PlayerSay.teamChatCallback = fun
end
function PlayerSay:AllChatHandler(fun)
	PlayerSay.allChatCallback = fun
end

function PlayerSay:SendConfigToAll(allowTeam, allowAll)
	PlayerSay:SendConfig(-1, allowTeam, allowAll)
end
function PlayerSay:SendConfig(pid, allowTeam, allowAll)
	local obj = {pid=pid, allowTeam=allowTeam, allowAll=allowAll}
	FireGameEvent("player_say_config", obj)
end


-- DataManager.lua
-- Server-side data management and persistence using DataStore

local DataManager = {}

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local Constants = require(script.Parent.Parent.shared:WaitForChild("Constants"))
local Utilities = require(script.Parent.Parent.shared:WaitForChild("Utilities"))

-- Create DataStore
local playerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
local buildingsDataStore = DataStoreService:GetDataStore("Buildings_v1")

-- ==================== PLAYER DATA ====================

function DataManager.GetPlayerData(player)
	local userId = player.UserId
	local success, data = pcall(function()
		return playerDataStore:GetAsync("Player_" .. userId)
	end)
	
	if success then
		if data then
			Utilities.Log("Loaded data for player: " .. player.Name)
			return data
		else
			Utilities.Log("Creating new data for player: " .. player.Name)
			return DataManager.CreateNewPlayerData(player)
		end
	else
		Utilities.LogError("Failed to load data for player: " .. player.Name)
		return DataManager.CreateNewPlayerData(player)
	end
end

function DataManager.CreateNewPlayerData(player)
	return {
		userId = player.UserId,
		playerName = player.Name,
		level = 1,
		experience = 0,
		resources = Utilities.DeepCopy(Constants.STARTING_RESOURCES),
		buildings = {},
		completedQuests = {},
		playTime = 0,
		joinedDate = os.time(),
		lastSave = os.time()
	}
end

function DataManager.SavePlayerData(player, playerData)
	local userId = player.UserId
	playerData.lastSave = os.time()
	
	local success, err = pcall(function()
		playerDataStore:SetAsync("Player_" .. userId, playerData)
	end)
	
	if success then
		Utilities.Log("Saved data for player: " .. player.Name)
		return true
	else
		Utilities.LogError("Failed to save data for player: " .. player.Name .. " - " .. tostring(err))
		return false
	end
end

-- ==================== BUILDING DATA ====================

function DataManager.SaveBuildings(player, buildingsData)
	local userId = player.UserId
	
	local success, err = pcall(function()
		buildingsDataStore:SetAsync("Buildings_" .. userId, buildingsData)
	end)
	
	if success then
		Utilities.Log("Saved buildings for player: " .. player.Name)
		return true
	else
		Utilities.LogError("Failed to save buildings for player: " .. player.Name)
		return false
	end
end

function DataManager.LoadBuildings(player)
	local userId = player.UserId
	local success, buildings = pcall(function()
		return buildingsDataStore:GetAsync("Buildings_" .. userId)
	end)
	
	if success and buildings then
		Utilities.Log("Loaded buildings for player: " .. player.Name)
		return buildings
	else
		Utilities.Log("No buildings found for player: " .. player.Name)
		return {}
	end
end

-- ==================== RESOURCE UPDATES ====================

function DataManager.UpdateResources(player, playerData, resourceUpdates)
	for resource, amount in pairs(resourceUpdates) do
		if playerData.resources[resource] then
			local newAmount = playerData.resources[resource] + amount
			-- Clamp to max resources
			newAmount = Utilities.Clamp(newAmount, 0, Constants.MAX_RESOURCES[resource])
			playerData.resources[resource] = newAmount
		end
	end
	
	DataManager.SavePlayerData(player, playerData)
	return playerData
end

-- ==================== LEADERBOARD ====================

function DataManager.GetLeaderboardData(limit)
	limit = limit or 10
	local success, orderedStore = pcall(function()
		return DataStoreService:GetOrderedDataStore("PlayerLevels_v1")
	end)
	
	if not success then
		Utilities.LogError("Failed to access leaderboard data")
		return {}
	end
	
	local success2, pages = pcall(function()
		return orderedStore:GetSortedAsync(false, limit)
	end)
	
	if not success2 then
		Utilities.LogError("Failed to retrieve sorted data")
		return {}
	end
	
	local leaderboard = {}
	local page = pages:GetCurrentPage()
	
	for rank, data in ipairs(page) do
		table.insert(leaderboard, {
			rank = rank,
			userId = data.key,
			level = data.value
		})
	end
	
	return leaderboard
end

-- ==================== LEVEL SYSTEM ====================

function DataManager.AddExperience(player, playerData, amount)
	playerData.experience = playerData.experience + amount
	
	local xpPerLevel = Constants.XP_PER_LEVEL
	while playerData.experience >= xpPerLevel do
		playerData.experience = playerData.experience - xpPerLevel
		playerData.level = playerData.level + 1
		Utilities.Log("Player " .. player.Name .. " reached level " .. playerData.level)
	end
	
	DataManager.SavePlayerData(player, playerData)
	return playerData
end

-- ==================== QUEST TRACKING ====================

function DataManager.CompleteQuest(player, playerData, questId)
	if not table.find(playerData.completedQuests, questId) then
		table.insert(playerData.completedQuests, questId)
		DataManager.SavePlayerData(player, playerData)
		return true
	end
	return false
end

function DataManager.HasCompletedQuest(playerData, questId)
	return table.find(playerData.completedQuests, questId) ~= nil
end

-- ==================== CLEANUP ====================

function DataManager.OnPlayerLeaving(player)
	-- This should be called when a player leaves to save their data
	Utilities.Log("Player leaving: " .. player.Name)
end

return DataManager

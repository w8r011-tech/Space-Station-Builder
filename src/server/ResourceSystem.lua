-- ResourceSystem.lua
-- Server-side resource generation and management

local ResourceSystem = {}

local Constants = require(script.Parent.Parent.shared:WaitForChild("Constants"))
local Utilities = require(script.Parent.Parent.shared:WaitForChild("Utilities"))

-- ==================== RESOURCE GENERATION ====================

function ResourceSystem.CalculateResourceProduction(buildings)
	local production = {}
	
	for resourceName, _ in pairs(Constants.RESOURCES) do
		production[resourceName] = 0
	end
	
	for buildingName, buildingData in pairs(buildings) do
		local config = Constants.BUILDING_CONFIG[buildingName]
		if config and config.produces then
			for resource, amount in pairs(config.produces) do
				if buildingData.level and buildingData.level > 0 then
					-- Increase production based on level
					local levelMultiplier = 1 + (buildingData.level - 1) * 0.2
					production[resource] = (production[resource] or 0) + (amount * levelMultiplier)
				end
			end
		end
	end
	
	return production
end

function ResourceSystem.CalculateResourceConsumption()
	local consumption = {}
	
	for resourceName, rate in pairs(Constants.CONSUMPTION_RATES) do
		consumption[resourceName] = rate
	end
	
	return consumption
end

function ResourceSystem.UpdateResources(playerData, buildings, deltaTime)
	deltaTime = deltaTime or 1
	
	local production = ResourceSystem.CalculateResourceProduction(buildings)
	local consumption = ResourceSystem.CalculateResourceConsumption()
	
	for resource, _ in pairs(Constants.RESOURCES) do
		local netChange = (production[resource] or 0) - (consumption[resource] or 0)
		netChange = netChange * deltaTime
		
		local newAmount = playerData.resources[resource] + netChange
		newAmount = Utilities.Clamp(newAmount, 0, Constants.MAX_RESOURCES[resource])
		playerData.resources[resource] = newAmount
	end
	
	return playerData
end

-- ==================== BUILDING MANAGEMENT ====================

function ResourceSystem.CanBuildBuilding(playerData, buildingName)
	local config = Constants.BUILDING_CONFIG[buildingName]
	if not config then return false, "Building not found" end
	
	-- Check if player has enough resources
	if config.cost then
		for resource, amount in pairs(config.cost) do
			if playerData.resources[resource] < amount then
				return false, "Not enough " .. resource
			end
		end
	end
	
	return true, "Can build"
end

function ResourceSystem.BuildBuilding(playerData, buildingName)
	local config = Constants.BUILDING_CONFIG[buildingName]
	if not config then return false end
	
	-- Deduct resources
	if config.cost then
		for resource, amount in pairs(config.cost) do
			playerData.resources[resource] = playerData.resources[resource] - amount
		end
	end
	
	-- Create new building
	local buildingId = #playerData.buildings + 1
	playerData.buildings[buildingName .. "_" .. buildingId] = {
		name = buildingName,
		level = 1,
		builtAt = os.time()
	}
	
	return true, buildingId
end

function ResourceSystem.UpgradeBuilding(playerData, buildingKey)
	local building = playerData.buildings[buildingKey]
	if not building then return false, "Building not found" end
	
	local config = Constants.BUILDING_CONFIG[building.name]
	if not config then return false, "Building config not found" end
	
	-- Check max level
	if building.level >= config.maxLevel then
		return false, "Building already at max level"
	end
	
	-- Calculate upgrade cost (increases with level)
	local upgradeCost = {}
	for resource, baseCost in pairs(config.cost) do
		upgradeCost[resource] = baseCost * building.level
	end
	
	-- Check resources
	for resource, amount in pairs(upgradeCost) do
		if playerData.resources[resource] < amount then
			return false, "Not enough " .. resource
		end
	end
	
	-- Deduct resources
	for resource, amount in pairs(upgradeCost) do
		playerData.resources[resource] = playerData.resources[resource] - amount
	end
	
	-- Upgrade building
	building.level = building.level + 1
	building.upgradedAt = os.time()
	
	return true, "Building upgraded to level " .. building.level
end

-- ==================== STORAGE CALCULATION ====================

function ResourceSystem.GetTotalStorage(buildings)
	local totalStorage = 500 -- Base storage
	
	for _, buildingData in pairs(buildings) do
		if buildingData.name == Constants.BUILDINGS.STORAGE then
			local config = Constants.BUILDING_CONFIG[Constants.BUILDINGS.STORAGE]
			if config.storage_bonus then
				totalStorage = totalStorage + (config.storage_bonus * buildingData.level)
			end
		end
	end
	
	return totalStorage
end

function ResourceSystem.UpdateMaxResources(buildings)
	local maxStorage = ResourceSystem.GetTotalStorage(buildings)
	
	for resource, _ in pairs(Constants.RESOURCES) do
		Constants.MAX_RESOURCES[resource] = maxStorage
	end
end

-- ==================== DANGER EVENTS ====================

function ResourceSystem.TriggerDangerEvent(playerData, eventType)
	local effects = {
		["Meteor Shower"] = {[Constants.RESOURCES.MATERIALS] = -20},
		["Solar Flare"] = {[Constants.RESOURCES.ENERGY] = -50},
		["Power Failure"] = {[Constants.RESOURCES.ENERGY] = -100},
		["Oxygen Leak"] = {[Constants.RESOURCES.OXYGEN] = -75},
		["Hull Breach"] = {[Constants.RESOURCES.OXYGEN] = -50, [Constants.RESOURCES.ENERGY] = -30}
	}
	
	if effects[eventType] then
		for resource, amount in pairs(effects[eventType]) do
			playerData.resources[resource] = Utilities.Clamp(
				playerData.resources[resource] + amount,
				0,
				Constants.MAX_RESOURCES[resource]
			)
		end
		return true
	end
	
	return false
end

return ResourceSystem

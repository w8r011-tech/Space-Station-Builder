-- Constants.lua
-- Global constants and configuration for Space Station Builder

local Constants = {}

-- ==================== RESOURCES ====================
Constants.RESOURCES = {
	OXYGEN = "Oxygen",
	ENERGY = "Energy",
	FOOD = "Food",
	MATERIALS = "Materials"
}

-- Starting resources for new players
Constants.STARTING_RESOURCES = {
	[Constants.RESOURCES.OXYGEN] = 100,
	[Constants.RESOURCES.ENERGY] = 100,
	[Constants.RESOURCES.FOOD] = 50,
	[Constants.RESOURCES.MATERIALS] = 50
}

-- Maximum resource storage
Constants.MAX_RESOURCES = {
	[Constants.RESOURCES.OXYGEN] = 1000,
	[Constants.RESOURCES.ENERGY] = 1000,
	[Constants.RESOURCES.FOOD] = 500,
	[Constants.RESOURCES.MATERIALS] = 500
}

-- Resource consumption rates (per second)
Constants.CONSUMPTION_RATES = {
	[Constants.RESOURCES.OXYGEN] = 0.5,
	[Constants.RESOURCES.ENERGY] = 0.3,
	[Constants.RESOURCES.FOOD] = 0.1
}

-- Resource generation rates (per second)
Constants.GENERATION_RATES = {
	[Constants.RESOURCES.OXYGEN] = 1.0,
	[Constants.RESOURCES.ENERGY] = 0.8,
	[Constants.RESOURCES.FOOD] = 0.2,
	[Constants.RESOURCES.MATERIALS] = 0.3
}

-- ==================== BUILDINGS ====================
Constants.BUILDINGS = {
	LIFE_SUPPORT = "LifeSupport",
	POWER_PLANT = "PowerPlant",
	FARM = "Farm",
	STORAGE = "Storage",
	RESEARCH_LAB = "ResearchLab",
	MINING_FACILITY = "MiningFacility"
}

-- Building costs and effects
Constants.BUILDING_CONFIG = {
	[Constants.BUILDINGS.LIFE_SUPPORT] = {
		cost = {Materials = 100},
		produces = {[Constants.RESOURCES.OXYGEN] = 2.0},
		level = 1,
		maxLevel = 5,
		description = "Generates oxygen for the station"
	},
	[Constants.BUILDINGS.POWER_PLANT] = {
		cost = {Materials = 150},
		produces = {[Constants.RESOURCES.ENERGY] = 2.5},
		level = 1,
		maxLevel = 5,
		description = "Generates energy for operations"
	},
	[Constants.BUILDINGS.FARM] = {
		cost = {Materials = 80},
		produces = {[Constants.RESOURCES.FOOD] = 1.5},
		level = 1,
		maxLevel = 5,
		description = "Grows food for the crew"
	},
	[Constants.BUILDINGS.STORAGE] = {
		cost = {Materials = 120},
		storage_bonus = 500,
		level = 1,
		maxLevel = 10,
		description = "Increases resource storage capacity"
	},
	[Constants.BUILDINGS.RESEARCH_LAB] = {
		cost = {Materials = 200},
		level = 1,
		maxLevel = 3,
		description = "Unlocks new technologies"
	},
	[Constants.BUILDINGS.MINING_FACILITY] = {
		cost = {Materials = 250},
		produces = {[Constants.RESOURCES.MATERIALS] = 3.0},
		level = 1,
		maxLevel = 5,
		description = "Mines materials from asteroids"
	}
}

-- ==================== PLANETS ====================
Constants.PLANETS = {
	MERCURY = "Mercury",
	VENUS = "Venus",
	MARS = "Mars",
	JUPITER = "Jupiter",
	SATURN = "Saturn"
}

Constants.PLANET_RESOURCES = {
	[Constants.PLANETS.MERCURY] = {Materials = 30, difficulty = 1},
	[Constants.PLANETS.VENUS] = {Materials = 50, Food = 20, difficulty = 2},
	[Constants.PLANETS.MARS] = {Materials = 100, Food = 50, difficulty = 3},
	[Constants.PLANETS.JUPITER] = {Materials = 200, difficulty = 4},
	[Constants.PLANETS.SATURN] = {Materials = 300, difficulty = 5}
}

-- ==================== QUESTS ====================
Constants.QUEST_TYPES = {
	GATHER = "Gather",
	BUILD = "Build",
	EXPLORE = "Explore",
	SURVIVE = "Survive"
}

-- ==================== ECONOMY ====================
Constants.BASE_PRICES = {
	[Constants.RESOURCES.OXYGEN] = 10,
	[Constants.RESOURCES.ENERGY] = 15,
	[Constants.RESOURCES.FOOD] = 20,
	[Constants.RESOURCES.MATERIALS] = 25
}

-- Price fluctuation limits
Constants.PRICE_FLUCTUATION = 0.3 -- 30% max change

-- ==================== EVENTS ====================
Constants.DANGER_EVENTS = {
	"Meteor Shower",
	"Solar Flare",
	"Power Failure",
	"Oxygen Leak",
	"Hull Breach"
}

-- ==================== TIME ====================
Constants.DAY_LENGTH = 1200 -- 20 minutes in game
Constants.RESOURCE_UPDATE_INTERVAL = 1 -- Update resources every 1 second

-- ==================== LEVELS ====================
Constants.MAX_LEVEL = 100
Constants.XP_PER_LEVEL = 1000

return Constants

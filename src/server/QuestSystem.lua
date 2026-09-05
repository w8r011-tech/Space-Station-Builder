-- QuestSystem.lua
-- Quest management and progression system

local QuestSystem = {}

local Constants = require(script.Parent.Parent.shared:WaitForChild("Constants"))
local Utilities = require(script.Parent.Parent.shared:WaitForChild("Utilities"))

-- Define available quests
QuestSystem.Quests = {
	TUTORIAL_1 = {
		id = "TUTORIAL_1",
		title = "Welcome to Space Station",
		description = "Build your first Life Support system",
		type = Constants.QUEST_TYPES.BUILD,
		target = Constants.BUILDINGS.LIFE_SUPPORT,
		targetAmount = 1,
		reward = {experience = 100, resources = {Materials = 50}},
		difficulty = 1
	},
	
	TUTORIAL_2 = {
		id = "TUTORIAL_2",
		title = "Power Your Station",
		description = "Build a Power Plant",
		type = Constants.QUEST_TYPES.BUILD,
		target = Constants.BUILDINGS.POWER_PLANT,
		targetAmount = 1,
		reward = {experience = 150, resources = {Materials = 75}},
		difficulty = 1
	},
	
	GATHER_MATERIALS = {
		id = "GATHER_MATERIALS",
		title = "Gather Resources",
		description = "Collect 100 Materials",
		type = Constants.QUEST_TYPES.GATHER,
		target = Constants.RESOURCES.MATERIALS,
		targetAmount = 100,
		reward = {experience = 200, resources = {Energy = 100}},
		difficulty = 2
	},
	
	BUILD_FARM = {
		id = "BUILD_FARM",
		title = "Establish Agriculture",
		description = "Build a Farm",
		type = Constants.QUEST_TYPES.BUILD,
		target = Constants.BUILDINGS.FARM,
		targetAmount = 1,
		reward = {experience = 250, resources = {Food = 200}},
		difficulty = 2
	},
	
	EXPLORE_MERCURY = {
		id = "EXPLORE_MERCURY",
		title = "Explore Mercury",
		description = "Visit Mercury and gather resources",
		type = Constants.QUEST_TYPES.EXPLORE,
		target = Constants.PLANETS.MERCURY,
		targetAmount = 1,
		reward = {experience = 300, resources = {Materials = 150}},
		difficulty = 2
	},
	
	SURVIVE_WEEK = {
		id = "SURVIVE_WEEK",
		title = "One Week Survivor",
		description = "Maintain your station for 7 in-game days without critical failures",
		type = Constants.QUEST_TYPES.SURVIVE,
		targetAmount = 7,
		reward = {experience = 500, resources = {Materials = 300, Energy = 200}},
		difficulty = 3
	},
	
	UPGRADE_BUILDINGS = {
		id = "UPGRADE_BUILDINGS",
		title = "Enhance Infrastructure",
		description = "Upgrade 3 buildings to level 2",
		type = Constants.QUEST_TYPES.BUILD,
		target = "upgrade",
		targetAmount = 3,
		reward = {experience = 400, resources = {Materials = 250}},
		difficulty = 3
	},
	
	BUILD_RESEARCH_LAB = {
		id = "BUILD_RESEARCH_LAB",
		title = "Unlock Technology",
		description = "Build a Research Lab",
		type = Constants.QUEST_TYPES.BUILD,
		target = Constants.BUILDINGS.RESEARCH_LAB,
		targetAmount = 1,
		reward = {experience = 350, resources = {Materials = 200}},
		difficulty = 3
	}
}

-- ==================== QUEST TRACKING ====================

function QuestSystem.GetActiveQuests(playerData)
	local activeQuests = {}
	
	for questId, questData in pairs(QuestSystem.Quests) do
		if not Utilities.FindInArray(playerData.completedQuests, questId) then
			table.insert(activeQuests, {
				id = questId,
				data = questData,
				progress = QuestSystem.GetQuestProgress(playerData, questId)
			})
		end
	end
	
	return activeQuests
end

function QuestSystem.GetCompletedQuests(playerData)
	local completed = {}
	
	for _, questId in ipairs(playerData.completedQuests) do
		if QuestSystem.Quests[questId] then
			table.insert(completed, QuestSystem.Quests[questId])
		end
	end
	
	return completed
end

-- ==================== QUEST PROGRESS ====================

function QuestSystem.GetQuestProgress(playerData, questId)
	local quest = QuestSystem.Quests[questId]
	if not quest then return 0 end
	
	if quest.type == Constants.QUEST_TYPES.GATHER then
		-- Check resource amount
		return playerData.resources[quest.target] or 0
	elseif quest.type == Constants.QUEST_TYPES.BUILD then
		-- Count buildings of target type
		local count = 0
		for _, building in pairs(playerData.buildings) do
			if building.name == quest.target then
				count = count + 1
			end
		end
		return count
	end
	
	return 0
end

function QuestSystem.IsQuestComplete(playerData, questId)
	local quest = QuestSystem.Quests[questId]
	if not quest then return false end
	
	local progress = QuestSystem.GetQuestProgress(playerData, questId)
	return progress >= quest.targetAmount
end

-- ==================== QUEST COMPLETION ====================

function QuestSystem.CompleteQuest(playerData, questId)
	local quest = QuestSystem.Quests[questId]
	if not quest then return false, "Quest not found" end
	
	if not QuestSystem.IsQuestComplete(playerData, questId) then
		return false, "Quest not complete"
	end
	
	if Utilities.FindInArray(playerData.completedQuests, questId) then
		return false, "Quest already completed"
	end
	
	-- Mark as completed
	table.insert(playerData.completedQuests, questId)
	
	-- Apply rewards
	if quest.reward then
		if quest.reward.experience then
			playerData.experience = playerData.experience + quest.reward.experience
		end
		
		if quest.reward.resources then
			for resource, amount in pairs(quest.reward.resources) do
				playerData.resources[resource] = 
					(playerData.resources[resource] or 0) + amount
			end
		end
	end
	
	Utilities.Log("Player completed quest: " .. questId)
	return true, "Quest completed!"
end

-- ==================== QUEST SUGGESTIONS ====================

function QuestSystem.GetSuggestedQuests(playerData, count)
	count = count or 3
	local suggested = {}
	
	for questId, questData in pairs(QuestSystem.Quests) do
		if not Utilities.FindInArray(playerData.completedQuests, questId) then
			table.insert(suggested, {
				id = questId,
				data = questData,
				difficulty = questData.difficulty,
				progress = QuestSystem.GetQuestProgress(playerData, questId)
			})
		end
	end
	
	-- Sort by difficulty and progress
	table.sort(suggested, function(a, b)
		if a.difficulty ~= b.difficulty then
			return a.difficulty < b.difficulty
		end
		return a.progress > b.progress
	end)
	
	-- Return top count quests
	local result = {}
	for i = 1, math.min(count, #suggested) do
		table.insert(result, suggested[i])
	end
	
	return result
end

return QuestSystem

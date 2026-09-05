-- GameManager.lua
-- Main server-side game logic and orchestration

local GameManager = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Parent.shared:WaitForChild("Constants"))
local Utilities = require(script.Parent.Parent.shared:WaitForChild("Utilities"))
local DataManager = require(script.Parent:WaitForChild("DataManager"))
local ResourceSystem = require(script.Parent:WaitForChild("ResourceSystem"))
local QuestSystem = require(script.Parent:WaitForChild("QuestSystem"))
local EconomySystem = require(script.Parent:WaitForChild("EconomySystem"))

-- ==================== PLAYER DATA STORAGE ====================

local playerSessions = {}

function GameManager.OnPlayerAdded(player)
    Utilities.Log("Player joined: " .. player.Name)
    
    -- Load player data
    local playerData = DataManager.GetPlayerData(player)
    playerSessions[player.UserId] = {
        player = player,
        data = playerData,
        buildings = DataManager.LoadBuildings(player),
        lastUpdate = os.time()
    }
    
    -- Send initial data to client
    local event = Instance.new("RemoteEvent")
    event.Name = "PlayerDataLoaded"
    event.Parent = player
    event:FireClient(player, playerData)
end

function GameManager.OnPlayerRemoving(player)
    Utilities.Log("Player left: " .. player.Name)
    
    local session = playerSessions[player.UserId]
    if session then
        -- Save player data
        DataManager.SavePlayerData(player, session.data)
        DataManager.SaveBuildings(player, session.buildings)
        playerSessions[player.UserId] = nil
    end
end

-- ==================== GAME LOOP ====================

function GameManager.UpdateGameLoop()
    RunService.Heartbeat:Connect(function(deltaTime)
        -- Update all player sessions
        for userId, session in pairs(playerSessions) do
            if session.player and session.player.Parent then
                -- Update resources every second
                if os.time() - session.lastUpdate >= Constants.RESOURCE_UPDATE_INTERVAL then
                    ResourceSystem.UpdateResources(session.data, session.buildings, Constants.RESOURCE_UPDATE_INTERVAL)
                    session.lastUpdate = os.time()
                end
                
                -- Check for danger events (randomly)
                if math.random(1, 1000) > 995 then
                    local events = Constants.DANGER_EVENTS
                    local randomEvent = events[math.random(1, #events)]
                    ResourceSystem.TriggerDangerEvent(session.data, randomEvent)
                    Utilities.Log("Danger event triggered: " .. randomEvent)
                end
            end
        end
        
        -- Update market prices
        EconomySystem.UpdatePricesIfNeeded()
    end)
end

-- ==================== REMOTE FUNCTIONS ====================

function GameManager.SetupRemoteFunctions()
    local ServerScriptService = game:GetService("ServerScriptService")
    
    -- Create RemoteEvent for resource updates
    local resourceUpdateEvent = Instance.new("RemoteEvent")
    resourceUpdateEvent.Name = "ResourceUpdate"
    resourceUpdateEvent.Parent = ServerScriptService
    
    -- Create RemoteFunction for building
    local buildingFunction = Instance.new("RemoteFunction")
    buildingFunction.Name = "BuildBuilding"
    buildingFunction.Parent = ServerScriptService
    
    buildingFunction.OnServerInvoke = function(player, buildingName)
        local session = playerSessions[player.UserId]
        if not session then return false, "Session not found" end
        
        local canBuild, message = ResourceSystem.CanBuildBuilding(session.data, buildingName)
        if not canBuild then
            return false, message
        end
        
        local success, buildingId = ResourceSystem.BuildBuilding(session.data, buildingName)
        if success then
            DataManager.SavePlayerData(player, session.data)
            return true, "Building constructed: " .. buildingName
        else
            return false, "Failed to build"
        end
    end
    
    -- Create RemoteFunction for quests
    local questFunction = Instance.new("RemoteFunction")
    questFunction.Name = "CompleteQuest"
    questFunction.Parent = ServerScriptService
    
    questFunction.OnServerInvoke = function(player, questId)
        local session = playerSessions[player.UserId]
        if not session then return false, "Session not found" end
        
        local success, message = QuestSystem.CompleteQuest(session.data, questId)
        if success then
            DataManager.SavePlayerData(player, session.data)
            return true, message
        else
            return false, message
        end
    end
end

-- ==================== INITIALIZATION ====================

function GameManager.Initialize()
    Utilities.Log("Initializing GameManager")
    
    -- Connect player events
    Players.PlayerAdded:Connect(GameManager.OnPlayerAdded)
    Players.PlayerRemoving:Connect(GameManager.OnPlayerRemoving)
    
    -- Setup remote functions
    GameManager.SetupRemoteFunctions()
    
    -- Start game loop
    GameManager.UpdateGameLoop()
    
    -- Load existing players (in case of script restart)
    for _, player in ipairs(Players:GetPlayers()) do
        GameManager.OnPlayerAdded(player)
    end
    
    Utilities.Log("GameManager initialized successfully")
end

-- Initialize on script start
if RunService:IsServer() then
    GameManager.Initialize()
end

return GameManager

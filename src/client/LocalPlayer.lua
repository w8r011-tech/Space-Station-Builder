-- LocalPlayer.lua
-- Client-side player controller

local LocalPlayer = {}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== PLAYER DATA ====================

local playerData = {}

function LocalPlayer.LoadPlayerData()
    local event = player:WaitForChild("PlayerDataLoaded")
    event.OnClientEvent:Connect(function(data)
        playerData = data
        Utilities.Log("Player data loaded")
    end)
end

function LocalPlayer.GetPlayerData()
    return playerData
end

function LocalPlayer.UpdatePlayerData(newData)
    playerData = newData
end

-- ==================== BUILDING ====================

function LocalPlayer.RequestBuild(buildingName)
    local buildingFunction = game:GetService("ServerScriptService"):WaitForChild("BuildBuilding")
    local success, message = buildingFunction:InvokeServer(buildingName)
    
    if success then
        print("✓ " .. message)
        return true
    else
        print("✗ " .. message)
        return false
    end
end

-- ==================== QUESTS ====================

function LocalPlayer.RequestCompleteQuest(questId)
    local questFunction = game:GetService("ServerScriptService"):WaitForChild("CompleteQuest")
    local success, message = questFunction:InvokeServer(questId)
    
    if success then
        print("✓ " .. message)
        return true
    else
        print("✗ " .. message)
        return false
    end
end

-- ==================== UI UPDATES ====================

function LocalPlayer.UpdateUI()
    RunService.Heartbeat:Connect(function()
        if playerData and playerData.resources then
            -- Update resource displays
            -- This would connect to UI scripts
        end
    end)
end

-- ==================== INITIALIZATION ====================

function LocalPlayer.Initialize()
    print("Initializing LocalPlayer")
    LocalPlayer.LoadPlayerData()
    LocalPlayer.UpdateUI()
    print("LocalPlayer initialized")
end

-- Initialize on client start
if RunService:IsClient() then
    LocalPlayer.Initialize()
end

return LocalPlayer

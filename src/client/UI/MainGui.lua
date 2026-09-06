-- MainGui.lua
-- Main menu and HUD system

local MainGui = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Constants = require(game.ReplicatedStorage:WaitForChild("Constants"))
local Utilities = require(game.ReplicatedStorage:WaitForChild("Utilities"))

-- ==================== CREATE MAIN HUD ====================

function MainGui.CreateMainHUD()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MainHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = screenGui
    
    -- Station name
    local stationName = Instance.new("TextLabel")
    stationName.Name = "StationName"
    stationName.Size = UDim2.new(0, 300, 1, 0)
    stationName.Position = UDim2.new(0, 20, 0, 0)
    stationName.BackgroundTransparency = 1
    stationName.TextColor3 = Color3.fromRGB(0, 200, 255)
    stationName.TextSize = 24
    stationName.Font = Enum.Font.GothamBold
    stationName.TextXAlignment = Enum.TextXAlignment.Left
    stationName.Text = "🚀 SPACE STATION ALPHA"
    stationName.Parent = titleBar
    
    -- Player level and experience
    local levelInfo = Instance.new("TextLabel")
    levelInfo.Name = "LevelInfo"
    levelInfo.Size = UDim2.new(0, 200, 1, 0)
    levelInfo.Position = UDim2.new(1, -220, 0, 0)
    levelInfo.BackgroundTransparency = 1
    levelInfo.TextColor3 = Color3.fromRGB(255, 255, 0)
    levelInfo.TextSize = 14
    levelInfo.Font = Enum.Font.Gotham
    levelInfo.TextXAlignment = Enum.TextXAlignment.Right
    levelInfo.Text = "Level: 1 | XP: 0"
    levelInfo.Parent = titleBar
    
    -- Center status display
    local statusPanel = Instance.new("Frame")
    statusPanel.Name = "StatusPanel"
    statusPanel.Size = UDim2.new(0, 400, 0, 100)
    statusPanel.Position = UDim2.new(0.5, -200, 1, -120)
    statusPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    statusPanel.BorderSizePixel = 2
    statusPanel.BorderColor3 = Color3.fromRGB(0, 255, 150)
    statusPanel.Parent = screenGui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = statusPanel
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -10, 1, -10)
    statusText.Position = UDim2.new(0, 5, 0, 5)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusText.TextSize = 12
    statusText.Font = Enum.Font.Gotham
    statusText.TextWrapped = true
    statusText.Text = "🟢 Station Status: OPERATIONAL\nAll systems online"
    statusText.Parent = statusPanel
    
    return screenGui
end

function MainGui.UpdateLevelInfo(playerData)
    local gui = playerGui:FindFirstChild("MainHUD")
    if not gui then return end
    
    local titleBar = gui:FindFirstChild("TitleBar")
    if titleBar then
        local levelInfo = titleBar:FindFirstChild("LevelInfo")
        if levelInfo then
            levelInfo.Text = "Level: " .. playerData.level .. " | XP: " .. playerData.experience
        end
    end
end

-- ==================== CREATE MENU BUTTONS ====================

function MainGui.CreateMenuButtons()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MenuButtons"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local buttonSize = 40
    local spacing = 50
    local startX = 20
    local startY = 80
    
    -- Buttons configuration
    local buttons = {
        {name = "Build", icon = "🏗️", color = Color3.fromRGB(200, 100, 0)},
        {name = "Explore", icon = "🌍", color = Color3.fromRGB(0, 150, 255)},
        {name = "Shop", icon = "🏪", color = Color3.fromRGB(255, 100, 200)},
        {name = "Quests", icon = "📋", color = Color3.fromRGB(0, 200, 100)},
        {name = "Settings", icon = "⚙️", color = Color3.fromRGB(150, 150, 150)}
    }
    
    for i, buttonData in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = buttonData.name .. "Button"
        button.Size = UDim2.new(0, buttonSize, 0, buttonSize)
        button.Position = UDim2.new(0, startX, 0, startY + (i-1) * spacing)
        button.BackgroundColor3 = buttonData.color
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 20
        button.Font = Enum.Font.GothamBold
        button.Text = buttonData.icon
        button.Parent = screenGui
        
        -- Corner
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            print(buttonData.name .. " button clicked")
            -- Handle button click
        end)
    end
    
    return screenGui
end

-- ==================== INITIALIZATION ====================

function MainGui.Initialize()
    MainGui.CreateMainHUD()
    MainGui.CreateMenuButtons()
    print("Main GUI initialized")
end

if RunService:IsClient() then
    MainGui.Initialize()
end

return MainGui

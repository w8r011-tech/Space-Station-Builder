-- BuildGui.lua
-- Client-side building interface

local BuildGui = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Constants = require(game.ReplicatedStorage:WaitForChild("Constants"))
local Utilities = require(game.ReplicatedStorage:WaitForChild("Utilities"))

-- ==================== CREATE BUILD UI ====================

function BuildGui.CreateBuildFrame()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BuildGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 350, 0, 400)
    container.Position = UDim2.new(1, -370, 0, 20)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    container.BorderSizePixel = 2
    container.BorderColor3 = Color3.fromRGB(200, 100, 0)
    container.Parent = screenGui
    
    -- Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Text = "🏗️ BUILD STATION"
    title.BorderSizePixel = 0
    title.Parent = container
    
    -- Scroll frame for buildings
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -10, 1, -50)
    scrollFrame.Position = UDim2.new(0, 5, 0, 45)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = container
    
    -- UIGridLayout
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(1, -10, 0, 80)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    gridLayout.Parent = scrollFrame
    
    return screenGui, scrollFrame
end

function BuildGui.CreateBuildingButton(building, scrollFrame)
    local config = Constants.BUILDING_CONFIG[building]
    if not config then return end
    
    local button = Instance.new("TextButton")
    button.Name = building
    button.Size = UDim2.new(1, -10, 0, 70)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(100, 150, 255)
    button.Parent = scrollFrame
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    
    -- Building name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -10, 0, 20)
    nameLabel.Position = UDim2.new(0, 5, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = building
    nameLabel.Parent = button
    
    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -10, 0, 15)
    descLabel.Position = UDim2.new(0, 5, 0, 25)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Text = config.description
    descLabel.Parent = button
    
    -- Cost
    local costLabel = Instance.new("TextLabel")
    costLabel.Name = "Cost"
    costLabel.Size = UDim2.new(1, -10, 0, 15)
    costLabel.Position = UDim2.new(0, 5, 0, 42)
    costLabel.BackgroundTransparency = 1
    costLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    costLabel.TextSize = 10
    costLabel.Font = Enum.Font.Gotham
    costLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local costText = ""
    if config.cost then
        for resource, amount in pairs(config.cost) do
            costText = costText .. resource .. ": " .. amount .. " | "
        end
    end
    costLabel.Text = "Cost: " .. costText
    costLabel.Parent = button
    
    -- Build button click
    button.MouseButton1Click:Connect(function()
        BuildGui.RequestBuild(building)
    end)
    
    return button
end

function BuildGui.RequestBuild(buildingName)
    local buildingFunction = game:GetService("ServerScriptService"):FindFirstChild("BuildBuilding")
    if not buildingFunction then
        warn("BuildBuilding function not found")
        return
    end
    
    local success, message = buildingFunction:InvokeServer(buildingName)
    print(message)
end

-- ==================== INITIALIZATION ====================

function BuildGui.Initialize()
    local screenGui, scrollFrame = BuildGui.CreateBuildFrame()
    
    -- Add all buildings
    for building, _ in pairs(Constants.BUILDINGS) do
        BuildGui.CreateBuildingButton(building, scrollFrame)
    end
    
    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollFrame.UIGridLayout.AbsoluteContentSize.Y)
    
    print("Build GUI initialized")
end

if RunService:IsClient() then
    BuildGui.Initialize()
end

return BuildGui

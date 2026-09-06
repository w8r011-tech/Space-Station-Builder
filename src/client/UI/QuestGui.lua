-- QuestGui.lua
-- Client-side quest display interface

local QuestGui = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Constants = require(game.ReplicatedStorage:WaitForChild("Constants"))
local Utilities = require(game.ReplicatedStorage:WaitForChild("Utilities"))

-- ==================== CREATE QUEST UI ====================

function QuestGui.CreateQuestFrame()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "QuestGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 350, 0, 400)
    container.Position = UDim2.new(0.5, -175, 1, -420)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    container.BorderSizePixel = 2
    container.BorderColor3 = Color3.fromRGB(0, 255, 100)
    container.Parent = screenGui
    
    -- Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Text = "📋 ACTIVE QUESTS"
    title.BorderSizePixel = 0
    title.Parent = container
    
    -- Scroll frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -10, 1, -50)
    scrollFrame.Position = UDim2.new(0, 5, 0, 45)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = container
    
    -- UIListLayout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    return screenGui, scrollFrame
end

function QuestGui.CreateQuestItem(quest, scrollFrame)
    local questFrame = Instance.new("Frame")
    questFrame.Name = quest.id
    questFrame.Size = UDim2.new(1, -10, 0, 70)
    questFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    questFrame.BorderSizePixel = 1
    questFrame.BorderColor3 = Color3.fromRGB(100, 200, 100)
    questFrame.Parent = scrollFrame
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = questFrame
    
    -- Quest title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = quest.title or quest.data.title
    titleLabel.Parent = questFrame
    
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
    descLabel.Text = quest.data.description
    descLabel.Parent = questFrame
    
    -- Progress
    local progressLabel = Instance.new("TextLabel")
    progressLabel.Name = "Progress"
    progressLabel.Size = UDim2.new(1, -10, 0, 15)
    progressLabel.Position = UDim2.new(0, 5, 0, 42)
    progressLabel.BackgroundTransparency = 1
    progressLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    progressLabel.TextSize = 10
    progressLabel.Font = Enum.Font.Gotham
    progressLabel.TextXAlignment = Enum.TextXAlignment.Left
    progressLabel.Text = "Progress: " .. (quest.progress or 0) .. "/" .. quest.data.targetAmount
    progressLabel.Parent = questFrame
    
    -- Complete button
    local completeButton = Instance.new("TextButton")
    completeButton.Name = "CompleteBtn"
    completeButton.Size = UDim2.new(0, 60, 0, 20)
    completeButton.Position = UDim2.new(1, -65, 0, 5)
    completeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    completeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    completeButton.TextSize = 10
    completeButton.Font = Enum.Font.GothamBold
    completeButton.Text = "COMPLETE"
    completeButton.Parent = questFrame
    
    -- Corner
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 3)
    btnCorner.Parent = completeButton
    
    completeButton.MouseButton1Click:Connect(function()
        QuestGui.RequestCompleteQuest(quest.id)
    end)
    
    return questFrame
end

function QuestGui.RequestCompleteQuest(questId)
    local questFunction = game:GetService("ServerScriptService"):FindFirstChild("CompleteQuest")
    if not questFunction then
        warn("CompleteQuest function not found")
        return
    end
    
    local success, message = questFunction:InvokeServer(questId)
    print(message)
end

-- ==================== INITIALIZATION ====================

function QuestGui.Initialize()
    local screenGui, scrollFrame = QuestGui.CreateQuestFrame()
    print("Quest GUI initialized")
end

if RunService:IsClient() then
    QuestGui.Initialize()
end

return QuestGui

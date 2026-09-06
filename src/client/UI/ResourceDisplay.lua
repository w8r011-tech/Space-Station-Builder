-- ResourceDisplay.lua
-- Client-side resource display UI

local ResourceDisplay = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Constants = require(game.ReplicatedStorage:WaitForChild("Constants"))
local Utilities = require(game.ReplicatedStorage:WaitForChild("Utilities"))

-- ==================== CREATE UI ====================

function ResourceDisplay.CreateResourceFrame()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ResourceDisplay"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 400, 0, 150)
    container.Position = UDim2.new(0, 20, 0, 20)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    container.BorderSizePixel = 2
    container.BorderColor3 = Color3.fromRGB(0, 150, 255)
    container.Parent = screenGui
    
    -- Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Text = "🚀 STATION RESOURCES"
    title.BorderSizePixel = 0
    title.Parent = container
    
    -- Create resource displays
    local resources = {Constants.RESOURCES.OXYGEN, Constants.RESOURCES.ENERGY, Constants.RESOURCES.FOOD, Constants.RESOURCES.MATERIALS}
    local yOffset = 40
    
    for i, resource in ipairs(resources) do
        local resourceFrame = Instance.new("Frame")
        resourceFrame.Name = resource
        resourceFrame.Size = UDim2.new(1, -10, 0, 25)
        resourceFrame.Position = UDim2.new(0, 5, 0, yOffset)
        resourceFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        resourceFrame.BorderSizePixel = 0
        resourceFrame.Parent = container
        
        -- Resource name
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0, 100, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(200, 200, 255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = resource .. ":"
        label.Parent = resourceFrame
        
        -- Amount
        local amount = Instance.new("TextLabel")
        amount.Name = "Amount"
        amount.Size = UDim2.new(0, 100, 1, 0)
        amount.Position = UDim2.new(1, -100, 0, 0)
        amount.BackgroundTransparency = 1
        amount.TextColor3 = Color3.fromRGB(100, 255, 100)
        amount.TextSize = 12
        amount.Font = Enum.Font.GothamBold
        amount.TextXAlignment = Enum.TextXAlignment.Right
        amount.Text = "0"
        amount.Parent = resourceFrame
        
        yOffset = yOffset + 28
    end
    
    return screenGui
end

-- ==================== UPDATE DISPLAY ====================

function ResourceDisplay.UpdateDisplay(playerData)
    local screenGui = playerGui:FindFirstChild("ResourceDisplay")
    if not screenGui then return end
    
    local container = screenGui:FindFirstChild("Container")
    if not container then return end
    
    for resource, amount in pairs(playerData.resources) do
        local resourceFrame = container:FindFirstChild(resource)
        if resourceFrame then
            local amountLabel = resourceFrame:FindFirstChild("Amount")
            if amountLabel then
                amountLabel.Text = Utilities.FormatNumber(amount)
            end
        end
    end
end

-- ==================== INITIALIZATION ====================

function ResourceDisplay.Initialize()
    ResourceDisplay.CreateResourceFrame()
    
    -- Listen for updates
    local updateEvent = Instance.new("RemoteEvent")
    updateEvent.Name = "ResourceUpdateEvent"
    updateEvent.Parent = player
    
    updateEvent.OnClientEvent:Connect(function(playerData)
        ResourceDisplay.UpdateDisplay(playerData)
    end)
    
    print("Resource Display initialized")
end

if RunService:IsClient() then
    ResourceDisplay.Initialize()
end

return ResourceDisplay

-- ShopGui.lua
-- Client-side shop and trading interface

local ShopGui = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Constants = require(game.ReplicatedStorage:WaitForChild("Constants"))
local Utilities = require(game.ReplicatedStorage:WaitForChild("Utilities"))

-- ==================== CREATE SHOP UI ====================

function ShopGui.CreateShopFrame()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShopGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0.6, 0, 0.8, 0)
    container.Position = UDim2.new(0.2, 0, 0.1, 0)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    container.BorderSizePixel = 2
    container.BorderColor3 = Color3.fromRGB(255, 100, 200)
    container.Visible = false
    container.Parent = screenGui
    
    -- Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(255, 100, 200)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Text = "🛍️ TRADING POST"
    title.BorderSizePixel = 0
    title.Parent = container
    
    -- Left panel - Buy
    local buyPanel = Instance.new("Frame")
    buyPanel.Name = "BuyPanel"
    buyPanel.Size = UDim2.new(0.5, -5, 1, -60)
    buyPanel.Position = UDim2.new(0, 10, 0, 55)
    buyPanel.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
    buyPanel.BorderSizePixel = 1
    buyPanel.BorderColor3 = Color3.fromRGB(100, 200, 100)
    buyPanel.Parent = container
    
    -- Buy title
    local buyTitle = Instance.new("TextLabel")
    buyTitle.Name = "Title"
    buyTitle.Size = UDim2.new(1, 0, 0, 30)
    buyTitle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    buyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyTitle.TextSize = 14
    buyTitle.Font = Enum.Font.GothamBold
    buyTitle.Text = "📥 BUY RESOURCES"
    buyTitle.BorderSizePixel = 0
    buyTitle.Parent = buyPanel
    
    -- Scroll frame for buy items
    local buyScroll = Instance.new("ScrollingFrame")
    buyScroll.Name = "ScrollFrame"
    buyScroll.Size = UDim2.new(1, -10, 1, -40)
    buyScroll.Position = UDim2.new(0, 5, 0, 35)
    buyScroll.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
    buyScroll.BorderSizePixel = 0
    buyScroll.ScrollBarThickness = 8
    buyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    buyScroll.Parent = buyPanel
    
    local buyLayout = Instance.new("UIListLayout")
    buyLayout.Padding = UDim.new(0, 5)
    buyLayout.Parent = buyScroll
    
    -- Right panel - Sell
    local sellPanel = Instance.new("Frame")
    sellPanel.Name = "SellPanel"
    sellPanel.Size = UDim2.new(0.5, -5, 1, -60)
    sellPanel.Position = UDim2.new(0.5, 5, 0, 55)
    sellPanel.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
    sellPanel.BorderSizePixel = 1
    sellPanel.BorderColor3 = Color3.fromRGB(200, 100, 100)
    sellPanel.Parent = container
    
    -- Sell title
    local sellTitle = Instance.new("TextLabel")
    sellTitle.Name = "Title"
    sellTitle.Size = UDim2.new(1, 0, 0, 30)
    sellTitle.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    sellTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    sellTitle.TextSize = 14
    sellTitle.Font = Enum.Font.GothamBold
    sellTitle.Text = "📤 SELL RESOURCES"
    sellTitle.BorderSizePixel = 0
    sellTitle.Parent = sellPanel
    
    -- Scroll frame for sell items
    local sellScroll = Instance.new("ScrollingFrame")
    sellScroll.Name = "ScrollFrame"
    sellScroll.Size = UDim2.new(1, -10, 1, -40)
    sellScroll.Position = UDim2.new(0, 5, 0, 35)
    sellScroll.BackgroundColor3 = Color3.fromRGB(50, 40, 40)
    sellScroll.BorderSizePixel = 0
    sellScroll.ScrollBarThickness = 8
    sellScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    sellScroll.Parent = sellPanel
    
    local sellLayout = Instance.new("UIListLayout")
    sellLayout.Padding = UDim.new(0, 5)
    sellLayout.Parent = sellScroll
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 35)
    closeButton.Position = UDim2.new(1, -110, 1, -45)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 12
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "CLOSE"
    closeButton.Parent = container
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        container.Visible = false
    end)
    
    return screenGui, buyScroll, sellScroll
end

function ShopGui.CreateResourceItem(resource, isForSale, scrollFrame)
    local item = Instance.new("Frame")
    item.Name = resource
    item.Size = UDim2.new(1, -10, 0, 50)
    item.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    item.BorderSizePixel = 1
    item.BorderColor3 = Color3.fromRGB(100, 100, 150)
    item.Parent = scrollFrame
    
    -- Resource name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(0, 80, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = resource
    nameLabel.Parent = item
    
    -- Price
    local priceLabel = Instance.new("TextLabel")
    priceLabel.Name = "Price"
    priceLabel.Size = UDim2.new(0, 70, 1, 0)
    priceLabel.Position = UDim2.new(0, 85, 0, 0)
    priceLabel.BackgroundTransparency = 1
    priceLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    priceLabel.TextSize = 10
    priceLabel.Font = Enum.Font.Gotham
    priceLabel.Text = "Price: 100"
    priceLabel.Parent = item
    
    -- Amount input
    local amountInput = Instance.new("TextBox")
    amountInput.Name = "AmountInput"
    amountInput.Size = UDim2.new(0, 50, 0, 25)
    amountInput.Position = UDim2.new(0.5, -60, 0.5, -12)
    amountInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    amountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    amountInput.TextSize = 10
    amountInput.Font = Enum.Font.Gotham
    amountInput.Text = "1"
    amountInput.Parent = item
    
    -- Action button
    local actionButton = Instance.new("TextButton")
    actionButton.Name = "ActionButton"
    actionButton.Size = UDim2.new(0, 50, 0, 25)
    actionButton.Position = UDim2.new(1, -55, 0.5, -12)
    actionButton.BackgroundColor3 = isForSale and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(100, 150, 255)
    actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionButton.TextSize = 10
    actionButton.Font = Enum.Font.GothamBold
    actionButton.Text = isForSale and "SELL" or "BUY"
    actionButton.Parent = item
    
    return item
end

-- ==================== INITIALIZATION ====================

function ShopGui.Initialize()
    local screenGui, buyScroll, sellScroll = ShopGui.CreateShopFrame()
    
    -- Add resources
    for resource, _ in pairs(Constants.RESOURCES) do
        ShopGui.CreateResourceItem(resource, false, buyScroll)
        ShopGui.CreateResourceItem(resource, true, sellScroll)
    end
    
    print("Shop GUI initialized")
end

if RunService:IsClient() then
    ShopGui.Initialize()
end

return ShopGui

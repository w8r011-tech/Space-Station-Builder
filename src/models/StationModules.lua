-- StationModules.lua
-- Station building modules and their properties

local StationModules = {}

local Constants = require(script.Parent.Parent.shared:WaitForChild("Constants"))

-- ==================== MODULE TEMPLATES ====================

StationModules.Templates = {
    [Constants.BUILDINGS.LIFE_SUPPORT] = {
        name = "Life Support",
        size = Vector3.new(5, 5, 5),
        color = Color3.fromRGB(0, 255, 150),
        production = Constants.RESOURCES.OXYGEN
    },
    [Constants.BUILDINGS.POWER_PLANT] = {
        name = "Power Plant",
        size = Vector3.new(6, 6, 6),
        color = Color3.fromRGB(255, 200, 0),
        production = Constants.RESOURCES.ENERGY
    },
    [Constants.BUILDINGS.FARM] = {
        name = "Farm",
        size = Vector3.new(4, 3, 8),
        color = Color3.fromRGB(0, 200, 0),
        production = Constants.RESOURCES.FOOD
    },
    [Constants.BUILDINGS.STORAGE] = {
        name = "Storage",
        size = Vector3.new(8, 4, 8),
        color = Color3.fromRGB(150, 100, 50),
        storage = true
    },
    [Constants.BUILDINGS.RESEARCH_LAB] = {
        name = "Research Lab",
        size = Vector3.new(5, 5, 5),
        color = Color3.fromRGB(200, 100, 255),
        research = true
    },
    [Constants.BUILDINGS.MINING_FACILITY] = {
        name = "Mining Facility",
        size = Vector3.new(7, 6, 7),
        color = Color3.fromRGB(100, 100, 100),
        production = Constants.RESOURCES.MATERIALS
    }
}

-- ==================== MODULE CREATION ====================

function StationModules.CreateModule(buildingName, position)
    local template = StationModules.Templates[buildingName]
    if not template then return nil end
    
    -- Create main part
    local part = Instance.new("Part")
    part.Name = buildingName
    part.Shape = Enum.PartType.Block
    part.Size = template.size
    part.Position = position or Vector3.new(0, 10, 0)
    part.Color = template.color
    part.Material = Enum.Material.SmoothPlastic
    part.CanCollide = true
    part.CFrame = CFrame.new(part.Position)
    
    -- Add humanoid touch detection
    local touchedConnections = {}
    part.Touched:Connect(function(hit)
        if hit.Parent:FindFirstChild("Humanoid") then
            -- Player touched the building
        end
    end)
    
    -- Add BillboardGui for information
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, template.size.Y/2 + 3, 0)
    billboard.Parent = part
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.BackgroundTransparency = 0.5
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = template.name
    textLabel.Parent = billboard
    
    return part
end

function StationModules.PlaceModule(buildingName, position)
    local module = StationModules.CreateModule(buildingName, position)
    if module then
        module.Parent = workspace.StationModules or workspace
        return module
    end
    return nil
end

-- ==================== MODULE DESTRUCTION ====================

function StationModules.DestroyModule(module)
    if module and module.Parent then
        module:Destroy()
    end
end

return StationModules

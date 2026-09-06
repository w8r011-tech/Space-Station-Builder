-- Planets.lua
-- Planet definitions and exploration data

local Planets = {}

local Constants = require(script.Parent.Parent.shared:WaitForChild("Constants"))

-- ==================== PLANET DEFINITIONS ====================

Planets.PlanetData = {
    [Constants.PLANETS.MERCURY] = {
        name = "Mercury",
        description = "The smallest planet, extremely hot and close to the sun",
        color = Color3.fromRGB(169, 169, 169),
        distance = 58,
        resources = {Materials = 30},
        difficulty = 1,
        rewards = {experience = 50, materials = 30}
    },
    [Constants.PLANETS.VENUS] = {
        name = "Venus",
        description = "Similar to Earth, but with a toxic atmosphere",
        color = Color3.fromRGB(255, 200, 100),
        distance = 108,
        resources = {Materials = 50, Food = 20},
        difficulty = 2,
        rewards = {experience = 100, materials = 50, food = 20}
    },
    [Constants.PLANETS.MARS] = {
        name = "Mars",
        description = "The red planet, ideal for exploration and resource gathering",
        color = Color3.fromRGB(200, 100, 50),
        distance = 228,
        resources = {Materials = 100, Food = 50},
        difficulty = 3,
        rewards = {experience = 200, materials = 100, food = 50}
    },
    [Constants.PLANETS.JUPITER] = {
        name = "Jupiter",
        description = "A gas giant with extreme storms and rare materials",
        color = Color3.fromRGB(200, 150, 100),
        distance = 778,
        resources = {Materials = 200},
        difficulty = 4,
        rewards = {experience = 300, materials = 200}
    },
    [Constants.PLANETS.SATURN] = {
        name = "Saturn",
        description = "The ringed planet, extremely dangerous but rich in resources",
        color = Color3.fromRGB(220, 200, 150),
        distance = 1427,
        resources = {Materials = 300},
        difficulty = 5,
        rewards = {experience = 500, materials = 300}
    }
}

-- ==================== EXPLORATION SYSTEM ====================

function Planets.CreatePlanetModel(planetName)
    local data = Planets.PlanetData[planetName]
    if not data then return nil end
    
    -- Create planet part
    local planet = Instance.new("Part")
    planet.Name = planetName
    planet.Shape = Enum.PartType.Ball
    planet.Size = Vector3.new(data.distance / 50, data.distance / 50, data.distance / 50)
    planet.Position = Vector3.new(data.distance, 100, 0)
    planet.Color = data.color
    planet.Material = Enum.Material.SmoothPlastic
    planet.CanCollide = false
    
    -- Add atmosphere
    local atmosphere = Instance.new("Part")
    atmosphere.Name = "Atmosphere"
    atmosphere.Shape = Enum.PartType.Ball
    atmosphere.Size = planet.Size * 1.2
    atmosphere.Position = planet.Position
    atmosphere.Color = data.color
    atmosphere.Material = Enum.Material.Neon
    atmosphere.CanCollide = false
    atmosphere.Transparency = 0.5
    atmosphere.Parent = planet
    
    -- Add info label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, planet.Size.Y/2 + 5, 0)
    billboard.Parent = planet
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.BackgroundTransparency = 0.3
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = data.name .. "\n" .. "Difficulty: " .. data.difficulty
    textLabel.Parent = billboard
    
    return planet
end

function Planets.StartExploration(playerData, planetName)
    local data = Planets.PlanetData[planetName]
    if not data then
        return false, "Planet not found"
    end
    
    if playerData.level < data.difficulty then
        return false, "Your level is too low for this planet"
    end
    
    -- Simulate exploration
    local gatheredResources = {}
    for resource, amount in pairs(data.resources) do
        -- Random amount based on difficulty
        local variance = math.random(80, 120) / 100
        gatheredResources[resource] = math.floor(amount * variance)
    end
    
    -- Add rewards
    playerData.experience = playerData.experience + data.rewards.experience
    for resource, amount in pairs(gatheredResources) do
        playerData.resources[resource] = (playerData.resources[resource] or 0) + amount
    end
    
    return true, "Exploration successful! Gathered: " .. table.concat(gatheredResources, ", ")
end

function Planets.GetAllPlanets()
    local planetsList = {}
    for planetName, data in pairs(Planets.PlanetData) do
        table.insert(planetsList, {
            name = planetName,
            data = data
        })
    end
    return planetsList
end

return Planets

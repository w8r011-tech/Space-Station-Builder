-- EconomySystem.lua
-- Server-side economy and trading system

local EconomySystem = {}

local Constants = require(script.Parent.Parent.shared:WaitForChild("Constants"))
local Utilities = require(script.Parent.Parent.shared:WaitForChild("Utilities"))

-- ==================== MARKET DATA ====================

local marketData = {
    lastUpdate = os.time(),
    prices = Utilities.DeepCopy(Constants.BASE_PRICES),
    tradingVolume = {}
}

-- Initialize trading volume
for resource, _ in pairs(Constants.RESOURCES) do
    marketData.tradingVolume[resource] = 0
end

-- ==================== PRICE MANAGEMENT ====================

function EconomySystem.GetCurrentPrices()
    return marketData.prices
end

function EconomySystem.UpdateMarketPrices()
    -- Simulate market fluctuation based on supply and demand
    for resource, basePrice in pairs(Constants.BASE_PRICES) do
        local volume = marketData.tradingVolume[resource] or 0
        local fluctuation = 1 + (math.random() - 0.5) * Constants.PRICE_FLUCTUATION
        
        -- Volume affects price
        if volume > 100 then
            fluctuation = fluctuation * 1.1 -- High demand increases price
        elseif volume < 20 then
            fluctuation = fluctuation * 0.9 -- Low demand decreases price
        end
        
        local newPrice = basePrice * fluctuation
        marketData.prices[resource] = Utilities.Clamp(newPrice, basePrice * 0.7, basePrice * 1.5)
    end
    
    marketData.lastUpdate = os.time()
    Utilities.Log("Market prices updated")
end

-- Update prices every 5 minutes (in game time)
local priceUpdateInterval = 300
local lastPriceUpdate = os.time()

function EconomySystem.UpdatePricesIfNeeded()
    if os.time() - lastPriceUpdate >= priceUpdateInterval then
        EconomySystem.UpdateMarketPrices()
        lastPriceUpdate = os.time()
    end
end

-- ==================== BUYING & SELLING ====================

function EconomySystem.BuyResource(playerData, resource, amount)
    if not Constants.RESOURCES[resource] then
        return false, "Invalid resource"
    end
    
    local price = marketData.prices[resource] or Constants.BASE_PRICES[resource]
    local totalCost = price * amount
    
    -- Check if player has enough currency (using Materials as currency)
    if playerData.resources[Constants.RESOURCES.MATERIALS] < totalCost then
        return false, "Not enough Materials"
    end
    
    -- Check storage
    local totalResources = 0
    for res, amt in pairs(playerData.resources) do
        totalResources = totalResources + amt
    end
    
    if totalResources + amount > Constants.MAX_RESOURCES[resource] then
        return false, "Not enough storage"
    end
    
    -- Execute trade
    playerData.resources[Constants.RESOURCES.MATERIALS] = 
        playerData.resources[Constants.RESOURCES.MATERIALS] - totalCost
    playerData.resources[resource] = 
        (playerData.resources[resource] or 0) + amount
    
    marketData.tradingVolume[resource] = 
        (marketData.tradingVolume[resource] or 0) + amount
    
    Utilities.Log("Player bought " .. amount .. " " .. resource)
    return true, "Purchase successful"
end

function EconomySystem.SellResource(playerData, resource, amount)
    if not Constants.RESOURCES[resource] then
        return false, "Invalid resource"
    end
    
    if playerData.resources[resource] < amount then
        return false, "Not enough " .. resource
    end
    
    local price = marketData.prices[resource] or Constants.BASE_PRICES[resource]
    local totalEarnings = price * amount
    
    -- Execute trade
    playerData.resources[resource] = playerData.resources[resource] - amount
    playerData.resources[Constants.RESOURCES.MATERIALS] = 
        playerData.resources[Constants.RESOURCES.MATERIALS] + totalEarnings
    
    Utilities.Log("Player sold " .. amount .. " " .. resource)
    return true, totalEarnings
end

-- ==================== ECONOMY STATS ====================

function EconomySystem.GetMarketStats()
    return {
        prices = Utilities.DeepCopy(marketData.prices),
        volume = Utilities.DeepCopy(marketData.tradingVolume),
        lastUpdate = marketData.lastUpdate
    }
end

function EconomySystem.GetResourcePrice(resource)
    return marketData.prices[resource] or Constants.BASE_PRICES[resource]
end

return EconomySystem

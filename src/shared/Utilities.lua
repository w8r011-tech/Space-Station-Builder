-- Utilities.lua
-- Shared utility functions for Space Station Builder

local Utilities = {}

-- ==================== TABLE UTILITIES ====================

function Utilities.DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			copy[k] = Utilities.DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

function Utilities.Merge(table1, table2)
	local merged = Utilities.DeepCopy(table1)
	for k, v in pairs(table2) do
		if type(v) == "table" and type(merged[k]) == "table" then
			merged[k] = Utilities.Merge(merged[k], v)
		else
			merged[k] = v
		end
	end
	return merged
end

-- ==================== STRING UTILITIES ====================

function Utilities.FormatNumber(num)
	if num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	else
		return tostring(math.floor(num))
	end
end

function Utilities.Capitalize(str)
	return str:sub(1,1):upper() .. str:sub(2):lower()
end

-- ==================== MATH UTILITIES ====================

function Utilities.Clamp(value, min, max)
	if value < min then return min end
	if value > max then return max end
	return value
end

function Utilities.Lerp(a, b, t)
	return a + (b - a) * t
end

function Utilities.RandomFloat(min, max)
	return min + math.random() * (max - min)
end

function Utilities.RandomInt(min, max)
	return math.random(min, max)
end

-- ==================== VALIDATION ====================

function Utilities.ValidateResource(resourceName)
	local Constants = require(script.Parent:WaitForChild("Constants"))
	for _, resource in pairs(Constants.RESOURCES) do
		if resource == resourceName then
			return true
		end
	end
	return false
end

function Utilities.ValidateBuilding(buildingName)
	local Constants = require(script.Parent:WaitForChild("Constants"))
	for _, building in pairs(Constants.BUILDINGS) do
		if building == buildingName then
			return true
		end
	end
	return false
end

-- ==================== TIME UTILITIES ====================

function Utilities.GetCurrentGameTime()
	return os.time()
end

function Utilities.HasEnoughTimePassed(lastTime, interval)
	return (os.time() - lastTime) >= interval
end

function Utilities.FormatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- ==================== ARRAY UTILITIES ====================

function Utilities.FindInArray(array, value)
	for i, v in ipairs(array) do
		if v == value then
			return i
		end
	end
	return nil
end

function Utilities.TableToArray(tbl)
	local arr = {}
	for k, v in pairs(tbl) do
		table.insert(arr, {key = k, value = v})
	end
	return arr
end

function Utilities.ArrayToTable(arr, keyField, valueField)
	local tbl = {}
	for _, item in ipairs(arr) do
		tbl[item[keyField]] = item[valueField]
	end
	return tbl
end

-- ==================== LOGGING ====================

function Utilities.Log(message, level)
	level = level or "INFO"
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	print(string.format("[%s] [%s] %s", timestamp, level, message))
end

function Utilities.LogError(message)
	Utilities.Log(message, "ERROR")
end

function Utilities.LogWarning(message)
	Utilities.Log(message, "WARNING")
end

-- ==================== SIGNAL SYSTEM ====================

local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	self._bindable = Instance.new("BindableEvent")
	return self
end

function Signal:Connect(callback)
	return self._bindable.Event:Connect(callback)
end

function Signal:Fire(...)
	self._bindable:Fire(...)
end

function Signal:Wait()
	return self._bindable.Event:Wait()
end

function Signal:Destroy()
	self._bindable:Destroy()
end

Utilities.Signal = Signal

return Utilities

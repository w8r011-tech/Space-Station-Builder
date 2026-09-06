-- MainScript.lua
-- This is the main entry point - place this in ServerScriptService
-- Make sure all other scripts are already in place before running this

local RunService = game:GetService("RunService")

if not RunService:IsServer() then return end

-- Initialize game systems
print("[Space Station Builder] Initializing...")

-- Wait for shared modules to load
local Constants = require(game.ReplicatedStorage:WaitForChild("Constants"))
local Utilities = require(game.ReplicatedStorage:WaitForChild("Utilities"))

-- Wait for server modules
local DataManager = require(script.Parent:WaitForChild("DataManager"))
local ResourceSystem = require(script.Parent:WaitForChild("ResourceSystem"))
local QuestSystem = require(script.Parent:WaitForChild("QuestSystem"))
local EconomySystem = require(script.Parent:WaitForChild("EconomySystem"))
local GameManager = require(script.Parent:WaitForChild("GameManager"))

print("[Space Station Builder] ✅ All systems initialized successfully!")
print("[Space Station Builder] 🎮 Game is ready to play")

-- Log server start
Utilities.Log("Space Station Builder server started", "INFO")

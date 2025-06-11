-- Test script for Blacklist addon
print("Loading test script for Blacklist addon")

-- Simulate addon environment
local addonName = "Blacklist"
local addon = {}

-- Include some mock WoW API functions
_G = _G or {}
function GetRealmName() return "TestRealm" end
function UnitName() return "Player" end
function time() return 1000000 end
function print(...) print("ADDON:", ...) end
function CreateFrame() return {} end
_G.GameTooltip = {GetUnit = function() return nil, "player" end}
function hooksecurefunc() end

-- Load key files from the addon
dofile("e:/development/Projects/blacklist/localization.lua")
dofile("e:/development/Projects/blacklist/db.lua")
dofile("e:/development/Projects/blacklist/core.lua")
dofile("e:/development/Projects/blacklist/modules/tooltip.lua")

print("Test script completed!")

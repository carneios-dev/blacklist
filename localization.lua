-- The Blacklist: Localization
local addonName, addon = ...

-- Default locale (English - US)
local L = {
    -- General
    ["addonName"] = "The Blacklist",
    ["version"] = "Version: %s",
    ["loadedMessage"] = "|cFF33FF99The Blacklist|r v%s loaded! Type /bl or /blacklist for options.",
    
    -- Commands
    ["cmd_help"] = "Shows this help message",
    ["cmd_list"] = "Shows your blacklist",
    ["cmd_add"] = "Adds a player to your blacklist",
    ["cmd_remove"] = "Removes a player from your blacklist",
    ["cmd_config"] = "Opens the configuration panel",
    ["cmd_target"] = "Adds your current target to the blacklist",
    ["cmd_note"] = "Adds or updates a note for a blacklisted player",
    ["cmd_reset"] = "Resets all settings to default",
    
    -- UI
    ["enable"] = "Enable Blacklist",
    ["autoDecline"] = "Auto-decline invites from blacklisted players",
    ["promptKick"] = "Prompt to kick blacklisted players from group",
    ["showInTooltip"] = "Show blacklist status in tooltips",
    ["showMinimap"] = "Show minimap button",
    ["debugMode"] = "Debug Mode",
    ["resetAll"] = "Reset All",
    
    -- Confirmation dialogs
    ["resetConfirm"] = "Are you sure you want to reset all Blacklist settings and clear your blacklist?",
    ["yes"] = "Yes",
    ["no"] = "No",
    
    -- Content types
    ["content_mythicplus"] = "Mythic+",
    ["content_raid"] = "Raids",
    ["content_pvp"] = "PvP",
    ["content_questing"] = "Questing",
    
    -- Role types
    ["role_tank"] = "Tank",
    ["role_healer"] = "Healer",
    ["role_dps"] = "DPS",
    
    -- Error messages
    ["error_notInitialized"] = "The Blacklist addon is not fully initialized yet.",
    ["error_invalidCommand"] = "Invalid command. Type /bl help for a list of commands.",
}

-- Store the localization table in the addon namespace
addon.L = L

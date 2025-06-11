-- The Blacklist Add-on
-- Author: Carneios
-- Version: 1.0

-- Create the addon namespace
local addonName, addon = ...
_G["Blacklist"] = addon

-- Constants
addon.VERSION = "1.0.0"
addon.EXPANSION = "The War Within"

-- Default settings
addon.defaults = {
    enabled = true,
    autoDecline = true,    promptKick = false,
    promptIgnore = true,   -- Prompt to ignore players when blacklisting
    autoIgnore = false,    -- Automatically ignore players when blacklisting
    showInTooltip = true,
    debug = false,
    filters = {
        duration = 0, -- 0 means indefinite
        content = {
            mythicplus = true,
            raid = true,
            pvp = true,
            questing = true,
        },
        roles = {
            tank = true,
            healer = true,
            dps = true,
        }
    }
}

-- Debug function
function addon:Debug(...)
    if self.db and self.db.debug then
        print("|cFF33FF99Blacklist Debug:|r", ...)
    end
end

-- Error reporting function
function addon:Error(...)
    print("|cFFFF0000Blacklist Error:|r", ...)
    -- Log to chat frame for visibility during development
    if self.db and self.db.debug then
        -- Include a stack trace in debug mode
        print("|cFFFF0000Stack:|r", debugstack(2, 3, 0))
    end
end

-- Initialize the addon
function addon:OnInitialize()
    -- Initialize database
    self:InitializeDB()
    
    -- Initialize core functionality
    self:InitializeCore()
      -- Initialize modules
    if self.tooltipModule and self.tooltipModule.Initialize then
        self.tooltipModule:Initialize()
    end
    
    if self.groupModule and self.groupModule.Initialize then
        self.groupModule:Initialize()
    end
    
    if self.commandsModule and self.commandsModule.Initialize then
        self.commandsModule:Initialize()
    end
      if self.minimapModule and self.minimapModule.Initialize then
        self.minimapModule:Initialize()
    end
    
    -- Initialize UI components
    if self.configUI and self.configUI.Initialize then
        self.configUI:Initialize()
    end
    
    if self.mainUI and self.mainUI.Initialize then
        self.mainUI:Initialize()
    end
    
    -- Print loaded message
    local msg = string.format(self.L["loadedMessage"] or "|cFF33FF99The Blacklist|r v%s loaded! Type /bl or /blacklist for options.", self.VERSION)
    print(msg)
end

-- Register for events
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        addon:OnInitialize()
    end
end)

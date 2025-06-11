-- The Blacklist: Commands Module
local addonName, addon = ...
local commandsModule = {}

-- Initialize the commands module
function commandsModule:Initialize()
    -- Register slash commands
    SLASH_BLACKLIST1 = "/blacklist"
    SLASH_BLACKLIST2 = "/bl"
    SlashCmdList["BLACKLIST"] = function(msg)
        self:HandleSlashCommand(msg)
    end
    
    addon:Debug("Commands module initialized")
end

-- Handle slash commands
function commandsModule:HandleSlashCommand(msg)
    local args = {}
    for arg in string.gmatch(msg, "[^%s]+") do
        table.insert(args, arg)
    end
    
    local command = args[1] and string.lower(args[1]) or ""
    
    if command == "" or command == "help" then
        self:PrintHelp()
    elseif command == "add" or command == "blacklist" then
        self:CommandAdd(select(2, unpack(args)))
    elseif command == "remove" or command == "delete" then
        self:CommandRemove(args[2])
    elseif command == "list" then
        self:CommandList()
    elseif command == "config" or command == "options" then
        self:OpenConfig()
    elseif command == "enable" then
        self:CommandEnable(true)
    elseif command == "disable" then
        self:CommandEnable(false)
    elseif command == "debug" then
        self:CommandDebug()
    else
        print("|cFF33FF99Blacklist:|r Unknown command. Type |cFFFFFF00/bl help|r for a list of commands.")
    end
end

-- Print help information
function commandsModule:PrintHelp()
    print("|cFF33FF99The Blacklist - Commands|r")
    print("|cFFFFFF00/bl|r or |cFFFFFF00/blacklist|r - Open the config UI")
    print("|cFFFFFF00/bl add NAME [reason]|r - Add a player to your blacklist")
    print("|cFFFFFF00/bl remove NAME|r - Remove a player from your blacklist")
    print("|cFFFFFF00/bl list|r - List all blacklisted players")
    print("|cFFFFFF00/bl config|r - Open the configuration panel")
    print("|cFFFFFF00/bl enable|r - Enable the addon")
    print("|cFFFFFF00/bl disable|r - Disable the addon")
    print("|cFFFFFF00/bl debug|r - Toggle debug mode")
    print("|cFFFFFF00/bl help|r - Show this help message")
end

-- Add a player to the blacklist
function commandsModule:CommandAdd(...)
    local args = {...}
    
    if not args[1] then
        print("|cFF33FF99Blacklist:|r Usage: /bl add NAME [reason]")
        return
    end
    
    local name = args[1]
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    
    if reason == "" then reason = nil end
    
    if addon:BlacklistPlayer(name, reason) then
        print(string.format("|cFF33FF99Blacklist:|r Added %s to your blacklist%s", 
            name, reason and " - Reason: " .. reason or ""))
    else
        print("|cFF33FF99Blacklist:|r Failed to add player to blacklist.")
    end
end

-- Remove a player from the blacklist
function commandsModule:CommandRemove(name)
    if not name then
        print("|cFF33FF99Blacklist:|r Usage: /bl remove NAME")
        return
    end
    
    if addon:RemoveFromBlacklist(name) then
        print("|cFF33FF99Blacklist:|r Removed " .. name .. " from your blacklist.")
    else
        print("|cFF33FF99Blacklist:|r Could not find " .. name .. " in your blacklist.")
    end
end

-- List all blacklisted players
function commandsModule:CommandList()
    if not addon.db or not addon.db.blacklist then
        print("|cFF33FF99Blacklist:|r No players are blacklisted.")
        return
    end
    
    local count = 0
    print("|cFF33FF99Blacklist:|r Current blacklisted players:")
    
    for name, entry in pairs(addon.db.blacklist) do
        local expiryInfo = ""
        if entry.duration and entry.duration > 0 and entry.expiresAt then
            local timeLeft = math.max(0, entry.expiresAt - time())
            local days = math.floor(timeLeft / 86400)
            local hours = math.floor((timeLeft % 86400) / 3600)
            
            if days > 0 then
                expiryInfo = string.format(" (Expires in %d days %d hours)", days, hours)
            elseif hours > 0 then
                expiryInfo = string.format(" (Expires in %d hours)", hours)
            else
                expiryInfo = " (Expires soon)"
            end
        elseif entry.duration == 0 then
            expiryInfo = " (Indefinite)"
        end
        
        local reason = entry.reason and " - Reason: " .. entry.reason or ""
        print("- " .. name .. expiryInfo .. reason)
        count = count + 1
    end
    
    if count == 0 then
        print("No players are blacklisted.")
    else
        print(string.format("Total: %d blacklisted player%s", count, count > 1 and "s" or ""))
    end
end

-- Open the config UI
function commandsModule:OpenConfig()
    if addon.ui and addon.ui.ShowConfig then
        addon.ui.ShowConfig()
    else
        print("|cFF33FF99Blacklist:|r UI module is not loaded.")
        print("|cFF33FF99Blacklist:|r Current settings:")
        print("Enabled: " .. (addon.db.enabled and "Yes" or "No"))
        print("Auto-decline invites: " .. (addon.db.autoDecline and "Yes" or "No"))
        print("Prompt to kick: " .. (addon.db.promptKick and "Yes" or "No"))
        print("Show in tooltips: " .. (addon.db.showInTooltip and "Yes" or "No"))
    end
end

-- Enable or disable the addon
function commandsModule:CommandEnable(enableState)
    addon.db.enabled = enableState
    
    if enableState then
        print("|cFF33FF99Blacklist:|r Addon is now enabled.")
    else
        print("|cFF33FF99Blacklist:|r Addon is now disabled.")
    end
end

-- Toggle debug mode
function commandsModule:CommandDebug()
    addon.db.debug = not addon.db.debug
    print("|cFF33FF99Blacklist:|r Debug mode is now " .. (addon.db.debug and "enabled" or "disabled"))
end

-- Register the module
addon.commandsModule = commandsModule

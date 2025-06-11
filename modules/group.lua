-- The Blacklist: Group Module
local addonName, addon = ...
local groupModule = {}

-- Initialize the group module
function groupModule:Initialize()
    if not addon.db or not addon.db.enabled then return end
    
    addon:Debug("Group module initialized")
end

-- Check if a player should be auto-declined based on content and role filters
function groupModule:ShouldAutoDecline(playerName, contentType, role)
    local isBlacklisted, entry = addon:IsBlacklisted(playerName)
    
    if not isBlacklisted then
        return false
    end
    
    -- If no specific filters, decline for all content and roles
    if not entry.contentTypes and not entry.roles then
        return true
    end
    
    -- Check content type if provided
    if contentType and entry.contentTypes and not entry.contentTypes[contentType] then
        return false
    end
    
    -- Check role if provided
    if role and entry.roles and not entry.roles[role] then
        return false
    end
    
    return true
end

-- Show a dialog to kick a blacklisted player
function groupModule:ShowKickPrompt(playerName, reason)
    if not StaticPopupDialogs["BLACKLIST_KICK_DIALOG"] then
        StaticPopupDialogs["BLACKLIST_KICK_DIALOG"] = {
            text = "%s is blacklisted. Reason: %s\nDo you want to kick them from the group?",
            button1 = "Kick",
            button2 = "Ignore",
            OnAccept = function(self, data)
                if data and data.name and (UnitInParty(data.name) or UnitInRaid(data.name)) then
                    UninviteUnit(data.name)
                    print("|cFF33FF99Blacklist:|r", data.name, "has been kicked from the group.")
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end
    
    StaticPopup_Show("BLACKLIST_KICK_DIALOG", playerName, reason or "No reason specified", {name = playerName})
end

-- Monitor group invite requests
function groupModule:OnGroupInviteRequest(event, name)
    if not addon.db.enabled or not addon.db.autoDecline then return end
    
    local isBlacklisted, entry = addon:IsBlacklisted(name)
    if isBlacklisted then
        -- Get current content type
        local contentType = "questing" -- default
        if IsInInstance() then
            local _, instanceType = GetInstanceInfo()
            if instanceType == "raid" then
                contentType = "raid"
            elseif instanceType == "party" then
                contentType = "mythicplus" -- assumption
            elseif instanceType == "pvp" or instanceType == "arena" then
                contentType = "pvp"
            end
        end
        
        -- Check if we should decline based on content type
        if self:ShouldAutoDecline(name, contentType) then
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
            print("|cFFFF0000Blacklist:|r Automatically declined invite from blacklisted player:", name)
            return true
        end
    end
    
    return false
end

-- Register the module
addon.groupModule = groupModule

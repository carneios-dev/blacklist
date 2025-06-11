-- The Blacklist: Core functionality
local addonName, addon = ...

-- Local functions
local function FormatPlayerName(name)
    -- Handle name-realm format
    if name and not string.find(name, "-") then
        name = name .. "-" .. (GetRealmName() or "")
    end
    return name
end

-- Initialize core functionality
function addon:InitializeCore()
    self:Debug("Core initialized")
    self:RegisterEvents()
    self:SetupUnitMenu()
end

-- Setup unit right-click menu
function addon:SetupUnitMenu()
    -- We'll use a simpler approach using the context menu API
    self:Debug("Setting up context menu")
    
    -- Create a context menu option for adding to blacklist
    local function AddToBlacklist(unit)
        local playerName = UnitName(unit)
        if not playerName or UnitIsUnit(unit, "player") then return end
        
        -- Initialize the name editor with the player's name
        if addon.mainUI and addon.mainUI.nameEditBox then
            addon.mainUI:ShowManager()
            addon.mainUI.nameEditBox:SetText(playerName)
            addon.mainUI.reasonEditBox:SetFocus()
        else
            -- Fallback if UI is not ready
            addon:BlacklistPlayer(playerName)
            print("|cFF33FF99Blacklist:|r Added " .. playerName .. " to your blacklist.")
        end
    end
    
    -- Try to register with blizzard context menu
    if LibStub and LibStub:GetLibrary("LibContextMenu", true) then
        local LCM = LibStub:GetLibrary("LibContextMenu")
        LCM:Register("player", {
            { text = "Add to Blacklist", 
              icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain", 
              func = function(unitFrame) 
                AddToBlacklist(unitFrame.unit) 
              end 
            }
        })
        self:Debug("Registered with LibContextMenu")    else
        -- Fallback: Create a bind function
        SLASH_BLACKLISTTARGET1 = "/blacklisttarget"
        SLASH_BLACKLISTTARGET2 = "/blt"
        SlashCmdList["BLACKLISTTARGET"] = function(msg)
            if UnitExists("target") and UnitIsPlayer("target") then
                AddToBlacklist("target")
            else
                print("|cFF33FF99Blacklist:|r You need to target a player first.")
            end
        end
        self:Debug("Created /blacklisttarget command as context menu fallback")
        print("|cFF33FF99Blacklist:|r Use /blacklisttarget or /blt to blacklist your current target.")end
    
    self:Debug("Unit menu setup complete")
end

-- Register all needed events
function addon:RegisterEvents()
    -- Events for group interactions
    self.eventFrame = self.eventFrame or CreateFrame("Frame")
    self.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    self.eventFrame:RegisterEvent("PARTY_INVITE_REQUEST")
    self.eventFrame:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
    
    self.eventFrame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
        if event == "GROUP_ROSTER_UPDATE" then
            addon:OnGroupRosterUpdate()
        elseif event == "PARTY_INVITE_REQUEST" then
            addon:OnPartyInviteRequest(arg1)
        elseif event == "LFG_LIST_APPLICANT_UPDATED" then
            addon:OnLFGApplicationUpdate()
        end
    end)
end

-- Check if a player is blacklisted
function addon:IsBlacklisted(playerName)
    playerName = FormatPlayerName(playerName)
    if not playerName or not self.db.blacklist then return false end
    
    if self.db.blacklist[playerName] then
        local entry = self.db.blacklist[playerName]
        
        -- Check if blacklist has expired
        if entry.duration and entry.duration > 0 then
            local timeRemaining = entry.expiresAt - time()
            if timeRemaining <= 0 then
                -- Blacklist expired
                self.db.blacklist[playerName] = nil
                self:Debug(playerName, "blacklist has expired and was removed")
                return false
            end
        end
        
        return true, entry
    end
    
    return false
end

-- Add a player to the blacklist
function addon:BlacklistPlayer(playerName, reason, duration, contentTypes, roles, skipPrompt)
    playerName = FormatPlayerName(playerName)
    if not playerName then return false end
    
    local guid = nil
    
    -- Try to get GUID for a player if we can
    if UnitExists("target") and UnitIsPlayer("target") and GetUnitName("target", true) == playerName then
        guid = UnitGUID("target")
    end
    
    -- Create or update blacklist entry
    self.db.blacklist[playerName] = {
        name = playerName,
        reason = reason or "No reason specified",
        addedAt = time(),        duration = duration or 0, -- 0 means indefinite
        expiresAt = duration and (time() + duration) or 0,
        guid = guid, -- Store GUID for future reference
        contentTypes = contentTypes or {
            mythicplus = true,
            raid = true, 
            pvp = true,
            questing = true
        },
        roles = roles or {
            tank = true,
            healer = true,
            dps = true
        }
    }
    
    self:Debug("Added", playerName, "to blacklist")
    
    -- Handle the ignore functionality
    if self.db.autoIgnore or (self.db.promptIgnore and not skipPrompt) then
        self:HandleIgnorePrompt(playerName, reason)
    end
    
    self:OnGroupRosterUpdate() -- Check current group
    return true
end

-- Remove a player from the blacklist
function addon:RemoveFromBlacklist(playerName)
    playerName = FormatPlayerName(playerName)
    if not playerName or not self.db.blacklist then return false end
    
    if self.db.blacklist[playerName] then
        self.db.blacklist[playerName] = nil
        self:Debug("Removed", playerName, "from blacklist")
        return true
    end
    
    return false
end

-- Check current group for blacklisted players
function addon:OnGroupRosterUpdate()
    if not self.db.enabled then return end
    
    -- Check all members
    local blacklistedMembers = {}
    local isLeader = UnitIsGroupLeader("player")
    
    if IsInGroup() then
        local groupSize = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
        for i = 1, groupSize do
            local unit = IsInRaid() and "raid"..i or "party"..i
            local name = GetUnitName(unit, true)
            
            local isBlacklisted, entry = self:IsBlacklisted(name)
            if isBlacklisted then
                table.insert(blacklistedMembers, {name = name, entry = entry})
            end
        end
    end
    
    -- Notify about blacklisted members
    if #blacklistedMembers > 0 then
        for _, member in ipairs(blacklistedMembers) do
            self:NotifyBlacklistedPlayerInGroup(member.name, member.entry, isLeader)
        end
    end
end

-- Notify when a blacklisted player is in the group
function addon:NotifyBlacklistedPlayerInGroup(playerName, entry, isLeader)
    local reason = entry and entry.reason or "No reason specified"
    print("|cFFFF0000Blacklist Alert:|r", playerName, "is in your group! Reason:", reason)
    
    -- If kick prompt is enabled and player is leader, show prompt
    if isLeader and self.db.promptKick then
        self:ShowKickPrompt(playerName, reason)
    end
end

-- Show prompt to kick blacklisted player
function addon:ShowKickPrompt(playerName, reason)
    if not StaticPopupDialogs["BLACKLIST_KICK_DIALOG"] then
        StaticPopupDialogs["BLACKLIST_KICK_DIALOG"] = {
            text = "%s is blacklisted. Reason: %s\nDo you want to kick them from the group?",
            button1 = "Kick",
            button2 = "Ignore",
            OnAccept = function(self, data)
                if data and data.name then
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

-- Handle party invite requests (to auto-decline blacklisted players)
function addon:OnPartyInviteRequest(playerName)
    if not self.db.enabled or not self.db.autoDecline then return end
    
    local isBlacklisted = self:IsBlacklisted(playerName)
    if isBlacklisted then
        self:Debug("Auto-declining invite from blacklisted player:", playerName)
        DeclineGroup()
        StaticPopup_Hide("PARTY_INVITE")
        print("|cFFFF0000Blacklist:|r Automatically declined invite from blacklisted player:", playerName)
    end
end

-- Handle LFG application updates (to auto-decline blacklisted applicants)
function addon:OnLFGApplicationUpdate()
    if not self.db.enabled or not self.db.autoDecline then return end
    if not UnitIsGroupLeader("player") then return end
    
    local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
    if not activeEntryInfo then return end
    
    local applicants = C_LFGList.GetApplicants()
    if not applicants or #applicants == 0 then return end
    
    for i, applicantID in ipairs(applicants) do
        local applicantInfo = C_LFGList.GetApplicantInfo(applicantID)
        if applicantInfo and not applicantInfo.applicationStatus then
            local numMembers = applicantInfo.numMembers or 0
            
            for j = 1, numMembers do
                local name, class, _, _, _, _, _, _, _, _, _, inviteStatus = C_LFGList.GetApplicantMemberInfo(applicantID, j)
                
                if name and inviteStatus == "invitepending" then
                    local isBlacklisted = self:IsBlacklisted(name)
                    
                    if isBlacklisted then
                        self:Debug("Auto-declining LFG applicant:", name)
                        C_LFGList.DeclineApplicant(applicantID)
                        print("|cFFFF0000Blacklist:|r Automatically declined LFG application from blacklisted player:", name)
                        break
                    end
                end
            end
        end
    end
end

-- Show the configuration UI
function addon:ShowConfig()
    if self.configUI and self.configUI.ShowConfig then
        self.configUI:ShowConfig()
    else
        self:Debug("ConfigUI not initialized")
    end
end

-- Handle prompting to ignore a blacklisted player
function addon:HandleIgnorePrompt(playerName, reason)
    if not playerName then return end
    
    -- If auto-ignore is enabled, add them to ignore list directly
    if self.db.autoIgnore then
        self:IgnorePlayer(playerName)
        return
    end
    
    -- Otherwise show a prompt if promptIgnore is enabled
    if self.db.promptIgnore then
        if not StaticPopupDialogs["BLACKLIST_IGNORE_DIALOG"] then
            StaticPopupDialogs["BLACKLIST_IGNORE_DIALOG"] = {
                text = "%s has been added to your blacklist.\nDo you want to add them to your ignore list as well?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function(self, data)
                    if data and data.name then
                        addon:IgnorePlayer(data.name)
                    end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
        end
        
        local displayReason = reason and reason ~= "" and ("\nReason: " .. reason) or ""
        local text = string.format("%s has been added to your blacklist.%s\nDo you want to add them to your ignore list as well?", playerName, displayReason)
        
        StaticPopupDialogs["BLACKLIST_IGNORE_DIALOG"].text = text
        StaticPopup_Show("BLACKLIST_IGNORE_DIALOG", nil, nil, {name = playerName})
    end
end

-- Add a player to the ignore list
function addon:IgnorePlayer(playerName)
    if not playerName then return end
    
    -- Check if the player is already ignored
    if C_FriendList.IsIgnored(playerName) then
        self:Debug(playerName, "is already on your ignore list")
        return
    end
    
    -- Add the player to the ignore list
    C_FriendList.AddIgnore(playerName)
    self:Debug("Added", playerName, "to ignore list")
    print("|cFF33FF99Blacklist:|r Added " .. playerName .. " to your ignore list.")
end

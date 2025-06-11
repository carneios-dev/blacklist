-- The Blacklist: Tooltip Module
local addonName, addon = ...
local tooltipModule = {}

-- Initialize the tooltip module
function tooltipModule:Initialize()
    if not addon.db or not addon.db.enabled or not addon.db.showInTooltip then return end
    
    -- Hook tooltip functions
    self:HookTooltips()
    
    addon:Debug("Tooltip module initialized")
end

-- Hook tooltip functions to show blacklist status
function tooltipModule:HookTooltips()
    -- Define the tooltip display function
    local function AddBlacklistToTooltip(tooltip)
        if not tooltip or not tooltip.GetUnit then return end
        if not addon.db.enabled or not addon.db.showInTooltip then return end
        
        local _, unit = tooltip:GetUnit()
        if not unit or not UnitIsPlayer(unit) then return end
        
        -- Get full name with realm
        local name = GetUnitName(unit, true)
        
        local isBlacklisted, entry = addon:IsBlacklisted(name)
        if isBlacklisted then
            -- Add blacklist information to tooltip
            tooltip:AddLine(" ")
            tooltip:AddLine("|cFFFF0000Blacklisted Player|r")
            
            if entry and entry.reason then
                tooltip:AddLine("Reason: " .. entry.reason, 1, 0.5, 0.5)
            end
            
            if entry and entry.duration and entry.duration > 0 and entry.expiresAt then
                local timeLeft = math.max(0, entry.expiresAt - time())
                local days = math.floor(timeLeft / 86400)
                local hours = math.floor((timeLeft % 86400) / 3600)
                
                if days > 0 then
                    tooltip:AddLine(string.format("Expires in: %d days %d hours", days, hours), 1, 0.5, 0.5)
                elseif hours > 0 then
                    tooltip:AddLine(string.format("Expires in: %d hours", hours), 1, 0.5, 0.5)
                else
                    tooltip:AddLine("Expires soon", 1, 0.5, 0.5)
                end
            elseif entry and entry.duration and entry.duration == 0 then
                tooltip:AddLine("Duration: Indefinite", 1, 0.5, 0.5)
            end
            
            tooltip:AddLine(" ")
        end
    end

    -- Use the simplest and most compatible method
    addon:Debug("Using tooltip hooking")
    
    -- Use hooksecurefunc which is available in all versions
    hooksecurefunc(GameTooltip, "SetUnit", AddBlacklistToTooltip)
    
    -- Also hook other tooltips used in LFG and group finder
    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", function(tooltip, resultID, autoAcceptOption)
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
        if not searchResultInfo or not searchResultInfo.leaderName then return end
        
        local leaderName = searchResultInfo.leaderName
        
        local isBlacklisted, entry = addon:IsBlacklisted(leaderName)
        if isBlacklisted then
            tooltip:AddLine(" ")
            tooltip:AddLine("|cFFFF0000Group Leader is Blacklisted!|r")
            
            if entry and entry.reason then
                tooltip:AddLine("Reason: " .. entry.reason, 1, 0.5, 0.5)
            end
            
            tooltip:AddLine(" ")
        end
    end)
end

-- Register the module
addon.tooltipModule = tooltipModule

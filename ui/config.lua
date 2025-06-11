-- The Blacklist: Fixed Config UI
local addonName, addon = ...
local configUI = {}

-- Initialize the config UI
function configUI:Initialize()
    self:CreateConfigFrame()
    addon:Debug("Config UI initialized")
end

-- Create a simple configuration UI for the addon
function configUI:CreateConfigFrame()
    -- Main Frame
    self.frame = CreateFrame("Frame", "BlacklistConfigFrame", UIParent, "BasicFrameTemplate")
    self.frame:SetSize(400, 350)
    self.frame:SetPoint("CENTER")
    self.frame:Hide()
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", self.frame.StopMovingOrSizing)
    
    -- Title
    self.frame.TitleText:SetText("Blacklist Settings")
    
    -- Configuration content
    local title = self.frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -30)
    title:SetText("The Blacklist")
    
    local version = self.frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    version:SetText("Version: " .. addon.VERSION)
    
    -- Options
    self.checkboxes = {}
    
    -- Enable addon
    self.checkboxes.enabled = self:CreateCheckbox(
        self.frame,
        "Enable Blacklist",
        "Enable or disable the entire addon",
        version,
        -20,
        function(checked) 
            addon.db.enabled = checked 
        end
    )
    self.checkboxes.enabled:SetChecked(addon.db and addon.db.enabled)
    
    -- Auto-decline invites
    self.checkboxes.autoDecline = self:CreateCheckbox(
        self.frame,
        "Auto-decline invites from blacklisted players",
        "Automatically decline party invites from blacklisted players",
        self.checkboxes.enabled,
        -8,
        function(checked) 
            addon.db.autoDecline = checked 
        end
    )
    self.checkboxes.autoDecline:SetChecked(addon.db and addon.db.autoDecline)
    
    -- Prompt kick
    self.checkboxes.promptKick = self:CreateCheckbox(
        self.frame,
        "Prompt to kick blacklisted players from group",
        "Show a dialog asking if you want to kick blacklisted players who join your group",
        self.checkboxes.autoDecline,
        -8,
        function(checked) 
            addon.db.promptKick = checked 
        end
    )
    self.checkboxes.promptKick:SetChecked(addon.db and addon.db.promptKick)
      -- Show in tooltip
    self.checkboxes.showInTooltip = self:CreateCheckbox(
        self.frame,
        "Show blacklist status in tooltips",
        "Show blacklist information when hovering over players",
        self.checkboxes.promptKick,
        -8,
        function(checked) 
            addon.db.showInTooltip = checked 
        end
    )
    self.checkboxes.showInTooltip:SetChecked(addon.db and addon.db.showInTooltip)
    
    -- Prompt to ignore
    self.checkboxes.promptIgnore = self:CreateCheckbox(
        self.frame,
        "Prompt to ignore blacklisted players",
        "Show a prompt asking if you want to ignore a player when adding them to the blacklist",
        self.checkboxes.showInTooltip,
        -8,
        function(checked)
            addon.db.promptIgnore = checked
            
            -- Disable autoIgnore if promptIgnore is unchecked
            if not checked and self.checkboxes.autoIgnore then
                self.checkboxes.autoIgnore:SetChecked(false)
                addon.db.autoIgnore = false
            end
        end
    )
    self.checkboxes.promptIgnore:SetChecked(addon.db and addon.db.promptIgnore)
    
    -- Auto ignore
    self.checkboxes.autoIgnore = self:CreateCheckbox(
        self.frame,
        "Auto-ignore blacklisted players",
        "Automatically ignore players when adding them to the blacklist without showing a prompt",
        self.checkboxes.promptIgnore,
        -8,
        function(checked)
            addon.db.autoIgnore = checked
            
            -- Enable promptIgnore if autoIgnore is checked
            if checked and self.checkboxes.promptIgnore then
                self.checkboxes.promptIgnore:SetChecked(true)
                addon.db.promptIgnore = true
            end
        end
    )    self.checkboxes.autoIgnore:SetChecked(addon.db and addon.db.autoIgnore)
    
    -- Minimap button
    self.checkboxes.minimap = self:CreateCheckbox(
        self.frame,
        "Show minimap button",
        "Show or hide the minimap button for quick access",
        self.checkboxes.autoIgnore,
        -20,
        function(checked) 
            if not addon.db.minimap then
                addon.db.minimap = {
                    hide = not checked,
                    position = 225,
                    radius = 80,
                }
            else
                addon.db.minimap.hide = not checked
            end
            
            if addon.minimapModule and addon.minimapModule.button then
                addon.minimapModule.button:SetShown(checked)
            end
        end
    )
    self.checkboxes.minimap:SetChecked(addon.db and addon.db.minimap and not addon.db.minimap.hide)
    
    -- Debug checkbox
    self.checkboxes.debug = self:CreateCheckbox(
        self.frame,
        "Debug Mode",
        "Enable debug messages",
        self.checkboxes.minimap,
        -15,
        function(checked) 
            addon.db.debug = checked 
        end
    )
    self.checkboxes.debug:SetChecked(addon.db and addon.db.debug)
    
    -- Reset button
    local resetButton = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
    resetButton:SetSize(100, 25)
    resetButton:SetPoint("BOTTOMLEFT", 15, 10)
    resetButton:SetText("Reset All")
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("BLACKLIST_RESET_CONFIRM")
    end)
    
    -- Close button already exists in BasicFrameTemplate
    self.frame.CloseButton:SetScript("OnClick", function() self.frame:Hide() end)
    
    -- Reset confirmation dialog
    if not StaticPopupDialogs["BLACKLIST_RESET_CONFIRM"] then
        StaticPopupDialogs["BLACKLIST_RESET_CONFIRM"] = {
            text = "Are you sure you want to reset all Blacklist settings and clear your blacklist?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                addon:ResetDB()
                self:UpdateOptions()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end
end

-- Create a checkbox in the config frame
function configUI:CreateCheckbox(parent, text, tooltip, anchorTo, yOffset, onClick)
    -- Create a unique name for the checkbox to avoid nil issues
    local frameName = "BlacklistCheckbox_" .. text:gsub("%s+", "")
    local checkbox = CreateFrame("CheckButton", frameName, parent, "ChatConfigCheckButtonTemplate")
    -- Get the text object directly since we know the name
    local checkboxText = _G[frameName.."Text"]
    checkbox:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, yOffset)
    checkboxText:SetText(text)
    checkbox.tooltip = tooltip
    
    -- Tooltip handling
    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text)
        GameTooltip:AddLine(tooltip, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    
    checkbox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Click handling
    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        if onClick then
            onClick(checked)
        end
    end)
    
    return checkbox
end

-- Show the configuration UI
function configUI:ShowConfig()
    self:UpdateOptions()
    self.frame:Show()
end

-- Update the checkbox options
function configUI:UpdateOptions()
    -- Loop through all checkboxes
    for name, checkbox in pairs(self.checkboxes) do
        if name:find("%.") then
            -- Handle nested keys
            local mainKey, subKey = name:match("([^.]+)%.(.+)")
            if addon.db[mainKey] then
                checkbox:SetChecked(addon.db[mainKey][subKey])
            end
        else
            -- Handle regular keys
            if name == "enabled" then
                checkbox:SetChecked(addon.db and addon.db.enabled)
            elseif name == "autoDecline" then
                checkbox:SetChecked(addon.db and addon.db.autoDecline)
            elseif name == "promptKick" then
                checkbox:SetChecked(addon.db and addon.db.promptKick)            elseif name == "showInTooltip" then
                checkbox:SetChecked(addon.db and addon.db.showInTooltip)
            elseif name == "promptIgnore" then
                checkbox:SetChecked(addon.db and addon.db.promptIgnore)            elseif name == "autoIgnore" then
                checkbox:SetChecked(addon.db and addon.db.autoIgnore)
            elseif name == "minimap" then
                checkbox:SetChecked(addon.db and addon.db.minimap and not addon.db.minimap.hide)
            elseif name == "debug" then
                checkbox:SetChecked(addon.db and addon.db.debug)
            end
        end
    end
end

-- Register the module
addon.configUI = configUI

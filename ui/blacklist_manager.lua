-- The Blacklist: Blacklist Manager UI
local addonName, addon = ...
local mainUI = {}

-- Initialize the main UI
function mainUI:Initialize()
    -- Create blacklist manager frame
    self:CreateBlacklistManager()
    
    -- Create Filter UI for content types and roles
    self:CreateFilterUI()
    
    -- Create Export/Import functionality
    self:CreateExportImportUI()
    
    addon:Debug("Main UI initialized")
end

-- Create the blacklist manager frame
function mainUI:CreateBlacklistManager()
    -- Main frame
    self.frame = CreateFrame("Frame", "BlacklistManagerFrame", UIParent, "BasicFrameTemplateWithInset")
    self.frame:SetSize(500, 400)
    self.frame:SetPoint("CENTER")
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", self.frame.StopMovingOrSizing)
    self.frame:Hide()
    
    -- Set title
    self.frame.title = self.frame:CreateFontString(nil, "OVERLAY")
    self.frame.title:SetFontObject("GameFontHighlight")
    self.frame.title:SetPoint("TOPLEFT", self.frame.TitleBg, "TOPLEFT", 5, 0)
    self.frame.title:SetText("The Blacklist - Manager")
    
    -- Create blacklist scrollframe
    self:CreateBlacklistScrollFrame()
    
    -- Create add blacklist section
    self:CreateAddBlacklistSection()
    
    -- Close button already exists in BasicFrameTemplate
    self.frame.CloseButton:SetScript("OnClick", function() self.frame:Hide() end)
end

-- Create the scrollframe to display blacklisted players
function mainUI:CreateBlacklistScrollFrame()
    -- Create the scroll frame
    self.scrollFrame = CreateFrame("ScrollFrame", "BlacklistScrollFrame", self.frame, "UIPanelScrollFrameTemplate")
    self.scrollFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -30)
    self.scrollFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -30, 100)
    
    -- Create the scroll child frame
    self.scrollChild = CreateFrame("Frame", "BlacklistScrollChild", self.scrollFrame)
    self.scrollChild:SetSize(self.scrollFrame:GetWidth(), 1) -- Height will be adjusted
    self.scrollFrame:SetScrollChild(self.scrollChild)
    
    -- Header
    self.headerFrame = CreateFrame("Frame", "BlacklistHeaderFrame", self.frame)
    self.headerFrame:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT", 0, 20)
    self.headerFrame:SetPoint("RIGHT", self.scrollFrame, "RIGHT", -16, 0)
    self.headerFrame:SetHeight(20)
    
    -- Header background
    self.headerBg = self.headerFrame:CreateTexture(nil, "BACKGROUND")
    self.headerBg:SetAllPoints()
    self.headerBg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
    
    -- Header columns
    self.nameHeader = self.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.nameHeader:SetPoint("TOPLEFT", self.headerFrame, "TOPLEFT", 5, 0)
    self.nameHeader:SetText("Name")
    
    self.reasonHeader = self.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.reasonHeader:SetPoint("LEFT", self.nameHeader, "RIGHT", 100, 0)
    self.reasonHeader:SetText("Reason")
    
    self.expiryHeader = self.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.expiryHeader:SetPoint("LEFT", self.reasonHeader, "RIGHT", 100, 0)
    self.expiryHeader:SetText("Expiry")
    
    self.actionsHeader = self.headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.actionsHeader:SetPoint("LEFT", self.expiryHeader, "RIGHT", 100, 0)
    self.actionsHeader:SetText("Actions")
end

-- Create the section for adding new blacklisted players
function mainUI:CreateAddBlacklistSection()
    -- Add blacklist section
    self.addSection = CreateFrame("Frame", "BlacklistAddSection", self.frame)
    self.addSection:SetPoint("TOPLEFT", self.scrollFrame, "BOTTOMLEFT", 0, -10)
    self.addSection:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -10, 10)
    
    -- Name label and editbox
    self.nameLabel = self.addSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.nameLabel:SetPoint("TOPLEFT", self.addSection, "TOPLEFT", 5, -5)
    self.nameLabel:SetText("Player Name:")
    
    self.nameEditBox = CreateFrame("EditBox", "BlacklistNameEditBox", self.addSection, "InputBoxTemplate")
    self.nameEditBox:SetPoint("TOPLEFT", self.nameLabel, "TOPRIGHT", 10, 0)
    self.nameEditBox:SetPoint("RIGHT", self.addSection, "CENTER", -10, 0)
    self.nameEditBox:SetHeight(20)
    self.nameEditBox:SetAutoFocus(false)
    
    -- Reason label and editbox
    self.reasonLabel = self.addSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.reasonLabel:SetPoint("TOPLEFT", self.nameLabel, "BOTTOMLEFT", 0, -15)
    self.reasonLabel:SetText("Reason:")
    
    self.reasonEditBox = CreateFrame("EditBox", "BlacklistReasonEditBox", self.addSection, "InputBoxTemplate")
    self.reasonEditBox:SetPoint("TOPLEFT", self.reasonLabel, "TOPRIGHT", 10, 0)
    self.reasonEditBox:SetPoint("RIGHT", self.addSection, "RIGHT", -10, 0)
    self.reasonEditBox:SetHeight(20)
    self.reasonEditBox:SetAutoFocus(false)
      -- Duration label and dropdown
    self.durationLabel = self.addSection:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.durationLabel:SetPoint("TOPLEFT", self.reasonLabel, "BOTTOMLEFT", 0, -15)
    self.durationLabel:SetText("Duration:")
    
    -- Add blacklist button
    self.addButton = CreateFrame("Button", "BlacklistAddButton", self.addSection, "UIPanelButtonTemplate")
    self.addButton:SetText("Add to Blacklist")
    self.addButton:SetWidth(120)
    self.addButton:SetHeight(24)
    self.addButton:SetPoint("BOTTOMRIGHT", self.addSection, "BOTTOMRIGHT", 0, 5)    self.addButton:SetScript("OnClick", function()
        local name = self.nameEditBox:GetText()
        local reason = self.reasonEditBox:GetText()
        
        if name and name ~= "" then
            -- Get content types
            local contentTypes = {}
            for typeName, checkbox in pairs(self.contentChecks or {}) do
                contentTypes[typeName] = checkbox:GetChecked()
            end
            
            -- Get roles
            local roles = {}
            for roleName, checkbox in pairs(self.roleChecks or {}) do
                roles[roleName] = checkbox:GetChecked()
            end
            
            -- Get duration
            local duration = self.selectedDuration or 0
            
            -- Add to blacklist with filters
            addon:BlacklistPlayer(name, reason ~= "" and reason or nil, duration, contentTypes, roles)
            self:UpdateBlacklist()
            self.nameEditBox:SetText("")
            self.reasonEditBox:SetText("")
        end
    end)
end

-- Create the blacklist filter UI
function mainUI:CreateFilterUI()
    -- Filter section frame
    self.filterFrame = CreateFrame("Frame", "BlacklistFilterFrame", self.frame)
    self.filterFrame:SetPoint("TOPLEFT", self.addSection, "BOTTOMLEFT", 0, -10)
    self.filterFrame:SetPoint("BOTTOMRIGHT", self.addSection, "BOTTOMRIGHT", 0, -80)
    
    -- Create background
    self.filterBg = self.filterFrame:CreateTexture(nil, "BACKGROUND")
    self.filterBg:SetAllPoints()
    self.filterBg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    
    -- Title
    self.filterTitle = self.filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.filterTitle:SetPoint("TOPLEFT", self.filterFrame, "TOPLEFT", 5, -5)
    self.filterTitle:SetText("Blacklist Filters")
    
    -- Duration section
    self.durationLabel = self.filterFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.durationLabel:SetPoint("TOPLEFT", self.filterTitle, "BOTTOMLEFT", 0, -10)
    self.durationLabel:SetText("Duration:")
    
    -- Duration options as radio buttons
    self.durationOptions = {
        { text = "Indefinite", value = 0 },
        { text = "1 Day", value = 86400 },
        { text = "1 Week", value = 604800 },
        { text = "1 Month", value = 2592000 }
    }
    
    self.durationRadios = {}
    local lastRadio
    
    for i, option in ipairs(self.durationOptions) do
        local radio = CreateFrame("CheckButton", "BlacklistDuration"..i, self.filterFrame, "UIRadioButtonTemplate")
        
        if i == 1 then
            radio:SetPoint("TOPLEFT", self.durationLabel, "BOTTOMLEFT", 5, -5)
        else
            radio:SetPoint("LEFT", lastRadio, "RIGHT", 70, 0)
        end
        
        _G[radio:GetName().."Text"]:SetText(option.text)
        radio.value = option.value
        
        radio:SetScript("OnClick", function(self)
            -- Uncheck all other radio buttons
            for _, r in pairs(mainUI.durationRadios) do
                if r ~= self then
                    r:SetChecked(false)
                end
            end
            self:SetChecked(true)
            mainUI.selectedDuration = self.value
        end)
        
        -- Set the default selected
        if i == 1 then
            radio:SetChecked(true)
            self.selectedDuration = option.value
        end
        
        self.durationRadios[i] = radio
        lastRadio = radio
    end
    
    -- Content types section
    self.contentLabel = self.filterFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.contentLabel:SetPoint("TOPLEFT", self.durationLabel, "BOTTOMLEFT", 0, -30)
    self.contentLabel:SetText("Content Types:")
    
    -- Content type checkboxes
    self.contentChecks = {}
    local contentTypes = {
        { name = "mythicplus", label = "Mythic+" },
        { name = "raid", label = "Raid" },
        { name = "pvp", label = "PvP" },
        { name = "questing", label = "Questing" }
    }
    
    local lastCheck
    for i, content in ipairs(contentTypes) do
        local check = CreateFrame("CheckButton", "BlacklistContent"..content.name, self.filterFrame, "UICheckButtonTemplate")
        
        if i == 1 then
            check:SetPoint("TOPLEFT", self.contentLabel, "BOTTOMLEFT", 5, -5)
        else
            check:SetPoint("LEFT", lastCheck, "RIGHT", 60, 0)
        end
        
        _G[check:GetName().."Text"]:SetText(content.label)
        check:SetChecked(true)
        check.contentType = content.name
        
        self.contentChecks[content.name] = check
        lastCheck = check
    end
    
    -- Roles section
    self.roleLabel = self.filterFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.roleLabel:SetPoint("TOPLEFT", self.contentLabel, "BOTTOMLEFT", 0, -40)
    self.roleLabel:SetText("Roles:")
    
    -- Role checkboxes
    self.roleChecks = {}
    local roles = {
        { name = "tank", label = "Tank" },
        { name = "healer", label = "Healer" },
        { name = "dps", label = "DPS" }
    }
    
    local lastRoleCheck
    for i, role in ipairs(roles) do
        local check = CreateFrame("CheckButton", "BlacklistRole"..role.name, self.filterFrame, "UICheckButtonTemplate")
        
        if i == 1 then
            check:SetPoint("TOPLEFT", self.roleLabel, "BOTTOMLEFT", 5, -5)
        else
            check:SetPoint("LEFT", lastRoleCheck, "RIGHT", 70, 0)
        end
        
        _G[check:GetName().."Text"]:SetText(role.label)
        check:SetChecked(true)
        check.roleType = role.name
        
        self.roleChecks[role.name] = check
        lastRoleCheck = check
    end
end

-- Update the blacklist display
function mainUI:UpdateBlacklist()
    -- First, clear existing entries
    for _, child in ipairs({self.scrollChild:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    if not addon.db or not addon.db.blacklist then return end
    
    -- Sort blacklist entries by name
    local sortedEntries = {}
    for name, data in pairs(addon.db.blacklist) do
        table.insert(sortedEntries, {name = name, data = data})
    end
    
    table.sort(sortedEntries, function(a, b) return a.name < b.name end)
    
    -- Create entry frames for each blacklisted player
    local yOffset = -5
    local rowHeight = 25
    
    for i, entry in ipairs(sortedEntries) do
        local entryFrame = CreateFrame("Frame", "BlacklistEntry" .. i, self.scrollChild)
        entryFrame:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 5, yOffset)
        entryFrame:SetPoint("RIGHT", self.scrollChild, "RIGHT", -5, 0)
        entryFrame:SetHeight(rowHeight)
        
        -- Row background (alternate colors)
        local bg = entryFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        if i % 2 == 0 then
            bg:SetColorTexture(0.2, 0.2, 0.2, 0.3)
        else
            bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        end
        
        -- Name
        local nameText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nameText:SetPoint("TOPLEFT", entryFrame, "TOPLEFT", 0, 0)
        nameText:SetWidth(100)
        nameText:SetText(entry.name)
        nameText:SetWordWrap(false)
        nameText:SetJustifyH("LEFT")
        
        -- Reason
        local reasonText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        reasonText:SetPoint("LEFT", nameText, "RIGHT", 0, 0)
        reasonText:SetWidth(100)
        reasonText:SetText(entry.data.reason or "")
        reasonText:SetWordWrap(false)
        reasonText:SetJustifyH("LEFT")
        
        -- Expiry
        local expiryText = entryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        expiryText:SetPoint("LEFT", reasonText, "RIGHT", 0, 0)
        expiryText:SetWidth(100)
        
        if entry.data.duration and entry.data.duration > 0 and entry.data.expiresAt then
            local timeLeft = math.max(0, entry.data.expiresAt - time())
            local days = math.floor(timeLeft / 86400)
            local hours = math.floor((timeLeft % 86400) / 3600)
            
            if days > 0 then
                expiryText:SetText(string.format("%d days %d hrs", days, hours))
            elseif hours > 0 then
                expiryText:SetText(string.format("%d hours", hours))
            else
                expiryText:SetText("Expires soon")
            end
        else
            expiryText:SetText("Indefinite")
        end
        
        -- Remove button
        local removeButton = CreateFrame("Button", "BlacklistRemoveButton" .. i, entryFrame)
        removeButton:SetSize(20, 20)
        removeButton:SetPoint("LEFT", expiryText, "RIGHT", 0, 0)
        removeButton:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
        removeButton:SetHighlightTexture("Interface\\Buttons\\UI-StopButton", "ADD")
        removeButton:SetScript("OnClick", function()
            addon:RemoveFromBlacklist(entry.name)
            self:UpdateBlacklist()
        end)
        
        yOffset = yOffset - rowHeight - 2
    end
    
    -- Update the scroll child's height
    self.scrollChild:SetHeight(math.abs(yOffset) + 5)
end

-- Create the export/import UI
function mainUI:CreateExportImportUI()
    -- Export Button
    self.exportButton = CreateFrame("Button", "BlacklistExportButton", self.frame, "UIPanelButtonTemplate")
    self.exportButton:SetText("Export")
    self.exportButton:SetWidth(80)
    self.exportButton:SetHeight(24)
    self.exportButton:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 10, 10)
    self.exportButton:SetScript("OnClick", function()
        self:ShowExportDialog()
    end)
    
    -- Import Button
    self.importButton = CreateFrame("Button", "BlacklistImportButton", self.frame, "UIPanelButtonTemplate")
    self.importButton:SetText("Import")
    self.importButton:SetWidth(80)
    self.importButton:SetHeight(24)
    self.importButton:SetPoint("LEFT", self.exportButton, "RIGHT", 5, 0)
    self.importButton:SetScript("OnClick", function()
        self:ShowImportDialog()
    end)
    
    -- Create Export Dialog
    if not StaticPopupDialogs["BLACKLIST_EXPORT_DIALOG"] then
        StaticPopupDialogs["BLACKLIST_EXPORT_DIALOG"] = {
            text = "Copy the text below to share your blacklist:",
            button1 = "Close",
            OnShow = function(self, data)
                local exportString = addon:ExportBlacklist()
                self.editBox:SetText(exportString)
                self.editBox:HighlightText()
                self.editBox:SetFocus()
            end,
            hasEditBox = true,
            editBoxWidth = 350,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end
    
    -- Create Import Dialog
    if not StaticPopupDialogs["BLACKLIST_IMPORT_DIALOG"] then
        StaticPopupDialogs["BLACKLIST_IMPORT_DIALOG"] = {
            text = "Paste the blacklist string to import:",
            button1 = "Import",
            button2 = "Cancel",
            OnAccept = function(self)
                local importString = self.editBox:GetText()
                local success, message = addon:ImportBlacklist(importString)
                
                if success then
                    print("|cFF33FF99Blacklist:|r " .. message)
                    mainUI:UpdateBlacklist()
                else
                    print("|cFFFF0000Blacklist Error:|r " .. message)
                end
            end,
            hasEditBox = true,
            editBoxWidth = 350,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end
end

-- Show export dialog
function mainUI:ShowExportDialog()
    StaticPopup_Show("BLACKLIST_EXPORT_DIALOG")
end

-- Show import dialog
function mainUI:ShowImportDialog()
    StaticPopup_Show("BLACKLIST_IMPORT_DIALOG")
end

-- Show the blacklist manager UI
function mainUI:ShowManager()
    self:UpdateBlacklist()
    self.frame:Show()
end

-- Register the module
addon.mainUI = mainUI

-- The Blacklist: Minimap Button
local addonName, addon = ...
local minimapModule = {}

-- Initialize the minimap module
function minimapModule:Initialize()
    self:CreateMinimapButton()
    addon:Debug("Minimap module initialized")
end

-- Create the minimap button
function minimapModule:CreateMinimapButton()
    -- Default minimap button position
    if not addon.db.minimap then
        addon.db.minimap = {
            hide = false,
            position = 225,
            radius = 80,
        }
    end

    -- Create the button frame
    self.button = CreateFrame("Button", "BlacklistMinimapButton", Minimap)
    self.button:SetSize(32, 32)
    self.button:SetFrameStrata("MEDIUM")
    self.button:SetFrameLevel(8)
    
    -- Set the button texture
    self.button:SetNormalTexture("Interface\\AddOns\\blacklist\\assets\\logo_small.jpg")
    self.button:SetPushedTexture("Interface\\AddOns\\blacklist\\assets\\logo_small.jpg")
    
    -- Set the highlight texture with a slight glow
    local highlight = self.button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints()
    
    -- Position the button on the minimap
    self:UpdateMinimapPosition()
    
    -- Set up mouse events
    self.button:EnableMouse(true)
    self.button:SetMovable(false)
      -- Set button scripts
    self.button:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if addon.mainUI and addon.mainUI.ShowManager then
                addon.mainUI:ShowManager()
            else
                addon:Debug("MainUI not initialized yet")
            end
        elseif button == "RightButton" then
            if addon.configUI and addon.configUI.ShowConfig then
                addon.configUI:ShowConfig()
            else
                addon:Debug("ConfigUI not initialized yet")
            end
        end
    end)
    
    self.button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("The Blacklist")
        GameTooltip:AddLine("Left-Click: Open Blacklist Manager", 1, 1, 1)
        GameTooltip:AddLine("Right-Click: Open Settings", 1, 1, 1)
        GameTooltip:AddLine("Shift-Drag: Move Button", 0.7, 0.7, 1)
        GameTooltip:Show()
    end)
    
    self.button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    self.button:RegisterForDrag("LeftButton")
    self.button:SetScript("OnDragStart", function(self)
        if IsShiftKeyDown() then
            self:StartMoving()
            self.isDragging = true
        end
    end)
    
    self.button:SetScript("OnDragStop", function(self)
        if self.isDragging then
            self:StopMovingOrSizing()
            self.isDragging = false
            minimapModule:UpdateMinimapPosition()
        end
    end)
    
    -- Register for updates to handle dragging
    self.button:SetScript("OnUpdate", function()
        if self.isDragging then
            minimapModule:UpdateDragPosition()
        end
    end)
    
    -- Show or hide based on settings
    self.button:SetShown(not addon.db.minimap.hide)
end

-- Update the position based on current settings
function minimapModule:UpdateMinimapPosition()
    if not self.button then return end
    
    local angle = math.rad(addon.db.minimap.position or 225)
    local radius = addon.db.minimap.radius or 80
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius
    
    self.button:ClearAllPoints()
    self.button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Update position during dragging
function minimapModule:UpdateDragPosition()
    if not self.button or not self.button.isDragging then return end
    
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    
    px, py = px / scale, py / scale
    
    local angle = math.deg(math.atan2(py - my, px - mx))
    if angle < 0 then angle = angle + 360 end
    
    addon.db.minimap.position = angle
    self:UpdateMinimapPosition()
end

-- Toggle button visibility
function minimapModule:ToggleMinimapButton()
    addon.db.minimap.hide = not addon.db.minimap.hide
    self.button:SetShown(not addon.db.minimap.hide)
end

-- Register the module
addon.minimapModule = minimapModule

-- The Blacklist: Database handling
local addonName, addon = ...

-- Utility function for deep copying tables
function addon:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Initialize database
function addon:InitializeDB()
    -- Set up default DB if none exists
    BlacklistDB = BlacklistDB or {}
    
    -- Check for and apply any data migrations if needed
    self:CheckDBVersion()
    
    -- Initialize the DB with defaults for any missing values
    self.db = BlacklistDB
    
    -- Set default values for any missing entries
    if not self.db.version then 
        self.db.version = addon.VERSION 
    end
    
    if not self.db.enabled then 
        self.db.enabled = addon.defaults.enabled 
    end
    
    if not self.db.autoDecline then 
        self.db.autoDecline = addon.defaults.autoDecline 
    end
      if not self.db.promptKick then 
        self.db.promptKick = addon.defaults.promptKick 
    end
    
    if not self.db.showInTooltip then 
        self.db.showInTooltip = addon.defaults.showInTooltip 
    end
    
    -- Initialize new settings
    if not self.db.promptIgnore then
        self.db.promptIgnore = addon.defaults.promptIgnore
    end
      if not self.db.autoIgnore then
        self.db.autoIgnore = addon.defaults.autoIgnore
    end
    
    if not self.db.debug then 
        self.db.debug = addon.defaults.debug 
    end
      if not self.db.filters then
        -- Use a deep copy function to copy the filters table
        self.db.filters = self:DeepCopy(addon.defaults.filters)
    end
    
    -- Initialize the blacklist table if it doesn't exist
    if not self.db.blacklist then
        self.db.blacklist = {}
    end
    
    self:Debug("Database initialized")
end

-- Check DB version and perform migrations if needed
function addon:CheckDBVersion()
    if not BlacklistDB.version or BlacklistDB.version ~= addon.VERSION then
        self:MigrateDB(BlacklistDB.version or "0")
        BlacklistDB.version = addon.VERSION
    end
end

-- Migrate database from older versions
function addon:MigrateDB(oldVersion)
    self:Debug("Migrating database from version", oldVersion, "to", addon.VERSION)
    -- Migration logic would go here as needed
    
    -- Example migration:
    -- if oldVersion == "0.9" then
    --    -- Convert data from 0.9 format to 1.0 format
    -- end
    
    -- For initial release, nothing to migrate
end

-- Reset database to defaults
function addon:ResetDB()
    wipe(BlacklistDB)
    self:InitializeDB()
    self:Debug("Database reset to defaults")
    print("|cFF33FF99Blacklist:|r Database has been reset to default settings.")
end

-- Export blacklist to string
function addon:ExportBlacklist()
    if not self.db.blacklist then return "" end
    
    local exportTable = {}
    for name, data in pairs(self.db.blacklist) do
        table.insert(exportTable, {
            name = name,
            reason = data.reason,
            addedAt = data.addedAt,
            duration = data.duration,
            expiresAt = data.expiresAt,
            contentTypes = data.contentTypes,
            roles = data.roles
        })
    end
    
    -- Convert to Base64 encoded string for easier sharing
    -- This is a simplified approach; a real addon might use proper serialization
    local serialized = self:TableToString(exportTable)
    return serialized
end

-- Convert a table to a string representation
function addon:TableToString(tbl)
    if type(tbl) ~= "table" then return tostring(tbl) end
    
    local result = "{"
    for k, v in pairs(tbl) do
        -- Handle the key
        if type(k) == "string" then
            result = result .. "[\"" .. k .. "\"]="
        else
            result = result .. "[" .. tostring(k) .. "]="
        end
        
        -- Handle the value
        if type(v) == "table" then
            result = result .. self:TableToString(v)
        elseif type(v) == "string" then
            result = result .. "\"" .. v .. "\""
        else
            result = result .. tostring(v)
        end
        result = result .. ","
    end
    
    -- Remove trailing comma and close the table
    if result:sub(-1) == "," then
        result = result:sub(1, -2)
    end
    result = result .. "}"
    
    return result
end

-- Import blacklist from string
function addon:ImportBlacklist(importString)
    if not importString or importString == "" then
        return false, "Import string is empty"
    end    local success, importTable = pcall(function()
        -- This is unsafe but simplified for example purposes
        -- In a real addon, use a proper deserialization library
        local func, err = loadstring("return " .. importString)
        if func then
            return func()
        else
            error(err)
        end
    end)
    
    if not success or type(importTable) ~= "table" then
        self:Debug("Import failed: Invalid import string")
        return false, "Invalid import string format"
    end
    
    -- Process imported entries
    local importCount = 0
    for _, entry in ipairs(importTable) do
        if entry.name then
            -- Add or update entry in blacklist
            self.db.blacklist[entry.name] = {
                name = entry.name,
                reason = entry.reason or "Imported - No reason specified",
                addedAt = entry.addedAt or time(),
                duration = entry.duration or 0,
                expiresAt = entry.expiresAt or 0,
                contentTypes = entry.contentTypes or self:DeepCopy(addon.defaults.filters.content),
                roles = entry.roles or self:DeepCopy(addon.defaults.filters.roles)
            }
            importCount = importCount + 1
        end
    end
    
    self:Debug("Imported " .. importCount .. " entries")
    return true, "Successfully imported " .. importCount .. " blacklist entries"
end

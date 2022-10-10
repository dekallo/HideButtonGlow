local addonName, addon = ...

-- globals
local GetSpellInfo, tinsert, tremove, tContains, tonumber = GetSpellInfo, tinsert, tremove, tContains, tonumber

function GetOptions()
    return {
        order = 1,
        type = "group",
        name = "Hide Button Glow",
        args = {
            general = {
                order = 1,
                type = "group",
                name = "Options",
                args = {
                    spacer = {
                        order = 1,
                        type = "description",
                        name = ""
                    },
                    hideAll = {
                        order = 2,
                        type = "toggle",
                        name = "Hide all glows",
                        desc = "Hide all spell glows, except for those under \"Allowed Spells\".",
                        get = function()
                            return HideButtonGlowDB.hideAll
                        end,
                        set = function()
                            HideButtonGlowDB.hideAll = not HideButtonGlowDB.hideAll
                        end
                    },
                    debugMode = {
                        order = 3,
                        type = "toggle",
                        name = "Debug mode",
                        desc = "Prints all filtered/unfiltered spells to chat. Useful for finding spell IDs, or checking how your settings work.",
                        get = function()
                            return HideButtonGlowDB.debugMode
                        end,
                        set = function()
                            HideButtonGlowDB.debugMode = not HideButtonGlowDB.debugMode
                        end
                    },
                    hiddenSpellHeader = {
                        order = 4,
                        type = "header",
                        name = "Filtered Spells",
                        hidden = function()
                            return HideButtonGlowDB.hideAll
                        end
                    },
                    hiddenSpellDescription = {
                        order = 5,
                        type = "description",
                        name = "Input spell names or spell IDs to prevent button glow for those abilities.",
                        hidden = function()
                            return HideButtonGlowDB.hideAll
                        end
                    },
                    hiddenSpellAdd = {
                        order = 6,
                        type = "input",
                        width = "full",
                        name = "Add",
                        desc = "Type a spell name or spell ID to prevent it from glowing.",
                        get = function() return "" end,
                        set = function(info, value)
                            local spellId = tonumber(value)
                            if spellId ~= nil then
                                local name = GetSpellInfo(spellId)
                                if name then
                                    if tContains(HideButtonGlowDB.spells, spellId) then
                                        addon:AddMessage(("ID %2$d already filtered as spell %1$s."):format(name, spellId))
                                    else
                                        addon:AddMessage(("Filtering button glow for spell %s with ID %d."):format(name, spellId))
                                        tinsert(HideButtonGlowDB.spells, spellId)
                                    end
                                else
                                    addon:AddMessage(("Invalid spell ID: %s"):format(value))
                                end
                            else
                                local name, _, _, _, _, _, spellId = GetSpellInfo(value)
                                if spellId then
                                    if tContains(HideButtonGlowDB.spells, spellId) then
                                        addon:AddMessage(("\"%3$s\" already filtered as spell %1$s with ID %2$d."):format(name, spellId, value))
                                    else
                                        addon:AddMessage(("Filtering button glow for \"%3$s\" as spell %1$s with ID %2$d."):format(name, spellId, value))
                                        tinsert(HideButtonGlowDB.spells, spellId)
                                    end
                                else
                                    addon:AddMessage(("Invalid spell name: %s"):format(value))
                                end
                            end
                        end,
                        hidden = function()
                            return HideButtonGlowDB.hideAll
                        end
                    },
                    hiddenSpellDelete = {
                        order = 7,
                        type = "select",
                        width = "full",
                        name = "Delete",
                        desc = "Delete an existing filtered spell.",
                        get = false,
                        set = function(info, index)
                            local spellId = HideButtonGlowDB.spells[index]
                            local name = GetSpellInfo(spellId)
                            addon:AddMessage(("Removing button glow filter for spell %s with ID %d."):format(name, spellId))
                            tremove(HideButtonGlowDB.spells, index)
                        end,
                        values = function()
                            local spellNames = {}
                            for _, spellId in ipairs(HideButtonGlowDB.spells) do
                                local name = GetSpellInfo(spellId)
                                tinsert(spellNames, name)
                            end
                            return spellNames
                        end,
                        disabled = function()
                            return #HideButtonGlowDB.spells == 0
                        end,
                        hidden = function()
                            return HideButtonGlowDB.hideAll
                        end
                    },
                    allowedSpellHeader = {
                        order = 9,
                        type = "header",
                        name = "Allowed Spells",
                        hidden = function()
                            return not HideButtonGlowDB.hideAll
                        end
                    },
                    allowedSpellDescription = {
                        order = 10,
                        type = "description",
                        name = "Input spell names or spell IDs for buttons which will always be allowed to glow, bypassing the \"Hide all glows\" setting.",
                        hidden = function()
                            return not HideButtonGlowDB.hideAll
                        end
                    },
                    allowedSpellAdd = {
                        order = 11,
                        type = "input",
                        width = "full",
                        name = "Add",
                        desc = "Type a spell name or spell ID to always allow it to glow.",
                        get = function() return "" end,
                        set = function(info, value)
                            local spellId = tonumber(value)
                            if spellId ~= nil then
                                local name = GetSpellInfo(spellId)
                                if name then
                                    if tContains(HideButtonGlowDB.allowedSpells, spellId) then
                                        addon:AddMessage(("ID %2$d already allowed as spell %1$s."):format(name, spellId))
                                    else
                                        addon:AddMessage(("Allowing button glow for spell %s with ID %d."):format(name, spellId))
                                        tinsert(HideButtonGlowDB.allowedSpells, spellId)
                                    end
                                else
                                    addon:AddMessage(("Invalid spell ID: %s"):format(value))
                                end
                            else
                                local name, _, _, _, _, _, spellId = GetSpellInfo(value)
                                if spellId then
                                    if tContains(HideButtonGlowDB.allowedSpells, spellId) then
                                        addon:AddMessage(("\"%3$s\" already allowed as spell %s with ID %d."):format(name, spellId, value))
                                    else
                                        addon:AddMessage(("Allowing button glow for \"%3$s\" as spell %1$s with ID %2$d."):format(name, spellId, value))
                                        tinsert(HideButtonGlowDB.allowedSpells, spellId)
                                    end
                                else
                                    addon:AddMessage(("Invalid spell name: %s"):format(value))
                                end
                            end
                        end,
                        hidden = function()
                            return not HideButtonGlowDB.hideAll
                        end
                    },
                    allowedSpellDelete = {
                        order = 12,
                        type = "select",
                        width = "full",
                        name = "Delete",
                        desc = "Delete an existing allowed spell.",
                        get = false,
                        set = function(info, index)
                            local spellId = HideButtonGlowDB.allowedSpells[index]
                            local name = GetSpellInfo(spellId)
                            addon:AddMessage(("Removing allowed button glow for spell %s with ID %d."):format(name, spellId))
                            tremove(HideButtonGlowDB.allowedSpells, index)
                        end,
                        values = function()
                            local spellNames = {}
                            for _, spellId in ipairs(HideButtonGlowDB.allowedSpells) do
                                local name = GetSpellInfo(spellId)
                                tinsert(spellNames, name)
                            end
                            return spellNames
                        end,
                        disabled = function()
                            return #HideButtonGlowDB.allowedSpells == 0
                        end,
                        hidden = function()
                            return not HideButtonGlowDB.hideAll
                        end
                    }
                }
            }
        }
    }
end

LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(addonName, GetOptions)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, nil, nil, "general")

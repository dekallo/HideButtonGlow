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
                        desc = "Hide all spell glows, regardless of settings below.",
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
                    header = {
                        order = 4,
                        type = "header",
                        name = "Filtered Spells"
                    },
                    hiddenSpellAdd = {
                        order = 5,
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
                                        addon:addMessage("ID "..spellId.." already filtered as spell "..name..".")
                                    else
                                        addon:addMessage("Filtering button glow for spell "..name.." with ID "..spellId..".")
                                        tinsert(HideButtonGlowDB.spells, spellId)
                                    end
                                else
                                    addon:addMessage("Invalid spell ID: "..value)
                                end
                            else
                                local name, _, _, _, _, _, spellId = GetSpellInfo(value)
                                if spellId then
                                    if tContains(HideButtonGlowDB.spells, spellId) then
                                        addon:addMessage("\""..value.."\" already filtered as spell "..name.." with ID "..spellId..".")
                                    else
                                        addon:addMessage("Filtering button glow for \""..value.."\" as spell "..name.." with ID "..spellId..".")
                                        tinsert(HideButtonGlowDB.spells, spellId)
                                    end
                                else
                                    addon:addMessage("Invalid spell name: "..value)
                                end
                            end
                        end
                    },
                    hiddenSpellDelete = {
                        order = 6,
                        type = "select",
                        width = "full",
                        name = "Delete",
                        desc = "Delete an existing filtered spell",
                        get = false,
                        set = function(info, index)
                            local spellId = HideButtonGlowDB.spells[index]
                            local name = GetSpellInfo(spellId)
                            addon:addMessage("Removing button glow filter for spell "..name.." with ID "..spellId..".")
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
                        end
                    }
                }
            }
        }
    }
end

LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, GetOptions)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, nil, nil, "general")

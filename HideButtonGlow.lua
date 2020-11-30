local addon = CreateFrame('Frame')
addon.name = "HideButtonGlow"
addon:SetScript('OnEvent', function(self, event, ...)
    if self[event] then return self[event](...) end
end)
addon:RegisterEvent('PLAYER_LOGIN')

function addon:PLAYER_LOGIN()
    if not HideButtonGlowDB then
        HideButtonGlowDB = {}
        HideButtonGlowDB.hideAll = false
        HideButtonGlowDB.spells = {}
    end
end

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
                    spacer = {order = 1, type = "description", name = ""},
                    hideAll = {
                        order = 2,
                        type = "toggle",
                        name = "Hide all glows",
                        desc = "Hide all spell glows, regardless of settings below.",
                        get = function()
                            return HideButtonGlowDB.hideAll
                        end,
                        set = function()
                            local hide = not HideButtonGlowDB.hideAll
                            HideButtonGlowDB.hideAll = hide
                        end
                    },
                    header = {
                        order = 3,
                        type = "header",
                        name = "Filtered Spells"
                    },
                    hiddenSpellAdd = {
                        order = 4,
                        type = "input",
                        width = "full",
                        name = "Add",
                        desc = "Type a spell name or spell ID to prevent it from glowing.",
                        get = function() return "" end,
                        set = function(info, value)
                            local spellId = tonumber(value)
                            if spellId ~= nil then
                                -- TODO validate
                                tinsert(HideButtonGlowDB.spells, spellId)
                            else
                                -- TODO getspellinfo for text and validate
                            end
                        end
                    },
                    hiddenSpellDelete = {
                        order = 5,
                        type = "select",
                        width = "full",
                        name = "Delete",
                        desc = "Delete an existing filtered spell",
                        get = false,
                        set = function(key, value)
                            tremove(HideButtonGlowDB.spells, value)
                        end,
                        values = function()
                            -- TODO convert to spell names
                            return HideButtonGlowDB.spells
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

LibStub('AceConfig-3.0'):RegisterOptionsTable(addon.name, GetOptions)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addon.name, nil, nil, "general")

local glowLib = LibStub("LibButtonGlow-1.0", true)
local showGlow = glowLib.ShowOverlayGlow
function glowLib.ShowOverlayGlow(self)
    -- check if the 'hide all' option is set
    if HideButtonGlowDB.hideAll then
        print("hiding all")
        return
    end

    -- else iterate through filter list
    for _, spellToFilter in ipairs(HideButtonGlowDB.spells) do
        print("checking filter value " .. spellToFilter)
        if self:GetSpellId() == spellToFilter then
            print("filter match")
            return
        end
        print("filter didn't match spell id: " .. self:GetSpellId())
    end

    -- else show the glow
    print("showing glow for spell id: " .. self:GetSpellId())
    showGlow(self)
end

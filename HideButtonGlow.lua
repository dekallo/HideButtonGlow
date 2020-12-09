local addonName, addon = ...

-- globals
local CreateFrame, GetSpellInfo = CreateFrame, GetSpellInfo

local addonFrame = CreateFrame('Frame')
addonFrame:SetScript('OnEvent', function(self, event, ...)
    if self[event] then return self[event](...) end
end)
addonFrame:RegisterEvent('PLAYER_LOGIN')

function addonFrame:PLAYER_LOGIN()
    if not HideButtonGlowDB then
        HideButtonGlowDB = {}
        HideButtonGlowDB.hideAll = false
        HideButtonGlowDB.debugMode = false
        HideButtonGlowDB.spells = {}
        HideButtonGlowDB.allowedSpells = {}
    elseif not HideButtonGlowDB.allowedSpells then
        -- upgrade db for v3
        HideButtonGlowDB.allowedSpells = {}
    end
end

function addon:addMessage(message, debugOnly)
    if not debugOnly or HideButtonGlowDB.debugMode then
        DEFAULT_CHAT_FRAME:AddMessage(message)
    end
end

local glowLib = LibStub("LibButtonGlow-1.0", true)
local showGlow = glowLib.ShowOverlayGlow
function glowLib.ShowOverlayGlow(self)
    local spellId = self:GetSpellId()
    local spellName = GetSpellInfo(spellId)

    -- check if the 'hide all' option is set
    if HideButtonGlowDB.hideAll then
        for _, spellToAllow in ipairs(HideButtonGlowDB.allowedSpells) do
            if spellId == spellToAllow then
                addon:addMessage("Found in whitelist, allowing spell glow for "..spellName.." (ID "..spellId..").", true)
                return showGlow(self)
            end
        end
        addon:addMessage("Hide All is checked, hiding spell glow for "..spellName.." (ID"..spellId..").", true)
        return
    end

    -- else iterate through filter list
    for _, spellToFilter in ipairs(HideButtonGlowDB.spells) do
        if spellId == spellToFilter then
            addon:addMessage("Filter matched, hiding spell glow for "..spellName.." (ID "..spellId..").", true)
            return
        end
    end

    -- else show the glow
    addon:addMessage("No filters matched, allowing spell glow for "..spellName.." (ID "..spellId..").", true)
    return showGlow(self)
end

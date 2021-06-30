local addonName, addon = ...

-- globals
local CreateFrame, GetSpellInfo, GetActionInfo, GetMacroSpell = CreateFrame, GetSpellInfo, GetActionInfo, GetMacroSpell

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

function addon:shouldHideGlow(spellId)
    local spellName = GetSpellInfo(spellId)

    -- check if the 'hide all' option is set
    if HideButtonGlowDB.hideAll then
        for _, spellToAllow in ipairs(HideButtonGlowDB.allowedSpells) do
            if spellId == spellToAllow then
                addon:addMessage("Found in whitelist, allowing spell glow for "..spellName.." (ID "..spellId..").", true)
                return false
            end
        end
        addon:addMessage("Hide All is checked, hiding spell glow for "..spellName.." (ID"..spellId..").", true)
        return true
    end

    -- else iterate through filter list
    for _, spellToFilter in ipairs(HideButtonGlowDB.spells) do
        if spellId == spellToFilter then
            addon:addMessage("Filter matched, hiding spell glow for "..spellName.." (ID "..spellId..").", true)
            return true
        end
    end

    -- else show the glow
    addon:addMessage("No filters matched, allowing spell glow for "..spellName.." (ID "..spellId..").", true)
    return false
end

-- hide LibButtonGlow based glows
local glowLib = LibStub("LibButtonGlow-1.0", true)
if glowLib and glowLib.ShowOverlayGlow then
    local showGlow = glowLib.ShowOverlayGlow
    function glowLib.ShowOverlayGlow(self)
        local spellId = self:GetSpellId()

        if addon:shouldHideGlow(spellId) then
            return
        end

        return showGlow(self)
    end
end

-- hide default blizzard button glows
local function PreventGlow(actionButton)
    if (actionButton.action) then
        local spellType, id = GetActionInfo(actionButton.action)

        local spellId
        if spellType == "spell" then
            spellId = id
        elseif spellType == "macro" then
            spellId = GetMacroSpell(id)
        end

        if addon:shouldHideGlow(spellId) then
            actionButton.overlay:Hide()
        end
    end
end
hooksecurefunc('ActionButton_ShowOverlayGlow', PreventGlow)

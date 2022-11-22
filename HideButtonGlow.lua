local addonName, addon = ...

-- globals
local CreateFrame, GetSpellInfo, GetActionInfo, GetMacroSpell, DEFAULT_CHAT_FRAME, InterfaceOptionsFrame_OpenToCategory = CreateFrame, GetSpellInfo, GetActionInfo, GetMacroSpell, DEFAULT_CHAT_FRAME, InterfaceOptionsFrame_OpenToCategory

local addonFrame = CreateFrame('Frame')
addonFrame:SetScript('OnEvent', function(self, event, ...)
    if self[event] then return self[event](self, ...) end
end)
addonFrame:RegisterEvent('PLAYER_LOGIN')
addonFrame:RegisterEvent("ADDON_LOADED")

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

function addonFrame:ADDON_LOADED(loadedAddon)
    if loadedAddon ~= addonName then
        return
    end
    self:UnregisterEvent("ADDON_LOADED")

    SlashCmdList.HideButtonGlow = function()
        InterfaceOptionsFrame_OpenToCategory(addonName)
        InterfaceOptionsFrame_OpenToCategory(addonName)
    end
    SLASH_HideButtonGlow1 = "/hbg"
end

function addon:AddMessage(message)
    DEFAULT_CHAT_FRAME:AddMessage(message)
end

function addon:ShouldHideGlow(spellId)
    -- check if the 'hide all' option is set
    if HideButtonGlowDB.hideAll then
        for _, spellToAllow in ipairs(HideButtonGlowDB.allowedSpells) do
            if spellId == spellToAllow then
                if HideButtonGlowDB.debugMode then
                    addon:AddMessage(("Found in allow list, allowing spell glow for %s (ID %d)."):format(GetSpellInfo(spellId), spellId))
                end
                return false
            end
        end
        if HideButtonGlowDB.debugMode then
            addon:AddMessage(("Hide All is checked, hiding spell glow for %s (ID %d)."):format(GetSpellInfo(spellId), spellId))
        end
        return true
    end

    -- else iterate through filter list
    for _, spellToFilter in ipairs(HideButtonGlowDB.spells) do
        if spellId == spellToFilter then
            if HideButtonGlowDB.debugMode then
                addon:AddMessage(("Filter matched, hiding spell glow for %s (ID %d)."):format(GetSpellInfo(spellId), spellId))
            end
            return true
        end
    end

    -- else show the glow
    if HideButtonGlowDB.debugMode then
        addon:AddMessage(("No filters matched, allowing spell glow for %s (ID %d)."):format(GetSpellInfo(spellId), spellId))
    end
    return false
end

-- prevent LibButtonGlow based glows from ever showing
local glowLib = LibStub("LibButtonGlow-1.0", true)
if glowLib and glowLib.ShowOverlayGlow then
    local showGlow = glowLib.ShowOverlayGlow
    function glowLib.ShowOverlayGlow(self)
        local spellId = self:GetSpellId()

        if spellId and addon:ShouldHideGlow(spellId) then
            return
        end

        return showGlow(self)
    end
end

-- hide default blizzard button glows
local function PreventGlow(actionButton)
    if actionButton and actionButton.action then
        local spellType, id = GetActionInfo(actionButton.action)

        local spellId
        if spellType == "spell" then
            spellId = id
        elseif spellType == "macro" then
            spellId = GetMacroSpell(id)
        end

        if spellId and addon:ShouldHideGlow(spellId) then
            if actionButton.overlay then
                -- classic, pre 10.0.2
                actionButton.overlay:Hide()
            end
            if actionButton.SpellActivationAlert then
                -- dragonflight, post 10.0.2
                actionButton.SpellActivationAlert:Hide()
            end
        end
    end
end
hooksecurefunc('ActionButton_ShowOverlayGlow', PreventGlow)

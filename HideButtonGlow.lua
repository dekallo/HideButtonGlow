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

local glowLib = LibStub("LibButtonGlow-1.0", true)
local showGlow = glowLib.ShowOverlayGlow
function glowLib.ShowOverlayGlow(self)
    -- check if the 'hide all' option is set
    if HideButtonGlowDB.hideAll then
        --print("hiding all")
        return
    end

    -- else iterate through filter list
    for _, spellToFilter in ipairs(HideButtonGlowDB.spells) do
        --print("checking filter value " .. spellToFilter)
        if self:GetSpellId() == spellToFilter then
            --print("filter match")
            return
        end
        --print("filter didn't match spell id: " .. self:GetSpellId())
    end

    -- else show the glow
    --print("showing glow for spell id: " .. self:GetSpellId())
    showGlow(self)
end

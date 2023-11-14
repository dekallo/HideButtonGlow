local addonName, addon = ...

-- globals
local CreateFrame, GetSpellInfo, GetActionInfo, GetMacroSpell, DEFAULT_CHAT_FRAME, InterfaceOptionsFrame_OpenToCategory = CreateFrame, GetSpellInfo, GetActionInfo, GetMacroSpell, DEFAULT_CHAT_FRAME, InterfaceOptionsFrame_OpenToCategory

local eventFrame = CreateFrame('Frame')
eventFrame:SetScript('OnEvent', function(self, event, ...)
	if self[event] then return self[event](self, ...) end
end)
eventFrame:RegisterEvent('PLAYER_LOGIN')
eventFrame:RegisterEvent("ADDON_LOADED")

function eventFrame:PLAYER_LOGIN()
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

function eventFrame:ADDON_LOADED(loadedAddon)
	if loadedAddon ~= addonName then
		return
	end
	self:UnregisterEvent("ADDON_LOADED")

	SlashCmdList.HideButtonGlow = function()
		-- call this twice to ensure it opens to the right category
		InterfaceOptionsFrame_OpenToCategory(addonName)
		InterfaceOptionsFrame_OpenToCategory(addonName)
	end
	SLASH_HideButtonGlow1 = "/hbg"
	SLASH_HideButtonGlow2 = "/hidebuttonglow"
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
local LibButtonGlow = LibStub("LibButtonGlow-1.0", true)
if LibButtonGlow and LibButtonGlow.ShowOverlayGlow then
	local OriginalShowOverlayGlow = LibButtonGlow.ShowOverlayGlow
	function LibButtonGlow.ShowOverlayGlow(self)
		local spellId = self:GetSpellId()
		if spellId and addon:ShouldHideGlow(spellId) then
			return
		end
		return OriginalShowOverlayGlow(self)
	end
end

-- prevent ElvUI bar glows from ever showing
-- ElvUI adds a ShowOverlayGlow function to LibCustomGlow
if ElvUI then
	local E = unpack(ElvUI)
	local LibCustomGlow = E and E.Libs and E.Libs.CustomGlow
	if LibCustomGlow and LibCustomGlow.ShowOverlayGlow then
		local OriginalShowOverlayGlow = LibCustomGlow.ShowOverlayGlow
		function LibCustomGlow.ShowOverlayGlow(self)
			local spellId = self:GetSpellId()
			if spellId and addon:ShouldHideGlow(spellId) then
				return
			end
			return OriginalShowOverlayGlow(self)
		end
	end
end

-- hide default blizzard button glows
local function PreventGlow(actionButton)
	if actionButton and actionButton.action then
		local spellType, id = GetActionInfo(actionButton.action)
		-- only check spell and macro glows
		if id and (spellType == "spell" or spellType == "macro") and addon:ShouldHideGlow(id) then
			if actionButton.SpellActivationAlert then
				-- dragonflight, post 10.0.2
				actionButton.SpellActivationAlert:Hide()
			elseif actionButton.overlay then
				-- classic, pre 10.0.2
				actionButton.overlay:Hide()
			end
		end
	end
end
hooksecurefunc('ActionButton_ShowOverlayGlow', PreventGlow)

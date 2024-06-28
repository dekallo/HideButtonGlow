local addonName, addon = ...

-- globals
local CreateFrame, GetActionInfo, DEFAULT_CHAT_FRAME, Settings = CreateFrame, GetActionInfo, DEFAULT_CHAT_FRAME, Settings

-- TWW uses C_Spell, compatibility code for older clients
local GetSpellName = C_Spell and C_Spell.GetSpellName or GetSpellInfo

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if self[event] then return self[event](self, event, ...) end
end)
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")

function eventFrame:PLAYER_LOGIN(event)
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
	self:UnregisterEvent(event)
end

function eventFrame:ADDON_LOADED(event, loadedAddon)
	if loadedAddon ~= addonName then
		return
	end
	self:UnregisterEvent(event)
	SlashCmdList.HideButtonGlow = function()
		Settings.OpenToCategory(addonName)
	end
	SLASH_HideButtonGlow1 = "/hbg"
	SLASH_HideButtonGlow2 = "/hidebuttonglow"
end

function addon:AddMessage(message)
	DEFAULT_CHAT_FRAME:AddMessage(message)
end

function addon:ShouldHideGlow(spellId)
	-- check if the "hide all" option is set
	if HideButtonGlowDB.hideAll then
		for i = 1, #HideButtonGlowDB.allowedSpells do
			if spellId == HideButtonGlowDB.allowedSpells[i] then
				if HideButtonGlowDB.debugMode then
					self:AddMessage(("Found in allow list, allowing spell glow for %s (ID %d)."):format(GetSpellName(spellId), spellId))
				end
				return false
			end
		end
		if HideButtonGlowDB.debugMode then
			self:AddMessage(("Hide All is checked, hiding spell glow for %s (ID %d)."):format(GetSpellName(spellId), spellId))
		end
		return true
	end
	-- else iterate through filter list
	for i = 1, #HideButtonGlowDB.spells do
		if spellId == HideButtonGlowDB.spells[i] then
			if HideButtonGlowDB.debugMode then
				self:AddMessage(("Filter matched, hiding spell glow for %s (ID %d)."):format(GetSpellName(spellId), spellId))
			end
			return true
		end
	end
	-- else show the glow
	if HideButtonGlowDB.debugMode then
		self:AddMessage(("No filters matched, allowing spell glow for %s (ID %d)."):format(GetSpellName(spellId), spellId))
	end
	return false
end

-- LibButtonGlow

do
	local LibButtonGlow = LibStub("LibButtonGlow-1.0", true)
	if LibButtonGlow and LibButtonGlow.ShowOverlayGlow then
		local OriginalShowOverlayGlow = LibButtonGlow.ShowOverlayGlow
		function LibButtonGlow.ShowOverlayGlow(self)
			local spellId = self:GetSpellId()
			if not spellId or not addon:ShouldHideGlow(spellId) then
				return OriginalShowOverlayGlow(self)
			end
		end
	end
end

-- ElvUI

if ElvUI then
	local E = unpack(ElvUI)
	local LibCustomGlow = E and E.Libs and E.Libs.CustomGlow
	-- ElvUI adds a ShowOverlayGlow function to LibCustomGlow where there was not one before
	if LibCustomGlow and LibCustomGlow.ShowOverlayGlow then
		local OriginalShowOverlayGlow = LibCustomGlow.ShowOverlayGlow
		function LibCustomGlow.ShowOverlayGlow(self)
			local spellId = self.GetSpellId and self:GetSpellId()
			if not spellId or not addon:ShouldHideGlow(spellId) then
				return OriginalShowOverlayGlow(self)
			end
		end
	end
end

-- Dominos

if Dominos then
	-- since version 10.2.5-beta1, Dominos defines their own ActionButton instead of reusing the buttons
	-- from the default Blizzard bars.
	local ActionButton = Dominos.ActionButton
	if ActionButton and ActionButton.ShowOverlayGlow then
		local OriginalShowOverlayGlow = ActionButton.ShowOverlayGlow
		function ActionButton.ShowOverlayGlow(self)
			local spellType, id = GetActionInfo(self.action)
			-- only check spell and macro glows
			if not id or not (spellType == "spell" or spellType == "macro") or not addon:ShouldHideGlow(id) then
				return OriginalShowOverlayGlow(self)
			end
		end
	end
end

-- Blizzard Bars

hooksecurefunc("ActionButton_ShowOverlayGlow", function(actionButton)
	if actionButton and actionButton.action then
		local spellType, id = GetActionInfo(actionButton.action)
		-- only check spell and macro glows
		if id and (spellType == "spell" or spellType == "macro") and addon:ShouldHideGlow(id) then
			if actionButton.SpellActivationAlert then
				-- Retail, post 10.0.2
				actionButton.SpellActivationAlert:Hide()
			elseif actionButton.overlay then
				-- Cata Classic, pre 10.0.2
				actionButton.overlay:Hide()
			end
		end
	end
end)

local addonName, HideButtonGlow = ...

local CreateFrame, GetActionInfo, DEFAULT_CHAT_FRAME, Settings, GetSpellName = CreateFrame, GetActionInfo, DEFAULT_CHAT_FRAME, Settings, C_Spell.GetSpellName
local L = LibStub("AceLocale-3.0"):GetLocale("HideButtonGlow")

local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", function(self, event, ...)
	if self[event] then return self[event](self, event, ...) end
end)
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:RegisterEvent("ADDON_LOADED")

function EventFrame:PLAYER_LOGIN(event)
	self:UnregisterEvent(event)
	-- set up and validate db
	if not HideButtonGlowDB then
		HideButtonGlowDB = {}
	end
	if type(HideButtonGlowDB.hideAll) ~= "boolean" then
		HideButtonGlowDB.hideAll = false
	end
	if type(HideButtonGlowDB.debugMode) ~= "boolean" then
		HideButtonGlowDB.debugMode = false
	end
	if type(HideButtonGlowDB.filtered) ~= "table" then
		HideButtonGlowDB.filtered = {}
		-- migrate old db if present
		if type(HideButtonGlowDB.spells) == "table" then
			for i = 1, #HideButtonGlowDB.spells do
				HideButtonGlowDB.filtered[HideButtonGlowDB.spells[i]] = GetSpellName(HideButtonGlowDB.spells[i])
			end
			HideButtonGlowDB.spells = nil
		end
	end
	if type(HideButtonGlowDB.allowed) ~= "table" then
		HideButtonGlowDB.allowed = {}
		-- migrate old db if present
		if type(HideButtonGlowDB.allowedSpells) == "table" then
			for i = 1, #HideButtonGlowDB.allowedSpells do
				HideButtonGlowDB.allowed[HideButtonGlowDB.allowedSpells[i]] = GetSpellName(HideButtonGlowDB.allowedSpells[i])
			end
			HideButtonGlowDB.allowedSpells = nil
		end
	end
end

function EventFrame:ADDON_LOADED(event, loadedAddon)
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

function HideButtonGlow:AddMessage(message)
	DEFAULT_CHAT_FRAME:AddMessage(("|cFF00FF98HideButtonGlow|r: %s"):format(message))
end

function HideButtonGlow:AddDebugMessageWithSpell(message, spellId)
	if HideButtonGlowDB.debugMode then
		self:AddMessage(message:format(GetSpellName(spellId), spellId))
	end
end

function HideButtonGlow:ShouldHideGlow(spellId)
	-- check if the "hide all" option is set
	if HideButtonGlowDB.hideAll then
		if HideButtonGlowDB.allowed[spellId] then
			self:AddDebugMessageWithSpell(L.debug_allowed, spellId)
			return false
		end
		self:AddDebugMessageWithSpell(L.debug_filtered, spellId)
		return true
	end
	-- else check filter list
	if HideButtonGlowDB.filtered[spellId] then
		self:AddDebugMessageWithSpell(L.debug_filtered, spellId)
		return true
	end
	-- else show the glow
	self:AddDebugMessageWithSpell(L.debug_allowed, spellId)
	return false
end

-- LibButtonGlow

do
	local LibButtonGlow = LibStub("LibButtonGlow-1.0", true)
	if LibButtonGlow and LibButtonGlow.ShowOverlayGlow then
		local OriginalShowOverlayGlow = LibButtonGlow.ShowOverlayGlow
		function LibButtonGlow.ShowOverlayGlow(self)
			local spellId = self:GetSpellId()
			if not spellId or not HideButtonGlow:ShouldHideGlow(spellId) then
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
			if not spellId or not HideButtonGlow:ShouldHideGlow(spellId) then
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
			if not id or not (spellType == "spell" or spellType == "macro") or not HideButtonGlow:ShouldHideGlow(id) then
				return OriginalShowOverlayGlow(self)
			end
		end
	end
end

-- Blizzard Bars

if ActionButtonSpellAlertManager and C_ActionBar.IsAssistedCombatAction then -- Retail (11.1.7+)
	local IsAssistedCombatAction = C_ActionBar.IsAssistedCombatAction
	hooksecurefunc(ActionButtonSpellAlertManager, "ShowAlert", function(actionButton)
		if actionButton and actionButton.activeAlerts then
			for activeAlert in pairs(actionButton.activeAlerts) do
				local action = activeAlert.action
				if not action then
					-- don't hide glows from buttons that don't have actions (PTR issue reporter)
					return
				end
				local spellType, id = GetActionInfo(action)
				-- only check spell and macro glows
				if id and (spellType == "spell" or spellType == "macro") and HideButtonGlow:ShouldHideGlow(id) then
					if IsAssistedCombatAction(action) then
						-- hide matched glows on the Single-Button Assistant button
						if activeAlert.AssistedCombatRotationFrame and activeAlert.AssistedCombatRotationFrame.SpellActivationAlert then
							activeAlert.AssistedCombatRotationFrame.SpellActivationAlert:Hide()
						end
					elseif activeAlert.SpellActivationAlert then
						-- hide matched glows on regular action bars
						activeAlert.SpellActivationAlert:Hide()
					end
				end
			end
		end
	end)
else -- Classic, Retail (pre 11.1.7)
	hooksecurefunc("ActionButton_ShowOverlayGlow", function(actionButton)
		if actionButton and actionButton.action then
			local spellType, id = GetActionInfo(actionButton.action)
			-- only check spell and macro glows
			if id and (spellType == "spell" or spellType == "macro") and HideButtonGlow:ShouldHideGlow(id) then
				if actionButton.SpellActivationAlert then
					-- Retail (10.0.2+)
					actionButton.SpellActivationAlert:Hide()
				elseif actionButton.overlay then
					-- Cata Classic, Mists Classic, Retail (pre 10.0.2)
					actionButton.overlay:Hide()
				end
			end
		end
	end)
end

td = "lua51"
max_line_length = false
codes = true
files["Locales/*.lua"].ignore = {
    "211/L"
}
ignore = {
    "212/self",
    "421" -- shadowing
}
globals = {
    "ActionButtonSpellAlertManager",
    "C_ActionBar",
    "C_Spell",
    "CreateFrame",
    "DEFAULT_CHAT_FRAME",
    "ElvUI",
    "GetActionInfo",
    "GetMacroSpell",
    "GetTime",
    "HideButtonGlowDB",
    "hooksecurefunc",
    "InCombatLockdown",
    "LibStub",
    "Settings",
    "SLASH_HideButtonGlow1",
    "SLASH_HideButtonGlow2",
    "SlashCmdList",
    "tonumber"
}

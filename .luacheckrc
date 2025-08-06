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
    "CreateFrame",
    "C_ActionBar",
    "C_Spell",
    "GetActionInfo",
    "GetMacroSpell",
    "GetTime",
    "hooksecurefunc",
    "tonumber",
    "LibStub",
    "HideButtonGlowDB",
    "DEFAULT_CHAT_FRAME",
    "Settings",
    "SlashCmdList",
    "SLASH_HideButtonGlow1",
    "SLASH_HideButtonGlow2",
    "ElvUI"
}

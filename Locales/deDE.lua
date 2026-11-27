local _, addon = ...

local baseLocale = {
    -- Shared picker labels
    ["ACTIVE_SPEC_SUFFIX"] = " (Aktiv)",
    ["UNASSIGNED"] = "Nicht zugewiesen",
    ["CLEAR_ASSIGNMENT"] = "Zuweisung löschen",
    ["NO_SPECIALIZATIONS"] = "Keine Spezialisierungen verfügbar.",
    ["CHAT_LOGS"] = "Chatmeldungen",
    ["WHEN_QUEUED"] = "Beim Vormerken",
    ["WHEN_EXECUTED"] = "Bei Ausführung",
    ["SEARCH"] = SEARCH or "Suchen",
    ["PREVIOUS"] = PREVIOUS or "Vorherige",
    ["NEXT"] = NEXT or "Weiter",

    -- Pets
    ["PETS"] = COMPANIONS or "Haustiere",
    ["APPLY_TO_SPEC"] = "Einer Spezialisierung zuweisen",
    ["PET_PICKER_INSTRUCTIONS"] = "Wähle eine Spezialisierung und dann ein Haustier aus deinem Haustierführer.",
    ["PET_FOR_SPEC"] = "Haustier für %s",
    ["PET_UNAVAILABLE"] = "Haustier nicht verfügbar",
    ["NO_COLLECTED_PETS"] = "Keine gesammelten Haustiere verfügbar.",
    ["NO_PETS_MATCH"] = "Keine Haustiere passen zu deiner Suche.",
    ["LEVEL_ABBR"] = LEVEL_ABBR or "St.",
    ["PET_SUMMON_QUEUED"] = "Haustierbeschwörung vorgemerkt%s.",
    ["PET_SUMMON_EXECUTED"] = "Haustier beschworen%s.",

    -- Titles
    ["SYNC_MANUAL_TITLE_CHANGES"] = "Manuelle Titelwechsel synchronisieren",
    ["TITLES"] = PAPERDOLL_SIDEBAR_TITLES or "Titel",
    ["TITLE_PICKER_INSTRUCTIONS"] = "Wähle eine Spezialisierung und dann einen Titel.",
    ["TITLE_FOR_SPEC"] = "Titel für %s",
    ["TITLE_UNAVAILABLE"] = "Titel nicht verfügbar",
    ["NO_TITLES_MATCH"] = "Keine Titel passen zu deiner Suche.",
    ["KEEP_CURRENT_TITLE"] = "Aktuellen Titel beibehalten",
    ["NO_TITLE"] = PLAYER_TITLE_NONE or "Kein Titel",
    ["TITLE_CHANGE_QUEUED"] = "Titelwechsel vorgemerkt (%s).",
    ["TITLE_CHANGE_EXECUTED"] = "Titelwechsel ausgeführt (%s).",
}

addon:RegisterLocale("deDE", baseLocale)

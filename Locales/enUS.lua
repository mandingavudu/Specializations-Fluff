local _, addon = ...

local baseLocale = {
    -- Shared picker labels
    ["CHAT_PREFIX"] = "[Specializations Fluff] ",
    ["ACTIVE_SPEC_SUFFIX"] = " (Active)",
    ["UNASSIGNED"] = "Unassigned",
    ["CLEAR_ASSIGNMENT"] = "Clear assignment",
    ["NO_SPECIALIZATIONS"] = "No specializations available.",
    ["CHAT_LOGS"] = "Chat logs",
    ["WHEN_QUEUED"] = "When queued",
    ["WHEN_EXECUTED"] = "When executed",
    ["SEARCH"] = SEARCH or "Search",
    ["PREVIOUS"] = PREVIOUS or "Previous",
    ["NEXT"] = NEXT or "Next",

    -- Pets
    ["PETS"] = "Pets",
    ["APPLY_TO_SPEC"] = "Apply to Spec",
    ["PET_PICKER_INSTRUCTIONS"] = "Choose a specialization, then select a pet from your Pet Journal.",
    ["PET_FOR_SPEC"] = "Pet for %s",
    ["PET_UNAVAILABLE"] = "Pet unavailable",
    ["NO_COLLECTED_PETS"] = "No collected pets available.",
    ["NO_PETS_MATCH"] = "No pets match your search.",
    ["LEVEL_ABBR"] = LEVEL_ABBR or "Lv.",
    ["PET_SUMMON_QUEUED"] = "Pet summon queued%s.",
    ["PET_SUMMON_EXECUTED"] = "Pet summoned%s.",

    -- Titles
    ["TITLES"] = PAPERDOLL_SIDEBAR_TITLES or "Titles",
    ["TITLE_PICKER_INSTRUCTIONS"] = "Choose a specialization, then select a title.",
    ["TITLE_FOR_SPEC"] = "Title for %s",
    ["TITLE_UNAVAILABLE"] = "Title unavailable",
    ["NO_TITLES_MATCH"] = "No titles match your search.",
    ["KEEP_CURRENT_TITLE"] = "No-Op",
    ["NO_TITLE"] = PLAYER_TITLE_NONE or "No Title",
    ["TITLE_CHANGE_QUEUED"] = "Title change queued (%s).",
    ["TITLE_CHANGE_EXECUTED"] = "Title change executed (%s).",
}

addon:RegisterLocale("enUS", baseLocale)

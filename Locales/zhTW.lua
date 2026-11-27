local _, addon = ...

local baseLocale = {
    -- Shared picker labels
    ["ACTIVE_SPEC_SUFFIX"] = "（目前）",
    ["UNASSIGNED"] = "未指派",
    ["CLEAR_ASSIGNMENT"] = "清除指派",
    ["NO_SPECIALIZATIONS"] = "沒有可用的專精。",
    ["CHAT_LOGS"] = "聊天視窗訊息",
    ["WHEN_QUEUED"] = "加入佇列時",
    ["WHEN_EXECUTED"] = "執行時",
    ["SEARCH"] = SEARCH or "搜尋",
    ["PREVIOUS"] = PREVIOUS or "往前",
    ["NEXT"] = NEXT or "繼續",

    -- Pets
    ["PETS"] = PETS or "寵物",
    ["APPLY_TO_SPEC"] = "指派給專精",
    ["PET_PICKER_INSTRUCTIONS"] = "選擇一個專精，然後從寵物日誌中選擇一隻寵物。",
    ["PET_FOR_SPEC"] = "寵物（%s）",
    ["PET_UNAVAILABLE"] = "寵物無法使用",
    ["NO_COLLECTED_PETS"] = "收藏中沒有可用的寵物。",
    ["NO_PETS_MATCH"] = "沒有符合搜尋條件的寵物。",
    ["LEVEL_ABBR"] = LEVEL_ABBR or "Lv",
    ["PET_SUMMON_QUEUED"] = "寵物召喚已加入佇列%s。",
    ["PET_SUMMON_EXECUTED"] = "已召喚寵物%s。",

    -- Titles
    ["TITLES"] = PAPERDOLL_SIDEBAR_TITLES or "頭銜",
    ["TITLE_PICKER_INSTRUCTIONS"] = "選擇一個專精，然後選擇一個頭銜。",
    ["TITLE_FOR_SPEC"] = "頭銜（%s）",
    ["TITLE_UNAVAILABLE"] = "頭銜無法使用",
    ["NO_TITLES_MATCH"] = "沒有符合搜尋條件的頭銜。",
    ["KEEP_CURRENT_TITLE"] = "保留目前的頭銜",
    ["NO_TITLE"] = PLAYER_TITLE_NONE or "無頭銜",
    ["TITLE_CHANGE_QUEUED"] = "頭銜變更已加入佇列（%s）。",
    ["TITLE_CHANGE_EXECUTED"] = "已變更頭銜（%s）。",
}

addon:RegisterLocale("zhTW", baseLocale)

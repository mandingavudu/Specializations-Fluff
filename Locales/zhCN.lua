local _, addon = ...

local baseLocale = {
    -- Shared picker labels
    ["ACTIVE_SPEC_SUFFIX"] = "（当前）",
    ["UNASSIGNED"] = "未分配",
    ["CLEAR_ASSIGNMENT"] = "清除分配",
    ["NO_SPECIALIZATIONS"] = "没有可用的专精。",
    ["CHAT_LOGS"] = "聊天框消息",
    ["WHEN_QUEUED"] = "加入队列时",
    ["WHEN_EXECUTED"] = "执行时",
    ["WHEN_SYNCED"] = "同步时",
    ["SEARCH"] = SEARCH or "搜索",
    ["PREVIOUS"] = PREVIOUS or "返回",
    ["NEXT"] = NEXT or "下一页",

    -- Pets
    ["PETS"] = PETS or "宠物",
    ["APPLY_TO_SPEC"] = "分配给专精",
    ["PET_PICKER_INSTRUCTIONS"] = "选择一个专精，然后从宠物手册中选择一只宠物。",
    ["PET_FOR_SPEC"] = "宠物（%s）",
    ["PET_UNAVAILABLE"] = "宠物不可用",
    ["NO_COLLECTED_PETS"] = "收藏中没有可用的宠物。",
    ["NO_PETS_MATCH"] = "没有符合搜索条件的宠物。",
    ["LEVEL_ABBR"] = LEVEL_ABBR or "Lv",
    ["PET_SUMMON_QUEUED"] = "宠物召唤已加入队列%s。",
    ["PET_SUMMON_EXECUTED"] = "已召唤宠物%s。",

    -- Titles
    ["SYNC_MANUAL_TITLE_CHANGES"] = "同步手动更改的头衔",
    ["TITLES"] = PAPERDOLL_SIDEBAR_TITLES or "头衔",
    ["TITLE_PICKER_INSTRUCTIONS"] = "选择一个专精，然后选择一个头衔。",
    ["TITLE_FOR_SPEC"] = "头衔（%s）",
    ["TITLE_UNAVAILABLE"] = "头衔不可用",
    ["NO_TITLES_MATCH"] = "没有符合搜索条件的头衔。",
    ["KEEP_CURRENT_TITLE"] = "保留当前头衔",
    ["NO_TITLE"] = PLAYER_TITLE_NONE or "无头衔",
    ["TITLE_CHANGE_QUEUED"] = "头衔变更已加入队列（%s）。",
    ["TITLE_CHANGE_EXECUTED"] = "已更改头衔（%s）。",
    ["TITLE_CHANGE_SYNCED"] = "已保存手动更改的头衔（%s）。",
}

addon:RegisterLocale("zhCN", baseLocale)

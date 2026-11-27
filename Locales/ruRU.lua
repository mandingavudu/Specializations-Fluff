local _, addon = ...

local baseLocale = {
    -- Shared picker labels
    ["ACTIVE_SPEC_SUFFIX"] = " (активная)",
    ["UNASSIGNED"] = "Не назначено",
    ["CLEAR_ASSIGNMENT"] = "Снять выбор",
    ["NO_SPECIALIZATIONS"] = "Нет доступных специализаций.",
    ["CHAT_LOGS"] = "Сообщения в чате",
    ["WHEN_QUEUED"] = "В очереди",
    ["WHEN_EXECUTED"] = "При выполнении",
    ["SEARCH"] = SEARCH or "Поиск",
    ["PREVIOUS"] = PREVIOUS or "Назад",
    ["NEXT"] = NEXT or "Далее",

    -- Pets
    ["PETS"] = PETS or "Питомцы",
    ["APPLY_TO_SPEC"] = "Назначить для специализации",
    ["PET_PICKER_INSTRUCTIONS"] = "Выберите специализацию и питомца из атласа питомцев.",
    ["PET_FOR_SPEC"] = "Питомец (%s)",
    ["PET_UNAVAILABLE"] = "Питомец недоступен",
    ["NO_COLLECTED_PETS"] = "В вашей коллекции нет доступных питомцев.",
    ["NO_PETS_MATCH"] = "По вашему запросу питомцы не найдены.",
    ["LEVEL_ABBR"] = LEVEL_ABBR or "Ур.",
    ["PET_SUMMON_QUEUED"] = "Призыв питомца поставлен в очередь%s.",
    ["PET_SUMMON_EXECUTED"] = "Питомец призван%s.",

    -- Titles
    ["SYNC_MANUAL_TITLE_CHANGES"] = "Синхронизировать ручную смену звания",
    ["TITLES"] = PAPERDOLL_SIDEBAR_TITLES or "Звания",
    ["TITLE_PICKER_INSTRUCTIONS"] = "Выберите специализацию и звание.",
    ["TITLE_FOR_SPEC"] = "Звание (%s)",
    ["TITLE_UNAVAILABLE"] = "Звание недоступно",
    ["NO_TITLES_MATCH"] = "По вашему запросу звания не найдены.",
    ["KEEP_CURRENT_TITLE"] = "Сохранить текущее звание",
    ["NO_TITLE"] = PLAYER_TITLE_NONE or "Без звания",
    ["TITLE_CHANGE_QUEUED"] = "Изменение звания поставлено в очередь (%s).",
    ["TITLE_CHANGE_EXECUTED"] = "Звание изменено (%s).",
}

addon:RegisterLocale("ruRU", baseLocale)

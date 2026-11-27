local _, addon = ...

local baseLocale = {
    -- Shared picker labels
    ["ACTIVE_SPEC_SUFFIX"] = " (활성)",
    ["UNASSIGNED"] = "미지정",
    ["CLEAR_ASSIGNMENT"] = "지정 해제",
    ["NO_SPECIALIZATIONS"] = "선택할 수 있는 전문화가 없습니다.",
    ["CHAT_LOGS"] = "대화창 메시지",
    ["WHEN_QUEUED"] = "대기열 등록 시",
    ["WHEN_EXECUTED"] = "실행 시",
    ["SEARCH"] = SEARCH or "검색",
    ["PREVIOUS"] = PREVIOUS or "이전",
    ["NEXT"] = NEXT or "다음",

    -- Pets
    ["PETS"] = "애완동물",
    ["APPLY_TO_SPEC"] = "전문화에 지정",
    ["PET_PICKER_INSTRUCTIONS"] = "전문화를 선택한 다음 애완동물 도감에서 애완동물을 선택하세요.",
    ["PET_FOR_SPEC"] = "%s 전문화의 애완동물",
    ["PET_UNAVAILABLE"] = "사용할 수 없는 애완동물",
    ["NO_COLLECTED_PETS"] = "수집한 애완동물 중 선택할 수 있는 것이 없습니다.",
    ["NO_PETS_MATCH"] = "검색 조건에 맞는 애완동물이 없습니다.",
    ["LEVEL_ABBR"] = LEVEL_ABBR or "레벨",
    ["PET_SUMMON_QUEUED"] = "애완동물 소환이 대기열에 등록되었습니다%s.",
    ["PET_SUMMON_EXECUTED"] = "애완동물을 소환했습니다%s.",

    -- Titles
    ["SYNC_MANUAL_TITLE_CHANGES"] = "수동 칭호 변경 동기화",
    ["TITLES"] = PAPERDOLL_SIDEBAR_TITLES or "칭호",
    ["TITLE_PICKER_INSTRUCTIONS"] = "전문화를 선택한 다음 칭호를 선택하세요.",
    ["TITLE_FOR_SPEC"] = "%s 전문화의 칭호",
    ["TITLE_UNAVAILABLE"] = "사용할 수 없는 칭호",
    ["NO_TITLES_MATCH"] = "검색 조건에 맞는 칭호가 없습니다.",
    ["KEEP_CURRENT_TITLE"] = "현재 칭호 유지",
    ["NO_TITLE"] = PLAYER_TITLE_NONE or "칭호 없음",
    ["TITLE_CHANGE_QUEUED"] = "칭호 변경이 대기열에 등록되었습니다 (%s).",
    ["TITLE_CHANGE_EXECUTED"] = "칭호를 변경했습니다 (%s).",
}

addon:RegisterLocale("koKR", baseLocale)

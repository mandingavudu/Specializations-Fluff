local _, addon = ...

local baseLocale = {
    -- Shared picker labels
    ["ACTIVE_SPEC_SUFFIX"] = " (Ativa)",
    ["UNASSIGNED"] = "Sem atribuição",
    ["CLEAR_ASSIGNMENT"] = "Limpar atribuição",
    ["NO_SPECIALIZATIONS"] = "Nenhuma especialização disponível.",
    ["CHAT_LOGS"] = "Mensagens no chat",
    ["WHEN_QUEUED"] = "Ao enfileirar",
    ["WHEN_EXECUTED"] = "Ao executar",
    ["SEARCH"] = SEARCH or "Procurar",
    ["PREVIOUS"] = PREVIOUS or "Anterior",
    ["NEXT"] = NEXT or "Próx.",

    -- Pets
    ["PETS"] = "Mascotes",
    ["APPLY_TO_SPEC"] = "Aplicar à especialização",
    ["PET_PICKER_INSTRUCTIONS"] = "Escolha uma especialização e selecione um mascote do seu Diário de Mascotes.",
    ["PET_FOR_SPEC"] = "Mascote para %s",
    ["PET_UNAVAILABLE"] = "Mascote indisponível",
    ["NO_COLLECTED_PETS"] = "Nenhum mascote coletado disponível.",
    ["NO_PETS_MATCH"] = "Nenhum mascote corresponde à sua busca.",
    ["LEVEL_ABBR"] = LEVEL_ABBR or "Nvl",
    ["PET_SUMMON_QUEUED"] = "Invocação de mascote na fila%s.",
    ["PET_SUMMON_EXECUTED"] = "Mascote invocado%s.",

    -- Titles
    ["SYNC_MANUAL_TITLE_CHANGES"] = "Sincronizar alterações manuais de título",
    ["TITLES"] = PAPERDOLL_SIDEBAR_TITLES or "Títulos",
    ["TITLE_PICKER_INSTRUCTIONS"] = "Escolha uma especialização e selecione um título.",
    ["TITLE_FOR_SPEC"] = "Título para %s",
    ["TITLE_UNAVAILABLE"] = "Título indisponível",
    ["NO_TITLES_MATCH"] = "Nenhum título corresponde à sua busca.",
    ["KEEP_CURRENT_TITLE"] = "Manter título atual",
    ["NO_TITLE"] = PLAYER_TITLE_NONE or "Sem título",
    ["TITLE_CHANGE_QUEUED"] = "Alteração de título na fila (%s).",
    ["TITLE_CHANGE_EXECUTED"] = "Alteração de título executada (%s).",
}

addon:RegisterLocale("ptBR", baseLocale)

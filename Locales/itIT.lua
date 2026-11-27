local _, addon = ...

local baseLocale = {
    -- Shared picker labels
    ["ACTIVE_SPEC_SUFFIX"] = " (Attiva)",
    ["UNASSIGNED"] = "Non assegnato",
    ["CLEAR_ASSIGNMENT"] = "Rimuovi scelta",
    ["NO_SPECIALIZATIONS"] = "Non ci sono specializzazioni disponibili.",
    ["CHAT_LOGS"] = "Messaggi in chat",
    ["WHEN_QUEUED"] = "All’accodamento",
    ["WHEN_EXECUTED"] = "All’esecuzione",
    ["SEARCH"] = SEARCH or "Cerca",
    ["PREVIOUS"] = PREVIOUS or "Precedente",
    ["NEXT"] = NEXT or "Avanti",

    -- Pets
    ["PETS"] = COMPANIONS or "Mascotte",
    ["APPLY_TO_SPEC"] = "Assegna a una specializzazione",
    ["PET_PICKER_INSTRUCTIONS"] = "Scegli una specializzazione, poi seleziona una mascotte nella scheda Mascotte.",
    ["PET_FOR_SPEC"] = "Mascotte per %s",
    ["PET_UNAVAILABLE"] = "Mascotte non disponibile",
    ["NO_COLLECTED_PETS"] = "Non ci sono mascotte disponibili nella tua collezione.",
    ["NO_PETS_MATCH"] = "Nessuna mascotte corrisponde alla ricerca.",
    ["LEVEL_ABBR"] = LEVEL_ABBR or "Liv",
    ["PET_SUMMON_QUEUED"] = "Evocazione della mascotte in coda%s.",
    ["PET_SUMMON_EXECUTED"] = "Mascotte evocata%s.",

    -- Titles
    ["SYNC_MANUAL_TITLE_CHANGES"] = "Sincronizza le modifiche manuali al titolo",
    ["TITLES"] = PAPERDOLL_SIDEBAR_TITLES or "Titoli",
    ["TITLE_PICKER_INSTRUCTIONS"] = "Scegli una specializzazione, poi seleziona un titolo.",
    ["TITLE_FOR_SPEC"] = "Titolo per %s",
    ["TITLE_UNAVAILABLE"] = "Titolo non disponibile",
    ["NO_TITLES_MATCH"] = "Nessun titolo corrisponde alla ricerca.",
    ["KEEP_CURRENT_TITLE"] = "Mantieni il titolo attuale",
    ["NO_TITLE"] = PLAYER_TITLE_NONE or "Nessun titolo",
    ["TITLE_CHANGE_QUEUED"] = "Cambio di titolo in coda (%s).",
    ["TITLE_CHANGE_EXECUTED"] = "Cambio di titolo applicato (%s).",
}

addon:RegisterLocale("itIT", baseLocale)

local _, addon = ...

local baseLocale = {
    -- Shared picker labels
    ["ACTIVE_SPEC_SUFFIX"] = " (Activa)",
    ["UNASSIGNED"] = "Sin asignar",
    ["CLEAR_ASSIGNMENT"] = "Quitar asignación",
    ["NO_SPECIALIZATIONS"] = "No hay especializaciones disponibles.",
    ["CHAT_LOGS"] = "Mensajes del chat",
    ["WHEN_QUEUED"] = "Al poner en cola",
    ["WHEN_EXECUTED"] = "Al ejecutar",
    ["WHEN_SYNCED"] = "Al sincronizar",
    ["SEARCH"] = SEARCH or "Buscar",
    ["PREVIOUS"] = PREVIOUS or "Anterior",
    ["NEXT"] = NEXT or "Sig.",

    -- Pets
    ["PETS"] = PETS or "Mascotas",
    ["APPLY_TO_SPEC"] = "Asignar a una especialización",
    ["PET_PICKER_INSTRUCTIONS"] = "Selecciona una especialización y luego elige una mascota de tu diario de mascotas.",
    ["PET_FOR_SPEC"] = "Mascota para %s",
    ["PET_UNAVAILABLE"] = "Mascota no disponible",
    ["NO_COLLECTED_PETS"] = "No hay mascotas disponibles en tu colección.",
    ["NO_PETS_MATCH"] = "No se encontraron mascotas para esta búsqueda.",
    ["LEVEL_ABBR"] = LEVEL_ABBR or "Niv",
    ["PET_SUMMON_QUEUED"] = "Invocación de mascota en cola%s.",
    ["PET_SUMMON_EXECUTED"] = "Mascota invocada%s.",

    -- Titles
    ["SYNC_MANUAL_TITLE_CHANGES"] = "Sincronizar cambios manuales de título",
    ["TITLES"] = PAPERDOLL_SIDEBAR_TITLES or "Títulos",
    ["TITLE_PICKER_INSTRUCTIONS"] = "Selecciona una especialización y luego elige un título.",
    ["TITLE_FOR_SPEC"] = "Título para %s",
    ["TITLE_UNAVAILABLE"] = "Título no disponible",
    ["NO_TITLES_MATCH"] = "No se encontraron títulos para esta búsqueda.",
    ["KEEP_CURRENT_TITLE"] = "Mantener el título actual",
    ["NO_TITLE"] = PLAYER_TITLE_NONE or "Sin título",
    ["TITLE_CHANGE_QUEUED"] = "Cambio de título en cola (%s).",
    ["TITLE_CHANGE_EXECUTED"] = "Cambio de título aplicado (%s).",
    ["TITLE_CHANGE_SYNCED"] = "Cambio manual de título guardado (%s).",
}

addon:RegisterLocale("esMX", baseLocale)

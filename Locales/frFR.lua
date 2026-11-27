local _, addon = ...

local baseLocale = {
    -- Shared picker labels
    ["ACTIVE_SPEC_SUFFIX"] = " (Active)",
    ["UNASSIGNED"] = "Non attribué",
    ["CLEAR_ASSIGNMENT"] = "Effacer le choix",
    ["NO_SPECIALIZATIONS"] = "Aucune spécialisation disponible.",
    ["CHAT_LOGS"] = "Messages dans le chat",
    ["WHEN_QUEUED"] = "Mise en file",
    ["WHEN_EXECUTED"] = "Exécution",
    ["SEARCH"] = SEARCH or "Recherche",
    ["PREVIOUS"] = PREVIOUS or "Précédent",
    ["NEXT"] = NEXT or "Suiv.",

    -- Pets
    ["PETS"] = COMPANIONS or "Mascottes",
    ["APPLY_TO_SPEC"] = "Attribuer à une spécialisation",
    ["PET_PICKER_INSTRUCTIONS"] = "Choisissez une spécialisation, puis une mascotte dans votre codex des mascottes.",
    ["PET_FOR_SPEC"] = "Mascotte pour %s",
    ["PET_UNAVAILABLE"] = "Mascotte indisponible",
    ["NO_COLLECTED_PETS"] = "Aucune mascotte de votre collection n’est disponible.",
    ["NO_PETS_MATCH"] = "Aucune mascotte ne correspond à votre recherche.",
    ["LEVEL_ABBR"] = LEVEL_ABBR or "Niv",
    ["PET_SUMMON_QUEUED"] = "Invocation de mascotte mise en file d’attente%s.",
    ["PET_SUMMON_EXECUTED"] = "Mascotte invoquée%s.",

    -- Titles
    ["SYNC_MANUAL_TITLE_CHANGES"] = "Synchroniser les changements manuels de titre",
    ["TITLES"] = PAPERDOLL_SIDEBAR_TITLES or "Titres",
    ["TITLE_PICKER_INSTRUCTIONS"] = "Choisissez une spécialisation, puis un titre.",
    ["TITLE_FOR_SPEC"] = "Titre pour %s",
    ["TITLE_UNAVAILABLE"] = "Titre indisponible",
    ["NO_TITLES_MATCH"] = "Aucun titre ne correspond à votre recherche.",
    ["KEEP_CURRENT_TITLE"] = "Conserver le titre actuel",
    ["NO_TITLE"] = PLAYER_TITLE_NONE or "Pas de titre",
    ["TITLE_CHANGE_QUEUED"] = "Changement de titre mis en file d’attente (%s).",
    ["TITLE_CHANGE_EXECUTED"] = "Changement de titre effectué (%s).",
}

addon:RegisterLocale("frFR", baseLocale)

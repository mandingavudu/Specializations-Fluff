local _, addon = ...
local isPortuguese = GetLocale() == "ptBR"
local title = PAPERDOLL_SIDEBAR_TITLES or (isPortuguese and "Títulos" or "Titles")

function addon.RegisterTitleOptions(parentCategory)
    local category, refresh = addon.RegisterSpecPicker(parentCategory, {
        title = title,
        instructions = isPortuguese and "Escolha uma especialização e selecione um título."
            or "Choose a specialization, then select a title.",
        heading = isPortuguese and "Título para %s" or "Title for %s",
        unavailable = isPortuguese and "Título indisponível" or "Title unavailable",
        noMatches = isPortuguese and "Nenhum título corresponde à sua busca." or "No titles match your search.",
        getCollection = addon.GetTitleCollection,
        getBinding = addon.GetTitleBinding,
        setBinding = addon.SetTitleBinding,
        defaultBinding = addon.TITLE_NO_OP,
        events = { "KNOWN_TITLES_UPDATE" },
    })
    addon.RefreshTitleOptions = refresh
    return category
end

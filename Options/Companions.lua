local _, addon = ...
local isPortuguese = GetLocale() == "ptBR"
local title = COMPANIONS or (isPortuguese and "Mascotes" or "Companions")

local function SetupCompanionRow(row)
    row.level = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    row.level:SetPoint("RIGHT", -8, 0)
    row.favoriteStar = row:CreateTexture(nil, "ARTWORK")
    row.favoriteStar:SetAtlas("PetJournal-FavoritesIcon")
    row.favoriteStar:SetSize(14, 14)
    row.favoriteStar:SetPoint("RIGHT", row.level, "LEFT", -4, 0)
    row.favoriteStar:Hide()
end

local function UpdateCompanionRow(row, pet)
    row.favoriteStar:SetShown(pet and pet.isFavorite or false)
    if pet then
        row.icon:SetTexture(pet.icon)
        row.level:SetText(pet.level > 0 and string.format("%s %d", LEVEL_ABBR or "Lv.", pet.level) or "")
    end
end

function addon.RegisterCompanionOptions(parentCategory)
    local category, refresh = addon.RegisterSpecPicker(parentCategory, {
        title = title,
        instructions = isPortuguese and "Escolha uma especialização e selecione um mascote da sua coleção."
            or "Choose a specialization, then select a companion from your collection.",
        heading = isPortuguese and "Mascote para %s" or "Companion for %s",
        unavailable = isPortuguese and "Mascote indisponível" or "Companion unavailable",
        emptyCollection = isPortuguese and "Nenhum mascote coletado disponível." or "No collected companions available.",
        noMatches = isPortuguese and "Nenhum mascote corresponde à sua busca." or "No companions match your search.",
        getCollection = addon.GetCompanionCollection,
        getBinding = addon.GetCompanionBinding,
        setBinding = addon.SetCompanionBinding,
        resultIcons = true,
        resultLabelInset = 72,
        setupResultRow = SetupCompanionRow,
        updateResultRow = UpdateCompanionRow,
        events = {
            "PET_JOURNAL_LIST_UPDATE", "NEW_PET_ADDED", "PET_JOURNAL_PET_DELETED",
            "PET_JOURNAL_PET_RESTORED", "PET_JOURNAL_PET_REVOKED",
        },
    })
    addon.RefreshCompanionOptions = refresh
    return category
end

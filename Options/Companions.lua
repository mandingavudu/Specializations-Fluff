local _, addon = ...
local journal = C_PetJournal
local isPortuguese = GetLocale() == "ptBR"
local title = isPortuguese and "Mascotes" or "Pets"
local applyToSpec = isPortuguese and "Aplicar à especialização" or "Apply to Spec"

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
        instructions = isPortuguese and "Escolha uma especialização e selecione um mascote do seu Diário de Mascotes."
            or "Choose a specialization, then select a pet from your Pet Journal.",
        heading = isPortuguese and "Mascote para %s" or "Pet for %s",
        unavailable = isPortuguese and "Mascote indisponível" or "Pet unavailable",
        emptyCollection = isPortuguese and "Nenhum mascote coletado disponível." or "No collected pets available.",
        noMatches = isPortuguese and "Nenhum mascote corresponde à sua busca." or "No pets match your search.",
        getCollection = addon.GetCompanionCollection,
        getBinding = addon.GetCompanionBinding,
        setBinding = addon.SetCompanionBinding,
        getLogSettings = addon.GetCompanionLogSettings,
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

Menu.ModifyMenu("MENU_PET_COLLECTION_PET", function(owner, rootDescription)
    -- The list row stores the pet ID itself. Icon and pet card buttons use their parent.
    local parent = owner:GetParent()
    local petID = owner.petID or (parent and parent.petID)
    if not petID or (journal.PetIsRevoked and journal.PetIsRevoked(petID)) then
        return
    end

    local specializations = addon.GetSpecializations()
    if #specializations == 0 then
        return
    end

    local submenu = rootDescription:CreateButton(applyToSpec)
    for _, spec in ipairs(specializations) do
        submenu:CreateButton(spec.name, function(specID)
            addon.SetCompanionBinding(specID, petID)
            if addon.RefreshCompanionOptions then
                addon.RefreshCompanionOptions()
            end
        end, spec.id)
    end
end)

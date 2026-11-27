local _, addon = ...
local L = addon.L
local journal = C_PetJournal

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
        row.level:SetText(pet.level > 0 and string.format("%s %d", L.LEVEL_ABBR, pet.level) or "")
    end
end

function addon.RegisterCompanionOptions(parentCategory)
    local category, refresh = addon.RegisterSpecPicker(parentCategory, {
        title = L.PETS,
        instructions = L.PET_PICKER_INSTRUCTIONS,
        heading = L.PET_FOR_SPEC,
        unavailable = L.PET_UNAVAILABLE,
        emptyCollection = L.NO_COLLECTED_PETS,
        noMatches = L.NO_PETS_MATCH,
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

    local submenu = rootDescription:CreateButton(L.APPLY_TO_SPEC)
    for _, spec in ipairs(specializations) do
        submenu:CreateButton(spec.name, function(specID)
            addon.SetCompanionBinding(specID, petID)
            if addon.RefreshCompanionOptions then
                addon.RefreshCompanionOptions()
            end
        end, spec.id)
    end
end)

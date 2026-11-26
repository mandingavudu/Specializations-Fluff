local _, addon = ...
local specInfo = C_SpecializationInfo
local title = COMPANIONS or (GetLocale() == "ptBR" and "Mascotes" or "Companions")
local pageSize = 6

local panel
local specRows = {}
local selectedSpecID
local pets, petsByGUID = {}, {}
local matches = {}
local page = 1

local function AddLabel(parent, font, point, x, y, text)
    local label = parent:CreateFontString(nil, "ARTWORK", font)
    label:SetPoint(point, x, y)
    label:SetText(text)
    return label
end

local function CreateRow(parent, height)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(height)
    local selection = row:CreateTexture(nil, "BACKGROUND")
    selection:SetAllPoints()
    selection:SetColorTexture(0.75, 0.54, 0.21, 0.22)
    row.selection = selection

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.12)
    row:SetHighlightTexture(highlight)

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(20, 20)
    row.icon:SetPoint("LEFT", 6, 0)
    row.label = AddLabel(row, "GameFontHighlight", "LEFT", 34, 0)
    row.label:SetJustifyH("LEFT")
    row.label:SetWordWrap(false)
    return row
end

function addon.RefreshCompanionOptions()
    if not panel or not panel:IsVisible() then
        return
    end
    local activeSpecID = addon.GetActiveSpecID()
    for _, row in ipairs(specRows) do
        local guid = addon.GetCompanionBinding(row.specID)
        local pet = petsByGUID[guid]
        row.label:SetText(row.specID == activeSpecID and (row.specName .. " (Active)") or row.specName)
        row.selection:SetShown(row.specID == selectedSpecID)
        row.binding:SetText(pet and pet.label or (guid and "Companion unavailable" or "Unassigned"))
    end
end

local function RefreshResults()
    local selectedGUID = addon.GetCompanionBinding(selectedSpecID)
    local maxPage = math.max(1, math.ceil(#matches / pageSize))
    page = math.min(page, maxPage)

    for index, row in ipairs(panel.results) do
        local pet = matches[(page - 1) * pageSize + index]
        row.guid = pet and pet.guid
        row:SetShown(pet ~= nil)
        row.favoriteStar:SetShown(pet and pet.isFavorite or false)
        if pet then
            row.label:SetText(pet.label)
            row.icon:SetTexture(pet.icon)
            row.level:SetText(pet.level > 0 and string.format("%s %d", LEVEL_ABBR or "Lv.", pet.level) or "")
            row.selection:SetShown(pet.guid == selectedGUID)
        end
    end
    panel.empty:SetText(#pets == 0 and "No collected companions available." or "No companions match your search.")
    panel.empty:SetShown(#matches == 0)
    panel.pageText:SetText(string.format("%d / %d", page, maxPage))
    panel.previous:SetEnabled(page > 1)
    panel.next:SetEnabled(page < maxPage)
    panel.clear:SetEnabled(selectedGUID ~= nil)
end

local function FilterResults()
    local query = panel.search:GetText():lower():match("^%s*(.-)%s*$")
    matches = {}
    for _, pet in ipairs(pets) do
        if pet.searchName:find(query, 1, true) then
            matches[#matches + 1] = pet
        end
    end
    page = 1
    RefreshResults()
end

local function SetBinding(guid)
    if not selectedSpecID then
        return
    end
    addon.SetCompanionBinding(selectedSpecID, guid)
    addon.RefreshCompanionOptions()
    if guid and panel.search:GetText() ~= "" then
        panel.search:SetText("")
    else
        RefreshResults()
    end
end

local function CreateButton(parent, label, width, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 24)
    button:SetText(label)
    button:SetScript("OnClick", onClick)
    return button
end

function addon.RegisterCompanionOptions(parentCategory)
    panel = CreateFrame("Frame")
    panel:Hide()
    AddLabel(panel, "GameFontNormalLarge", "TOPLEFT", 20, -18, title)
    AddLabel(panel, "GameFontHighlight", "TOPLEFT", 20, -46,
        "Choose a specialization, then select a companion from your collection.")

    local y = -74
    local _, _, classID = UnitClass("player")
    for index = 1, specInfo.GetNumSpecializationsForClassID(classID) do
        local id, name, _, icon = specInfo.GetSpecializationInfo(index)
        if id and id > 0 and name then
            local row = CreateRow(panel, 26)
            row:SetPoint("TOPLEFT", 20, y)
            row:SetPoint("TOPRIGHT", -20, y)
            row.icon:SetTexture(icon)
            row.specID, row.specName = id, name
            row.label:SetWidth(190)
            row.binding = AddLabel(row, "GameFontHighlightSmall", "LEFT", 236, 0)
            row.binding:SetPoint("RIGHT", -8, 0)
            row.binding:SetJustifyH("LEFT")
            row.binding:SetWordWrap(false)
            row:SetScript("OnClick", function()
                selectedSpecID = row.specID
                panel.pickerTitle:SetText("Companion for " .. row.specName)
                addon.RefreshCompanionOptions()
                RefreshResults()
            end)
            specRows[#specRows + 1] = row
            y = y - 28
        end
    end

    if #specRows == 0 then
        AddLabel(panel, "GameFontDisable", "TOPLEFT", 20, y, "No specializations available.")
    else
        panel.pickerTitle = AddLabel(panel, "GameFontNormal", "TOPLEFT", 20, y - 12)
        panel.clear = CreateButton(panel, "Clear assignment", 126, function() SetBinding(nil) end)
        panel.clear:SetPoint("TOPRIGHT", -20, y - 9)
        panel.clear:SetEnabled(false)

        AddLabel(panel, "GameFontHighlightSmall", "TOPLEFT", 20, y - 44, SEARCH or "Search")
        panel.search = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        panel.search:SetSize(230, 24)
        panel.search:SetPoint("TOPLEFT", 76, y - 38)
        panel.search:SetAutoFocus(false)
        panel.search:SetScript("OnEscapePressed", panel.search.ClearFocus)
        panel.search:SetScript("OnEnterPressed", panel.search.ClearFocus)

        panel.results = {}
        for index = 1, pageSize do
            local row = CreateRow(panel, 23)
            local rowY = y - 68 - (index - 1) * 24
            row:SetPoint("TOPLEFT", 20, rowY)
            row:SetPoint("TOPRIGHT", -20, rowY)
            row.label:SetPoint("RIGHT", -72, 0)
            row.level = AddLabel(row, "GameFontHighlightSmall", "RIGHT", -8, 0)
            row.favoriteStar = row:CreateTexture(nil, "ARTWORK")
            row.favoriteStar:SetAtlas("PetJournal-FavoritesIcon")
            row.favoriteStar:SetSize(14, 14)
            row.favoriteStar:SetPoint("RIGHT", row.level, "LEFT", -4, 0)
            row.favoriteStar:Hide()
            row:SetScript("OnClick", function(self)
                panel.search:ClearFocus()
                SetBinding(self.guid)
            end)
            row:Hide()
            panel.results[index] = row
        end

        panel.empty = AddLabel(panel, "GameFontDisable", "TOPLEFT", 20, y - 72)
        local controlsY = y - 68 - pageSize * 24 - 6
        panel.previous = CreateButton(panel, PREVIOUS or "Previous", 90, function()
            page = page - 1
            RefreshResults()
        end)
        panel.previous:SetPoint("TOPLEFT", 20, controlsY)
        panel.next = CreateButton(panel, NEXT or "Next", 90, function()
            page = page + 1
            RefreshResults()
        end)
        panel.next:SetPoint("TOPLEFT", 190, controlsY)
        panel.pageText = AddLabel(panel, "GameFontHighlightSmall", "TOPLEFT", 110, controlsY - 5)
        panel.pageText:SetWidth(80)
        panel.search:SetScript("OnTextChanged", FilterResults)

        local refreshPending = false
        local function RefreshCollection()
            if InCombatLockdown() then
                refreshPending = true
                return
            end
            refreshPending = false
            if not selectedSpecID then
                local activeSpecID = addon.GetActiveSpecID()
                local selected = specRows[1]
                for _, row in ipairs(specRows) do
                    if row.specID == activeSpecID then
                        selected = row
                        break
                    end
                end
                selectedSpecID = selected.specID
                panel.pickerTitle:SetText("Companion for " .. selected.specName)
            end
            pets, petsByGUID = addon.GetCompanionCollection()
            addon.RefreshCompanionOptions()
            FilterResults()
        end
        panel:SetScript("OnShow", RefreshCollection)
        for _, event in ipairs({
            "PET_JOURNAL_LIST_UPDATE", "NEW_PET_ADDED", "PET_JOURNAL_PET_DELETED",
            "PET_JOURNAL_PET_RESTORED", "PET_JOURNAL_PET_REVOKED",
        }) do
            panel:RegisterEvent(event)
        end
        panel:RegisterEvent("PLAYER_REGEN_ENABLED")
        panel:SetScript("OnEvent", function(_, event)
            if panel:IsVisible() and (event ~= "PLAYER_REGEN_ENABLED" or refreshPending) then
                RefreshCollection()
            end
        end)
    end

    return Settings.RegisterCanvasLayoutSubcategory(parentCategory, panel, title)
end

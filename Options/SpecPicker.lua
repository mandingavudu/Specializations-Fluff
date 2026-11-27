local _, addon = ...
local L = addon.L
local pageSize = 15

local function AddLabel(parent, font, point, x, y, text)
    local label = parent:CreateFontString(nil, "ARTWORK", font)
    label:SetPoint(point, x, y)
    label:SetText(text)
    return label
end

local function CreateRow(parent, height, withIcon)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(height)
    row.selection = row:CreateTexture(nil, "BACKGROUND")
    row.selection:SetAllPoints()
    row.selection:SetColorTexture(0.75, 0.54, 0.21, 0.22)

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.12)
    row:SetHighlightTexture(highlight)

    if withIcon then
        row.icon = row:CreateTexture(nil, "ARTWORK")
        local iconSize = math.min(20, height - 2)
        row.icon:SetSize(iconSize, iconSize)
        row.icon:SetPoint("LEFT", 6, 0)
    end
    row.label = AddLabel(row, "GameFontHighlight", "LEFT", withIcon and 34 or 8, 0)
    row.label:SetJustifyH("LEFT")
    row.label:SetWordWrap(false)
    return row
end

local function CreateButton(parent, label, width, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 24)
    button:SetText(label)
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateCheckbox(panel, text, checked, onChange)
    local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    checkbox:SetSize(22, 22)
    checkbox.label = checkbox:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    checkbox.label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
    checkbox.label:SetText(text)
    checkbox:SetChecked(checked)
    checkbox:SetScript("OnClick", function(self)
        onChange(self:GetChecked() == true)
    end)
    return checkbox
end

local function CreateLogCheckbox(panel, settings, key, text)
    return CreateCheckbox(panel, text, settings[key] == true, function(checked)
        settings[key] = checked
    end)
end

local function SetupLogHeader(panel, settings)
    local master = CreateLogCheckbox(panel, settings, "enabled", L.CHAT_LOGS)
    local queued = CreateLogCheckbox(panel, settings, "queued", L.WHEN_QUEUED)
    local executed = CreateLogCheckbox(panel, settings, "executed", L.WHEN_EXECUTED)
    master:SetPoint("TOPLEFT", 220, -13)
    queued:SetPoint("LEFT", master.label, "RIGHT", 14, 0)
    executed:SetPoint("LEFT", queued.label, "RIGHT", 14, 0)

    local function RefreshLogControls()
        local enabled = settings.enabled == true
        for _, checkbox in ipairs({ queued, executed }) do
            checkbox:SetEnabled(enabled)
            checkbox:SetAlpha(enabled and 1 or 0.5)
        end
    end

    master:HookScript("OnClick", RefreshLogControls)
    RefreshLogControls()
end

function addon.RegisterSpecPicker(parentCategory, picker)
    local panel = CreateFrame("Frame")
    panel:Hide()
    AddLabel(panel, "GameFontNormalLarge", "TOPLEFT", 20, -18, picker.title)
    AddLabel(panel, "GameFontHighlight", "TOPLEFT", 20, -46, picker.instructions)
    if picker.getLogSettings then
        SetupLogHeader(panel, picker.getLogSettings())
    end
    local y = -70
    if picker.headerCheckbox then
        local option = picker.headerCheckbox
        local checkbox = CreateCheckbox(panel, option.text, option.isChecked(), option.setChecked)
        checkbox:SetPoint("TOPLEFT", 16, -64)
        y = y - 24
    end

    local specRows = {}
    local selectedSpecID
    local entries, entriesByID, matches = {}, {}, {}
    local page = 1

    local function RefreshSpecializations()
        local activeSpecID = addon.GetActiveSpecID()
        for _, row in ipairs(specRows) do
            local binding = picker.getBinding(row.specID)
            local entry = entriesByID[binding]
            row.label:SetText(row.specID == activeSpecID and (row.specName .. L.ACTIVE_SPEC_SUFFIX) or row.specName)
            row.selection:SetShown(row.specID == selectedSpecID)
            row.binding:SetText(entry and entry.label or (binding ~= nil and picker.unavailable or L.UNASSIGNED))
        end
    end

    local function RefreshResults()
        local selected = picker.getBinding(selectedSpecID)
        local maxPage = math.max(1, math.ceil(#matches / pageSize))
        page = math.min(page, maxPage)

        for index, row in ipairs(panel.results) do
            local entry = matches[(page - 1) * pageSize + index]
            row.entryID = entry and entry.id
            row:SetShown(entry ~= nil)
            if entry then
                row.label:SetText(entry.label)
                row.selection:SetShown(entry.id == selected)
            end
            if picker.updateResultRow then
                picker.updateResultRow(row, entry)
            end
        end
        panel.empty:SetText(#entries == 0 and picker.emptyCollection or picker.noMatches)
        panel.empty:SetShown(#matches == 0)
        panel.pageText:SetText(string.format("%d / %d", page, maxPage))
        panel.previous:SetEnabled(page > 1)
        panel.next:SetEnabled(page < maxPage)
        panel.clear:SetEnabled(selected ~= nil and selected ~= picker.defaultBinding)
    end

    local function FilterResults()
        local query = strlower(strtrim(panel.search:GetText()))
        matches = {}
        for _, entry in ipairs(entries) do
            if entry.searchName:find(query, 1, true) then
                matches[#matches + 1] = entry
            end
        end
        page = 1
        RefreshResults()
    end

    local function SelectSpec(row)
        selectedSpecID = row.specID
        panel.pickerTitle:SetText(picker.heading:format(row.specName))
    end

    local function SetBinding(id)
        if not selectedSpecID then
            return
        end
        picker.setBinding(selectedSpecID, id)
        RefreshSpecializations()
        if id ~= nil and panel.search:GetText() ~= "" then
            panel.search:SetText("")
        else
            RefreshResults()
        end
    end

    for _, spec in ipairs(addon.GetSpecializations()) do
        local row = CreateRow(panel, 26, true)
        row:SetPoint("TOPLEFT", 20, y)
        row:SetPoint("TOPRIGHT", -20, y)
        row.icon:SetTexture(spec.icon)
        row.specID, row.specName = spec.id, spec.name
        row.label:SetWidth(190)
        row.binding = AddLabel(row, "GameFontHighlightSmall", "LEFT", 236, 0)
        row.binding:SetPoint("RIGHT", -8, 0)
        row.binding:SetJustifyH("LEFT")
        row.binding:SetWordWrap(false)
        row:SetScript("OnClick", function()
            SelectSpec(row)
            RefreshSpecializations()
            RefreshResults()
        end)
        specRows[#specRows + 1] = row
        y = y - 28
    end

    if #specRows == 0 then
        AddLabel(panel, "GameFontDisable", "TOPLEFT", 20, y, L.NO_SPECIALIZATIONS)
        return Settings.RegisterCanvasLayoutSubcategory(parentCategory, panel, picker.title), RefreshSpecializations
    end

    panel.pickerTitle = AddLabel(panel, "GameFontNormal", "TOPLEFT", 20, y - 12)
    panel.clear = CreateButton(panel, L.CLEAR_ASSIGNMENT, 126, function() SetBinding(nil) end)
    panel.clear:SetPoint("TOPRIGHT", -20, y - 9)
    panel.clear:SetEnabled(false)

    AddLabel(panel, "GameFontHighlightSmall", "TOPLEFT", 20, y - 44, L.SEARCH)
    panel.search = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    panel.search:SetSize(230, 24)
    panel.search:SetPoint("TOPLEFT", 76, y - 38)
    panel.search:SetAutoFocus(false)
    panel.search:SetScript("OnEscapePressed", panel.search.ClearFocus)
    panel.search:SetScript("OnEnterPressed", panel.search.ClearFocus)

    local resultHeight = 18
    local resultStride = resultHeight + 1
    local resultsY = y - 68
    panel.results = {}
    for index = 1, pageSize do
        local row = CreateRow(panel, resultHeight, picker.resultIcons)
        local rowY = resultsY - (index - 1) * resultStride
        row:SetPoint("TOPLEFT", 20, rowY)
        row:SetPoint("TOPRIGHT", -20, rowY)
        row.label:SetPoint("RIGHT", -(picker.resultLabelInset or 8), 0)
        if picker.setupResultRow then
            picker.setupResultRow(row)
        end
        row:SetScript("OnClick", function(self)
            panel.search:ClearFocus()
            SetBinding(self.entryID)
        end)
        row:Hide()
        panel.results[index] = row
    end

    panel.empty = AddLabel(panel, "GameFontDisable", "TOPLEFT", 20, y - 72)
    local controlsY = resultsY - pageSize * resultStride - 6
    panel.previous = CreateButton(panel, L.PREVIOUS, 90, function()
        page = page - 1
        RefreshResults()
    end)
    panel.previous:SetPoint("TOPLEFT", 20, controlsY)
    panel.next = CreateButton(panel, L.NEXT, 90, function()
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
            SelectSpec(selected)
        end
        entries, entriesByID = picker.getCollection()
        RefreshSpecializations()
        FilterResults()
    end
    panel:SetScript("OnShow", RefreshCollection)
    for _, event in ipairs(picker.events) do
        panel:RegisterEvent(event)
    end
    panel:RegisterEvent("PLAYER_REGEN_ENABLED")
    panel:SetScript("OnEvent", function(_, event)
        if panel:IsVisible() and (event ~= "PLAYER_REGEN_ENABLED" or refreshPending) then
            RefreshCollection()
        end
    end)

    local function RefreshBindings()
        if panel:IsVisible() then
            RefreshSpecializations()
            RefreshResults()
        end
    end

    return Settings.RegisterCanvasLayoutSubcategory(parentCategory, panel, picker.title), RefreshBindings
end

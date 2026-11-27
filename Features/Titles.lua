local _, addon = ...
local L = addon.L

local NO_OP = 0
local NO_TITLE = -1
local logFormats = {
    queued = L.TITLE_CHANGE_QUEUED,
    executed = L.TITLE_CHANGE_EXECUTED,
}
local inWorld = false
local activeSpecID
local assignmentPending = false
local keyListener
local queuedTitleID

addon.TITLE_NO_OP = NO_OP

function addon.GetTitleLogSettings()
    return addon.GetChatLogSettings("titleLogSettings")
end

local function LogTitleChange(kind, titleName)
    local settings = addon.GetTitleLogSettings()
    if settings.enabled == true and settings[kind] == true then
        addon.WriteChatLog(logFormats[kind]:format(titleName))
    end
end

local function GetPlayerTitleName(titleID)
    if IsTitleKnown(titleID) then
        local name, isPlayerTitle = GetTitleName(titleID)
        if name and isPlayerTitle then
            name = strtrim(name)
            if name ~= "" then
                return name
            end
        end
    end
end

function addon.GetTitleCollection()
    local titles, titlesByID = {}, {}
    for titleID = 1, GetNumTitles() do
        local name = GetPlayerTitleName(titleID)
        if name then
            local title = { id = titleID, label = name, searchName = strlower(name) }
            titles[#titles + 1] = title
            titlesByID[titleID] = title
        end
    end
    table.sort(titles, function(a, b)
        if a.searchName ~= b.searchName then
            return a.searchName < b.searchName
        end
        return a.id < b.id
    end)

    local noOp = { id = NO_OP, label = L.KEEP_CURRENT_TITLE, searchName = strlower(L.KEEP_CURRENT_TITLE) }
    local noTitle = { id = NO_TITLE, label = L.NO_TITLE, searchName = strlower(L.NO_TITLE) }
    table.insert(titles, 1, noTitle)
    table.insert(titles, 1, noOp)
    titlesByID[NO_OP] = noOp
    titlesByID[NO_TITLE] = noTitle
    return titles, titlesByID
end

function addon.GetTitleBinding(specID)
    if not specID then
        return
    end
    local bindings = SpecializationsFluffDB and SpecializationsFluffDB.titles
    local titleID = type(bindings) == "table" and bindings[specID]
    if type(titleID) == "number" and (titleID == NO_TITLE or titleID > 0) then
        return titleID
    end
    return NO_OP
end

local function ResolvePendingTitle()
    if not inWorld or InCombatLockdown() then
        return
    end
    local specID = addon.GetActiveSpecID()
    if not specID then
        return
    end

    if specID ~= activeSpecID then
        activeSpecID = specID
        assignmentPending = true
        if addon.RefreshTitleOptions then
            addon.RefreshTitleOptions()
        end
    end
    if not assignmentPending then
        return
    end

    local titleID = addon.GetTitleBinding(specID)
    if titleID == NO_OP then
        assignmentPending = false
        return
    end
    local currentTitle = GetCurrentTitle()
    if titleID == currentTitle or (titleID == NO_TITLE and currentTitle <= 0) then
        assignmentPending = false
        return
    end
    local titleName = titleID == NO_TITLE and L.NO_TITLE or GetPlayerTitleName(titleID)
    if titleName then
        return titleID, titleName
    end
    -- The known-title list can become available after entering the world.
end

local function SuspendInputQueue()
    if keyListener then
        keyListener:Hide()
    end
    if not assignmentPending then
        queuedTitleID = nil
    end
end

local function OnTitleKeyDown()
    local titleID, titleName = ResolvePendingTitle()
    if not titleID then
        SuspendInputQueue()
        return
    end
    assignmentPending = false
    SuspendInputQueue()
    SetCurrentTitle(titleID)
    LogTitleChange("executed", titleName)
end

local function RefreshInputQueue()
    local titleID, titleName = ResolvePendingTitle()
    if not titleID then
        SuspendInputQueue()
        return
    end
    if not keyListener then
        keyListener = CreateFrame("Frame", nil, UIParent)
        keyListener:SetAllPoints(UIParent)
        keyListener:SetFrameStrata("TOOLTIP")
        keyListener:SetFrameLevel(UIParent:GetFrameLevel() + 1000)
        keyListener:EnableKeyboard(true)
        keyListener:SetPropagateKeyboardInput(true)
        keyListener:SetScript("OnKeyDown", OnTitleKeyDown)
    end
    keyListener:Show()
    if queuedTitleID ~= titleID then
        queuedTitleID = titleID
        LogTitleChange("queued", titleName)
    end
end

function addon.SetTitleBinding(specID, titleID)
    if type(SpecializationsFluffDB.titles) ~= "table" then
        SpecializationsFluffDB.titles = {}
    end
    SpecializationsFluffDB.titles[specID] = titleID ~= NO_OP and titleID or nil
    if specID == addon.GetActiveSpecID() then
        assignmentPending = true
        RefreshInputQueue()
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_LEAVING_WORLD")
events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("KNOWN_TITLES_UPDATE")
events:RegisterEvent("UNIT_NAME_UPDATE")
events:SetScript("OnEvent", function(_, event, first, second)
    if event == "PLAYER_ENTERING_WORLD" then
        inWorld = true
        assignmentPending = assignmentPending or first or second
    elseif event == "PLAYER_LEAVING_WORLD" then
        inWorld = false
    elseif (event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UNIT_NAME_UPDATE") and first ~= "player" then
        return
    end
    RefreshInputQueue()
end)

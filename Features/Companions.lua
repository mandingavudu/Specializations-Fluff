local _, addon = ...
local L = addon.L
local journal = C_PetJournal
local logFormats = {
    queued = L.PET_SUMMON_QUEUED,
    executed = L.PET_SUMMON_EXECUTED,
}

local EMPTY_GRACE = 1.5
local DISMISS_GRACE = 5
local WORLD_GRACE = 4
local LOGIN_GRACE = 8
local MIN_RETRY = 5
local MAX_RETRY = 60

local inWorld = false
local openingPetBattle = false
local applyBinding = false
local bindingPending = false
local restoreOverride
local emptySince
local settleUntil = 0
local pendingSettle = 0
local lastSummonAt = -math.huge
local retryAt = 0
local retryDelay = MIN_RETRY
local ticker
local maintenanceScheduled = false
local queuedSummonGUID
local summonRequested = false
local requestingSummon = false
local observedPetGUID
local dismissedPetGUID
local dismissalPendingUntil

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function GetCompanionName(customName, species)
    if customName and customName ~= "" and customName ~= species then
        return string.format("%s (%s)", customName, species)
    end
    return species
end

function addon.GetCompanionLogSettings()
    return addon.GetChatLogSettings("companionLogSettings")
end

local function LogSummon(kind, guid)
    local settings = addon.GetCompanionLogSettings()
    if settings.enabled == true and settings[kind] == true then
        local _, customName, _, _, _, _, _, species = journal.GetPetInfoByPetID(guid)
        local suffix = ""
        if not IsSecret(species) and species then
            local name = GetCompanionName(not IsSecret(customName) and customName, species)
            suffix = " (" .. name .. ")"
        end
        addon.WriteChatLog(logFormats[kind]:format(suffix))
    end
end

local function QueueSummon(guid)
    if queuedSummonGUID ~= guid then
        queuedSummonGUID, summonRequested = guid, false
        LogSummon("queued", guid)
    end
end

function addon.GetCompanionCollection()
    local pets, petsByGUID = {}, {}
    local totals = {}
    for _, guid in ipairs(journal.GetOwnedPetIDs() or {}) do
        local _, customName, level, _, _, _, isFavorite, species, icon = journal.GetPetInfoByPetID(guid)
        if species and not (journal.PetIsRevoked and journal.PetIsRevoked(guid)) then
            local name = GetCompanionName(customName, species)
            local pet = {
                id = guid,
                name = name,
                searchName = strlower(name),
                level = level or 0,
                icon = icon,
                isFavorite = isFavorite,
            }
            pets[#pets + 1] = pet
            petsByGUID[guid] = pet
            totals[name] = (totals[name] or 0) + 1
        end
    end

    table.sort(pets, function(a, b)
        if a.searchName ~= b.searchName then
            return a.searchName < b.searchName
        end
        return a.id < b.id
    end)

    -- Keep each copy's number stable when favorites change.
    local copies = {}
    local orderedPets = {}
    for _, pet in ipairs(pets) do
        if totals[pet.name] > 1 then
            copies[pet.name] = (copies[pet.name] or 0) + 1
            pet.label = string.format("%s (#%d)", pet.name, copies[pet.name])
        else
            pet.label = pet.name
        end
        if pet.isFavorite then
            orderedPets[#orderedPets + 1] = pet
        end
    end

    for _, pet in ipairs(pets) do
        if not pet.isFavorite then
            orderedPets[#orderedPets + 1] = pet
        end
    end

    return orderedPets, petsByGUID
end

function addon.GetCompanionBinding(specID)
    local guid = specID and SpecializationsFluffDB and SpecializationsFluffDB[specID]
    if type(guid) == "string" and guid ~= "" then
        return guid
    end
end

local function ApplyBinding()
    applyBinding = true
    emptySince = nil
    retryAt = 0
    retryDelay = MIN_RETRY
end

local function ClearDismissal()
    dismissedPetGUID, dismissalPendingUntil = nil, nil
end

function addon.SetCompanionBinding(specID, guid)
    SpecializationsFluffDB[specID] = guid
    if specID == addon.activeSpecID then
        restoreOverride = nil
        ClearDismissal()
        bindingPending = true
    end
end

local function IsBusy(value)
    return IsSecret(value) or value
end

local function CanAct()
    return not (openingPetBattle or C_PetBattles.IsInBattle()
        or IsBusy(UnitIsDeadOrGhost("player")) or IsBusy(UnitIsAFK("player"))
        or IsBusy(UnitOnTaxi("player")) or IsBusy(UnitInVehicle("player"))
        or IsBusy(IsFlying()) or IsBusy(IsStealthed())
        or IsBusy(UnitCastingInfo("player")) or IsBusy(UnitChannelInfo("player")))
end

local function ObservePetAction(guid, isDismissal)
    if not inWorld or requestingSummon or IsSecret(guid) then
        return
    end
    local current = journal.GetSummonedPetGUID()
    if IsSecret(current) then
        return
    end

    -- The post-hook may run before or after the journal reports the dismissal.
    if isDismissal then
        guid = guid or current or observedPetGUID
    end
    if guid and (guid == observedPetGUID or (isDismissal and guid == current))
        and (not current or current == guid) then
        dismissedPetGUID = guid
        dismissalPendingUntil = current and GetTime() + DISMISS_GRACE or nil
        applyBinding = false
        emptySince = nil
        queuedSummonGUID, summonRequested = nil, false
    end
    observedPetGUID = current
end

hooksecurefunc(journal, "SummonPetByGUID", function(guid)
    ObservePetAction(guid, false)
end)
if journal.DismissSummonedPet then
    hooksecurefunc(journal, "DismissSummonedPet", function(guid)
        ObservePetAction(guid, true)
    end)
end
hooksecurefunc("UseAction", function(slot)
    if not inWorld or IsSecret(slot) then
        return
    end
    local actionType, guid = GetActionInfo(slot)
    if not IsSecret(actionType) and actionType == "summonpet" then
        ObservePetAction(guid, false)
    end
end)

local function MaintainCompanion()
    if not inWorld or InCombatLockdown() then
        return
    end

    -- Resolve queued changes against the specialization and binding that are current now.
    local specID, specChanged = addon.UpdateActiveSpecID()
    if specChanged then
        restoreOverride = nil
        ClearDismissal()
        bindingPending = true
        if addon.RefreshCompanionOptions then
            addon.RefreshCompanionOptions()
        end
    end
    if bindingPending then
        bindingPending = false
        ApplyBinding()
    end

    local binding = addon.GetCompanionBinding(specID)
    local now = GetTime()
    if pendingSettle > 0 then
        settleUntil = math.max(settleUntil, now + pendingSettle)
        pendingSettle = 0
    end

    local current = journal.GetSummonedPetGUID()
    if IsSecret(current) then
        return
    end
    observedPetGUID = current
    if dismissedPetGUID then
        if not current then
            dismissalPendingUntil = nil
            return
        end
        if current == dismissedPetGUID and dismissalPendingUntil and now < dismissalPendingUntil then
            return
        end
        ClearDismissal()
        applyBinding = false
    end

    if not binding or now < settleUntil then
        emptySince = nil
        if not binding then
            queuedSummonGUID, summonRequested = nil, false
        end
        return
    end

    local guid = restoreOverride or binding

    if current == guid or (current and not applyBinding) then
        local confirmed = current == queuedSummonGUID and summonRequested
        queuedSummonGUID, summonRequested = nil, false
        if confirmed then
            LogSummon("executed", current)
        end
        -- Once the binding is applied, an observed pet takes precedence for restores.
        restoreOverride = current ~= binding and current or nil
        applyBinding = false
        emptySince = nil
        retryAt = 0
        retryDelay = MIN_RETRY
        return
    end

    if not CanAct() then
        emptySince = nil
        if applyBinding then
            QueueSummon(guid)
        end
        return
    end

    if current then
        emptySince = nil
    else
        emptySince = emptySince or now
        if not applyBinding and now - emptySince < EMPTY_GRACE then
            return
        end
    end

    QueueSummon(guid)
    -- Allow a pending summon to land before retrying. Summoning the same pet toggles it off.
    if now < retryAt or now - lastSummonAt < MIN_RETRY then
        return
    end
    local summonable = journal.PetIsSummonable(guid)
    if IsSecret(summonable) or not summonable then
        return
    end

    lastSummonAt = now
    retryAt = now + retryDelay
    retryDelay = math.min(retryDelay * 2, MAX_RETRY)
    summonRequested = true
    requestingSummon = true
    journal.SummonPetByGUID(guid)
    requestingSummon = false
end

local function ScheduleMaintenance()
    if not maintenanceScheduled and inWorld and not InCombatLockdown() then
        maintenanceScheduled = true
        -- Companion updates can fire inside a journal call, before its post-hook.
        C_Timer.After(0, function()
            maintenanceScheduled = false
            MaintainCompanion()
        end)
    end
end

local function StartMaintenance()
    if inWorld and not ticker and not InCombatLockdown() then
        ticker = C_Timer.NewTicker(1, MaintainCompanion)
    end
end

local function StopMaintenance()
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
    emptySince = nil
end

local function SettleFor(seconds)
    if InCombatLockdown() then
        pendingSettle = math.max(pendingSettle, seconds)
    else
        settleUntil = math.max(settleUntil, GetTime() + seconds)
    end
end

local events = CreateFrame("Frame")
for _, event in ipairs({
    "PLAYER_ENTERING_WORLD", "PLAYER_LEAVING_WORLD", "PLAYER_SPECIALIZATION_CHANGED",
    "COMPANION_UPDATE", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
    "PLAYER_ALIVE", "PLAYER_UNGHOST", "PET_BATTLE_OPENING_START", "PET_BATTLE_CLOSE",
}) do
    events:RegisterEvent(event)
end

events:SetScript("OnEvent", function(_, event, first, second)
    if event == "PLAYER_ENTERING_WORLD" then
        inWorld = true
        settleUntil, pendingSettle = 0, 0
        SettleFor((first or second) and LOGIN_GRACE or WORLD_GRACE)
        bindingPending = true
        StartMaintenance()
        MaintainCompanion()
    elseif event == "PLAYER_LEAVING_WORLD" then
        inWorld = false
        openingPetBattle = false
        StopMaintenance()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" and first == "player" then
        bindingPending = true
    elseif event == "PET_BATTLE_OPENING_START" then
        openingPetBattle = true
    elseif event == "PET_BATTLE_CLOSE" or event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
        if event == "PET_BATTLE_CLOSE" then
            openingPetBattle = false
        end
        SettleFor(WORLD_GRACE)
    elseif event == "PLAYER_REGEN_DISABLED" then
        StopMaintenance()
    elseif event == "PLAYER_REGEN_ENABLED" then
        StartMaintenance()
        MaintainCompanion()
    elseif event == "COMPANION_UPDATE" then
        ScheduleMaintenance()
    end
end)

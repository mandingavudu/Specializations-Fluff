local _, addon = ...
local journal = C_PetJournal

local EMPTY_GRACE = 1.5
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

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

function addon.GetCompanionCollection()
    local pets, petsByGUID = {}, {}
    local totals = {}
    for _, guid in ipairs(journal.GetOwnedPetIDs() or {}) do
        local _, customName, level, _, _, _, _, species, icon = journal.GetPetInfoByPetID(guid)
        if species and not (journal.PetIsRevoked and journal.PetIsRevoked(guid)) then
            local name = species
            if customName and customName ~= "" and customName ~= species then
                name = string.format("%s (%s)", customName, species)
            end
            local pet = { guid = guid, name = name, searchName = name:lower(), level = level or 0, icon = icon }
            pets[#pets + 1] = pet
            petsByGUID[guid] = pet
            totals[name] = (totals[name] or 0) + 1
        end
    end

    table.sort(pets, function(a, b)
        if a.searchName ~= b.searchName then
            return a.searchName < b.searchName
        end
        return a.guid < b.guid
    end)

    local copies = {}
    for _, pet in ipairs(pets) do
        if totals[pet.name] > 1 then
            copies[pet.name] = (copies[pet.name] or 0) + 1
            pet.label = string.format("%s (#%d)", pet.name, copies[pet.name])
        else
            pet.label = pet.name
        end
    end

    return pets, petsByGUID
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

function addon.SetCompanionBinding(specID, guid)
    SpecializationsFluffDB[specID] = guid
    if specID == addon.activeSpecID then
        restoreOverride = nil
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

local function MaintainCompanion()
    if not inWorld or InCombatLockdown() then
        return
    end

    -- Resolve queued changes against the specialization and binding that are current now.
    local specID, specChanged = addon.UpdateActiveSpecID()
    if specChanged then
        restoreOverride = nil
        bindingPending = true
        addon.RefreshCompanionOptions()
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
    if not binding or now < settleUntil then
        emptySince = nil
        return
    end

    local guid = restoreOverride or binding
    local current = journal.GetSummonedPetGUID()
    if IsSecret(current) then
        return
    end

    if current == guid or (current and not applyBinding) then
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
    journal.SummonPetByGUID(guid)
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
        MaintainCompanion()
    end
end)

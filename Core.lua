local addonName, addon = ...
local specInfo = C_SpecializationInfo
local optionsPending = false

function addon.GetActiveSpecID()
    if InCombatLockdown() then
        return addon.activeSpecID
    end
    local index = specInfo.GetSpecialization()
    if index and index > 0 then
        local id = specInfo.GetSpecializationInfo(index)
        if id and id > 0 then
            return id
        end
    end
end

function addon.UpdateActiveSpecID()
    local specID = addon.GetActiveSpecID()
    local changed = specID ~= addon.activeSpecID
    addon.activeSpecID = specID
    return specID, changed
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_ENABLED")

events:SetScript("OnEvent", function(self, event, first)
    if event == "ADDON_LOADED" and first == addonName then
        if type(SpecializationsFluffDB) ~= "table" then
            SpecializationsFluffDB = type(SpecCompanionDB) == "table" and SpecCompanionDB or {}
        end
        self:UnregisterEvent(event)
    elseif event == "PLAYER_LOGIN" then
        if InCombatLockdown() then
            optionsPending = true
        else
            addon.RegisterOptions()
        end
    elseif event == "PLAYER_REGEN_ENABLED" and optionsPending and not InCombatLockdown() then
        optionsPending = false
        addon.RegisterOptions()
    end
end)

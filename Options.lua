local addonName, addon = ...
local categories = {}
local pendingPage

local function OpenOptions(page)
    local category = categories[page]
    if not category or InCombatLockdown() then
        pendingPage = page
        return
    end
    pendingPage = nil
    Settings.OpenToCategory(category:GetID())
end

local function OpenPendingOptions()
    if pendingPage then
        OpenOptions(pendingPage)
    end
end

SLASH_SPECIALIZATIONSFLUFF1 = "/fluff"
SLASH_SPECIALIZATIONSFLUFF2 = "/speccompanion"
SlashCmdList.SPECIALIZATIONSFLUFF = function()
    OpenOptions("main")
end

function addon.RegisterOptions()
    local title = C_AddOns.GetAddOnMetadata(addonName, "Title") or addonName
    local panel = CreateFrame("Frame")
    panel:Hide()

    local heading = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", 20, -18)
    heading:SetText(title)

    local category = Settings.RegisterCanvasLayoutCategory(panel, title)
    local companions = addon.RegisterCompanionOptions(category)
    categories.main = category
    categories.companions = companions

    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", 20, -46)
    button:SetSize(160, 24)
    button:SetText(companions:GetName())
    button:SetScript("OnClick", function()
        OpenOptions("companions")
    end)

    Settings.RegisterAddOnCategory(category)
    panel:RegisterEvent("PLAYER_REGEN_ENABLED")
    panel:SetScript("OnEvent", OpenPendingOptions)
    OpenPendingOptions()
end

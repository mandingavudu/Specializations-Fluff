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

local function AddPageButton(panel, page, y)
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", 20, y)
    button:SetSize(160, 24)
    button:SetText(categories[page]:GetName())
    button:SetScript("OnClick", function()
        OpenOptions(page)
    end)
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
    categories.main = category
    categories.companions = addon.RegisterCompanionOptions(category)
    categories.titles = addon.RegisterTitleOptions(category)
    AddPageButton(panel, "companions", -46)
    AddPageButton(panel, "titles", -76)

    Settings.RegisterAddOnCategory(category)
    panel:RegisterEvent("PLAYER_REGEN_ENABLED")
    panel:SetScript("OnEvent", OpenPendingOptions)
    OpenPendingOptions()
end

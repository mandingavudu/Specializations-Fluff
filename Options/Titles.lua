local _, addon = ...
local L = addon.L

function addon.RegisterTitleOptions(parentCategory)
    local category, refresh = addon.RegisterSpecPicker(parentCategory, {
        title = L.TITLES,
        instructions = L.TITLE_PICKER_INSTRUCTIONS,
        heading = L.TITLE_FOR_SPEC,
        unavailable = L.TITLE_UNAVAILABLE,
        noMatches = L.NO_TITLES_MATCH,
        getCollection = addon.GetTitleCollection,
        getBinding = addon.GetTitleBinding,
        setBinding = addon.SetTitleBinding,
        defaultBinding = addon.TITLE_NO_OP,
        getLogSettings = addon.GetTitleLogSettings,
        events = { "KNOWN_TITLES_UPDATE" },
    })
    addon.RefreshTitleOptions = refresh
    return category
end

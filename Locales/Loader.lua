local _, addon = ...

addon.L = addon.L or setmetatable({}, {
    __index = function(strings, key)
        rawset(strings, key, key)
        return key
    end,
    __newindex = function(strings, key, value)
        rawset(strings, key, value == true and key or value)
    end,
})

function addon:RegisterLocale(locale, strings)
    if locale ~= "enUS" and locale ~= GetLocale() then
        return
    end
    for key, value in pairs(strings) do
        self.L[key] = type(value) == "string" and value or key
    end
end

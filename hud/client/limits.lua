local enabled = true
local UIOpen = false
local currentStreet = nil
local frequency = 2000
local speedLimits = require 'data.speedLimits'

CreateThread(function()
    local savedState = GetResourceKvpString("hud:speedLimit")
    if savedState then
        enabled = savedState == "true"
    else
        SetResourceKvp("hud:speedLimit", "true")
    end
end)

RegisterCommand("togglespeedlimits", function(source, args)
    local toggle = not enabled
    if toggle then
        SendNUIMessage({ action = "show" })
        UIOpen = true
    else
        SendNUIMessage({ action = "hide" })
        UIOpen = false
        currentStreet = nil
    end
    enabled = toggle
    SetResourceKvp("hud:speedLimit", tostring(enabled))
end)

CreateThread(function()
    while true do
        Wait(frequency)
        if IsPedInAnyVehicle(PlayerPedId(), true) and enabled then
            if not UIOpen then
                SendNUIMessage({ action = "show" })
                UIOpen = true
            end

            local newStreet = GetStreetNameFromHashKey(GetStreetNameAtCoord(table.unpack(GetEntityCoords(PlayerPedId()))))
            if newStreet ~= currentStreet then
                currentStreet = newStreet
                local speed = speedLimits[currentStreet]
                if speed then
                    SendNUIMessage({ action = "setlimit", data = { speed = speed } })
                end
            end
        elseif UIOpen then
            SendNUIMessage({ action = "hide" })
            UIOpen = false
        end
    end
end)

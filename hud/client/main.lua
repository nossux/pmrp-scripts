local SendNUIMessage = SendNUIMessage


local isPlayerDead = false
local isPlayerLoaded = false
local hudEnabled = false
local minimapToggle = false

HUD = {}
HUD.Show = function(visible, vehicle)
    if not hudEnabled then return end

    SendNUIMessage({
        action = 'setVisible',
        data = visible
    })

    SendNUIMessage({
        action = 'setInVehicle',
        data = {
            isInVehicle = vehicle,
            minimap = minimapToggle
        }
    })

    SetResourceKvp('hud:visible', visible and '1' or '0')
end

HUD.Init = function()
    local ped = cache.ped
    local inVehicle = IsPedInAnyVehicle(ped, false)

    HUD.Show(hudEnabled, inVehicle)
end

local function setupPlayerStatus()
    isPlayerLoaded = true
    
    local hudKvp = GetResourceKvpString('hud:visible')
    hudEnabled = hudKvp == '1'

    local minimapKvp = GetResourceKvpString('hud:minimap')
    minimapToggle = minimapKvp == '1'

    HUD.Init()
    TriggerServerEvent('hud:server:fetchEnvironment')
end

RegisterNetEvent("onResourceStart", function(resourceName)
    if cache.resource ~= resourceName then return end
    Wait(500)

    setupPlayerStatus()
end)

RegisterNetEvent("playerLoaded", function()
    Wait(500)
    setupPlayerStatus()
end)

CreateThread(function()
    if NetworkIsSessionStarted() then
        Wait(500)
        setupPlayerStatus()
    end
end)

RegisterNetEvent('playerUnloaded', function()
    HUD.Show(false, false)
    isPlayerLoaded = false
end)

CreateThread(function()
    Wait(1000)
    if isPlayerLoaded then
        setupPlayerStatus()
    end
end)

RegisterNetEvent('nos_hud:client:updateAOP', function(data)
    SendNUIMessage({
        action = 'setAOP',
        data = {
            aop = data.aop,
            peacetime = data.peacetime,
            priority = data.priority
        }
    })
end)

function GetLocationInfo()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local streetName, crossRoad = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(streetName)
    local crossStreet = GetStreetNameFromHashKey(crossRoad)

    local camRot = GetGameplayCamRot(2)
    local heading = (camRot.z + 360.0) % 360.0

    return {
        heading = heading,
        street = street,
        crossStreet = crossStreet
    }
end

lib.onCache('ped', function(value, oldValue)
    ped = value
end)

CreateThread(function()
    local lastData = {
        inVehicle = false,
        speed = 0,
        fuel = 0,
        health = 0,
        armor = 0,
        heading = 0,
        street = "",
        crossStreet = "",
        rpm = 0,
        gear = 0,
        engineHealth = 100,
        seatbelt = false
    }

    local nextCompassUpdate = 0
    local nextHealthUpdate = 0
    local nextPostalUpdate = 0
    local nextVehicleUpdate = 0

    local currentPed
    local inVehicle
    local vehicleChanged

    while true do
        local currentTime = GetGameTimer()
        local sleep = inVehicle and 50 or 300

        if not isPlayerLoaded then
            Wait(1000)
            goto continue
        end

        if not hudEnabled then
            SendNUIMessage({ action = 'setVisible', data = false })
            SendNUIMessage({
                action = 'setInVehicle',
                data = {
                    isInVehicle = false,
                    minimap = minimapToggle
                }
            })
            Wait(1000)
            goto continue
        end

        currentPed = cache.ped
        inVehicle = IsPedInAnyVehicle(currentPed, false)
        vehicleChanged = inVehicle ~= lastData.inVehicle

        if IsPauseMenuActive() then
            HUD.Show(false, false)
        else
            if not isPlayerDead then
                HUD.Show(true, inVehicle)
            end
        end

        if vehicleChanged then
            HUD.Show(true, inVehicle and not isPlayerDead)
            lastData.inVehicle = inVehicle
        end

        if inVehicle then
            if minimapToggle then
                DisplayRadar(true)
            else
                if IsVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId(), false)) then
                    DisplayRadar(true)
                else
                    DisplayRadar(false)
                end
            end

            local vehicle = GetVehiclePedIsIn(currentPed, false)
            if vehicle and vehicle ~= 0 then
                local engineOn = GetIsVehicleEngineRunning(vehicle)

                if engineOn ~= lastData.engineOn or isPlayerDead ~= lastData.isDead then
                    HUD.Show(true, engineOn and not isPlayerDead)
                    lastData.engineOn = engineOn
                    lastData.isDead = isPlayerDead
                end

                if currentTime >= nextVehicleUpdate then
                    local fuel = math.floor(GetVehicleFuelLevel(vehicle))
                    local speed = math.floor(GetEntitySpeed(vehicle) * 2.237)
                    local rpm = math.floor(GetVehicleCurrentRpm(vehicle) * 8000)
                    local gear = GetVehicleCurrentGear(vehicle)
                    local engineHealth = math.floor(GetVehicleEngineHealth(vehicle) / 10)
                    local seatbelt = LocalPlayer.state.seatbelt

                    local shouldUpdate = vehicleChanged or
                        math.abs(speed - lastData.speed) >= Config.Thresholds.speed or
                        math.abs(fuel - lastData.fuel) >= Config.Thresholds.fuel or
                        gear ~= lastData.gear or
                        seatbelt ~= lastData.seatbelt or
                        math.abs(engineHealth - lastData.engineHealth) >= 5

                    if shouldUpdate then
                        if hudEnabled then
                            SendNUIMessage({
                                action = 'updateVehicle',
                                data = {
                                    fuel = fuel,
                                    speed = speed,
                                    rpm = rpm,
                                    gear = gear,
                                    seatbelt = seatbelt,
                                    engineHealth = engineHealth,
                                    engineLight = engineHealth < 60,
                                    oilLight = engineHealth < 40,
                                    batteryLight = engineHealth < 30,
                                }
                            })
                        end

                        lastData.speed = speed
                        lastData.fuel = fuel
                        lastData.rpm = rpm
                        lastData.gear = gear
                        lastData.engineHealth = engineHealth
                        lastData.seatbelt = seatbelt
                    end

                    nextVehicleUpdate = currentTime + 50
                end
            end
        else
            if vehicleChanged then
                HUD.Show(true, false)
                DisplayRadar(minimapToggle)
            end

            DisplayRadar(minimapToggle)
        end

        if currentTime >= nextHealthUpdate then
            isPlayerDead = IsEntityDead(currentPed)
            local health = isPlayerDead and 0 or (GetEntityHealth(currentPed) - 100)
            local armor = GetPedArmour(currentPed)

            if math.abs(health - lastData.health) >= Config.Thresholds.health or
                armor ~= lastData.armor or vehicleChanged then
                if hudEnabled then
                    SendNUIMessage({
                        action = 'setStatuses',
                        data = {
                            health = health,
                            armor = armor,
                        }
                    })
                end

                lastData.health = health
                lastData.armor = armor
            end

            nextHealthUpdate = currentTime + Config.UpdateIntervals.health
        end

        if currentTime >= nextPostalUpdate then
            if hudEnabled then
                UpdatePostals()
            end
        end

        if currentTime >= nextCompassUpdate then
            local compass = GetLocationInfo() or { heading = 0, street = "", crossStreet = "" }

            if math.abs(compass.heading - lastData.heading) >= Config.Thresholds.heading or
                compass.street ~= lastData.street or
                compass.crossStreet ~= lastData.crossStreet then
                if hudEnabled then
                    SendNUIMessage({
                        action = 'setCompass',
                        data = {
                            heading = compass.heading,
                            street = compass.street,
                            crossStreet = compass.crossStreet
                        }
                    })
                end

                lastData.heading = compass.heading
                lastData.street = compass.street
                lastData.crossStreet = compass.crossStreet
            end

            nextCompassUpdate = currentTime + Config.UpdateIntervals.compass
        end

        ::continue::
        Wait(sleep)
    end
end)


RegisterCommand('togglehud', function()
    hudEnabled = not hudEnabled
    SetResourceKvp('hud:visible', hudEnabled and '1' or '0')
    if not hudEnabled then
        SendNUIMessage({ action = 'setVisible', data = false })
        SendNUIMessage({
            action = 'setInVehicle',
            data = {
                isInVehicle = false,
                minimap = minimapToggle
            }
        })
    else
        HUD.Init()
    end
end, false)

RegisterCommand('toggleminimap', function()
    minimapToggle = not minimapToggle
    SetResourceKvp('hud:minimap', minimapToggle and '1' or '0')
    if minimapToggle then
        DisplayRadar(true)
        TriggerEvent('chat:addMessage', { args = { '^2Minimap', 'Always ON' } })
    else
        DisplayRadar(false)
        TriggerEvent('chat:addMessage', { args = { '^2Minimap', 'Vehicle/Engine Only' } })
    end
end, false)

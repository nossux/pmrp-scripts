AddEventHandler('onClientMapStart', function()
    Wait(2000)
    TriggerServerEvent('hud:server:fetchEnvironment')
end)

RegisterNetEvent('hud:client:sound', function()
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
end)

RegisterNetEvent('hud:client:environment:update', function(newCurAOP, peacetime, priority)
    currentAOP = newCurAOP
    peacetimeActive = peacetime
    currentPriority = priority or "Normal"
    priorityActive = (currentPriority and currentPriority ~= "Normal") or false

    print(currentAOP, peacetimeActive, priorityActive, currentPriority)

    TriggerEvent('nos_hud:client:updateAOP', {
        aop = currentAOP,
        peacetime = peacetimeActive,
        priority = {
            enabled = priorityActive,
            name = currentPriority
        },
    })
end)

CreateThread(function()
    local lastSpeedWarning = 0
    local lastPunchBlock = 0
    while true do
        local currentTime = GetGameTimer()
        local sleep = 1000 -- Check every second for peacetime

        if peacetimeActive then
            local player = PlayerPedId()

            if peacetimeNS then
                if IsControlPressed(0, 106) then
                    if currentTime >= lastPunchBlock then
                        ShowInfo("Peacetime is enabled. You cannot cause violence.")
                        lastPunchBlock = currentTime + 2000
                    end
                end

                if exports.Badger_Discord_API:HasDiscordRole("ALEA Certified") then
                    return
                end

                if GetSelectedPedWeapon(player) ~= GetHashKey('WEAPON_UNARMED') then
                    SetCurrentPedWeapon(player, GetHashKey('WEAPON_UNARMED'), true)
                end

                SetPlayerCanDoDriveBy(PlayerId(), false)
                DisablePlayerFiring(player, true)
                DisableControlAction(0, 140, true) -- Melee R
                DisableControlAction(0, 37, true)  -- Disable weapon wheel (Tab)
            end

            local veh = GetVehiclePedIsIn(player, false)
            if veh and veh ~= 0 and GetPedInVehicleSeat(veh, -1) == player then
                local mph = math.ceil(GetEntitySpeed(veh) * 2.23)
                if mph > maxPTSpeed and currentTime >= lastSpeedWarning then
                    ShowInfo("Please keep in mind peacetime is active! Slow down or stop.")
                    lastSpeedWarning = currentTime + 5000
                end
            end

            sleep = 0
        end

        Wait(sleep)
    end
end)

function ShowInfo(text)
    lib.notify({
        description = text,
        type = "info"
    })
end

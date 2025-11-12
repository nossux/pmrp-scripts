CreateThread(function()
    for i = 1, 25 do
        EnableDispatchService(i, false)
    end

    for i = 0, 255 do
        if NetworkIsPlayerConnected(i) then
            if NetworkIsPlayerConnected(i) and GetPlayerPed(i) ~= nil then
                SetCanAttackFriendly(GetPlayerPed(i), true, true)
            end
        end
    end

    for i = 1, 12 do
        EnableDispatchService(i, false)
    end
    SetAudioFlag('PoliceScannerDisabled', true)
    SetPlayerWantedLevel(PlayerId(), 0, false)
    SetPlayerWantedLevelNow(PlayerId(), false)
    SetPlayerWantedLevelNoDrop(PlayerId(), 0, false)

    NetworkSetFriendlyFireOption(true)
    DisablePlayerVehicleRewards(PlayerId())

    while true do
        Wait(0)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local timer = 0

        if IsPedInAnyVehicle(ped, false) then
            if GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), 0) == ped then
                if GetIsTaskActive(ped, 165) then
                    --    SetPedIntoVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
                end
            end

            timer = 0
        else
            if IsPedWearingHelmet(ped) then
                timer = timer + 1

                if timer >= 5000 and not IsPedInAnyVehicle(ped, true) then
                    RemovePedHelmet(ped, false)
                    timer = 0
                end
            end
        end

        -- disable combat role
        if IsPedArmed(GetPlayerPed(-1), 4 | 2) and IsControlPressed(0, 25) then
            DisableControlAction(0, 22, true)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1000)

        local id = PlayerId()
        SetPlayerWantedLevel(id, 0, false)
        SetPlayerWantedLevelNow(id, false)
        SetPlayerWantedLevelNoDrop(id, 0, false)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        local pos = GetEntityCoords(PlayerPedId(), false)
        local dist = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), 2729.47, 1514.56, 23.79, false)
        if dist > 150.0 then
            ClearAreaOfCops(pos, 400.0)
        else
            Wait(5000)
        end
    end
end)


-- SOME OTHER AI SHIT

-- This script suppresses and removes EMS, police, and military vehicles and personnel in the game
Citizen.CreateThread(function()
    local vehicleModels = {
        "ambulance", "firetruk", "polmav", "police", "police2", "police3", "police4", "fbi", "fbi2", "policet", "policeb",
        "riot", "apc", "barracks", "barracks2", "barracks3", "rhino", "hydra", "lazer", "valkyrie",
        "valkyrie2", "savage", "trailersmall2", "barrage", "chernobog", "khanjali", "menacer", "scarab", "scarab2",
        "scarab3", "armytanker", "avenger", "avenger2", "tula", "bombushka", "molotok", "volatol", "starling",
        "mogul", "nokota", "strikeforce", "rogue", "cargoplane", "jet", "buzzard", "besra", "titan", "cargobob",
        "cargobob2", "cargobob3", "cargobob4", "akula", "hunt"
    }

    local pedModels = {
        "s_m_m_paramedic_01", "s_m_m_paramedic_02", "s_m_y_fireman_01", "s_m_y_pilot_01", "s_m_y_cop_01", "s_m_y_cop_02",
        "s_m_y_swat_01", "s_m_y_hwaycop_01", "s_m_y_marine_01", "s_m_y_marine_02", "s_m_y_marine_03",
        "s_m_m_marine_01", "s_m_m_marine_02"
    }

    for _, modelName in ipairs(vehicleModels) do
        SetVehicleModelIsSuppressed(GetHashKey(modelName), true)
    end

    for _, modelName in ipairs(pedModels) do
        SetPedModelIsSuppressed(GetHashKey(modelName), true)
    end

    while true do
        Citizen.Wait(1250) -- wait 1.250 seconds before running the loop again

        local playerPed = GetPlayerPed(-1)
        local playerLocalisation = GetEntityCoords(playerPed)
        ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 400.0)

        local vehicles = GetGamePool("CVehicle")
        for i = 1, #vehicles do
            local vehicle = vehicles[i]
            local model = GetEntityModel(vehicle)

            for _, modelName in ipairs(vehicleModels) do
                if model == GetHashKey(modelName) then
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                    break
                end
            end
        end

        local peds = GetGamePool("CPed")
        for i = 1, #peds do
            local ped = peds[i]
            local model = GetEntityModel(ped)

            for _, modelName in ipairs(pedModels) do
                if model == GetHashKey(modelName) then
                    SetEntityAsMissionEntity(ped, true, true)
                    DeletePed(ped)
                    break
                end
            end
        end

        SetPedDensityMultiplierThisFrame(1.0)
        SetScenarioPedDensityMultiplierThisFrame(1.0, 1.0)
        SetVehicleDensityMultiplierThisFrame(1.0)
        SetRandomVehicleDensityMultiplierThisFrame(1.0)
        SetParkedVehicleDensityMultiplierThisFrame(1.0)
        SetScenarioTypeEnabled("DRIVE", true)
        SetScenarioTypeEnabled("WALK", true)
    end
end)

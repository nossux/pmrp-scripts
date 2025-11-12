local function Notify(message)
    lib.notify({
        description = message,
        type = "info"
    }
    )
end

RegisterNetEvent('nos_admin:client:deleteVehicles', function(radius)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehiclesDeleted = 0
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)

    -- local hasPermission = exports.Badger_Discord_API:HasDiscordRole("Staff Team")
    -- print(hasPermission)
    -- if not hasPermission then
    --     return lib.notify({
    --         description = 'You do not have permission to use this command.',
    --         type = 'error'
    --     })
    -- end

    if playerVehicle and playerVehicle ~= 0 then
        DeleteEntity(playerVehicle)
        vehiclesDeleted = vehiclesDeleted + 1
    end

    local vehicles = GetGamePool('CVehicle')

    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(coords - vehicleCoords)

            if distance <= radius and vehicle ~= playerVehicle then
                DeleteEntity(vehicle)
                vehiclesDeleted = vehiclesDeleted + 1
            end
        end
    end

    if vehiclesDeleted > 0 then
        lib.notify({
            type = 'success',
            description = 'Deleted ' .. vehiclesDeleted .. ' vehicle(s) within ' .. radius .. ' meters'
        })
    else
        lib.notify({
            type = 'info',
            description = 'No vehicles found within ' .. radius .. ' meters'
        })
    end
end)


CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/ooc', 'Out Of Character chat Message. (Global Chat)', {
        { name = "Message", help = "Put your questions or help request." }
    })

    TriggerEvent('chat:addSuggestion', '/me', 'Send message in the third person. (Proximity Chat)', {
        { name = "Action", help = "action." }
    })

    TriggerEvent('chat:addSuggestion', '/gme', 'Send message in the third person. (Global Chat)', {
        { name = "Action", help = "action." }
    })

    TriggerEvent('chat:addSuggestion', '/do', 'Send action message. (Proximity Chat)', {
        { name = "Action", help = "action." }
    })

    TriggerEvent('chat:addSuggestion', '/ad', 'Send an ad in game (Global Chat)', {
        { name = "Message", help = "Ad Message." }
    })

    TriggerEvent('chat:addSuggestion', '/twt', 'Send a Twotter in game. (Global Chat)', {
        { name = "Message", help = "Twotter Message." }
    })

    TriggerEvent('chat:addSuggestion', '/darkweb', 'Send a anonymous message in game. (Global Chat)', {
        { name = "Message", help = "Anonymous Message." }
    })

    TriggerEvent('chat:addSuggestion', '/dv', 'Delete vehicles in radius.')

    TriggerEvent('chat:addSuggestion', '/hu', 'Hands Up.')
end)

RegisterNetEvent('SendProximityMessage')
AddEventHandler('SendProximityMessage', function(id, name, message)
    local myID = PlayerId()
    local pID = GetPlayerFromServerId(id)
    if pID == myID then
        TriggerEvent('chatMessage', "^r" .. name .. "", { 128, 128, 128 }, "^r " .. message)
    elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myID)), GetEntityCoords(GetPlayerPed(pID)), true) < 19.999 then
        TriggerEvent('chatMessage', "^r" .. name .. "", { 128, 128, 128 }, "^r " .. message)
    end
end)

RegisterNetEvent('SendProximityMessageMe')
AddEventHandler('SendProximityMessageMe', function(id, name, message)
    local myID = PlayerId()
    local pID = GetPlayerFromServerId(id)
    if pID == myID then
        TriggerEvent('chatMessage', "", { 255, 0, 0 }, " ^6 ^*ME | ^7" .. name .. "^7: " .. "^r " .. message)
    elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myID)), GetEntityCoords(GetPlayerPed(pID)), true) < 19.999 then
        TriggerEvent('chatMessage', "", { 255, 0, 0 }, " ^6 ^*ME | ^7" .. name .. "^7: " .. "^r " .. message)
    end
end)

RegisterNetEvent('SendProximityMessageDo')
AddEventHandler('SendProximityMessageDo', function(id, name, message)
    local myID = PlayerId()
    local pID = GetPlayerFromServerId(id)
    if pID == myID then
        TriggerEvent('chatMessage', "", { 255, 0, 0 }, " ^9 ^*DO | " .. name .. "^7:  " .. "^r  " .. message)
    elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myID)), GetEntityCoords(GetPlayerPed(pID)), true) < 19.999 then
        TriggerEvent('chatMessage', "", { 255, 0, 0 }, " ^9 ^*DO | " .. name .. "^7:  " .. "^r  " .. message)
    end
end)

--

local numRetries = 5

RegisterNetEvent("DVCommand")
AddEventHandler("DVCommand", function()
    local ped = GetPlayerPed(-1)

    if (DoesEntityExist(ped) and not IsEntityDead(ped)) then
        local pos = GetEntityCoords(ped)

        if (IsPedSittingInAnyVehicle(ped)) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            if (GetPedInVehicleSeat(vehicle, -1) == ped) then
                DeleteGivenVehicle(vehicle, numRetries)
            else
                Notify("You must be in the driver's seat!")
            end
        else
            local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords(ped, 0.0, distanceToCheck, 0.0)
            local vehicle = GetVehicleInDirection(ped, pos, inFrontOfPlayer)

            if (DoesEntityExist(vehicle)) then
                DeleteGivenVehicle(vehicle, numRetries)
            else
                Notify("You must be in or near a vehicle to delete it.")
            end
        end
    end
end)

function DeleteGivenVehicle(veh, timeoutMax)
    local timeout = 0

    SetEntityAsMissionEntity(veh, true, true)
    DeleteVehicle(veh)

    if (DoesEntityExist(veh)) then
        while (DoesEntityExist(veh) and timeout < timeoutMax) do
            DeleteVehicle(veh)

            if (not DoesEntityExist(veh)) then
                Notify("Vehicle deleted.")
            end

            timeout = timeout + 1
            Citizen.Wait(500)

            if (DoesEntityExist(veh) and (timeout == timeoutMax - 1)) then
                Notify("Failed to delete vehicle after " .. timeoutMax .. " retries.")
            end
        end
    else
        Notify("Vehicle deleted.")
    end
end

function GetVehicleInDirection(entFrom, coordFrom, coordTo)
    local rayHandle = StartShapeTestCapsule(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 5.0,
        10, entFrom, 7)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)

    if (IsEntityAVehicle(vehicle)) then
        return vehicle
    end
end

--

RegisterNetEvent("HUCommand")
AddEventHandler("HUCommand", function()
    local playerPed = GetPlayerPed(-1)
    if DoesEntityExist(playerPed) then
        CreateThread(function()
            RequestAnimDict("random@getawaydriver")
            while not HasAnimDictLoaded("random@getawaydriver") do
                Wait(100)
            end

            if IsEntityPlayingAnim(playerPed, "random@getawaydriver", "idle_2_hands_up", 3) then
                ClearPedSecondaryTask(playerPed)
            else
                TaskPlayAnim(playerPed, "random@getawaydriver", "idle_2_hands_up", 8.0, -8, -1, 50, 0, 0, 0, 0)
            end
        end)
    end
end)

function ToggleHUK(toggle)
    local lPed = PlayerPedId()

    if (toggle) then
        RequestAnimDict("random")
        RequestAnimDict("random@getawaydriver")
        while not HasAnimDictLoaded("random@getawaydriver") do
            Citizen.Wait(100)
        end

        TaskPlayAnim(lPed, "random@getawaydriver", "idle_2_hands_up", 1.0, -1, -1, 0, 0, 0, 0, 0)
        Citizen.Wait(3500)
        TaskPlayAnim(lPed, "random@getawaydriver", "idle_a", 1.0, -1, -1, 1, 0, 0, 0, 0)
        SetEnableHandcuffs(lPed, true)
    else
        if IsEntityPlayingAnim(lPed, "random@getawaydriver", "idle_a", 3) and IsEntityPlayingAnim(lPed, "mp_arresting", "idle", 3) then
            StopAnimTask(lPed, "random@getawaydriver", "idle_a", 3)
            StopAnimTask(lPed, "random@getawaydriver", "idle_2_hands_up", 3)
            TaskPlayAnim(lPed, "random@getawaydriver", "hands_up_2_idle", 1.0, -1, -1, 0, 0, 0, 0, 0)
            ClearPedSecondaryTask(lPed)
            TaskPlayAnim(lPed, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
            SetEnableHandcuffs(lPed, true)
        elseif IsEntityPlayingAnim(lPed, "random@getawaydriver", "idle_a", 3) then
            StopAnimTask(lPed, "random@getawaydriver", "idle_a", 3)
            StopAnimTask(lPed, "random@getawaydriver", "idle_2_hands_up", 3)
            TaskPlayAnim(lPed, "random@getawaydriver", "hands_up_2_idle", 1.0, -1, -1, 0, 0, 0, 0, 0)
            ClearPedSecondaryTask(lPed)
            SetEnableHandcuffs(lPed, false)
        end
    end
end

RegisterNetEvent("HUKCommand")
AddEventHandler("HUKCommand", function()
    HUKToggle = not HUKToggle
    ToggleHUK(HUKToggle)
end)

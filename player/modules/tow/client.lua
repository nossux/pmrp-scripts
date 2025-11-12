local data = require 'modules.tow.config'
local _towTrucks = data._towTrucks
local _bannedClasses = data._bannedClasses
local _dotVehicles = data._dotVehicles

function GetVehicleBehindTowTruck(towTruck, distance)
    local fwdVector = GetEntityForwardVector(towTruck)
    local truckCoords = GetEntityCoords(towTruck)
    local targetCoords = truckCoords + (fwdVector * -distance)

    local ray = StartShapeTestSweptSphere(truckCoords, targetCoords, 0.75, 286, towTruck, 0)
    local _, hit, _, _, targetEntity = GetShapeTestResult(ray)
    if hit and targetEntity and DoesEntityExist(targetEntity) then
        return targetEntity
    end
    return false
end

function GetVehicleAttachOffset(towModel, targetVeh)
    local towPositioning = _towTrucks[towModel]
    if towPositioning then
        local model = GetEntityModel(targetVeh)
        local minDim, maxDim = GetModelDimensions(model)
        local vehSize = maxDim - minDim

        if towPositioning.classOverrides and towPositioning.classOverrides[GetVehicleClass(targetVeh)] then
            towPositioning = towPositioning.classOverrides[GetVehicleClass(targetVeh)]
        end

        return vector3(0.0, -(vehSize.y / towPositioning.position), towPositioning.height - minDim.z)
    end
end

function CanTowVehicle(truck, vehicle)
    if vehicle and IsEntityAVehicle(vehicle) and #(GetEntityCoords(truck) - GetEntityCoords(vehicle)) <= 20.0 and not _bannedClasses[GetVehicleClass(vehicle)] and not Entity(vehicle).state.towingVehicle then
        if IsVehicleEmpty(vehicle) then
            if GetEntitySpeed(vehicle) <= 1.0 then
                return true
            else
                return false, 'The Vehicle Is Still Moving'
            end
        else
            return false, 'The Vehicle Needs to Be Empty'
        end
    else
        return false, 'No Towable Vehicle Found Behind Truck'
    end
end

function RequestControlWithTimeout(veh, timeout)
    local requestTimeout = false
    if not NetworkHasControlOfEntity(veh) then
		NetworkRequestControlOfEntity(veh)

		SetTimeout(timeout, function()
            requestTimeout = true
        end)

		while not NetworkHasControlOfEntity(veh) and not requestTimeout do
			NetworkRequestControlOfEntity(veh)
			Wait(200)
		end
	end

	return NetworkHasControlOfEntity(veh)
end

function IsVehicleEmpty(veh)
    for i = -1, GetVehicleMaxNumberOfPassengers(veh) do
        local pedInSeat = GetPedInVehicleSeat(veh, i)
        if pedInSeat > 0 then
            return false
        end
    end
    return true
end


function GetClosestAvailableParkingSpace(pedCoords, parkingSpaces)
    table.sort(parkingSpaces, function(a, b) 
        local distA = #(a.xyz - pedCoords)
        local distB = #(b.xyz - pedCoords)
        return distA > distB
    end)

    local nearestCoords = false

    for k, v in ipairs(parkingSpaces) do
        if IsParkingSpaceFree(v) then
            nearestCoords = v
        end
    end

    return nearestCoords
end

function IsParkingSpaceFree(spaceCoords)
    return GetClosestVehicleWithinRadius(spaceCoords.xyz, 2.0) == false
end

-- Because the normal one doesn't fucking work
function GetClosestVehicleWithinRadius(coords, radius)
    if not radius then
        radius = 5.0
    end

    local poolVehicles = GetGamePool('CVehicle')
    local lastDist = radius
    local lastVeh = false
    
    for k, v in ipairs(poolVehicles) do
        if DoesEntityExist(v) then
            local dist = #(coords - GetEntityCoords(v))
            if dist <= lastDist then
                lastDist = dist
                lastVeh = v
            end
        end
    end

    return lastVeh
end

local _clientPickups = {}
local _towingAction = false

local function Notify(message, type)
    lib.notify({
        title = 'ADOT',
        description = message,
        type = type or 'info',
        icon = 'info'
    })
end

--- VEHICLE SPAWNER ---

local function spawnVehicle(model)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    lib.requestModel(model)

    local vehicle = CreateVehicle(model, coords.x + 2.0, coords.y, coords.z, heading, true, false)

    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

    lib.notify({
        title = 'Vehicle Spawned',
        description = 'Your vehicle has been spawned successfully!',
        type = 'success'
    })
end

local function createVehicleMenu(departmentName, vehicles)
    local options = {}

    for _, vehicle in ipairs(vehicles) do
        table.insert(options, {
            title = vehicle.name,
            description = 'Spawn ' .. vehicle.name,
            icon = 'car',
            onSelect = function()
                spawnVehicle(vehicle.model)
            end
        })
    end

    lib.registerContext({
        id = 'vehicle_menu_' .. departmentName:gsub("%s+", "_"):lower(),
        title = departmentName .. ' Vehicles',
        options = options
    })

    return 'vehicle_menu_' .. departmentName:gsub("%s+", "_"):lower()
end

local function openMainMenu()
    local options = {}

    for departmentName, departmentData in pairs(_dotVehicles) do
        local menuId = createVehicleMenu(departmentName, departmentData.vehicles)

        table.insert(options, {
            title = departmentName,
            description = 'View ' .. departmentName .. ' vehicles',
            icon = 'shield-alt',
            menu = menuId
        })
    end

    lib.registerContext({
        id = 'leo_spawner_main',
        title = 'LEO Vehicle Spawner',
        options = options
    })

    lib.showContext('leo_spawner_main')
end

RegisterNetEvent('nos_adot:client:open', function()
    openMainMenu()
end)


--- TARGETS ---

CreateThread(function()
    for modelHash, _ in pairs(_towTrucks) do
        exports.ox_target:addModel(modelHash, {
            {
                name = 'tow_begin',
                icon = 'fa-solid fa-car',
                label = 'Attach',
                distance = 3.0,
                canInteract = function(entity)
                    if not DoesEntityExist(entity) then return false end
                    local truckState = Entity(entity).state
                    if truckState and truckState.towingVehicle then return false end

                    local behind = GetVehicleBehindTowTruck(entity, 8.0)
                    local front = GetVehicleBehindTowTruck(entity, -8.0)
                    local candidate = behind or front
                    if candidate and DoesEntityExist(candidate) then
                        local canTow, _ = CanTowVehicle(entity, candidate)
                        return canTow
                    end
                    return false
                end,
                onSelect = function(data)
                    local ent = nil
                    if type(data) == 'number' then
                        ent = data
                    elseif type(data) == 'table' then
                        ent = data.entity or data[1] or data[2]
                    end
                    if not ent then return end
                    TriggerEvent('Vehicles:Client:BeginTow', { entity = ent })
                end,
            },
            {
                name = 'tow_release',
                icon = 'fa-solid fa-truck-arrow-right',
                label = 'Release',
                distance = 3.0,
                canInteract = function(entity)
                    if not DoesEntityExist(entity) then return false end
                    local truckState = Entity(entity).state
                    return truckState and truckState.towingVehicle
                end,
                onSelect = function(data)
                    local ent = nil
                    if type(data) == 'number' then
                        ent = data
                    elseif type(data) == 'table' then
                        ent = data.entity or data[1] or data[2]
                    end
                    if not ent then return end
                    TriggerEvent('Vehicles:Client:ReleaseTow', { entity = ent })
                end,
            }
        })
    end
end)

--- Events

RegisterNetEvent('Tow:Client:ForceClearTowedState', function(netId)
    if not netId then return end
    local veh = NetToVeh(netId)
    if veh and DoesEntityExist(veh) then
        pcall(function()
            if Entity(veh) and Entity(veh).state then
                Entity(veh).state:set('towingVehicle', false, true)
                Entity(veh).state:set('towedBy', false, true)
            end
        end)
    end
end)

RegisterNetEvent('Vehicles:Client:BeginTow', function(entityData)
    local truck = entityData.entity
    local truckState = Entity(truck).state
    local truckModel = GetEntityModel(truck)
    if not _towingAction and _towTrucks[truckModel] and truckState and not truckState.towingVehicle then
        local targetVehicle = GetVehicleBehindTowTruck(truck, 8.0)
        local canTow, errorMessage = CanTowVehicle(truck, targetVehicle)
        if canTow then
            _towingAction = true
            if lib.progressBar({
                    duration = 12000,
                    label = 'Attaching Vehicle',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        move = true,
                        car = true,
                        combat = true,
                    },
                    anim = {
                        dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                        clip = "machinic_loop_mechandplayer",
                        flag = 49,
                    },
                }) then
                local success = AttachVehicleToTow(truck, targetVehicle)
                if success then
                    truckState:set('towingVehicle', VehToNet(success), true)
                    Notify('Vehicle Now on Tow Truck', 'success')
                else
                    truckState:set('towingVehicle', false, true)
                    Notify('Failed to Tow Vehicle', 'error')
                end
            else
                lib.print.info('Cancelled')
            end

            _towingAction = false
        else
            Notify(errorMessage, 'info')
        end
    end
end)

RegisterNetEvent('Vehicles:Client:ReleaseTow', function(entityData)
    local truck = entityData.entity
    local truckState = Entity(truck).state
    local truckModel = GetEntityModel(truck)
    if _towTrucks[truckModel] and truckState then
        if truckState.towingVehicle then
            local towedNet = truckState.towingVehicle
            local towedVeh = NetToVeh(towedNet)

            if not DoesEntityExist(towedVeh) then
                Notify('Towed vehicle no longer exists', 'error')
                return
            end

            if lib.progressBar({
                    duration = 12000,
                    label = 'Detaching Vehicle',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        move = true,
                        car = true,
                        combat = true,
                    },
                    anim = {
                        dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                        clip = "machinic_loop_mechandplayer",
                        flag = 49,
                    },
                }) then
                local success = DetachVehicleFromTow(truck, towedVeh)
                if success then
                    Notify('Vehicle Released from Truck', 'info')
                else
                    if DoesEntityExist(towedVeh) then
                        Entity(towedVeh).state:set('towingVehicle', false, true)
                        Entity(towedVeh).state:set('towedBy', false, true)
                    end
                    truckState:set('towingVehicle', false, true)
                    Notify(
                        'Vehicle release attempted; cleared state locally. If vehicle is still attached, try moving/server restart.',
                        'error')
                end
                _towingAction = false
            else
                Notify('No Vehicle Being Towed', 'info')
            end
        else
            Notify('No Vehicle Being Towed', 'info')
        end
    end
end)

RegisterNetEvent('Tow:Client:CreatePickup', function(modelName, coords, spawnId)
    local modelHash = modelName
    if type(modelName) ~= 'number' then
        modelHash = GetHashKey(modelName)
    end

    RequestModel(modelHash)

    local tries = 0
    while not HasModelLoaded(modelHash) and tries < 50 do
        Wait(50)
        tries = tries + 1
    end

    local x, y, z, h
    if type(coords) == 'table' then
        x = coords.x or coords[1]
        y = coords.y or coords[2]
        z = coords.z or coords[3]
        h = coords.w or coords[4] or 0.0
    else
        x, y, z, h = table.unpack(coords)
    end

    local veh = CreateVehicle(modelHash, x, y, z, h, true, false)
    if not DoesEntityExist(veh) then
        return
    end

    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetVehicleDoorsLocked(Entity(veh), 2)

    pcall(function()
        if DoesEntityExist(veh) and Entity(veh) and Entity(veh).state then
            Entity(veh).state:set('towObjective', true, true)
        end
    end)

    local netId = VehToNet(veh)
    SetNetworkIdExistsOnAllMachines(netId, true)
    TriggerServerEvent('Tow:Server:PickupCreated', spawnId, netId)

    local blip = AddBlipForEntity(veh)
    SetBlipSprite(blip, 225)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Tow Pickup')
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip, false)

    SetBlipRoute(blip, true)
    SetBlipHighDetail(blip, true)

    pcall(function() Notify('New Tow Job Available - Check Your GPS', 'success') end)

    if not _clientPickups then _clientPickups = {} end
    _clientPickups[netId] = { veh = veh, blip = blip, blipCoord = blipCoord }
end)

RegisterNetEvent('Tow:Client:CleanupPickup', function(netId)
    if not netId then return end
    if _clientPickups and _clientPickups[netId] then
        local p = _clientPickups[netId]
        if DoesEntityExist(p.veh) then
            DeleteEntity(p.veh)
        end
        if p.blip then
            RemoveBlip(p.blip)
        end
        if p.blipCoord then
            RemoveBlip(p.blipCoord)
        end
        _clientPickups[netId] = nil
    end
end)

--- Functions

function AttachVehicleToTow(towTruck, targetVeh)
    local attachOffset = GetVehicleAttachOffset(GetEntityModel(towTruck), targetVeh)

    local towTruckControl = RequestControlWithTimeout(towTruck, 1500)
    local targetVehControl = RequestControlWithTimeout(targetVeh, 1500)

    if not attachOffset then
        pcall(function() Notify('Tow attach failed: missing attach offset', 'error') end)
        return false
    end

    if not towTruckControl or not targetVehControl then
        pcall(function() Notify('Tow attach failed: network control timeout', 'error') end)
        return false
    end

    local ok, err = pcall(function()
        local lowerHeight = 0.5
        AttachEntityToEntity(targetVeh, towTruck, GetEntityBoneIndexByName(towTruck, 'bodyshell'), 
            attachOffset.x, attachOffset.y, attachOffset.z - lowerHeight, 
            0, 0, 0, 1, 1, 0, 1, 0, 1)
    end)

    if not ok then
        pcall(function() Notify('Tow attach failed: ' .. tostring(err), 'error') end)
        return false
    end

    pcall(function()
        if DoesEntityExist(targetVeh) then
            Entity(targetVeh).state:set('towingVehicle', true, true)
            Entity(targetVeh).state:set('towedBy', VehToNet(towTruck), true)
        end
    end)

    return targetVeh
end 

function DetachVehicleFromTow(towTruck, towedVehicle)
    if towedVehicle and DoesEntityExist(towedVehicle) then
        local towTruckControl = RequestControlWithTimeout(towTruck, 1500)
        local towedVehControl = RequestControlWithTimeout(towedVehicle, 1500)

        if towTruckControl and towedVehControl then
            if IsEntityAttachedToEntity(towTruck, towedVehicle) then
                DetachEntity(towedVehicle, true, true)
            end

            local releaseCoords = GetOffsetFromEntityInWorldCoords(towTruck, 0.0, -10.0, 0.0)
            if releaseCoords then
                SetEntityCoords(towedVehicle, releaseCoords.x, releaseCoords.y, releaseCoords.z, false, false, false,
                    true)
            end
            
            Wait(50)
            SetEntityVelocity(towedVehicle, 0.0, 0.0, 0.0)
            SetVehicleOnGroundProperly(towedVehicle)

            if DoesEntityExist(towedVehicle) then
                Entity(towedVehicle).state:set('towingVehicle', false, true)
                Entity(towedVehicle).state:set('towedBy', false, true)
            end

            local netId = VehToNet(towedVehicle)
            TriggerServerEvent('Tow:Server:ClearTowedState', netId)
            if not (Entity(towedVehicle).state and Entity(towedVehicle).state.towObjective) then
                SetVehicleDoorsLockedForAllPlayers(towedVehicle, false)
            else
                SetVehicleDoorsLockedForAllPlayers(towedVehicle, true)
            end

            if DoesEntityExist(towTruck) and Entity(towTruck).state and Entity(towTruck).state.towingVehicle then
                Entity(towTruck).state:set('towingVehicle', false, true)
            end

            return true
        end
    end
    return false
end

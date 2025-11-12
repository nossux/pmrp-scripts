-- Vehicle Spawner

local config = require 'modules.alea.config'

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

    for departmentName, departmentData in pairs(config) do
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

RegisterNetEvent('alea:openMenu', function()
    openMainMenu()
end)

-- Alerts

RegisterNetEvent("publicAlert:showAlert", function(data)
    lib.notify({
        title = data.title,
        description = data.message,
        type = 'info',
        duration = 10000,
        position = 'top',
        style = {
            backgroundColor = '#1e1e1e',
            color = '#ffffff',
            borderLeftColor = '#f54242',
        }
    })
end)

RegisterNetEvent("publicAlert:openInput", function(dept)
    print("^3[PublicAlert] Opening input dialog for dept: " .. dept)

    local input = lib.inputDialog('Send Public Alert', {
        { type = 'input',    label = 'Headline',        placeholder = 'e.g. Missing Person' },
        { type = 'textarea', label = 'Message Details', placeholder = 'Last seen near the beach.' }
    })

    if not input then
        print("^1[PublicAlert] Input cancelled or closed")
        return
    end

    print("^2[PublicAlert] Input received:")
    print("^2Headline: " .. tostring(input[1]))
    print("^2Message: " .. tostring(input[2]))

    TriggerServerEvent("publicAlert:sendAlert", dept .. ": " .. input[1], input[2])
end)

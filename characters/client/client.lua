local spawns = require 'data.spawns'

local selectedName = nil

local function cloudTransition(coords)
    SwitchOutPlayer(PlayerPedId(), 0, 1)
    while GetPlayerSwitchState() ~= 5 do Wait(0) end
    -- RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    -- while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Wait(0) end
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, true, false, false, false)
    SetEntityHeading(PlayerPedId(), coords.h)
    SetEntityVisible(PlayerPedId(), true, false)
    SetPlayerInvincible(PlayerId(), false)
    RenderScriptCams(false, true, 1000, true, true)
    FreezeEntityPosition(PlayerPedId(), false)
    SetTimecycleModifier('default')
    SwitchInPlayer(PlayerPedId())
end

local function setPresence(name)
    TriggerEvent('presence:setCharacter', name)
end

local function showSpawnMenu()
    local options = {}
    for _, location in ipairs(spawns) do
        table.insert(options, {
            title = location.name,
            description = location.description,
            icon = 'map-marker-alt',
            onSelect = function()
                local confirmOptions = {
                    {
                        title = 'Confirm Spawn',
                        description = ('Spawn at %s'):format(location.name),
                        icon = 'check',
                        onSelect = function()
                            local x, y, z = location.coords.x, location.coords.y, location.coords.z
                            -- RequestCollisionAtCoord(x, y, z)
                            -- while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Wait(50) end
                            cloudTransition({ x = x, y = y, z = z + 1.0, h = location.heading })
                        end
                    },
                    {
                        title = 'Go Back',
                        description = 'Change character name',
                        icon = 'sign-out-alt',
                        onSelect = function()
                            selectedName = nil
                            showNameModal()
                        end
                    }
                }
                lib.registerContext({
                    id = 'spawn_confirm_' .. location.name,
                    title = ('Confirm Spawn'):format(location.name),
                    options = confirmOptions,
                    canClose = false
                })
                lib.showContext('spawn_confirm_' .. location.name)
            end
        })
    end
    lib.registerContext({
        id = 'spawn_selection',
        title = selectedName and ('Welcome %s'):format(selectedName) or 'Select Spawn',
        options = options,
        canClose = false
    })
    lib.showContext('spawn_selection')
end

function showNameModal()
    local input = lib.inputDialog('Enter Character Name', {
        { type = 'input', label = 'Character Name', required = true, min = 2, max = 32 }
    })
    if input and input[1] and #input[1] > 1 then
        selectedName = input[1]
        setPresence(selectedName)
        showSpawnMenu()
    else
        Wait(500)
        showNameModal()
    end
end

CreateThread(function()
    DoScreenFadeOut(250)
    while true do
        Wait(1000)
        if NetworkIsSessionStarted() then
            DoScreenFadeIn(1000)
            SwitchOutPlayer(PlayerPedId(), 0, 1)
            FreezeEntityPosition(PlayerPedId(), true)
            SetEntityVisible(PlayerPedId(), false, false)
            showNameModal()
            break
        end
    end
end)

-- local spawns = require 'data.spawns'
-- local genders = require 'data.genders'
-- local nationalities = require 'data.nationalities'

-- Characters = {}
-- Character = {
--     data = nil,
--     loggedOut = false,
-- }

-- local function cloudTransition(coords)
--     SwitchOutPlayer(PlayerPedId(), 0, 1)
--     while GetPlayerSwitchState() ~= 5 do Wait(0) end
--     RequestCollisionAtCoord(coords.x, coords.y, coords.z)
--     while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Wait(0) end

--     SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, true, false, false, false)
--     SetEntityHeading(PlayerPedId(), coords.h)

--     SetEntityVisible(PlayerPedId(), true, false)
--     SetPlayerInvincible(PlayerId(), false)
--     RenderScriptCams(false, true, 1000, true, true)
--     FreezeEntityPosition(PlayerPedId(), false)
--     SetTimecycleModifier('default')

--     SwitchInPlayer(PlayerPedId())
-- end

-- Characters.Spawn = function(location)
--     local x, y, z = location.coords.x, location.coords.y, location.coords.z
--     RequestCollisionAtCoord(x, y, z)
--     while not HasCollisionLoadedAroundEntity(PlayerPedId()) do Wait(50) end

--     cloudTransition({ x = x, y = y, z = z + 1.0, h = location.heading })

--     Wait(500)

--     Character.loggedOut = false

--     TriggerEvent('presence:setCharacter', Character.data.first_name .. ' ' .. Character.data.last_name)
-- end

-- local function showSpawnMenu()
--     local options = {}
--     for _, location in ipairs(spawns) do
--         table.insert(options, {
--             title = location.name,
--             description = location.description,
--             icon = 'map-marker-alt',
--             onSelect = function()
--                 local confirmOptions = {
--                     {
--                         title = 'Confirm Spawn',
--                         description = ('Spawn at %s'):format(location.name),
--                         icon = 'check',
--                         onSelect = function()
--                             Characters.Spawn(location)
--                         end
--                     },
--                     {
--                         title = 'Cancel',
--                         description = 'Choose another spawn',
--                         icon = 'times',
--                         onSelect = function()
--                             showSpawnMenu()
--                         end
--                     }
--                 }
--                 lib.registerContext({
--                     id = 'spawn_confirm_' .. location.name,
--                     title = ('Confirm Spawn'):format(location.name),
--                     options = confirmOptions,
--                     canClose = false
--                 })
--                 lib.showContext('spawn_confirm_' .. location.name)
--             end
--         })
--     end

--     table.insert(options, {
--         title = 'Go back',
--         description = 'Return to character selection',
--         icon = 'sign-out-alt',
--         onSelect = function()
--             Characters.Logout()
--         end
--     })

--     lib.registerContext({
--         id = 'spawn_selection',
--         title = ('Welcome %s %s'):format(Character.data.first_name, Character.data.last_name),
--         options = options,
--         canClose = false
--     })
--     lib.showContext('spawn_selection')
-- end

-- local function showCharacterMenu()
--     local chars = lib.callback.await('player:getCharacters', false)
--     if not chars or #chars == 0 then
--         local input = lib.inputDialog('Create Character', {
--             { type = 'input',  label = 'First Name',  required = true, min = 2,                max = 32 },
--             { type = 'input',  label = 'Last Name',   required = true, min = 2,                max = 32 },
--             { type = 'select', label = 'Gender',      required = true, options = genders },
--             { type = 'select', label = 'Nationality', required = true, options = nationalities }
--         })

--         if input then
--             local res = lib.callback.await('player:createCharacter', false, input[1], input[2], input[3], input[4])
--             if res and res.success then
--                 showCharacterMenu()
--             else
--                 lib.notify({
--                     title = 'Character Error',
--                     description = 'Failed to create character.',
--                     type = 'error'
--                 })
--                 Wait(1000)
--                 showCharacterMenu()
--             end
--         else
--             Wait(500)
--             showCharacterMenu()
--         end
--         return
--     end

--     local options = {}
--     for _, char in ipairs(chars) do
--         table.insert(options, {
--             title = ('[%s] %s %s'):format(char.stateid, char.first_name, char.last_name),
--             description = ('Gender: %s | Nationality: %s'):format(char.gender or 'N/A', char.nationality or 'N/A'),
--             onSelect = function()
--                 local submenuOptions = {
--                     {
--                         title = 'Select',
--                         description = 'Play as this character',
--                         icon = 'user',
--                         onSelect = function()
--                             Character.data = char
--                             showSpawnMenu()
--                         end
--                     },
--                     {
--                         title = 'Delete',
--                         description = 'Delete this character',
--                         icon = 'trash',
--                         onSelect = function()
--                             local confirm = lib.alertDialog({
--                                 header = 'Delete Character',
--                                 content = ('Are you sure you want to delete %s %s? This cannot be undone!'):format(
--                                     char.first_name, char.last_name),
--                                 centered = true,
--                                 cancel = true,
--                                 size = 'sm',
--                                 labels = { confirm = 'Delete', cancel = 'Cancel' }
--                             })
--                             if confirm == 'confirm' then
--                                 local res = lib.callback.await('player:deleteCharacter', false, tonumber(char.stateid))
--                                 if res and res.success then
--                                     lib.notify({
--                                         description = ('%s %s has been deleted.'):format(char.first_name, char.last_name),
--                                         type = 'success'
--                                     })
--                                     Wait(1000)
--                                     showCharacterMenu()
--                                 else
--                                     lib.notify({
--                                         description = 'Failed to delete character.',
--                                         type = 'error'
--                                     })
--                                     Wait(1000)
--                                     showCharacterMenu()
--                                 end
--                             end
--                         end
--                     }
--                 }
--                 lib.registerContext({
--                     id = 'character_submenu_' .. char.id,
--                     title = ('%s %s'):format(char.first_name, char.last_name),
--                     options = submenuOptions,
--                     canClose = true
--                 })
--                 lib.showContext('character_submenu_' .. char.id)
--             end
--         })
--     end

--     if #chars < 3 then
--         table.insert(options, {
--             title = 'Create New Character',
--             description = 'Create a new character slot',
--             icon = 'plus',
--             onSelect = function()
--                 local input = lib.inputDialog('Create Character', {
--                     { type = 'input',  label = 'First Name',  required = true, min = 2,                max = 32 },
--                     { type = 'input',  label = 'Last Name',   required = true, min = 2,                max = 32 },
--                     { type = 'select', label = 'Gender',      required = true, options = genders },
--                     { type = 'select', label = 'Nationality', required = true, options = nationalities }
--                 })
--                 if input then
--                     local res = lib.callback.await('player:createCharacter', false, input[1], input[2], input[3],
--                         input[4])
--                     if res and res.success then
--                         showCharacterMenu()
--                     else
--                         lib.notify({
--                             description = 'Failed to create character.',
--                             type = 'error'
--                         })
--                         Wait(1000)
--                         showCharacterMenu()
--                     end
--                 else
--                     Wait(500)
--                     showCharacterMenu()
--                 end
--             end
--         })
--     end

--     lib.registerContext({
--         id = 'character_selection',
--         title = 'Select Character',
--         options = options,
--         canClose = false
--     })
--     lib.showContext('character_selection')
-- end

-- Characters.Logout = function()
--     DoScreenFadeOut(250)
--     Wait(1000)
--     SwitchOutPlayer(PlayerPedId(), 0, 1)
--     FreezeEntityPosition(PlayerPedId(), true)
--     SetEntityVisible(PlayerPedId(), false, false)
--     DoScreenFadeIn(1000)

--     Character.loggedOut = true
--     showCharacterMenu()
-- end

-- RegisterCommand('logout', function()
--     Characters.Logout()
-- end)

-- CreateThread(function()
--     DoScreenFadeOut(250)
--     while true do
--         Wait(1000)
--         if NetworkIsSessionStarted() then
--             DoScreenFadeIn(1000)
--             SwitchOutPlayer(PlayerPedId(), 0, 1)
--             FreezeEntityPosition(PlayerPedId(), true)
--             SetEntityVisible(PlayerPedId(), false, false)
--             local chars = lib.callback.await('player:getCharacters', false)
--             if chars and #chars > 0 then
--                 local options = {}
--                 for _, char in ipairs(chars) do
--                     table.insert(options, {
--                         title = ('[%s] %s %s'):format(char.stateid, char.first_name, char.last_name),
--                         description = ('Gender: %s | Nationality: %s'):format(char.gender or 'N/A',
--                         char.nationality or 'N/A'),
--                         onSelect = function()
--                             Character.data = char
--                             TriggerServerEvent('characters:loadCharacter', char)
--                             showSpawnMenu()
--                         end
--                     })
--                 end
--                 lib.registerContext({
--                     id = 'character_selection',
--                     title = 'Select Character',
--                     options = options,
--                     canClose = false
--                 })
--                 lib.showContext('character_selection')
--             else
--                 showCharacterMenu()
--             end
--             break
--         end
--     end
-- end)

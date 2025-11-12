local postals = nil

CreateThread(function()
    postals = LoadResourceFile(GetCurrentResourceName(), 'data/postals.json')
    postals = json.decode(postals)
    for i, postal in ipairs(postals) do
        postals[i] = {
            vec(postal.x, postal.y),
            code = postal.code
        }
    end
end)

nearest = nil
pBlip = nil

exports('getPostal', function() return nearest and nearest.code or nil end)

-- Update

local vec = vec
local Wait = Citizen.Wait
local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords

function UpdatePostals()
    local postals = postals
    local _total = #postals

    while postals == nil do Wait(1) end

    local coords = GetEntityCoords(PlayerPedId())
    local flat_coords = vec(coords[1], coords[2])
    local _nearestIndex, _nearestD

    for i = 1, _total do
        local D = #(flat_coords - postals[i][1])
        if not _nearestD or D < _nearestD then
            _nearestIndex = i
            _nearestD = D
        end
    end

    local _code = postals[_nearestIndex].code
    nearest = { code = _code, dist = _nearestD }

    SendNUIMessage({
        action = 'setPostal',
        data = {
            code = nearest.code,
            dist = math.floor(nearest.dist)
        }
    })
end

-- Commands

local ipairs = ipairs
local upper = string.upper
local format = string.format

TriggerEvent('chat:addSuggestion', '/postal', 'Set the GPS to a specific postal',
    { { name = 'Postal Code', help = 'The postal code you would like to go to' } })

RegisterCommand('postal', function(_, args)
    local userPostal = upper(args[1])
    local foundPostal

    for _, p in ipairs(postals) do
        if upper(p.code) == userPostal then
            foundPostal = p
            break
        end
    end

    if foundPostal then
        SetNewWaypoint(foundPostal[1][1], foundPostal[1][2])
        TriggerEvent('ox_lib:notify', {
            description = format('Updated GPS to postal %s', foundPostal.code)
        })
    else
        TriggerEvent('ox_lib:notify', {
            description = 'That postal doesn\'t exist.'
        })
    end
end)

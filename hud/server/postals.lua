local postals = nil

CreateThread(function()
    postals = LoadResourceFile(GetCurrentResourceName(), 'data/postals.json')
    postals = json.decode(postals)
    for i, postal in ipairs(postals) do
        postals[i] = { vec(postal.x, postal.y), code = postal.code }
    end
end)

local function getPostalServer(coords)
    while postals == nil do
        Wait(1)
    end
    local _total = #postals
    local _nearestIndex, _nearestD
    coords = vec(coords[1], coords[2])

    for i = 1, _total do
        local D = #(coords - postals[i][1])
        if not _nearestD or D < _nearestD then
            _nearestIndex = i
            _nearestD = D
        end
    end
    local _code = postals[_nearestIndex].code
    local nearest = { code = _code, dist = _nearestD }
    return nearest or nil
end

exports('getPostalServer', function(coords)
    return getPostalServer(coords)
end)

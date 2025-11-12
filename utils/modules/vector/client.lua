local function CopyVector(type)
    local data = nil
    local coords = GetEntityCoords(cache.ped)
    local x, y, z = math.round(coords.x, 2), math.round(coords.y, 2), math.round(coords.z, 2)
    local heading = GetEntityHeading(cache.ped)
    local h = math.round(heading, 2)

    if type == 'vec2' then
        data = string.format('vec2(%s, %s)', x, y)
    elseif type == 'vec3' then
        data = string.format('vec3(%s, %s, %s)', x, y, z - 1.0)
    elseif type == 'vec4' then
        data = string.format('vec4(%s, %s, %s, %s)', x, y, z - 1.0, h)
    elseif type == 'heading' then
        data = tostring(h)
    end

    lib.setClipboard(data)
    lib.notify({
        description = string.format('%s copied to clipboard!', type),
        type = 'success'
    })
end

RegisterNetEvent('nos_player:vector:copy', function(type)
    CopyVector(type)
end)

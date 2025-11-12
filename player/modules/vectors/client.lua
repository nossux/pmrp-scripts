local function CopyVector(type)
    local coords = GetEntityCoords(cache.ped)
    local x, y, z = math.round(coords.x, 2), math.round(coords.y, 2), math.round(coords.z, 2)
    local h = math.round(GetEntityHeading(cache.ped), 2)

    local formats = {
        vec2 = string.format('vec2(%s, %s)', x, y),
        vec3 = string.format('vec3(%s, %s, %s)', x, y, z - 1.0),
        vec4 = string.format('vec4(%s, %s, %s, %s)', x, y, z - 1.0, h),
        heading = tostring(h)
    }

    local data = formats[type]
    if data then
        lib.setClipboard(data)
        lib.notify({
            description = string.format('%s copied to clipboard.', type),
            type = 'success'
        })
    end
end

RegisterNetEvent('admin:vector:copy', CopyVector)

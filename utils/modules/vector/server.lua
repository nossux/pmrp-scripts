local function CopyVector(source, type)
    TriggerClientEvent('nos_player:vector:copy', source, type)
end

lib.addCommand('vec2', {
    help = 'Copy your current coordinates as a vector2 to your clipboard.',
    params = {}
}, function(source, args)
    CopyVector(source, 'vec2')
end)

lib.addCommand('vec3', {
    help = 'Copy your current coordinates as a vector3 to your clipboard.',
    params = {}
}, function(source, args)
    CopyVector(source, 'vec3')
end)

lib.addCommand('vec4', {
    help = 'Copy your current coordinates as a vector4 to your clipboard.',
    params = {}
}, function(source, args)
    CopyVector(source, 'vec4')
end)

lib.addCommand('heading', {
    help = 'Copy your current heading to your clipboard.',
    params = {}
}, function(source, args)
    CopyVector(source, 'heading')
end)

lib.addCommand('vec2', {
    help = 'Copy your current coordinates as a vector2 to your clipboard.',
    params = {}
}, function(source, args)
    TriggerClientEvent('admin:vector:copy', source, 'vec2')
end)

lib.addCommand('vec3', {
    help = 'Copy your current coordinates as a vector3 to your clipboard.',
    params = {}
}, function(source, args)
    TriggerClientEvent('admin:vector:copy', source, 'vec3')
end)

lib.addCommand('vec4', {
    help = 'Copy your current coordinates as a vector4 to your clipboard.',
    params = {}
}, function(source, args)
    TriggerClientEvent('admin:vector:copy', source, 'vec4')
end)

lib.addCommand('heading', {
    help = 'Copy your current heading to your clipboard.',
    params = {}
}, function(source, args)
    TriggerClientEvent('admin:vector:copy', source, 'heading')
end)

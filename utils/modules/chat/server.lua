AddEventHandler('chatMessage', function(source, name, message)
    if string.sub(message, 1, string.len("/")) ~= "/" then
        local name = GetPlayerName(source)
        TriggerClientEvent("SendProximityMessage", -1, source, name, message)
    end
    CancelEvent()
end)

RegisterCommand('me', function(source, args, user)
    local name = GetPlayerName(source)
    TriggerClientEvent("SendProximityMessageMe", -1, source, name, table.concat(args, " "))
end, false)

RegisterCommand('do', function(source, args, user)
    local name = GetPlayerName(source)
    TriggerClientEvent("SendProximityMessageDo", -1, source, name, table.concat(args, " "))
end, false)

RegisterCommand('gme', function(source, args, user)
    TriggerClientEvent('chatMessage', -1, "^3^*GLOBAL ME | ^7" .. GetPlayerName(source) .. "^r", { 128, 128, 128 },
        table.concat(args, " "))
end, false)

RegisterCommand('twt', function(source, args, user)
    TriggerClientEvent('chatMessage', -1, "^0^*[^4Twotter^0] (^5@" .. GetPlayerName(source) .. "^0)^r",
        { 30, 144, 255 }, table.concat(args, " "))
end, false)

RegisterCommand('ooc', function(source, args, user)
    TriggerClientEvent('chatMessage', -1, "^*OOC | " .. GetPlayerName(source) .. "^r", { 128, 128, 128 },
        table.concat(args, " "))
end, false)

RegisterCommand('ad', function(source, args, user)
    TriggerClientEvent('chatMessage', -1, "^0^*[^1ADVERT^0]^r", { 255, 215, 0 }, table.concat(args, " "))
end, false)

RegisterCommand('darkweb', function(source, args, user)
    TriggerClientEvent('chatMessage', -1, "^*[^*Dark Web] (@^*Anonymous)^r", { 0, 0, 0 }, table.concat(args, " "))
end, false)

lib.addCommand('dv', {
    help = 'Delete nearby vehicles or the vehicle you are in',
    params = {
        { name = 'radius', help = 'Radius to delete vehicles (optional, default: 5.0)', optional = true }
    },
    
}, function(source, args)
    local radius = tonumber(args.radius) or 5.0
    TriggerClientEvent('nos_admin:client:deleteVehicles', source, radius)
end)

RegisterCommand('hu', function(source, args, user)
    TriggerClientEvent('HUCommand', source)
end, false)

RegisterCommand('huk', function(source, args, user)
    TriggerClientEvent('HUKCommand', source)
end, false)

RegisterCommand('discord', function()
    TriggerClientEvent('chatMessage', -1, "https://discord.gg/projectmontgomery", { 245, 191, 66 })
end, false)

RegisterCommand('website', function()
    TriggerClientEvent('chatMessage', -1, "https://projectmontgomery.net", { 245, 191, 66 })
end, false)

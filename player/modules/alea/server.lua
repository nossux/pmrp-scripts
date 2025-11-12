-- Vehicle Spawner

local aleaRoleID = "1412144211855413381"

lib.addCommand('alea', {
    help = 'Show LEO vehicle spawner menu',
    restricted = exports.Badger_Discord_API:HasDiscordRole("Staff Team")
}, function(source)
    TriggerClientEvent('alea:openMenu', source)
end)

-- Alerts

RegisterServerEvent("publicAlert:sendAlert", function(title, message)
    local src = source
    print(("[PublicAlert] Alert received from %s - %s: %s"):format(GetPlayerName(src), title, message))

    TriggerClientEvent("publicAlert:showAlert", -1, {
        title = title,
        message = message
    })
end)

RegisterCommand("mpdalert", function(src)
    TriggerClientEvent("publicAlert:openInput", src, "Montgomery Police Department")
end, true)

RegisterCommand("mcsoalert", function(src)
    TriggerClientEvent("publicAlert:openInput", src, "Montgomery County Sheriff's Office")
end, true)

RegisterCommand("aspalert", function(src)
    TriggerClientEvent("publicAlert:openInput", src, "Alabama State Police")
end, true)

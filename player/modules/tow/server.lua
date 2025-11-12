local adotRoleID = "1415856790574469281"

lib.addCommand('adot', {
    help = 'Show ADOT vehicle spawner menu',
    restricted = false
}, function(source)
    local roles = exports.Badger_Discord_API:GetDiscordRoles(source)
    if not roles then
        lib.print.error("Could not retrieve roles for player: ", source)
        return
    end

    for i = 1, #roles do
        local roleStr = tostring(roles[i])
        if roleStr == adotRoleID then
            TriggerClientEvent('nos_adot:client:open', source)
            return
        end
    end

    TriggerClientEvent('ox_lib:notify', source, {
        title = "Access Denied",
        description = "You do not have the required role to access this menu.",
        type = "error"
    })
end)


---

RegisterNetEvent('Tow:Server:ClearTowedState', function(netId)
    local src = source
    if not netId then return end
    TriggerClientEvent('Tow:Client:ForceClearTowedState', -1, netId)
end)

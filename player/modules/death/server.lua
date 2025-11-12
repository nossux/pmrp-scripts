local adminRoleID = '1402995942663127150'
local function IsAdmin(source)
    local roles = exports.Badger_Discord_API:GetDiscordRoles(source)
    if not roles then
        lib.print.error("Could not retrieve roles for player: ", source)
        return
    end

    for i = 1, #roles do
        local roleStr = tostring(roles[i])
        if roleStr == adminRoleID then
            return true
        end
    end

    return false
end

lib.addCommand('kill', {
    help = 'Kill a player or yourself',
    params = {
        {
            name = 'id',
            type = 'playerId',
            help = 'Player ID (optional, defaults to yourself)',
            optional = true
        }
    },
}, function(source, args)
    local targetId = args.id or source
    local targetPed = GetPlayerPed(targetId)

    if not IsAdmin(source) then
        lib.notify(source, {
            title = 'Error',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
        return
    end

    if not targetPed or targetPed == 0 then
        lib.notify(source, {
            title = 'Error',
            description = 'Player not found',
            type = 'error'
        })
        return
    end

    TriggerClientEvent('nos_death:admin:kill', targetId)

    if targetId == source then
        lib.notify(source, {
            title = 'Death System',
            description = 'You killed yourself',
            type = 'info'
        })
    else
        local targetName = GetPlayerName(targetId)
        lib.notify(source, {
            title = 'Death System',
            description = ('You killed %s (ID: %d)'):format(targetName, targetId),
            type = 'info'
        })

        lib.notify(targetId, {
            title = 'Death System',
            description = ('You were killed by %s'):format(GetPlayerName(source)),
            type = 'error'
        })
    end
end)

lib.addCommand('revive', {
    help = 'Revive a player or yourself',
    params = {
        {
            name = 'id',
            type = 'playerId',
            help = 'Player ID (optional, defaults to yourself)',
            optional = true
        }
    },
    restricted = 'group.admin'
}, function(source, args)
    local targetId = args.id or source
    local targetPed = GetPlayerPed(targetId)

    if not IsAdmin(source) then
        lib.notify(source, {
            title = 'Error',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
        return
    end

    if not targetPed or targetPed == 0 then
        lib.notify(source, {
            title = 'Error',
            description = 'Player not found',
            type = 'error'
        })
        return
    end

    TriggerClientEvent('nos_death:revive', targetId)

    if targetId == source then
        lib.notify(source, {
            title = 'Death System',
            description = 'You revived yourself',
            type = 'success'
        })
    else
        local targetName = GetPlayerName(targetId)
        lib.notify(source, {
            title = 'Death System',
            description = ('You revived %s (ID: %d)'):format(targetName, targetId),
            type = 'success'
        })

        lib.notify(targetId, {
            title = 'Death System',
            description = ('You were revived by %s'):format(GetPlayerName(source)),
            type = 'success'
        })
    end
end)

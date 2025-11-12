local function isAdmin(source)
    local isAdmin = exports.Badger_Discord_API:HasDiscordRole(source, 'Staff Team')
    return isAdmin
end

RegisterCommand('calladmin', function(source, args, raw)
    if source == 0 then return end

    local name = GetPlayerName(source)
    local message = (args[1] and table.concat(args, ' ')) or 'Admin assistance requested.'

    local players = GetPlayers()
    for _, src in ipairs(players) do
        if isAdmin(src) then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Admin Request',
                description = (name .. ': ' .. message),
                type = 'info',
                duration = 10000
            })
        end
    end
end, false)

local DUTY = {}
local webhook_url =
'https://discord.com/api/webhooks/NOLEAK'

local function formatTime(secs)
    if not secs or secs <= 0 then return '0s' end
    local h = math.floor(secs / 3600)
    local m = math.floor((secs % 3600) / 60)
    local s = secs % 60
    return string.format('%dh %dm %ds', h, m, s)
end

lib.addCommand('timetable', {
    help = 'Send all times table data to Discord (admin only)',
}, function(source, args)
    local times = MySQL.query.await('SELECT * FROM times')
    if not times or #times == 0 then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'No data found!' })
        return
    end

    local header = string.format('%-20s %-16s %-10s %-10s %-20s %-20s', 'Discord ID', 'Username', 'Today', 'Overall',
        'Last Clockin', 'Last Clockout')
    local sep = string.rep('-', 96)
    local rows = {}

    for _, t in ipairs(times) do
        table.insert(rows, string.format('%-20s %-16s %-10s %-10s %-20s %-20s',
            t.discord_id or '',
            t.username or '',
            formatTime(t.total_today or 0),
            formatTime(t.total_overall or 0),
            t.last_clockin and os.date('%Y-%m-%d %H:%M:%S', t.last_clockin) or 'N/A',
            t.last_clockout and os.date('%Y-%m-%d %H:%M:%S', t.last_clockout) or 'N/A'
        ))
    end

    local tableMsg = header .. '\n' .. sep .. '\n' .. table.concat(rows, '\n')

    PerformHttpRequest(webhook_url, function() end, 'POST', json.encode({
        username = 'Times Table Export',
        content = 'All times table data:\n```\n' .. tableMsg .. '\n```'
    }), { ['Content-Type'] = 'application/json' })
    TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = 'Times data sent to Discord!' })
end)

RegisterNetEvent('times:requestJobUsers', function(jobName)
    local src = source
    if not jobName then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'No job specified.' })
        return
    end

    local players = GetPlayers()
    local users = {}
    for _, p in ipairs(players) do
        local pid = tonumber(p)
        if pid then
            local ok = false
            if exports.Badger_Discord_API and exports.Badger_Discord_API.HasDiscordRole then
                ok = exports.Badger_Discord_API:HasDiscordRole(pid, jobName)
            else
                ok = lib.callback.await('discord:hasRole', false, jobName)
            end
            if ok then
                local discordId = nil
                for _, id in ipairs(GetPlayerIdentifiers(pid)) do
                    if string.sub(id, 1, 8) == 'discord:' then
                        discordId = string.sub(id, 9)
                        break
                    end
                end
                local info = {}
                if discordId then
                    local res = MySQL.query.await(
                        'SELECT username, total_today, total_overall, last_clockin FROM times WHERE discord_id = ?',
                        { discordId })
                    if res and res[1] then info = res[1] end
                end
                table.insert(users, {
                    serverId = pid,
                    name = GetPlayerName(pid),
                    discord_id = discordId,
                    totalToday = info.total_today or 0,
                    totalOverall = info.total_overall or 0,
                    lastClockin = info.last_clockin
                })
            end
        end
    end

    TriggerClientEvent('times:jobUsers', src, jobName, users)
end)


RegisterNetEvent('times:requestUserInfo', function(discord_id)
    local src = source
    if not discord_id then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'No discord id provided.' })
        return
    end
    local res = MySQL.query.await('SELECT * FROM times WHERE discord_id = ?', { discord_id })
    local info = res and res[1] or nil
    TriggerClientEvent('times:userInfo', src, info)
end)


AddEventHandler('playerDropped', function(reason)
    local src = source
    if not src then return end

    if not DUTY[src] then
        print(('[times] playerDropped: src=%s not on duty, skipping clock out'):format(src))
        return
    end

    print(('[times] playerDropped: src=%s on duty, clocking out'):format(src))
    clockOut(src, nil, true)
end)

local function formatTime(secs)
    if not secs or secs <= 0 then return '0s' end
    local h = math.floor(secs / 3600)
    local m = math.floor((secs % 3600) / 60)
    local s = secs % 60
    return string.format('%dh %dm %ds', h, m, s)
end

local function sendToDiscord(name, action, info)
    local embed = {
        title = name .. ' ' .. action,
        color = action == 'Clocked In' and 65280 or 16711680,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        fields = {
            { name = 'Current Session', value = formatTime(info.session or 0),                                 inline = true },
            { name = 'Last Session',    value = formatTime(info.last_session or 0),                            inline = true },
            { name = 'Total Today',     value = formatTime(info.total_today or 0),                             inline = true },
            { name = 'Total Overall',   value = formatTime(info.total_overall or 0),                           inline = true },
            { name = 'Clocked In At',   value = info.clockin_at and os.date('%X', info.clockin_at) or 'N/A',   inline = true },
            { name = 'Clocked Out At',  value = info.clockout_at and os.date('%X', info.clockout_at) or 'N/A', inline = true },
        }
    }
    local data = {
        username = 'Clock In/Out',
        embeds = { embed }
    }
    PerformHttpRequest(webhook_url, function() end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end

local MySQL = exports['oxmysql']

MySQL:query([[CREATE TABLE IF NOT EXISTS times (
    discord_id VARCHAR(32) NOT NULL,
    username VARCHAR(64) NOT NULL,
    total_today INT DEFAULT 0,
    total_overall INT DEFAULT 0,
    last_clockin INT DEFAULT NULL,
    last_clockout INT DEFAULT NULL,
    PRIMARY KEY (discord_id)
)]])


function clockIn(source, role)
    local player = GetPlayerName(source)
    local discordId = nil
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, 8) == 'discord:' then
            discordId = string.sub(id, 9)
            break
        end
    end
    if not discordId then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Discord not found!' })
        return
    end
    local now = os.time()
    DUTY[source] = true -- Mark player as on duty
    MySQL:execute(
        'INSERT INTO times (discord_id, username, last_clockin) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE username = VALUES(username), last_clockin = VALUES(last_clockin)',
        {
            discordId, player, now
        })
    MySQL:execute('SELECT * FROM times WHERE discord_id = ?', { discordId }, function(result)
        local info = result and result[1] or {}
        info.session = 0
        info.last_session = info.last_clockout and (info.last_clockout - (info.last_clockin or info.last_clockout)) or 0
        info.clockin_at = now
        info.clockout_at = nil
        info.total_today = info.total_today or 0
        info.total_overall = info.total_overall or 0
        sendToDiscord(player, 'Clocked In', info)
        TriggerClientEvent('times:clockedIn', source)
    end)
end

exports('clockIn', clockIn)

RegisterNetEvent('times:clockin', function(...)
    clockIn(source, ...)
end)

function clockOut(source, role, skipClient)
    local discordId = nil
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, 8) == 'discord:' then
            discordId = string.sub(id, 9)
            break
        end
    end

    if not DUTY[source] then
        if not skipClient then
            TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'You are not on duty!' })
        end
        return
    end
    DUTY[source] = nil -- Remove player from duty table

    if not discordId then
        if not skipClient then
            TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Discord not found!' })
        end
        return
    end

    local player = GetPlayerName(source) or ('[' .. discordId .. ']')
    local now = os.time()
    MySQL:scalar('SELECT last_clockin FROM times WHERE discord_id = ?', { discordId }, function(lastClockin)
        if lastClockin then
            local session = now - lastClockin
            MySQL:execute(
                'UPDATE times SET last_clockout = ?, total_today = total_today + ?, total_overall = COALESCE(total_overall,0) + ? WHERE discord_id = ?',
                {
                    now, session, session, discordId
                })
            MySQL:execute('SELECT total_today, total_overall FROM times WHERE discord_id = ?', { discordId },
                function(result)
                    local info = result and result[1] or {}
                    info.session = session
                    info.last_session = session
                    info.clockin_at = lastClockin
                    info.clockout_at = now
                    info.total_today = info.total_today or 0
                    info.total_overall = info.total_overall or 0
                    sendToDiscord(player, 'Clocked Out', info)
                    if not skipClient then
                        TriggerClientEvent('times:clockedOut', source, {
                            session = session,
                            totalToday = info.total_today,
                            totalOverall = info.total_overall,
                            lastSession = session,
                            clockinAt = lastClockin,
                            clockoutAt = now
                        })
                    end
                end)
        else
            if not skipClient then
                TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Not clocked in!' })
            end
        end
    end)
end

exports('clockOut', clockOut)

RegisterNetEvent('times:clockout', function(...)
    clockOut(source, ...)
end)

RegisterNetEvent('times:requestStats', function()
    local src = source
    local discordId = nil
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(id, 1, 8) == 'discord:' then
            discordId = string.sub(id, 9)
            break
        end
    end
    if not discordId then
        TriggerClientEvent('times:stats', src, {})
        return
    end
    MySQL:execute('SELECT * FROM times WHERE discord_id = ?', { discordId }, function(result)
        local info = result and result[1] or {}
        info.lastSession = info.last_clockout and (info.last_clockout - (info.last_clockin or info.last_clockout)) or 0
        info.clockinAt = info.last_clockin
        info.clockoutAt = info.last_clockout
        info.totalToday = info.total_today or 0
        info.totalOverall = info.total_overall or 0
        TriggerClientEvent('times:stats', src, info)
    end)
end)

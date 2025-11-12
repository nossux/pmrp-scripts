
local onDuty = false

RegisterNetEvent('times:clockedIn', function()
    onDuty = true
    lib.notify({ type = 'success', description = 'Clocked in successfully!' })
end)

local function format_unix(ts)
    if not ts or type(ts) ~= 'number' then
        return 'N/A'
    end

    local days = math.floor(ts / 86400)
    local secs = ts % 86400

    local z = days + 719468
    local era = math.floor(z / 146097)
    local doe = z - era * 146097
    local yoe = math.floor((doe - math.floor(doe / 1460) + math.floor(doe / 36524) - math.floor(doe / 146096)) / 365)
    local y = yoe + era * 400
    local doy = doe - (365 * yoe + math.floor(yoe / 4) - math.floor(yoe / 100))
    local mp = math.floor((5 * doy + 2) / 153)
    local d = doy - math.floor((153 * mp + 2) / 5) + 1
    local m = mp + (mp < 10 and 3 or -9)
    y = y + (m <= 2 and 1 or 0)

    local hour = math.floor(secs / 3600)
    local minute = math.floor((secs % 3600) / 60)
    local second = secs % 60

    return string.format('%04d-%02d-%02d %02d:%02d:%02d', y, m, d, hour, minute, second)
end


RegisterNetEvent('times:clockedOut', function(data)
    onDuty = false
    lib.notify({ type = 'info', description = 'Clocked out! Session: ' .. (data.session or 0) .. 's' })
end)

RegisterNetEvent('times:stats', function(data)
    local msg = 'Last Clocked Out: ' .. (data.lastClockout and format_unix(data.lastClockout) or 'N/A') .. '\n'
    msg = msg .. 'Session Time: ' .. (data.session or 0) .. 's\n'
    msg = msg .. 'Total Today: ' .. (data.totalToday or 0) .. 's\n'
    lib.notify({ type = 'info', description = msg })
end)

RegisterCommand('showtimes', function()
    TriggerServerEvent('times:requestJobs')
end, false)

RegisterNetEvent('times:clockIn', function()
    lib.notify({ type = 'info', description = 'Use /onduty [job] [password] to clock in.' })
end)

RegisterNetEvent('times:clockOut', function()
    if not onDuty then
        lib.notify({ type = 'error', description = 'You are not on duty!' })
        return
    end
    TriggerServerEvent('times:clockOut')
end)

RegisterNetEvent('times:clientRequestJob', function(args)
    if args and args.job then
        TriggerServerEvent('times:requestJobUsers', args.job)
    end
end)

RegisterNetEvent('times:jobUsers', function(jobName, users)
    if not users or #users == 0 then
        lib.notify({ type = 'info', description = 'No users found for ' .. (jobName or 'that job') })
        return
    end

    local userOptions = {}
    for _, u in ipairs(users) do
        local desc = 'Total: ' .. (u.totalOverall and tostring(u.totalOverall) or '0') .. 's'
        desc = desc .. ' • Today: ' .. (u.totalToday and tostring(u.totalToday) or '0')
        desc = desc .. ' • Last Clockin: ' .. (u.lastClockin and format_unix(u.lastClockin) or 'N/A')

        table.insert(userOptions, {
            title = u.name or ('[' .. (u.discord_id or 'unknown') .. ']'),
            description = desc,
            event = 'times:clientRequestUser',
            args = { discord_id = u.discord_id, job = jobName }
        })
    end

    lib.registerContext({ id = 'times_users_' .. (jobName or 'job'), title = jobName or 'Users', options = userOptions })
    lib.showContext('times_users_' .. (jobName or 'job'))
end)


RegisterNetEvent('times:clientRequestUser', function(args)
    if args and args.discord_id and args.job then
        TriggerServerEvent('times:requestUserInfo', args.discord_id, args.job)
    else
        lib.notify({ type = 'error', description = 'User discord id or job not available.' })
    end
end)

RegisterNetEvent('times:userInfo', function(info)
    if not info then
        lib.notify({ type = 'error', description = 'No info returned for user.' })
        return
    end

    local msg = (info.username or 'Unknown') .. '\n'
    msg = msg .. 'Total Today: ' .. (info.total_today or 0) .. 's\n'
    msg = msg .. 'Total Overall: ' .. (info.total_overall or 0) .. 's\n'
    msg = msg .. 'Last Clockin: ' .. (info.last_clockin and format_unix(info.last_clockin) or 'N/A') .. '\n'
    msg = msg .. 'Last Clockout: ' .. (info.last_clockout and format_unix(info.last_clockout) or 'N/A')

    lib.notify({ type = 'info', description = msg })
end)

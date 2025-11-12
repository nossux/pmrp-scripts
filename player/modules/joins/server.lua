local MAX_PLAYERS = GetConvarInt('sv_maxclients', 64)
local WEBHOOK_URL =
"https://discord.com/api/webhooks/NOLEAK"

local function getPlayerIdentifiersStr(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    local idStr = ""
    for i = 1, #identifiers do
        idStr = idStr .. identifiers[i] .. "\n"
    end
    return idStr
end

local function sendDiscordWebhook(title, fields, color)
    PerformHttpRequest(WEBHOOK_URL, function(err, text, headers) end, 'POST', json.encode({
        username = "Server Logger",
        embeds = {
            {
                title = title,
                color = color or 65280,
                fields = fields,
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
                footer = { text = "PMRP Server Logger" }
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end

AddEventHandler('playerJoining', function()
    local playerId = source
    local playerName = GetPlayerName(playerId)
    local identifiers = getPlayerIdentifiersStr(playerId)
    local joinTime = os.date('%Y-%m-%d %H:%M:%S')

    SetTimeout(1000, function()
        local playerCount = #GetPlayers()
        local fields = {
            { name = "Player",       value = playerName,                                       inline = true },
            { name = "ID",           value = tostring(playerId),                               inline = true },
            { name = "Time",         value = joinTime,                                         inline = true },
            { name = "Server Count", value = string.format('%d/%d', playerCount, MAX_PLAYERS), inline = true },
            { name = "Identifiers",  value = string.format('```%s```', identifiers),           inline = false }
        }
        sendDiscordWebhook("🟢 Player Joined", fields, 3066993) -- Discord green
    end)
end)

AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local playerName = GetPlayerName(playerId)
    local identifiers = getPlayerIdentifiersStr(playerId)
    local leaveTime = os.date('%Y-%m-%d %H:%M:%S')

    SetTimeout(1000, function()
        local playerCount = #GetPlayers()
        local fields = {
            { name = "Player",       value = playerName,                                       inline = true },
            { name = "ID",           value = tostring(playerId),                               inline = true },
            { name = "Time",         value = leaveTime,                                        inline = true },
            { name = "Reason",       value = reason or "N/A",                                  inline = true },
            { name = "Server Count", value = string.format('%d/%d', playerCount, MAX_PLAYERS), inline = true },
            { name = "Identifiers",  value = string.format('```%s```', identifiers),           inline = false }
        }
        sendDiscordWebhook("🔴 Player Left", fields, 15158332) -- Discord red
    end)
end)

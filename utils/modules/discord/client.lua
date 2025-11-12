local discord = {}
local playerCharacter = ""
local isPresenceReady = false

local function fetchConfig()
    local config = lib.callback.await('presence:getConfig', false)
    if config then
        discord = config
        return true
    end
    return false
end

local function updatePresence()
    if not isPresenceReady then return end
    
    if not playerCharacter or playerCharacter == "" then
        SetRichPresence('Selecting Character...')
        return
    end

    SetRichPresence(('Playing as %s'):format(playerCharacter))
end

local function initializePresence()
    if not discord.enabled then return false end
    
    SetDiscordAppId(discord.appId)
    SetDiscordRichPresenceAsset(discord.largeIcon.icon)
    SetDiscordRichPresenceAssetText(discord.largeIcon.text)
    SetDiscordRichPresenceAction(0, discord.firstButton.text, discord.firstButton.link)
    SetDiscordRichPresenceAction(1, discord.secondButton.text, discord.secondButton.link)
    
    isPresenceReady = true
    updatePresence()
    return true
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    CreateThread(function()
        Wait(1000)
        
        if not fetchConfig() then
            lib.print.error('Failed to fetch config from server')
            return
        end
        
        if not discord.enabled then
            lib.print.error('Discord presence is disabled in config')
            return
        end
        
        if initializePresence() then
            lib.print.info('Discord Rich Presence initialized successfully')
        else
            lib.print.error('Failed to initialize Discord Rich Presence')
        end
    end)
end)

RegisterNetEvent('presence:setCharacter', function(character)
    playerCharacter = character
    updatePresence()
end)

AddEventHandler('playerSpawned', function()
    Wait(2000)
    updatePresence()
end)

RegisterNetEvent('presence:refreshConfig', function()
    CreateThread(function()
        lib.print.info('Refreshing config...')
        
        if fetchConfig() then
            lib.print.info('Config refreshed successfully')

            if discord.enabled and not isPresenceReady then
                initializePresence()
            elseif not discord.enabled and isPresenceReady then
                isPresenceReady = false
                SetRichPresence('')
                lib.print.error('Discord presence disabled')
            end
        else
            lib.print.error('Failed to refresh config')
        end
    end)
end)

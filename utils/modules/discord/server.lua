local config = {
    enabled = true,                  -- This will enable or disable the built in discord rich presence.

    appId = '1417579027824115712',   -- This is the Application ID (Replace this with you own)

    largeIcon = {                    -- To set this up, visit https://forum.cfx.re/t/how-to-updated-discord-rich-presence-custom-image/157686
        icon = 'logo',               -- Here you will have to put the image name for the 'large' icon.
        text = 'Project Montgomery (Whitelisted)', -- Here you can add hover text for the 'large' icon.
    },

    firstButton = {
        text = 'Discord',
        link = 'https://discord.gg/projectmontgomery',
    },

    secondButton = {
        text = 'Website',
        link = 'https://www.projectmontgomery.net/',
    }
}

lib.callback.register('presence:getConfig', function()
    return config
end)

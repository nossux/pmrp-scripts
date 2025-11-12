fx_version 'cerulean'
game 'gta5'

author 'nossux'
description 'Player System for PMRP'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
}

server_scripts {
    'modules/carry/server.lua',
    'modules/chat/server.lua',
    'modules/discord/server.lua',
}

client_scripts {
    'modules/attack/client.lua',
    'modules/carry/client.lua',
    'modules/chat/client.lua',
    'modules/hud/client.lua',
    'modules/vector/client.lua',
    'modules/ai/client.lua',
    'modules/discord/client.lua',
}

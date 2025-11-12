fx_version 'cerulean'
game 'gta5'

ui_page 'web/build/index.html'
files {
    'web/build/**',
    'data/spawns.lua',
    'modules/alea/config.lua',
    'modules/tow/config.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
}

server_scripts {
    'modules/**/server.lua'
}

client_scripts {
    'modules/**/client.lua'
}

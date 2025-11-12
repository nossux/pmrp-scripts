fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'nossux'
description 'Wave HUD'
version '1.0.0'

ui_page 'web/build/index.html'

files {
    'web/build/**',
    'data/*'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

server_scripts {
    'server/*.lua',
}

client_scripts {
    'client/*.lua',
}

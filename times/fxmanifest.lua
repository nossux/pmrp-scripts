fx_version 'cerulean'
game 'gta5'

author 'nsosux'
description 'LEO/Fire clock-in system for tracking time and sending Discord notifications.'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}

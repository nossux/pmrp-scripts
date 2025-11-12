fx_version 'cerulean'
description "Loadingscreen script by BebikDEV"
games { 'gta5' }
lua54 "yes"

author 'PMR Ownership'
description 'Discord : https://discord.gg/projectmontgomery'
version '1.1.1'

loadscreen 'index.html'
loadscreen_manual_shutdown 'yes'
client_script 'client.lua'
server_script 'server.lua'
loadscreen_cursor 'yes'

files {
    'index.html',
    'css/*',
    'fonts/*',
    'script/*',
    'logo/*',
    'song/*',
    'img/*',
    'screenshots/*'
}

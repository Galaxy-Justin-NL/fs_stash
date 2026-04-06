fx_version 'cerulean'
game 'gta5'

author 'Galaxy_justin'
description 'Fs-Stash: Verkoopbare kluizen via Tablet'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'oxmysql'
}
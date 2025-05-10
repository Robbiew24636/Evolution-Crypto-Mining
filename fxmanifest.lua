fx_version 'cerulean'

game 'gta5'
lua54 'yes'

author 'Evolution Scripts'
description 'Crypto Mining Made By Evolution team'
version '1.0.0'

server_scripts {
    '@ox_lib/init.lua',
    'server.lua',
}

client_scripts {
    'client.lua',
}

dependencies {
    'ox_inventory',
}

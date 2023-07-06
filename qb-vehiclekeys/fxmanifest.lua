fx_version 'cerulean'
game 'gta5'

description 'mm-vehicleKeys'
version '1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

dependencies {
	'ox_lib'
}

lua54 'yes'

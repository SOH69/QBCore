fx_version 'cerulean'
game 'gta5'

description 'mm-weapons'
author 'Master Mind#8816'
version '1.1'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua',
    '@ox_lib/init.lua'
}

server_script 'server/main.lua'
client_script 'client/main.lua'

files {
    'weaponsnspistol.meta'
}

data_file 'WEAPONINFO_FILE_PATCH' 'weaponsnspistol.meta'

dependencies {
	'ox_lib'
}

lua54 'yes'

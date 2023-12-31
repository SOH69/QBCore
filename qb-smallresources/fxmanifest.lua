fx_version 'cerulean'
game 'gta5'

description 'mm-smallresources'
author 'Master Mind#8816'
version '1.0'

shared_script 'config.lua'
shared_script '@ox_lib/init.lua'
shared_script '@qb-core/shared/locale.lua'
shared_script 'locales/en.lua' -- Change to the language you want
server_script 'server/*.lua'
client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua'
}

data_file 'FIVEM_LOVES_YOU_4B38E96CC036038F' 'events.meta'
data_file 'FIVEM_LOVES_YOU_341B23A2F0E0F131' 'popgroups.ymt'

files {
	'events.meta',
	'popgroups.ymt',
	'relationships.dat'
}

dependencies {
	'ox_lib'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'

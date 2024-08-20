fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
author 'citRa'
description 'Framework, inventory, etc. bridge'
version '0.1.1'

dependencies {
    '/server:6166',
    '/gameBuild:2944',
    '/onesync',
    'oxmysql',
    'ox_lib',
}

shared_scripts {
    '@ox_lib/init.lua',
    'main.lua',
}

files {
    'shared/utils.lua',
    'shared/class.lua',
    'modules/**/client.lua',
    'modules/**/**/client.lua',
}

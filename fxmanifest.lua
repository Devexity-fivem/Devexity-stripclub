fx_version 'cerulean'
game 'gta5'

author 'Devexity'
description 'spawns strippers and adds a make it rain option at stripclub'
version '1.0.0'

-- Shared configuration
shared_script 'config.lua'

-- Client-side scripts
client_script 'client/main.lua'

-- Server-side scripts
server_scripts {
    'server/main.lua',
    'devexity.lua'
}
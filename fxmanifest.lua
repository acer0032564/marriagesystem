fx_version "adamant"

game "gta5"

author "Zohair 'Inferno Qureshi Aka Sevres986"

shared_script 'config.lua'

client_script "client.lua"

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

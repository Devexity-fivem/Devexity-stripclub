local QBCore = exports['qb-core']:GetCoreObject()

-- Event for "Make It Rain" Payment Handling
RegisterServerEvent('devexity-makeitrain:Server:Payment')
AddEventHandler('devexity-makeitrain:Server:Payment', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local money = Player.Functions.GetMoney('cash')
    local price = Config.Payment

    if money >= price then
        Player.Functions.RemoveMoney('cash', price)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('not_enough'))
    end
end)

local function getPlayerData(source, cb)
    local playerId = GetPlayerIdentifiers(source)[1]  -- Get the player identifier (adjust as needed)

    local query = 'SELECT * FROM crypto_mining_data WHERE player_id = ?'
    exports.oxmysql:query(query, {playerId}, function(result)
        if result[1] then
            -- If player data exists, return it
            cb(result[1])
        else
            -- If no data exists, create a new entry with default values
            cb({
                player_id = playerId,
                xp = 0,
                level = 1,
                lastDailyReward = 0
            })
        end
    end)
end

local function savePlayerData(playerId, data)
    local query = 'INSERT INTO crypto_mining_data (player_id, xp, level, lastDailyReward) VALUES (?, ?, ?, ?) ' ..
                  'ON DUPLICATE KEY UPDATE xp = ?, level = ?, lastDailyReward = ?'
    exports.oxmysql:query(query, {playerId, data.xp, data.level, data.lastDailyReward, data.xp, data.level, data.lastDailyReward})
end

lib.callback.register('crypto_mining:hasItem', function(source, item)
    return exports.ox_inventory:GetItemCount(source, item) > 0
end)

RegisterServerEvent('crypto_mining:gainXPWithBonus')
AddEventHandler('crypto_mining:gainXPWithBonus', function(bonusCrypto)
    local src = source

    getPlayerData(src, function(data)
        exports.ox_inventory:AddItem(src, 'crypto_chip', bonusCrypto)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Crypto Miner',
            description = ('You received %sx Crypto Chip(s).'):format(bonusCrypto),
            type = 'success'
        })

        data.xp = data.xp + 10
        if data.xp >= data.level * 100 then
            data.xp = 0
            data.level = data.level + 1

            exports.ox_inventory:AddItem(src, 'crypto_chip', 1)

            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Level Up!',
                description = 'You reached level ' .. data.level .. '! +1 Crypto Chip bonus.',
                type = 'success'
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'XP Gained',
                description = 'You gained 10 XP. Current XP: ' .. data.xp .. '/' .. (data.level * 100),
                type = 'inform'
            })
        end

        savePlayerData(GetPlayerIdentifiers(src)[1], data)
    end)
end)

RegisterServerEvent('crypto_mining:buyRTX4060')
AddEventHandler('crypto_mining:buyRTX4060', function()
    local src = source
    local playerId = GetPlayerIdentifiers(src)[1]
    local cryptoCount = exports.ox_inventory:GetItemCount(src, 'crypto_chip') -- Get the number of crypto_chip items the player has

    local itemCost = 30 -- Example cost for the RTX 4060 (can be adjusted)

    if cryptoCount >= itemCost then
        exports.ox_inventory:RemoveItem(src, 'crypto_chip', itemCost)

        exports.ox_inventory:AddItem(src, 'rtx_4060', 1)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Purchase Successful',
            description = 'You have bought 1x RTX 4060 GPU!',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Purchase Failed',
            description = 'You do not have enough Crypto Chips to buy the RTX 4060.',
            type = 'error'
        })
    end
end)

RegisterServerEvent('crypto_mining:buyRTX2060')
AddEventHandler('crypto_mining:buyRTX2060', function()
    local src = source
    local playerId = GetPlayerIdentifiers(src)[1]
    local cryptoCount = exports.ox_inventory:GetItemCount(src, 'crypto_chip') -- Get the number of crypto_chip items the player has

    local itemCost = 20 -- Example cost for the RTX 2060 (can be adjusted)

    if cryptoCount >= itemCost then
        -- Remove the crypto_chip from the player's inventory
        exports.ox_inventory:RemoveItem(src, 'crypto_chip', itemCost)

        exports.ox_inventory:AddItem(src, 'rtx_2060', 1)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Purchase Successful',
            description = 'You have bought 1x RTX 2060 GPU!',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Purchase Failed',
            description = 'You do not have enough Crypto Chips to buy the RTX 2060.',
            type = 'error'
        })
    end
end)

RegisterServerEvent('crypto_mining:buyGPU')
AddEventHandler('crypto_mining:buyGPU', function()
    local src = source
    local playerId = GetPlayerIdentifiers(src)[1]
    local cryptoCount = exports.ox_inventory:GetItemCount(src, 'crypto_chip') -- Get the number of crypto_chip items the player has

    local itemCost = 10 -- Example cost for the GTX 970 (can be adjusted)

    if cryptoCount >= itemCost then
        exports.ox_inventory:RemoveItem(src, 'crypto_chip', itemCost)

        exports.ox_inventory:AddItem(src, 'gtx_970', 1)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Purchase Successful',
            description = 'You have bought 1x GTX 970 GPU!',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Purchase Failed',
            description = 'You do not have enough Crypto Chips to buy the GTX 970.',
            type = 'error'
        })
    end
end)

RegisterServerEvent('ox_inventory:AddItem')
AddEventHandler('ox_inventory:AddItem', function()
    local src = source
    getPlayerData(src, function(data)
        local baseAmount = 10
        local bonus = math.floor(baseAmount * (data.level * 0.05))
        local total = baseAmount + bonus

        print(('[CryptoMining] Player %s collected %s crypto.'):format(src, total))

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Crypto Miner',
            description = ('You collected %s crypto (Level %s Bonus).'):format(total, data.level),
            type = 'success'
        })

        exports.ox_inventory:AddItem(src, 'crypto_chip', total)
    end)
end)

RegisterServerEvent('crypto_mining:getPlayerLevelAndXP')
AddEventHandler('crypto_mining:getPlayerLevelAndXP', function()
    local src = source

    getPlayerData(src, function(data)
        local level = data.level
        local xp = data.xp
        local nextLevelXP = level * 100
        local xpProgress = math.floor((xp / nextLevelXP) * 100)  -- Calculate XP progress percentage

        TriggerClientEvent('crypto_mining:showLevelAndXP', src, level, xp, xpProgress, nextLevelXP)
    end)
end)

RegisterServerEvent('crypto_mining:tradeCryptoForCash')
AddEventHandler('crypto_mining:tradeCryptoForCash', function()
    local src = source
    local player = GetPlayerIdentifiers(src)[1]
    local cryptoCount = exports.ox_inventory:GetItemCount(src, 'crypto_chip')

    if cryptoCount > 0 then
        local cashAmount = cryptoCount * 250

        exports.ox_inventory:RemoveItem(src, 'crypto_chip', cryptoCount)
        exports.ox_inventory:AddItem(src, 'cash', cashAmount)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Crypto for Cash',
            description = 'You traded ' .. cryptoCount .. ' Crypto Chips for $' .. cashAmount .. '.',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Crypto for Cash',
            description = 'You don\'t have any Crypto Chips to trade.',
            type = 'error'
        })
    end
end)

RegisterServerEvent('crypto_mining:claimDailyReward')
AddEventHandler('crypto_mining:claimDailyReward', function()
    local src = source
    getPlayerData(src, function(data)
        local currentTime = os.time()
        local timeSinceLastClaim = currentTime - data.lastDailyReward

        if timeSinceLastClaim >= 86400 then
            exports.ox_inventory:AddItem(src, 'crypto_chip', 10)
            data.lastDailyReward = currentTime
            savePlayerData(GetPlayerIdentifiers(src)[1], data)

            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Daily Reward',
                description = 'You have claimed your daily reward of 10 Crypto Chips!',
                type = 'success'
            })
        else
            local remainingTime = 86400 - timeSinceLastClaim
            local hours = math.floor(remainingTime / 3600)
            local minutes = math.floor((remainingTime % 3600) / 60)

            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Daily Reward',
                description = 'You can claim your next reward in ' .. hours .. ' hours and ' .. minutes .. ' minutes.',
                type = 'error'
            })
        end
    end)
end)
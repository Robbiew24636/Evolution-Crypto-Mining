local isInRange = false
local miningArea = vector3(-1701.69, -1133.62, 13.15)
local range = 2

Citizen.CreateThread(function()
    local model = `xm_prop_base_computer_03`
    RequestModel(model)

    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    local prop = CreateObject(model, miningArea.x, miningArea.y, miningArea.z - 1.0, false, false, false)
    SetEntityHeading(prop, 63.0)
    FreezeEntityPosition(prop, true)
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(miningArea.x, miningArea.y, miningArea.z)
    SetBlipSprite(blip, 478)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Crypto Mining Job")
    EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local distance = #(playerPos - miningArea)

        if distance < range then
            if not isInRange then
                isInRange = true
                lib.showTextUI('[E] - Mine Crypto')
            end
        else
            if isInRange then
                isInRange = false
                lib.hideTextUI()
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isInRange and IsControlJustPressed(0, 38) then
            lib.showContext('some_menu')
        end
    end
end)

RegisterCommand('testcontext', function()
    lib.showContext('some_menu')
end)

local function getMiningUpgrade()
    local upgrades = {
        { item = 'rtx_4060', timeReduction = 15000, reward = 5 },
        { item = 'rtx_2060', timeReduction = 10000, reward = 3 },
        { item = 'gtx_970', timeReduction = 5000, reward = 2 },
    }

    for _, upgrade in ipairs(upgrades) do
        if lib.callback.await('crypto_mining:hasItem', false, upgrade.item) then
            return upgrade.timeReduction, upgrade.reward
        end
    end

    return 0, 1 
end

lib.registerContext({
    id = 'other_menu',
    title = 'Upgrade Menu',
    menu = 'some_menu',
    onBack = function()
        print('Went back!')
    end,
    options = {
        {
            title = 'GTX 970',
            description = 'GTX 970 upgrade to increase profits!',
            icon = 'chart-bar',
            onSelect = function()
                TriggerServerEvent('crypto_mining:buyGPU')
            end,
        },
        {
            title = 'RTX 2060',
            description = 'RTX 2060 upgrade to increase profits!',
            icon = 'chart-bar',
            onSelect = function()
                TriggerServerEvent('crypto_mining:buyRTX2060')
            end,
        },
        {
            title = 'RTX 4060',
            description = 'RTX 4060 upgrade to increase profits!',
            icon = 'chart-bar',
            onSelect = function()
                TriggerServerEvent('crypto_mining:buyRTX4060')
            end,
        }
    }
})

lib.registerContext({
    id = 'some_menu',
    title = 'Crypto Miner',
    options = {
        {
            title = 'Crypto Miner',
            description = 'Establish a connection to mine crypto coins.',
            icon = 'dollar',
            onSelect = function()
                local success = lib.skillCheck({'easy', 'easy'}, {'w', 'a', 's', 'd'})
                if success then
                    local reduction, reward = getMiningUpgrade()
                    local baseDuration = 30000
                    local actualDuration = math.max(baseDuration - reduction, 1000)

                    lib.notify({
                        title = 'Crypto Miner',
                        description = 'Connection successful! Mining...',
                        type = 'success'
                    })

                    local miningCancelled = false

                    -- Start monitoring player state
                    CreateThread(function()
                        while not miningCancelled do
                            local ped = PlayerPedId()
                            if IsPedRagdoll(ped) or IsPedDeadOrDying(ped, true) or IsPedInAnyVehicle(ped, false) then
                                miningCancelled = true
                                lib.cancelProgress()
                                lib.notify({
                                    title = 'Crypto Miner',
                                    description = 'Mining interrupted!',
                                    type = 'error'
                                })
                            end
                            Wait(100)
                        end
                    end)

                    local progress = lib.progressBar({
                        duration = actualDuration,
                        label = 'Mining in progress...',
                        useWhileDead = false,
                        canCancel = false,
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                        }
                    })

                    miningCancelled = true 

                    if progress then
                        TriggerServerEvent('crypto_mining:gainXPWithBonus', reward)
                    end
                else
                    lib.notify({
                        title = 'Crypto Miner',
                        description = 'Connection failed! Try again.',
                        type = 'error'
                    })
                end
            end,
        },
        {
            title = 'Claim Daily Reward',
            description = 'Claim your daily reward!',
            icon = 'gift',
            onSelect = function()
                TriggerServerEvent('crypto_mining:claimDailyReward')
            end,
        },
        {
            title = 'Crypto for Cash',
            description = 'Trade all your Crypto Chips for cash.',
            icon = 'money-bill',
            onSelect = function()
                TriggerServerEvent('crypto_mining:tradeCryptoForCash')
            end,
        },
        {
            title = 'Upgrades',
            description = 'Upgrade menu!',
            menu = 'other_menu',
            icon = 'bars'
        },
        {
            title = 'View Level & XP',
            description = 'See your current level and XP progress.',
            icon = 'chart-bar',
            onSelect = function()
                TriggerServerEvent('crypto_mining:getPlayerLevelAndXP')
            end,
        }
    }
})

RegisterNetEvent('crypto_mining:showLevelAndXP')
AddEventHandler('crypto_mining:showLevelAndXP', function(level, xp, xpProgress, nextLevelXP)
    lib.notify({
        title = 'Current Level & XP',
        description = ('Level: %d\nXP: %d/%d\nProgress: %d%%'):format(level, xp, nextLevelXP, xpProgress),
        type = 'inform'
    })
end)

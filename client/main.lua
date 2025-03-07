local QBCore = exports['qb-core']:GetCoreObject()

-- Utility Functions
local function LoadAnimDict(lib)
    while not HasAnimDictLoaded(lib) do
        RequestAnimDict(lib)
        Wait(5)
    end
end

local function LoadParticleAsset(asset)
    if not HasNamedPtfxAssetLoaded(asset) then
        RequestNamedPtfxAsset(asset)
        while not HasNamedPtfxAssetLoaded(asset) do
            Wait(5)
        end
    end
end

local function CreateDancingNPCs(model, locationData, animDict, animName, isDual, animName2)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Citizen.Wait(10)
    end

    for _, item in pairs(locationData) do
        -- Use item.w for the rotation value
        local npc1 = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.w, false, true)
        local npc2 = nil

        if isDual then
            npc2 = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.w, false, true)
        end

        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(100)
        end

        local netScene = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)

        TaskSynchronizedScene(npc1, netScene, animDict, animName, 1.0, -4.0, 261, 0, 0)
        if isDual and npc2 then
            TaskSynchronizedScene(npc2, netScene, animDict, animName2, 1.0, -4.0, 261, 0, 0)
        end

        FreezeEntityPosition(npc1, true)
        SetEntityHeading(npc1, item.w)
        SetEntityInvincible(npc1, true)
        SetBlockingOfNonTemporaryEvents(npc1, true)

        if isDual and npc2 then
            FreezeEntityPosition(npc2, true)
            SetEntityHeading(npc2, item.w)
            SetEntityInvincible(npc2, true)
            SetBlockingOfNonTemporaryEvents(npc2, true)
        end

        SetSynchronizedSceneLooped(netScene, true)
    end

    SetModelAsNoLongerNeeded(GetHashKey(model))
end

-- Dancing NPCs Setup
Citizen.CreateThread(function()
    CreateDancingNPCs("a_f_y_topless_01", Config.Locations18, "mini@strip_club@lap_dance_2g@ld_2g_p2", "ld_2g_p2_s1", true, "ld_2g_p2_s2")
    CreateDancingNPCs("a_f_y_topless_01", Config.Locations19, "mini@strip_club@private_dance@part3", "priv_dance_p3", false)
    CreateDancingNPCs("a_f_y_topless_01", Config.Locations20, "mini@strip_club@private_dance@part1", "priv_dance_p1", false)
    CreateDancingNPCs("a_f_y_topless_01", Config.Locations21, "mini@strip_club@private_dance@part2", "priv_dance_p2", false)
    CreateDancingNPCs("a_f_y_topless_01", Config.Locations22, "mini@strip_club@pole_dance@pole_dance2", "pd_dance_02", false)
    CreateDancingNPCs("a_f_y_topless_01", Config.Locations23, "mini@strip_club@pole_dance@pole_dance3", "pd_dance_03", false)
    CreateDancingNPCs("a_f_y_topless_01", Config.Locations24, "mini@strip_club@lap_dance_2g@ld_2g_p1", "ld_2g_p1_s1", true, "ld_2g_p1_s2")
    CreateDancingNPCs("a_f_y_topless_01", Config.Locations25, "mini@strip_club@pole_dance@pole_dance1", "pd_dance_01", false)
end)

-- Make It Rain Feature
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local plyCoords = GetEntityCoords(playerPed)
        local distance = #(vector3(Config.Stage.x, Config.Stage.y, Config.Stage.z) - plyCoords)

        if distance < 10 then
            Wait(1)
            if not IsPedInAnyVehicle(playerPed, true) then
                if distance < 3 then
                    exports['qb-core']:DrawText('[E] Make It Rain $10,000', 'right')

                    if IsControlJustReleased(0, 54) then -- "E" Key
                        local PlayerData = QBCore.Functions.GetPlayerData()
                        local money = PlayerData.money.cash
                        
                        if money >= Config.Payment then
                            exports['qb-core']:HideText()
                            TriggerServerEvent('devexity-makeitrain:Server:Payment')

                            LoadParticleAsset("core")
                            LoadAnimDict('anim@mp_player_intcelebrationfemale@raining_cash')

                            local cash = CreateObject(GetHashKey("prop_cash_pile_01"), 0, 0, 0, true, true, true)
                            AttachEntityToEntity(cash, playerPed, GetPedBoneIndex(playerPed, 18905), 0.12, 0.028, 0.001, 300.00, 180.0, 20.0, true, true, false, true, 1, true)

                            TaskPlayAnim(playerPed, 'anim@mp_player_intcelebrationfemale@raining_cash', 'raining_cash', 8.0, -1, -1, 0, 0, false, false, false)
                            Citizen.Wait(1000)

                            UseParticleFxAssetNextCall("core")
                            StartParticleFxNonLoopedOnEntity("ent_brk_banknotes", playerPed, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

                            Citizen.Wait(500)
                            DeleteEntity(cash)
                        else
                            QBCore.Functions.Notify('Not enough cash!', 'error', 7500)
                        end
                    end
                else
                    exports['qb-core']:HideText()
                end
            end
        else
            Wait(500)
        end
    end
end)

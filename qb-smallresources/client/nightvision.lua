local QBCore = exports['qb-core']:GetCoreObject()

local nightvision = false

local mask = {
    male = 154,
    female = 131,
}

RegisterNetEvent("nightvision:UseNightvision", function()
    if not nightvision then
        QBCore.Functions.Progressbar("remove_gear", "Nightvision..", 250, false, true, {}, {}, {}, {}, function()
            local model = GetEntityModel(cache.ped)
            SetNightvision(true)
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "nv", 0.25)
            TriggerServerEvent('smallresources:server:nightvision', 'remove')
            nightvision = true
            if model == `mp_m_freemode_01` then
                SetPedPropIndex(cache.ped, 0, mask.male, 0, true)
            else
                SetPedPropIndex(cache.ped, 0, mask.female, 0, true)
            end
        end)
    end
end)

RegisterCommand('removenightvision', function()
    if nightvision then
        nightvision = false
        SetNightvision(false)
        SetPedPropIndex(cache.ped, 0, 155, 0, true)
        TriggerServerEvent('smallresources:server:nightvision', 'add')
    end
end, false)
local QBCore = exports['qb-core']:GetCoreObject()
local VehicleList = {}

local function GiveKeys(id, plate)
    local citizenid = QBCore.Functions.GetPlayer(id).PlayerData.citizenid
    if not VehicleList[plate] then VehicleList[plate] = {} end
    VehicleList[plate][citizenid] = true
    local ndata = {
        title = 'Recieved',
        description = 'I got the keys to the vehicle',
        type = 'success'
    }
    TriggerClientEvent('ox_lib:notify', id, ndata)
    TriggerClientEvent('vehiclekeys:client:AddTempKeys', id, plate)
end

local function RemoveKeys(id, plate)
    local citizenid = QBCore.Functions.GetPlayer(id).PlayerData.citizenid
    if VehicleList[plate] and VehicleList[plate][citizenid] then
        VehicleList[plate][citizenid] = nil
    end
    TriggerClientEvent('vehiclekeys:client:RemoveTempKeys', id, plate)
end

RegisterNetEvent('vehiclekeys:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

RegisterNetEvent('vehiclekeys:server:AcquireTempVehicleKeys', function(plate)
    local src = source
    GiveKeys(src, plate)
end)

RegisterNetEvent('vehiclekeys:server:RemoveTempVehicleKeys', function(plate)
    local src = source
    RemoveKeys(src, plate)
end)

RegisterNetEvent('vehiclekeys:server:AcquireVehicleKeys', function(plate, model)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local info = {}
		info.label = model.. '-' ..plate
        info.plate = plate
		if Config.Inventory == 'ox' then
            exports.ox_inventory:AddItem(src, 'vehiclekey', 1, info)
        elseif Config.Inventory == 'qb' then
            Player.Functions.AddItem('vehiclekey', 1, false, info)
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["vehiclekey"], "add")
        end
	end
end)

RegisterNetEvent('vehiclekeys:server:breakLockpick', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not (itemName == "lockpick" or itemName == "advancedlockpick") then return end
    if Config.Inventory == 'ox' then
        exports.ox_inventory:RemoveItem(src, itemName, 1)
    elseif Config.Inventory == 'qb' then
        if Player.Functions.RemoveItem(itemName, 1) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[itemName], "remove")
        end
    end
end)

RegisterNetEvent('vehiclekeys:server:RemoveVehicleKeys', function(plate, model)
    local src = source
    local info = {}
	info.label = model.. '-' ..plate
    info.plate = plate
    local items = nil
    if Config.Inventory == 'ox' then
        items = exports.ox_inventory:GetSlotsWithItem(src, 'vehiclekey', info, true)
    elseif Config.Inventory == 'qb' then
        items = exports[Config.Inventory]:GetItemsByName(src, 'vehiclekey')
    end
    if items then
        for _, v in pairs(items) do
            if Config.Inventory == 'ox' then
                if lib.table.matches(v.metadata, info) then
                    exports.ox_inventory:RemoveItem(src, 'vehiclekey', 1, false, v.slot)
                end
            elseif Config.Inventory == 'qb' then
                if lib.table.matches(v.info, info) then
                    exports[Config.Inventory]:RemoveItem(src, 'vehiclekey', 1, v.slot)
                end
            end
        end
    end
end)

lib.addCommand('givetempkeys', {
    help = 'Remove Temporary Keys',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'plate',
            type = 'string',
            help = 'Vehicle plate number',
        }
    },
    restricted = 'group.admin'
}, function(source, args)
    if not args.plate then
        local ndata = {
			title = 'Failed',
    		description = 'Arguments not filled in correctly',
    		type = 'error'
		}
		TriggerClientEvent('ox_lib:notify', source, ndata)
        return
    end
    GiveKeys(args.target or source, args.plate)
end)

lib.addCommand('removetempkeys', {
    help = 'Remove Temporary Keys',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'plate',
            type = 'string',
            help = 'Vehicle plate number',
        }
    },
    restricted = 'group.admin'
}, function(source, args)
    if not args.plate then
        local ndata = {
			title = 'Failed',
    		description = 'Arguments not filled in correctly',
    		type = 'error'
		}
		TriggerClientEvent('ox_lib:notify', source, ndata)
        return
    end
    RemoveKeys(args.target or source, args.plate)
end)

lib.addCommand('givekeys', {
    help = 'Give Permanent Keys',
    params = {},
}, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if (Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "cardealer") and Player.PlayerData.job.onduty then
        TriggerClientEvent('vehiclekeys:client:GiveKeyItem', src)
    else
        local ndata = {
			title = 'Failed',
    		description = 'Not Verified',
    		type = 'error'
		}
        TriggerClientEvent('ox_lib:notify', source, ndata)
    end
end)

lib.addCommand('removekeys', {
    help = 'Remove Permanent Keys',
    params = {},
}, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if (Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "cardealer") and Player.PlayerData.job.onduty then
        TriggerClientEvent('vehiclekeys:client:removeKeyItem', src)
    else
        local ndata = {
			title = 'Failed',
    		description = 'Not Verified',
    		type = 'error'
		}
        TriggerClientEvent('ox_lib:notify', source, ndata)
    end
end)

lib.callback.register('vehiclekeys:server:GetVehicleKeys', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    local keysList = {}
    for plate, citizenids in pairs (VehicleList) do
        if citizenids[citizenid] then
            keysList[plate] = true
        end
    end
    return keysList
end)
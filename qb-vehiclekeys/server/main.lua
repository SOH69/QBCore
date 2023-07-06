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
    TriggerClientEvent('ox_lib:notify', source, ndata)
    TriggerClientEvent('qb-vehiclekeys:client:AddTempKeys', id, plate)
end

local function RemoveKeys(id, plate)
    local citizenid = QBCore.Functions.GetPlayer(id).PlayerData.citizenid
    if VehicleList[plate] and VehicleList[plate][citizenid] then
        VehicleList[plate][citizenid] = nil
    end
    TriggerClientEvent('qb-vehiclekeys:client:RemoveTempKeys', id, plate)
end

RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

RegisterNetEvent('qb-vehiclekeys:server:AcquireTempVehicleKeys', function(plate)
    local src = source
    GiveKeys(src, plate)
end)

RegisterNetEvent('qb-vehiclekeys:server:AcquireVehicleKeys', function(plate, model)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local info = {}
		info.plate = plate
		info.model = model
		Player.Functions.AddItem('keya', 1, false, info)
		TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["keya"], "add")
	end
end)

RegisterNetEvent('qb-vehiclekeys:server:breakLockpick', function(itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not (itemName == "lockpick" or itemName == "advancedlockpick") then return end
    if Player.Functions.RemoveItem(itemName, 1) then
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[itemName], "remove")
    end
end)

QBCore.Commands.Add("tempkeys", 'Get Temporary Key to the Vehicle', {{name = 'ID', help = "Player ID"}, {name = 'Plate', help = 'Vehicle Plate Number'}}, true, function(source, args)
	local src = source
    if not args[1] or not args[2] then
        local ndata = {
			title = 'Failed',
    		description = 'Arguments not filled in correctly',
    		type = 'error'
		}
		TriggerClientEvent('ox_lib:notify', source, ndata)
        return
    end
    GiveKeys(tonumber(args[1]), args[2])
end, 'god')

QBCore.Commands.Add("removekeys", 'Remove Temporary Keys', {{name = 'ID', help = "Player ID"}, {name = 'Plate', help = 'Vehicle Plate Number'}}, true, function(source, args)
	local src = source
    if not args[1] or not args[2] then
        local ndata = {
			title = 'Failed',
    		description = 'Arguments not filled in correctly',
    		type = 'error'
		}
		TriggerClientEvent('ox_lib:notify', source, ndata)
        return
    end
    RemoveKeys(tonumber(args[1]), args[2])
end, 'god')

QBCore.Commands.Add("givekeys", 'Get Key Item(POLICE)', {}, false, function(source, args)
	local src = source
    TriggerClientEvent('qb-vehiclekeys:client:GiveKeyItem', src)
end)

lib.callback.register('qb-vehiclekeys:server:GetVehicleKeys', function(source)
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
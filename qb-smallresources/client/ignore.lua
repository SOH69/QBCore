CreateThread(function()
	while true do
		for _, sctyp in next, Config.BlacklistedScenarios['TYPES'] do
			SetScenarioTypeEnabled(sctyp, false)
		end
		for _, scgrp in next, Config.BlacklistedScenarios['GROUPS'] do
		---@diagnostic disable-next-line: param-type-mismatch
			SetScenarioGroupEnabled(scgrp, false)
		end
		Wait(10000)
	end
end)

AddEventHandler('populationPedCreating', function(x, y, z)
	Wait(500)	-- Give the entity some time to be created
	---@diagnostic disable-next-line: missing-parameter
	local _, handle = GetClosestPed(x, y, z, 1.0) -- Get the entity handle
	SetPedDropsWeaponsWhenDead(handle, false)
end)

CreateThread(function() -- all these should only need to be called once
	if Config.DisableAmbience then
		StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
	end
	SetAudioFlag('PoliceScannerDisabled', true)
	SetGarbageTrucks(false)
	SetCreateRandomCops(false)
	SetCreateRandomCopsNotOnScenarios(false)
	SetCreateRandomCopsOnScenarios(false)
	DistantCopCarSirens(false)
	SetFarDrawVehicles(false)
	RemoveVehiclesFromGeneratorsInArea(335.2616 - 300.0, -1432.455 - 300.0, 46.51 - 300.0, 335.2616 + 300.0, -1432.455 + 300.0, 46.51 + 300.0) -- central los santos medical center
	RemoveVehiclesFromGeneratorsInArea(441.8465 - 500.0, -987.99 - 500.0, 30.68 -500.0, 441.8465 + 500.0, -987.99 + 500.0, 30.68 + 500.0) -- police station mission row
	RemoveVehiclesFromGeneratorsInArea(316.79 - 300.0, -592.36 - 300.0, 43.28 - 300.0, 316.79 + 300.0, -592.36 + 300.0, 43.28 + 300.0) -- pillbox
	RemoveVehiclesFromGeneratorsInArea(-2150.44 - 500.0, 3075.99 - 500.0, 32.8 - 500.0, -2150.44 + 500.0, -3075.99 + 500.0, 32.8 + 500.0) -- military
	RemoveVehiclesFromGeneratorsInArea(-1108.35 - 300.0, 4920.64 - 300.0, 217.2 - 300.0, -1108.35 + 300.0, 4920.64 + 300.0, 217.2 + 300.0) -- nudist
	RemoveVehiclesFromGeneratorsInArea(-458.24 - 300.0, 6019.81 - 300.0, 31.34 - 300.0, -458.24 + 300.0, 6019.81 + 300.0, 31.34 + 300.0) -- police station paleto
	RemoveVehiclesFromGeneratorsInArea(1854.82 - 300.0, 3679.4 - 300.0, 33.82 - 300.0, 1854.82 + 300.0, 3679.4 + 300.0, 33.82 + 300.0) -- police station sandy
	RemoveVehiclesFromGeneratorsInArea(-724.46 - 300.0, -1444.03 - 300.0, 5.0 - 300.0, -724.46 + 300.0, -1444.03 + 300.0, 5.0 + 300.0) -- REMOVE CHOPPERS WOW
end)

if Config.Stun.active then
	CreateThread(function()
		local sleep
		while true do
			sleep = 1000
			if IsPedBeingStunned(cache.ped, 0) then
				sleep = 5
				SetPedMinGroundTimeForStungun(cache.ped, math.random(Config.Stun.min, Config.Stun.max))
			end
			Wait(sleep)
		end
	end)
end


CreateThread(function()
	for i = 1, 15 do
		EnableDispatchService(i, false)
	end

	SetMaxWantedLevel(0)
end)

if Config.IdleCamera then --Disable Idle Cinamatic Cam
	DisableIdleCamera(true)
end

lib.onCache('weapon', function(value)
	if value then
		while IsPedArmed(cache.ped, 6) do
			DisableControlAction(1, 140, true)
			DisableControlAction(1, 141, true)
			DisableControlAction(1, 142, true)

			if value == `WEAPON_FIREEXTINGUISHER` or value == `WEAPON_PETROLCAN` then
				if IsPedShooting(cache.ped) then
					SetPedInfiniteAmmo(cache.ped, true, `WEAPON_FIREEXTINGUISHER`)
					SetPedInfiniteAmmo(cache.ped, true, `WEAPON_PETROLCAN`)
				end
			end
			Wait(5)
		end
	end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    SendNUIMessage({
        action = "open",
    })
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    SendNUIMessage({
        action = "close",
    })
end)



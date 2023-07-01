---@diagnostic disable: param-type-mismatch, cast-local-type
local weapons = {
	'WEAPON_KNIFE',
    'WEAPON_NIGHTSTICK',
    'WEAPON_BREAD',
    'WEAPON_FLASHLIGHT',
    'WEAPON_HAMMER',
    'WEAPON_BAT',
    'WEAPON_GOLFCLUB',
    'WEAPON_CROWBAR',
    'WEAPON_BOTTLE',
    'WEAPON_DAGGER',
    'WEAPON_HATCHET',
    'WEAPON_MACHETE',
    'WEAPON_SWITCHBLADE',
    'WEAPON_BATTLEAXE',
    'WEAPON_POOLCUE',
    'WEAPON_WRENCH',
	'weapon_candycane',
    'WEAPON_PISTOL',
    'WEAPON_PISTOL_MK2',
	'weapon_smg_mk2',
	'weapon_bullpuprifle_mk2',
	'weapon_specialcarbine_mk2',
    'WEAPON_COMBATPISTOL',
    'WEAPON_APPISTOL',
    'WEAPON_PISTOL50',
    'WEAPON_REVOLVER',
    'WEAPON_SNSPISTOL',
    'WEAPON_HEAVYPISTOL',
    'WEAPON_VINTAGEPISTOL',
    'WEAPON_MICROSMG',
    'WEAPON_SMG',
    'WEAPON_ASSAULTSMG',
    'WEAPON_MINISMG',
    'WEAPON_MACHINEPISTOL',
    'WEAPON_COMBATPDW',
    'WEAPON_PUMPSHOTGUN',
    'WEAPON_SAWNOFFSHOTGUN',
    'WEAPON_ASSAULTSHOTGUN',
    'WEAPON_BULLPUPSHOTGUN',
    'WEAPON_HEAVYSHOTGUN',
    'WEAPON_ASSAULTRIFLE',
    'WEAPON_CARBINERIFLE',
    'WEAPON_ADVANCEDRIFLE',
    'WEAPON_SPECIALCARBINE',
    'WEAPON_BULLPUPRIFLE',
    'WEAPON_COMPACTRIFLE',
    'WEAPON_MG',
    'WEAPON_COMBATMG',
    'WEAPON_GUSENBERG',
    'WEAPON_SNIPERRIFLE',
    'WEAPON_HEAVYSNIPER',
    'WEAPON_MARKSMANRIFLE',
    'WEAPON_GRENADELAUNCHER',
    'WEAPON_RPG',
    'WEAPON_STINGER',
    'WEAPON_MINIGUN',
    'WEAPON_GRENADE',
    'WEAPON_STICKYBOMB',
    'WEAPON_SMOKEGRENADE',
    'WEAPON_BZGAS',
    'WEAPON_MOLOTOV',
    'WEAPON_DIGISCANNER',
    'WEAPON_FIREWORK',
    'WEAPON_MUSKET',
    'WEAPON_STUNGUN',
	'WEAPON_STUNGUN_MP',
    'WEAPON_HOMINGLAUNCHER',
    'WEAPON_PROXMINE',
    'WEAPON_FLAREGUN',
    'WEAPON_MARKSMANPISTOL',
    'WEAPON_RAILGUN',
    'WEAPON_DBSHOTGUN',
    'WEAPON_AUTOSHOTGUN',
    'WEAPON_COMPACTLAUNCHER',
    'WEAPON_PIPEBOMB',
    'WEAPON_DOUBLEACTION',
	'WEAPON_ASSAULTRIFLE_MK2',
	'WEAPON_CERAMICPISTOL',
	'WEAPON_SNSPISTOL_MK2',
	'WEAPON_CARBINERIFLE_MK2',
	'weapon_pistolxm3',
	'weapon_tecpistol',
	'weapon_heavyrifle',
	'weapon_militaryrifle',
	'weapon_tacticalrifle',
	'weapon_combatmg_mk2',
	'weapon_precisionrifle',
	'weapon_railgunxm3',
	'weapon_navyrevolver',
	'weapon_gadgetpistol',
	'weapon_revolver_mk2',
	'weapon_marksmanpistol',
	'weapon_raypistol',


    -- GGC Custom Weapons -- Melees
    'WEAPON_KATANA',
    'WEAPON_SHIV',
    'WEAPON_SLEDGEHAMMER',
    'WEAPON_KARAMBIT',
    'WEAPON_KEYBOARD',
    -- GGC Custom Weapons -- Hand Guns
    'WEAPON_GLOCK17',
    'WEAPON_GLOCK18C',
    'WEAPON_GLOCK22',
    'WEAPON_DEAGLE',
    'WEAPON_FNX45',
    'WEAPON_M1911',
    'WEAPON_GLOCK20',
    'WEAPON_GLOCK19GEN4',
    -- GGC Custom Weapons -- SMGs
    'WEAPON_PMXFM',
    'WEAPON_MAC10',
    -- GGC Custom Weapons -- Rifles
    'WEAPON_MK47FM',
    'WEAPON_M6IC',
    'WEAPON_SCARSC',
    'WEAPON_M4',
    'WEAPON_AK47',
    'WEAPON_AK74',
    'WEAPON_AKS74',
    'WEAPON_GROZA',
    'WEAPON_SCARH',
}

-- Wheapons that require the Police holster animation
local holsterableWeapons = {
	'WEAPON_PISTOL',
	'WEAPON_PISTOL_MK2',
	'WEAPON_COMBATPISTOL',
	'WEAPON_APPISTOL',
	'WEAPON_PISTOL50',
	'WEAPON_REVOLVER',
	'WEAPON_SNSPISTOL',
	'WEAPON_HEAVYPISTOL',
	'WEAPON_VINTAGEPISTOL',
	'WEAPON_GLOCK17',
    'WEAPON_GLOCK18C',
    'WEAPON_GLOCK22',
    'WEAPON_DEAGLE',
    'WEAPON_FNX45',
    'WEAPON_M1911',
    'WEAPON_GLOCK20',
    'WEAPON_GLOCK19GEN4',
	'weapon_pistolxm3',
	'weapon_tecpistol',
	'WEAPON_DBSHOTGUN',
	'WEAPON_STUNGUN',
	'WEAPON_STUNGUN_MP',
	'WEAPON_DOUBLEACTION',
	'WEAPON_CERAMICPISTOL',
	'WEAPON_SNSPISTOL_MK2',
	'WEAPON_SAWNOFFSHOTGUN',
	'weapon_navyrevolver',
	'weapon_gadgetpistol',
	'weapon_revolver_mk2',
	'weapon_marksmanpistol',
	'weapon_flaregun',
	'weapon_raypistol',
	'weapon_machinepistol'
}

local QBCore = exports['qb-core']:GetCoreObject()

local holstered = true
local canFire = true
local currWeapon = `WEAPON_UNARMED`
local currentHolster = nil
local currentHolsterTexture = nil
local WearingHolster = nil
local PlayerJob = {}

local function loadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

local function CheckWeapon(newWeap)
	for i = 1, #weapons do
		if joaat(weapons[i]) == newWeap then
			return true
		end
	end
	return false
end

local function IsWeaponHolsterable(weap)
	for i = 1, #holsterableWeapons do
		if joaat(holsterableWeapons[i]) == weap then
			return true
		end
	end
	return false
end

RegisterNetEvent('weapons:ResetHolster', function()
	holstered = true
	canFire = true
	currWeapon = `WEAPON_UNARMED`
	currentHolster = nil
	currentHolsterTexture = nil
	WearingHolster = nil
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

local function DisableFiring()
	CreateThread(function()
		while not canFire do
			DisableControlAction(0, 25, true)
			DisablePlayerFiring(PlayerId(), true)
			Wait(5)
		end
	end)
end

lib.onCache('weapon', function(value)
	if GetResourceState('mm_inventory') == 'missing' then return end -- This part is only made to work with mm_inventory, other inventories might conflict
	if value then
		local ped = cache.ped
		if DoesEntityExist(ped) and currWeapon ~= GetSelectedPedWeapon(ped) and not IsEntityDead(ped) and not IsPedInParachuteFreeFall(ped) and not IsPedFalling(ped) and (GetPedParachuteState(ped) == -1 or GetPedParachuteState(ped) == 0) then
			if currWeapon ~= GetSelectedPedWeapon(ped) then
				local pos = GetEntityCoords(ped, true)
				local rot = GetEntityHeading(ped)

				local newWeap = GetSelectedPedWeapon(ped)
				SetCurrentPedWeapon(ped, currWeapon, true)
				loadAnimDict("reaction@intimidation@1h")
				loadAnimDict("reaction@intimidation@cop@unarmed")
				loadAnimDict("rcmjosh4")
				loadAnimDict("weapons@pistol@")

				local HolsterVariant = GetPedDrawableVariation(ped, 8)
				--if PlayerJob.name == 'police' then
				--WearingHolster = true
				--else
				WearingHolster = false
				--end
				if CheckWeapon(newWeap) then
					if holstered then
						if WearingHolster then
							--TaskPlayAnim(ped, "rcmjosh4", "josh_leadout_cop2", 8.0, 2.0, -1, 48, 10, 0, 0, 0 )
							canFire = false
							DisableFiring()
							currentHolster = GetPedDrawableVariation(ped, 7)
							currentHolsterTexture = GetPedTextureVariation(ped, 7)
							TaskPlayAnimAdvanced(ped, "rcmjosh4", "josh_leadout_cop2", pos.x, pos.y, pos.z, 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
							Wait(300)
							SetCurrentPedWeapon(ped, newWeap, true)

							if IsWeaponHolsterable(newWeap) then
								SetPedComponentVariation(ped, 7, currentHolster == 8 and 2 or currentHolster == 1 and 3 or currentHolster == 6 and 5, currentHolsterTexture, 2)
							end
							currWeapon = newWeap
							Wait(300)
							ClearPedTasks(ped)
							holstered = false
							canFire = true
						else
							canFire = false
							DisableFiring()
							TaskPlayAnimAdvanced(ped, "reaction@intimidation@1h", "intro", pos.x, pos.y, pos.z, 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
							Wait(1000)
							SetCurrentPedWeapon(ped, newWeap, true)
							currWeapon = newWeap
							Wait(1400)
							ClearPedTasks(ped)
							holstered = false
							canFire = true
						end
					elseif newWeap ~= currWeapon and CheckWeapon(currWeapon) then
						if WearingHolster then
							canFire = false
							DisableFiring()
							TaskPlayAnimAdvanced(ped, "reaction@intimidation@cop@unarmed", "intro", pos.x, pos.y, pos.z, 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
							Wait(500)

							if IsWeaponHolsterable(currWeapon) then
								SetPedComponentVariation(ped, 7, currentHolster, currentHolsterTexture, 2)
							end

							SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
							currentHolster = GetPedDrawableVariation(ped, 7)
							currentHolsterTexture = GetPedTextureVariation(ped, 7)

							TaskPlayAnimAdvanced(ped, "rcmjosh4", "josh_leadout_cop2", pos.x, pos.y, pos.z, 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
							Wait(300)
							SetCurrentPedWeapon(ped, newWeap, true)

							if IsWeaponHolsterable(newWeap) then
								SetPedComponentVariation(ped, 7, currentHolster == 8 and 2 or currentHolster == 1 and 3 or currentHolster == 6 and 5, currentHolsterTexture, 2)
							end

							Wait(500)
							currWeapon = newWeap
							ClearPedTasks(ped)
							holstered = false
							canFire = true
						else
							canFire = false
							DisableFiring()
							TaskPlayAnimAdvanced(ped, "reaction@intimidation@1h", "outro", pos.x, pos.y, pos.z, 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
							Wait(1600)
							SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
							local newpos = GetEntityCoords(ped, true)
							TaskPlayAnimAdvanced(ped, "reaction@intimidation@1h", "intro", newpos.x, newpos.y, newpos.z, 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
							Wait(1000)
							SetCurrentPedWeapon(ped, newWeap, true)
							currWeapon = newWeap
							Wait(1400)
							ClearPedTasks(ped)
							holstered = false
							canFire = true
						end
					else
						if WearingHolster then
							SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
							currentHolster = GetPedDrawableVariation(ped, 7)
							currentHolsterTexture = GetPedTextureVariation(ped, 7)
							TaskPlayAnimAdvanced(ped, "rcmjosh4", "josh_leadout_cop2", pos.x, pos.y, pos.z, 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
							Wait(300)
							SetCurrentPedWeapon(ped, newWeap, true)

							if IsWeaponHolsterable(newWeap) then
								SetPedComponentVariation(ped, 7, currentHolster == 8 and 2 or currentHolster == 1 and 3 or currentHolster == 6 and 5, currentHolsterTexture, 2)
							end

							currWeapon = newWeap
							Wait(300)
							ClearPedTasks(ped)
							holstered = false
							canFire = true
						else
							SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
							TaskPlayAnimAdvanced(ped, "reaction@intimidation@1h", "intro", pos.x, pos.y, pos.z, 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
							Wait(1000)
							SetCurrentPedWeapon(ped, newWeap, true)
							currWeapon = newWeap
							Wait(1400)
							ClearPedTasks(ped)
							holstered = false
							canFire = true
						end
					end
				else
					if not holstered and CheckWeapon(currWeapon) then
						if WearingHolster then
							canFire = false
							DisableFiring()
							TaskPlayAnimAdvanced(ped, "reaction@intimidation@cop@unarmed", "intro", pos.x, pos.y, pos.z, 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
							Wait(500)

							if IsWeaponHolsterable(currWeapon) then
								SetPedComponentVariation(ped, 7, currentHolster, currentHolsterTexture, 2)
							end

							SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
							ClearPedTasks(ped)
							SetCurrentPedWeapon(ped, newWeap, true)
							holstered = true
							canFire = true
							currWeapon = newWeap
						else
							canFire = false
							DisableFiring()
							TaskPlayAnimAdvanced(ped, "reaction@intimidation@1h", "outro", pos.x, pos.y, pos.z, 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
							Wait(1400)
							SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
							ClearPedTasks(ped)
							SetCurrentPedWeapon(ped, newWeap, true)
							holstered = true
							canFire = true
							currWeapon = newWeap
						end
					else
						SetCurrentPedWeapon(ped, newWeap, true)
						holstered = false
						canFire = true
						currWeapon = newWeap
					end
				end
			end
		end
	end
end)
local Crouched = false
local CrouchedForce = false
local Aimed = false
local LastCam = 0
local Cooldown = false

local CoolDownTime = 500

local function RequestAnimationSet()
    while not HasAnimSetLoaded('move_ped_crouched') do
        Wait(5)
        RequestAnimSet('move_ped_crouched')
    end
end

local NormalWalk = function()
	local Player = cache.ped
	SetPedMaxMoveBlendRatio(Player, 1.0)
	ResetPedMovementClipset(Player, 0.55)
	ResetPedStrafeClipset(Player)
	SetPedCanPlayAmbientAnims(Player, true)
	SetPedCanPlayAmbientBaseAnims(Player, true)
	ResetPedWeaponMovementClipset(Player)
	Crouched = false
end

local RemoveCrouchAnim = function()
	RemoveAnimDict('move_ped_crouched')
end

local CanCrouch = function()
	local PlayerPed = cache.ped
	if IsPedOnFoot(PlayerPed) and not IsPedJumping(PlayerPed) and not IsPedFalling(PlayerPed) and not IsPedDeadOrDying(PlayerPed, false) then
		return true
	else
		return false
	end
end

local CrouchPlayer = function()
	local Player = cache.ped
	SetPedUsingActionMode(Player, false, -1, "DEFAULT_ACTION")
	SetPedMovementClipset(Player, 'move_ped_crouched', 0.55)
	SetPedStrafeClipset(Player, 'move_ped_crouched_strafing')
	SetWeaponAnimationOverride(Player, "Ballistic")
	Crouched = true
	Aimed = false
end

local SetPlayerAimSpeed = function()
	local Player = cache.ped
	SetPedMaxMoveBlendRatio(Player, 0.2)
	Aimed = true
end

local IsPlayerFreeAimed = function()
	local PlayerID = GetPlayerIndex()
	if IsPlayerFreeAiming(PlayerID) or IsAimCamActive() or IsAimCamThirdPersonActive() then
		return true
	else
		return false
	end
end

local CrouchLoop = function()
	RequestAnimationSet()
	while CrouchedForce do
		local CanDo = CanCrouch()
		if CanDo and Crouched and IsPlayerFreeAimed() then
			SetPlayerAimSpeed()
		elseif CanDo and (not Crouched or Aimed) then
			CrouchPlayer()
		elseif not CanDo and Crouched then
			CrouchedForce = false
			NormalWalk()
		end

		local NowCam = GetFollowPedCamViewMode()
		if CanDo and Crouched and NowCam == 4 then
			SetFollowPedCamViewMode(LastCam)
		elseif CanDo and Crouched and NowCam ~= 4 then
			LastCam = NowCam
		end

		Wait(500)
	end
	NormalWalk()
	RemoveCrouchAnim()
end

RegisterCommand('crouch', function()
	DisableControlAction(0, 36, true)
	if not Cooldown then
		CrouchedForce = not CrouchedForce

		if CrouchedForce then
			CreateThread(CrouchLoop)
		end

		Cooldown = true
		SetTimeout(CoolDownTime, function()
			Cooldown = false
		end)
	end
end, false)

RegisterKeyMapping('crouch', 'Crouch', 'keyboard', 'LCONTROL')


-- Exports --
local IsCrouched = function()
	return Crouched
end

exports("IsCrouched", IsCrouched)
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local keys = {}
local tempKeys = {}
local IsHotwiring = false
local looped = false
local isTakingKeys = false
local canCarjack = true
local isCarjacking = false
local lastPickedVehicle = nil
local showTxt = false
local grabkey = false

local function CheckKeys(PlayerItems)
    keys = {}
    for _, item in pairs(PlayerItems) do
        if item.name == "keya" then
            keys[item.info.plate] = true
        end
    end
end

local function GetKeys()
    lib.callback('qb-vehiclekeys:server:GetVehicleKeys', false, function(keysList)
        KeysList = keysList
    end)
end

local function AttemptPoliceAlert(type)
    if not AlertSend then
        local chance = Config.PoliceAlertChance
        if GetClockHours() >= 1 and GetClockHours() <= 6 then
            chance = Config.PoliceNightAlertChance
        end
        if math.random() <= chance then
           TriggerServerEvent('police:server:policeAlert', 'Vehicle theft in progress. Type: ' .. type)
        end
        AlertSend = true
        SetTimeout(Config.AlertCooldown, function()
            AlertSend = false
        end)
    end
end

local function HotwireHandler(vehicle, plate)
    local hotwireTime = math.random(Config.minHotwireTime, Config.maxHotwireTime)
    local ped = cache.ped
    IsHotwiring = true
    SetVehicleAlarm(vehicle, true)
    SetVehicleAlarmTimeLeft(vehicle, hotwireTime)
    exports['qb-core']:HideText()
    showTxt = false
    QBCore.Functions.Progressbar("hotwire_vehicle", 'Hotwiring Vehicle...', hotwireTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        flags = 16
    }, {}, {}, function() -- Done
        StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        if (math.random() <= Config.HotwireChance) then
            SetVehicleEngineOn(vehicle, true, false, true)
            TriggerServerEvent('qb-vehiclekeys:server:AcquireTempVehicleKeys', plate)
        else
            lib.notify({
                title = 'Failed',
                description = 'Aah it seems too hard!',
                type = 'error'
            })
        end
        Wait(1000)
        IsHotwiring = false
    end, function() -- Cancel
        exports['qb-core']:DrawText('[H] Hotwire Vehicle')
        showTxt = true
        StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
        Wait(1000)
        IsHotwiring = false
    end)
    SetTimeout(10000, function()
        AttemptPoliceAlert("steal")
    end)
end

local function ToggleVehicleLock(veh)
    if veh then
        local ped = cache.ped
        local vehLockStatus = GetVehicleDoorLockStatus(veh)

        lib.requestAnimDict("anim@mp_player_intmenu@key_fob@")
        TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false, false)

        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)

        NetworkRequestControlOfEntity(veh)
        if vehLockStatus == 1 then
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 2)
            lib.notify({
                title = 'Locked',
                type = 'success'
            })
        else
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1)
            lib.notify({
                title = 'Unlocked',
                type = 'success'
            })
        end

        SetVehicleLights(veh, 2)
        Wait(250)
        SetVehicleLights(veh, 1)
        Wait(200)
        SetVehicleLights(veh, 0)
        Wait(300)
        ClearPedTasks(ped)
    end
end

local function MakePedFlee(ped)
    SetPedFleeAttributes(ped, 0, false)
    TaskReactAndFleePed(ped, cache.ped)
end

local function AttemptPoliceAlert(type)
    if not AlertSend then
        local chance = Config.PoliceAlertChance
        if GetClockHours() >= 1 and GetClockHours() <= 6 then
            chance = Config.PoliceNightAlertChance
        end
        if math.random() <= chance then
           TriggerServerEvent('police:server:policeAlert', 'Vehicle theft in progress. Type: ' .. type)
        end
        AlertSend = true
        SetTimeout(Config.AlertCooldown, function()
            AlertSend = false
        end)
    end
end

local function IsBlacklistedWeapon(weapon)
    if weapon then
        for _, v in pairs(Config.NoCarjackWeapons) do
            if weapon == joaat(v) then
                return true
            end
        end
    end
    return false
end

local function GetPedsInVehicle(vehicle)
    local otherPeds = {}
    for seat=-1,GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))-2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if not IsPedAPlayer(pedInSeat) and pedInSeat ~= 0 then
            otherPeds[#otherPeds+1] = pedInSeat
        end
    end
    return otherPeds
end

local function CarjackVehicle(target,playerid)
    if not Config.CarJackEnable then return end
    isCarjacking = true
    canCarjack = false
    lib.requestAnimDict('mp_am_hold_up')
    local vehicle = GetVehiclePedIsUsing(target)
    local occupants = GetPedsInVehicle(vehicle)
    for p=1,#occupants do
        local ped = occupants[p]
        CreateThread(function()
            TaskLeaveVehicle(ped, vehicle, 0)
            if ped ~= target then
                TaskSmartFleePed(ped, cache.ped, -1, -1, false, false)
            end
        end)
        Wait(math.random(200,500))
    end
    TaskTurnPedToFaceEntity(target, cache.ped, 3.0)
    TaskSetBlockingOfNonTemporaryEvents(target, true)
    TaskPlayAnim(target, "mp_am_hold_up", "holdup_victim_20s", 8.0, -8, -1, 12, 1, false, false, false)
    
    -- Cancel progress bar if: Ped dies during robbery, car gets too far away
    CreateThread(function()
        while isCarjacking do
            SetPedKeepTask(target, true)
            local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(target))
            if IsPedDeadOrDying(target, false) or distance > 7.5 or IsPlayerFreeAiming(cache.ped) then
                TriggerEvent("progressbar:client:cancel")
            end
            Wait(100)
        end
    end)
    QBCore.Functions.Progressbar("rob_keys", 'Stealing Vehicle...', Config.CarjackingTime, false, true, {}, {}, {}, {}, function()
        local hasWeapon, weaponHash = GetCurrentPedWeapon(cache.ped, true)
        if hasWeapon and isCarjacking then
            local carjackChance
            if Config.CarjackChance[tostring(GetWeapontypeGroup(weaponHash))] then
                carjackChance = Config.CarjackChance[tostring(GetWeapontypeGroup(weaponHash))]
            else
                carjackChance = 0.5
            end
            if math.random() <= carjackChance then
                local plate = QBCore.Functions.GetPlate(vehicle)
                lib.requestAnimDict('mp_common')
                TaskPlayAnim(target, "mp_common", "givetake1_a", 8.0, -8, -1, 12, 1, false, false, false)
                Wait(1250)
                ClearPedTasksImmediately(target)
                MakePedFlee(target)
                TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
                if NetworkIsPlayerTalking(playerid) then
                    TriggerServerEvent('qb-vehiclekeys:server:AcquireTempVehicleKeys', plate)
                else
                    TaskVehicleMissionPedTarget(target, vehicle, cache.ped, 8, 100.0, 786468, 300.0, 15.0, true)
                    lib.notify({
                        title = 'Failed',
                        description = 'Driver Fled Away!',
                        type = 'error'
                    })
                end
            else
                lib.notify({
                    title = 'Failed',
                    description = 'Cannot retrive the keys!',
                    type = 'error'
                })
                TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            end
            isCarjacking = false
            Wait(2000)
            AttemptPoliceAlert("carjack")
            Wait(Config.DelayBetweenCarjackings)
            canCarjack = true
        end
    end, function()
        MakePedFlee(target)
        isCarjacking = false
        Wait(Config.DelayBetweenCarjackings)
        canCarjack = true
    end)
end

local function robKeyLoop(weapon)
    if looped == false then
        looped = true
        while true do
            local sleep = 1000
            if LocalPlayer.state.isLoggedIn then
                sleep = 100

                local ped = cache.ped
                local entering = GetVehiclePedIsTryingToEnter(ped)

                if weapon and Config.CarJackEnable and canCarjack then
                    local playerid = PlayerId()
                    local aiming, target = GetEntityPlayerIsFreeAimingAt(playerid)
                    if aiming and (target ~= nil and target ~= 0) then
                        if DoesEntityExist(target) and IsPedInAnyVehicle(target, false) and not IsEntityDead(target) and not IsPedAPlayer(target) then
                            local targetveh = GetVehiclePedIsIn(target, false)
                            if GetPedInVehicleSeat(targetveh, -1) == target and not IsBlacklistedWeapon(weapon) then
                                local pos = GetEntityCoords(ped, true)
                                local targetpos = GetEntityCoords(target, true)
                                if #(pos - targetpos) < 5.0 then
                                    CarjackVehicle(target, playerid)
                                end
                            end
                        end
                    end
                end

                if IsPedInAnyVehicle(ped, false) and not IsHotwiring then
                    sleep = 1000
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    local plate = QBCore.Functions.GetPlate(vehicle)
                    if GetPedInVehicleSeat(vehicle, -1) == cache.ped and (not keys[plate] and not tempKeys[plate]) then
                        sleep = 5
                        SetVehicleEngineOn(vehicle, false, false, true)
                        if IsControlJustPressed(0, 74) then
                            HotwireHandler(vehicle, plate)
                        end
                    end
                end

                if entering == 0 and not IsPedInAnyVehicle(ped, false) and GetSelectedPedWeapon(ped) == `WEAPON_UNARMED` then
                    if showTxt then
                        exports['qb-core']:HideText()
                        showTxt = false
                    end
                    looped = false
                    break
                end
            end
            Wait(sleep)
        end
    end
end

local function GrabKey(plate, vehicle)
    if grabkey then return end
    print('entering')
    grabkey = true
    local entering = vehicle
    local driver = GetPedInVehicleSeat(entering, -1)
    if driver ~= 0 and not IsPedAPlayer(driver) then
        if IsEntityDead(driver) then
            if not isTakingKeys then
                isTakingKeys = true
                QBCore.Functions.Progressbar("steal_keys", 'Taking keys...', 2500, false, false, {
                    disableMovement = false,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true
                }, {}, {}, {}, function() -- Done
                    TriggerServerEvent('qb-vehiclekeys:server:AcquireTempVehicleKeys', plate)
                    Wait(100)
                    isTakingKeys = false
                    grabkey = false
                end, function()
                    Wait(100)
                    isTakingKeys = false
                    grabkey = false
                end)
            end
        elseif Config.LockNPCDrivingCars then
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 2)
            SetPedCanBeDraggedOut(driver, false)
            TaskVehicleMissionPedTarget(driver, vehicle, cache.ped, 8, 50.0, 790564, 300.0, 15.0, true)
            grabkey = false
        else
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 1)
            if Config.GetKeyDefault then
                TriggerServerEvent('qb-vehiclekeys:server:AcquireTempVehicleKeys', plate)
            end
            --Make passengers flee
            local pedsInVehicle = GetPedsInVehicle(entering)
            for _, pedInVehicle in pairs(pedsInVehicle) do
                if pedInVehicle ~= GetPedInVehicleSeat(entering, -1) then
                    MakePedFlee(pedInVehicle)
                end
            end
            grabkey = false
        end
    elseif driver == 0 and entering ~= lastPickedVehicle and not isTakingKeys and not grabkey and (not keys[plate] or not tempKeys[plate]) then
        if Config.LockNPCParkedCars then
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 2)
        else
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 1)
        end
        grabkey = false
    end
end

local function LockpickFinishCallback(success, usingAdvanced)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local chance = math.random()
    if success then
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        lastPickedVehicle = vehicle
        if GetPedInVehicleSeat(vehicle, -1) == cache.ped then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', QBCore.Functions.GetPlate(vehicle))
        else
            lib.notify({
                title = 'Lockpicked',
                type = 'success'
            })
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)
        end
    else
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        AttemptPoliceAlert("steal")
    end
    if usingAdvanced then
        if chance <= Config.RemoveLockpickAdvanced then
            TriggerServerEvent("qb-vehiclekeys:server:breakLockpick", "advancedlockpick")
        end
    else
        if chance <= Config.RemoveLockpickNormal then
            TriggerServerEvent("qb-vehiclekeys:server:breakLockpick", "lockpick")
        end
    end
end

local function LockpickDoor(isAdvanced)
    local ped = cache.ped
    local pos = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle()

    if vehicle == nil or vehicle == 0 then return end
    if HasKeys(QBCore.Functions.GetPlate(vehicle)) then return end
    if #(pos - GetEntityCoords(vehicle)) > 2.5 then return end
    if GetVehicleDoorLockStatus(vehicle) <= 0 then return end

    exports['ps-ui']:Circle(function(success)
        LockpickFinishCallback(success, isAdvanced)
    end, Config.LockPick.Amt, Config.LockPick.Time) -- NumberOfCircles, MS
end

-- Ox Libs

lib.onCache('vehicle', function(value)
    if IsPedInAnyVehicle(cache.ped, true) then
        local vehicle = GetVehiclePedIsIn(cache.ped, true)
        local plate = QBCore.Functions.GetPlate(vehicle)

        if keys[plate] or tempKeys[plate] then
            SetVehicleEngineOn(vehicle, true, false, true)
            showTxt = false
        elseif not IsHotwiring then
            exports['qb-core']:DrawText('[H] Hotwire Vehicle')
            showTxt = true
            robKeyLoop(false)
        end
    else
        if showTxt then
            exports['qb-core']:HideText()
            showTxt = false
        end
        grabkey = false
    end
end)

lib.onCache('weapon', function(value)
    if value then
        robKeyLoop(value)
    end
end)


-- Handles state right when the player selects their character and location.
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    CheckKeys(PlayerData.items)
    GetKeys()
end)

-- Resets state on logout, in case of character change.
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    CheckKeys({})
    PlayerData = {}
end)

-- Handles state if resource is restarted live.
AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        PlayerData = QBCore.Functions.GetPlayerData()
        CheckKeys(PlayerData.items)
        GetKeys()
    end
end)

-- Handles state when PlayerData is changed. We're just looking for inventory updates.
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    CheckKeys(PlayerData.items)
end)

RegisterNetEvent('qb-vehiclekeys:client:AddTempKeys', function(plate)
    tempKeys[plate] = true
    local ped = cache.ped
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleplate = QBCore.Functions.GetPlate(vehicle)
        if plate == vehicleplate then
            SetVehicleEngineOn(vehicle, true, false, true)
        end
    end
end)

RegisterNetEvent('qb-vehiclekeys:client:RemoveTempKeys', function(plate)
    tempKeys[plate] = nil
end)

RegisterNetEvent('vehiclekeys:client:giveKeyItem', function(plate, veh)
    local model = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate, model)
end)

RegisterNetEvent('qb-vehiclekeys:client:GiveKeyItem', function()
    local ped = cache.ped
    local vehicle = GetVehiclePedIsIn(ped, false)
    local plate = QBCore.Functions.GetPlate(vehicle)
    local model = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate, model)
end)

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    LockpickDoor(isAdvanced)
end)

RegisterKeyMapping('togglelocks', 'LOCK Vehicle', 'keyboard', 'L')

RegisterCommand('togglelocks', function()
    local ped = cache.ped
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(cache.ped, true)
        local plate = QBCore.Functions.GetPlate(vehicle)
        if keys[plate] then
            ToggleVehicleLock(vehicle)
        end
    else
        local vehicle = lib.getClosestVehicle(GetEntityCoords(ped), 3.0, false)
        local plate = QBCore.Functions.GetPlate(vehicle)
        if keys[plate] then
            ToggleVehicleLock(vehicle)
        end
    end
end, false)

RegisterKeyMapping('engine', "Toggle Engine", 'keyboard', 'G')

RegisterCommand('engine', function()
    local vehicle = GetVehiclePedIsIn(cache.ped, true)
    local EngineOn = GetIsVehicleEngineRunning(vehicle)
    if vehicle then
        if EngineOn then
            SetVehicleEngineOn(vehicle, false, false, true)
        else
            SetVehicleEngineOn(vehicle, true, true, true)
        end
    end
end, false)


CreateThread(function()
    while true do
        local veh = GetVehiclePedIsTryingToEnter(cache.ped)
        local sleep = 250
        if DoesEntityExist(veh) then
            if grabkey then
                print('wait')
                sleep = 2500
            else
                GrabKey(QBCore.Functions.GetPlate(veh), veh) 
            end
        end
        Wait(sleep)
    end
end)
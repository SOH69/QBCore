local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function IsWeaponBlocked(WeaponName)
    local retval = false
    for _, name in pairs(Config.DurabilityBlockedWeapons) do
        if name == WeaponName then
            retval = true
            break
        end
    end
    return retval
end

local function HasAttachment(component, attachments)
    local retval = false
    local key = nil
    for k, v in pairs(attachments) do
        if v.component == component then
            key = k
            retval = true
        end
    end
    return retval, key
end

local function GetAttachmentType(attachments)
    local attype = nil
    for _, v in pairs(attachments) do
        attype = v.type
    end
    return attype
end

-- Callback
lib.callback.register("weapons:server:GetConfig", function()
    return Config.WeaponRepairPoints
end)
QBCore.Functions.CreateCallback("weapons:server:GetConfig", function(_, cb)
    cb(Config.WeaponRepairPoints)
end)


lib.callback.register("weapon:server:GetWeaponAmmo", function(source, WeaponData)
    local Player = QBCore.Functions.GetPlayer(source)
    local retval = 0
    if WeaponData then
        if Player then
            local ItemData = Player.Functions.GetItemBySlot(WeaponData.slot)
            if ItemData then
                retval = ItemData.info.ammo and ItemData.info.ammo or 0
            end
        end
    end
    return retval, WeaponData.name
end)
QBCore.Functions.CreateCallback("weapon:server:GetWeaponAmmo", function(source, cb, WeaponData)
    local Player = QBCore.Functions.GetPlayer(source)
    local retval = 0
    if WeaponData then
        if Player then
            local ItemData = Player.Functions.GetItemBySlot(WeaponData.slot)
            if ItemData then
                retval = ItemData.info.ammo and ItemData.info.ammo or 0
            end
        end
    end
    cb(retval, WeaponData.name)
end)


lib.callback.register('weapons:server:RemoveAttachment', function(source, AttachmentData, ItemData, slot)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Inventory = Player.PlayerData.items
    local AttachmentComponent = WeaponAttachments[ItemData.name:upper()][AttachmentData.attachment]
    if Inventory[ItemData.slot] then
        if Inventory[ItemData.slot].info.attachments and next(Inventory[ItemData.slot].info.attachments) then
            local HasAttach, key = HasAttachment(AttachmentComponent.component, Inventory[ItemData.slot].info.attachments)
            if HasAttach then
                table.remove(Inventory[ItemData.slot].info.attachments, key)
                Player.Functions.SetInventory(Player.PlayerData.items, true)
                Player.Functions.AddItem(AttachmentComponent.item, 1, slot)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[AttachmentComponent.item], "add")
                local ndata = {
                    title = 'Removed',
                    description = 'You have removed '..QBCore.Shared.Items[AttachmentComponent.item].label..' from the weapon',
                    type = 'success'
                }
                TriggerClientEvent('ox_lib:notify', source, ndata)
                return (Inventory[ItemData.slot].info.attachments)
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end)
QBCore.Functions.CreateCallback('weapons:server:RemoveAttachment', function(source, cb, AttachmentData, ItemData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Inventory = Player.PlayerData.items
    local AttachmentComponent = WeaponAttachments[ItemData.name:upper()][AttachmentData.attachment]
    if Inventory[ItemData.slot] then
        if Inventory[ItemData.slot].info.attachments and next(Inventory[ItemData.slot].info.attachments) then
            local HasAttach, key = HasAttachment(AttachmentComponent.component, Inventory[ItemData.slot].info.attachments)
            if HasAttach then
                table.remove(Inventory[ItemData.slot].info.attachments, key)
                Player.Functions.SetInventory(Player.PlayerData.items, true)
                Player.Functions.AddItem(AttachmentComponent.item, 1)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[AttachmentComponent.item], "add")
                TriggerClientEvent("QBCore:Notify", src, Lang:t('info.removed_attachment', { value = QBCore.Shared.Items[AttachmentComponent.item].label }), "error")
                cb(Inventory[ItemData.slot].info.attachments)
            else
                cb(false)
            end
        else
            cb(false)
        end
    else
        cb(false)
    end
end)


lib.callback.register("weapons:server:RepairWeapon", function(source, RepairPoint, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local minute = 60 * 1000
    local Timeout = math.random(5 * minute, 10 * minute)
    local WeaponData = QBCore.Shared.Weapons[GetHashKey(data.name)]
    local WeaponClass = (QBCore.Shared.SplitStr(WeaponData.ammotype, "_")[2]):lower()

    if Player.PlayerData.items[data.slot] then
        if Player.PlayerData.items[data.slot].info.quality then
            if Player.PlayerData.items[data.slot].info.quality ~= 100 then
                if Player.Functions.RemoveMoney('cash', Config.WeaponRepairCosts[WeaponClass]) then
                    Config.WeaponRepairPoints[RepairPoint].IsRepairing = true
                    Config.WeaponRepairPoints[RepairPoint].RepairingData = {
                        CitizenId = Player.PlayerData.citizenid,
                        WeaponData = Player.PlayerData.items[data.slot],
                        Ready = false,
                    }
                    Player.Functions.RemoveItem(data.name, 1, data.slot)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.name], "remove")
                    TriggerClientEvent("inventory:client:CheckWeapon", src, data.name)
                    TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[RepairPoint], RepairPoint)

                    SetTimeout(Timeout, function()
                        Config.WeaponRepairPoints[RepairPoint].IsRepairing = false
                        Config.WeaponRepairPoints[RepairPoint].RepairingData.Ready = true
                        TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[RepairPoint], RepairPoint)
                        exports['qb-phone']:sendNewMailToOffline(Player.PlayerData.citizenid, {
                            sender = Lang:t('mail.sender'),
                            subject = Lang:t('mail.subject'),
                            message = Lang:t('mail.message', { value = WeaponData.label })
                        })
                        SetTimeout(7 * 60000, function()
                            if Config.WeaponRepairPoints[RepairPoint].RepairingData.Ready then
                                Config.WeaponRepairPoints[RepairPoint].IsRepairing = false
                                Config.WeaponRepairPoints[RepairPoint].RepairingData = {}
                                TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[RepairPoint], RepairPoint)
                            end
                        end)
                    end)
                    return true
                else
                    return false
                end
            else
                TriggerClientEvent("QBCore:Notify", src, Lang:t('error.no_damage_on_weapon'), "error")
                return false
            end
        else
            TriggerClientEvent("QBCore:Notify", src, Lang:t('error.no_damage_on_weapon'), "error")
            return false
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_weapon_in_hand'), "error")
        TriggerClientEvent('weapons:client:SetCurrentWeapon', src, {}, false)
        return false
    end
end)
QBCore.Functions.CreateCallback("weapons:server:RepairWeapon", function(source, cb, RepairPoint, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local minute = 60 * 1000
    local Timeout = math.random(5 * minute, 10 * minute)
    local WeaponData = QBCore.Shared.Weapons[GetHashKey(data.name)]
    local WeaponClass = (QBCore.Shared.SplitStr(WeaponData.ammotype, "_")[2]):lower()

    if Player.PlayerData.items[data.slot] then
        if Player.PlayerData.items[data.slot].info.quality then
            if Player.PlayerData.items[data.slot].info.quality ~= 100 then
                if Player.Functions.RemoveMoney('cash', Config.WeaponRepairCosts[WeaponClass]) then
                    Config.WeaponRepairPoints[RepairPoint].IsRepairing = true
                    Config.WeaponRepairPoints[RepairPoint].RepairingData = {
                        CitizenId = Player.PlayerData.citizenid,
                        WeaponData = Player.PlayerData.items[data.slot],
                        Ready = false,
                    }
                    Player.Functions.RemoveItem(data.name, 1, data.slot)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.name], "remove")
                    TriggerClientEvent("inventory:client:CheckWeapon", src, data.name)
                    TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[RepairPoint], RepairPoint)

                    SetTimeout(Timeout, function()
                        Config.WeaponRepairPoints[RepairPoint].IsRepairing = false
                        Config.WeaponRepairPoints[RepairPoint].RepairingData.Ready = true
                        TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[RepairPoint], RepairPoint)
                        exports['qb-phone']:sendNewMailToOffline(Player.PlayerData.citizenid, {
                            sender = Lang:t('mail.sender'),
                            subject = Lang:t('mail.subject'),
                            message = Lang:t('mail.message', { value = WeaponData.label })
                        })
                        SetTimeout(7 * 60000, function()
                            if Config.WeaponRepairPoints[RepairPoint].RepairingData.Ready then
                                Config.WeaponRepairPoints[RepairPoint].IsRepairing = false
                                Config.WeaponRepairPoints[RepairPoint].RepairingData = {}
                                TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[RepairPoint], RepairPoint)
                            end
                        end)
                    end)
                    cb(true)
                else
                    cb(false)
                end
            else
                TriggerClientEvent("QBCore:Notify", src, Lang:t('error.no_damage_on_weapon'), "error")
                cb(false)
            end
        else
            TriggerClientEvent("QBCore:Notify", src, Lang:t('error.no_damage_on_weapon'), "error")
            cb(false)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_weapon_in_hand'), "error")
        TriggerClientEvent('weapons:client:SetCurrentWeapon', src, {}, false)
        cb(false)
    end
end)


lib.callback.register('prison:server:checkThrowable', function(source, weapon)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then return false end
    local throwable = false
    for _,v in pairs(Config.Throwables) do
        if QBCore.Shared.Weapons[weapon].name == 'weapon_'..v then
            Player.Functions.RemoveItem('weapon_'..v, 1)
            throwable = true
            break
        end
    end
    return throwable
end)
QBCore.Functions.CreateCallback('prison:server:checkThrowable', function(source, cb, weapon)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then return cb(false) end
    local throwable = false
    for _,v in pairs(Config.Throwables) do
        if QBCore.Shared.Weapons[weapon].name == 'weapon_'..v then
            Player.Functions.RemoveItem('weapon_'..v, 1)
            throwable = true
            break
        end
    end
    cb(throwable)
end)

-- Events

RegisterNetEvent("weapons:server:UpdateWeaponAmmo", function(CurrentWeaponData, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    amount = tonumber(amount)
    if CurrentWeaponData then
        if Player.PlayerData.items[CurrentWeaponData.slot] then
            Player.PlayerData.items[CurrentWeaponData.slot].info.ammo = amount
        end
        Player.Functions.SetInventory(Player.PlayerData.items, true)
    end
end)

RegisterNetEvent("weapons:server:TakeBackWeapon", function(k)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local itemdata = Config.WeaponRepairPoints[k].RepairingData.WeaponData
    itemdata.info.quality = 100
    Player.Functions.AddItem(itemdata.name, 1, false, itemdata.info)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemdata.name], "add")
    Config.WeaponRepairPoints[k].IsRepairing = false
    Config.WeaponRepairPoints[k].RepairingData = {}
    TriggerClientEvent('weapons:client:SyncRepairShops', -1, Config.WeaponRepairPoints[k], k)
end)

RegisterNetEvent("weapons:server:SetWeaponQuality", function(data, hp)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local WeaponSlot = Player.PlayerData.items[data.slot]
    WeaponSlot.info.quality = hp
    Player.Functions.SetInventory(Player.PlayerData.items, true)
end)

RegisterNetEvent('weapons:server:UpdateWeaponQuality', function(data, RepeatAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local WeaponData = QBCore.Shared.Weapons[GetHashKey(data.name)]
    local WeaponSlot = Player.PlayerData.items[data.slot]
    local DecreaseAmount = Config.DurabilityMultiplier[data.name] or 0.15
    if WeaponSlot then
        if not IsWeaponBlocked(WeaponData.name) then
            if WeaponSlot.info.quality then
                for _ = 1, RepeatAmount, 1 do
                    if WeaponSlot.info.quality - DecreaseAmount > 0 then
                        WeaponSlot.info.quality = WeaponSlot.info.quality - DecreaseAmount
                    else
                        WeaponSlot.info.quality = 0
                        TriggerClientEvent('inventory:client:UseWeapon', src, data, false)
                        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.weapon_broken_need_repair'), "error")
                        break
                    end
                end
            else
                WeaponSlot.info.quality = 100
                for _ = 1, RepeatAmount, 1 do
                    if WeaponSlot.info.quality - DecreaseAmount > 0 then
                        WeaponSlot.info.quality = WeaponSlot.info.quality - DecreaseAmount
                    else
                        WeaponSlot.info.quality = 0
                        TriggerClientEvent('inventory:client:UseWeapon', src, data, false)
                        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.weapon_broken_need_repair'), "error")
                        break
                    end
                end
            end
        end
    end
    Player.Functions.SetInventory(Player.PlayerData.items, true)
end)

RegisterNetEvent("weapons:server:EquipAttachment", function(ItemData, CurrentWeaponData, AttachmentData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Inventory = Player.PlayerData.items
    local GiveBackItem = nil
    if Inventory[CurrentWeaponData.slot] then
        if Inventory[CurrentWeaponData.slot].info.attachments and next(Inventory[CurrentWeaponData.slot].info.attachments) then
            local currenttype = GetAttachmentType(Inventory[CurrentWeaponData.slot].info.attachments)
            local HasAttach, key = HasAttachment(AttachmentData.component, Inventory[CurrentWeaponData.slot].info.attachments)
            if not HasAttach then
                if AttachmentData.type ~=nil and currenttype == AttachmentData.type then
                    for _, v in pairs(Inventory[CurrentWeaponData.slot].info.attachments) do
                        if v.type and v.type == currenttype then
                            GiveBackItem = tostring(v.item):lower()
                            table.remove(Inventory[CurrentWeaponData.slot].info.attachments, key)
                            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[GiveBackItem], "add")
                        end
                    end
                end
                Inventory[CurrentWeaponData.slot].info.attachments[#Inventory[CurrentWeaponData.slot].info.attachments+1] = {
                    component = AttachmentData.component,
                    label = QBCore.Shared.Items[AttachmentData.item].label,
                    item = AttachmentData.item,
                    type = AttachmentData.type,
                    dataItem = ItemData
                }
                TriggerClientEvent("addAttachment", src, AttachmentData.component)
                Player.Functions.SetInventory(Player.PlayerData.items, true)
                Player.Functions.RemoveItem(ItemData.name, 1)
                SetTimeout(1000, function()
                    TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "remove")
                end)
            else
                TriggerClientEvent("QBCore:Notify", src, Lang:t('error.attachment_already_on_weapon' , { value = QBCore.Shared.Items[AttachmentData.item].label }), "error", 3500)
            end
        else
            Inventory[CurrentWeaponData.slot].info.attachments = {}
            Inventory[CurrentWeaponData.slot].info.attachments[#Inventory[CurrentWeaponData.slot].info.attachments+1] = {
                component = AttachmentData.component,
                label = QBCore.Shared.Items[AttachmentData.item].label,
                item = AttachmentData.item,
                type = AttachmentData.type,
                dataItem = ItemData
            }
            TriggerClientEvent("addAttachment", src, AttachmentData.component)
            Player.Functions.SetInventory(Player.PlayerData.items, true)
            Player.Functions.RemoveItem(ItemData.name, 1)
            SetTimeout(1000, function()
                TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "remove")
            end)
        end
    end
    if GiveBackItem then
        Player.Functions.AddItem(GiveBackItem, 1, false)
    end
end)

RegisterNetEvent('weapons:server:removeWeaponAmmoItem', function(item)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player or type(item) ~= 'table' or not item.name or not item.slot then return end

    Player.Functions.RemoveItem(item.name, 1, item.slot)
end)

-- Commands

QBCore.Commands.Add("repairweapon", "Repair Weapon (God Only)", {{name="hp", help=Lang:t('info.hp_of_weapon')}}, true, function(source, args)
    TriggerClientEvent('weapons:client:SetWeaponQuality', source, tonumber(args[1]))
end, "god")

-- Items

-- AMMO
QBCore.Functions.CreateUseableItem('pistol_ammo', function(source, item)
    TriggerClientEvent('weapons:client:AddAmmo', source, 'AMMO_PISTOL', 12, item)
end)

QBCore.Functions.CreateUseableItem('rifle_ammo', function(source, item)
    TriggerClientEvent('weapons:client:AddAmmo', source, 'AMMO_RIFLE', 30, item)
end)

QBCore.Functions.CreateUseableItem('smg_ammo', function(source, item)
    TriggerClientEvent('weapons:client:AddAmmo', source, 'AMMO_SMG', 20, item)
end)

QBCore.Functions.CreateUseableItem('shotgun_ammo', function(source, item)
    TriggerClientEvent('weapons:client:AddAmmo', source, 'AMMO_SHOTGUN', 10, item)
end)

QBCore.Functions.CreateUseableItem('mg_ammo', function(source, item)
    TriggerClientEvent('weapons:client:AddAmmo', source, 'AMMO_MG', 30, item)
end)

QBCore.Functions.CreateUseableItem('snp_ammo', function(source, item)
    TriggerClientEvent('weapons:client:AddAmmo', source, 'AMMO_SNIPER', 10, item)
end)

QBCore.Functions.CreateUseableItem('emp_ammo', function(source, item)
    TriggerClientEvent('weapons:client:AddAmmo', source, 'AMMO_EMPLAUNCHER', 10, item)
end)
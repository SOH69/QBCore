local animDict = "missminuteman_1ig_2"
local anim = "handsup_base"
local handsup = false

local function HandsUp()
    lib.addKeybind({
        name = 'handsup',
        description = 'Put your hands up',
        defaultKey = 'X',
        onPressed = function(key)
            handsup = true
            lib.requestAnimDict(animDict, 1000)
            TaskPlayAnim(cache.ped, animDict, anim, 8.0, 8.0, -1, 50, 0, false, false, false)
        end,
        onReleased = function(key)
            handsup = false
            ClearPedTasks(cache.ped)
        end
    })
end

CreateThread(function() 
    HandsUp()
end)

RegisterKeyMapping('battlepass', 'Open Battlepass Menu', 'KEYBOARD', 'F2')

exports('getHandsup', function() return handsup end)

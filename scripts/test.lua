local mod = MilcomMOD

local isSpawningShit = false
local shitSpawningCounter = 0

mod:AddCallback(ModCallbacks.MC_POST_RENDER,
function(_)
    local room = Game():GetRoom()
    if(Input.IsActionTriggered(ButtonAction.ACTION_DROP, Isaac.GetPlayer().ControllerIndex)) then
        local item = Isaac.Spawn(5,100,mod.COLLECTIBLE_BLOOD_RITUAL,room:GetCenterPos(), Vector.Zero, nil)
    end
    if(Input.IsActionTriggered(ButtonAction.ACTION_BOMB, Isaac.GetPlayer().ControllerIndex)) then
        if(not isSpawningShit) then shitSpawningCounter=1 end
        isSpawningShit = true
    end

    if(isSpawningShit) then
        if(shitSpawningCounter<=10 and shitSpawningCounter%2==0) then
            local pos = Vector((shitSpawningCounter-6)*15, -80)
            print(pos)

            local pickup = Isaac.Spawn(5,PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, room:GetCenterPos()+pos, Vector.Zero, nil)
        end

        shitSpawningCounter = shitSpawningCounter+1
    end
end)

local lastWaveVal = 0

local function postUpdate()
    if((Ambush.GetCurrentWave()-lastWaveVal)>0 and Ambush.GetCurrentWave()>=1) then
        Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_NEW_ROOM, Ambush.GetCurrentWave())
    end

    if(not Game():GetRoom():IsAmbushDone() and not Game():GetRoom():IsAmbushActive()) then lastWaveVal = 0
    else lastWaveVal = Ambush.GetCurrentWave() end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

local function postNewRoom()
    Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_NEW_ROOM, -1)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.IMPORTANT, postNewRoom)
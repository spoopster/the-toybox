local mod = MilcomMOD
local lastWaveVal = 0

local function postUpdate()
    if((Ambush.GetCurrentWave()-lastWaveVal)>0 and Ambush.GetCurrentWave()>1) then
        Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_ROOM_CLEAR, Ambush.GetCurrentWave()-1)
    end

    if(not Game():GetRoom():IsAmbushDone() and not Game():GetRoom():IsAmbushActive()) then lastWaveVal = 0
    else lastWaveVal = Ambush.GetCurrentWave() end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

local function postRoomClear()
    Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_ROOM_CLEAR, Ambush.GetCurrentWave()-1)
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.IMPORTANT, postRoomClear)
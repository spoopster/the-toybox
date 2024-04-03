local mod = MilcomMOD

local PREV_INTENSITY = 0.25

local function getShaderParams(_, name)
    if(name==mod.SHADERS.EYESTRAIN) then
        local newIntensity = 1.0
        if(mod:isRoomClear()) then newIntensity = 0.25 end
        PREV_INTENSITY = mod:lerp(PREV_INTENSITY, newIntensity, 0.05)

        return {
            ShouldActivateIn = (PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_EYESTRAIN) and 1.0 or 0.0),
            IntensityIn = 2.0,
            ColorIntensityIn = PREV_INTENSITY,
            TimeIn = (Game():GetFrameCount()*1.5)%360,
        }
    end
end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, getShaderParams)
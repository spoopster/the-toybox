local mod = MilcomMOD

local function getShaderParams(_, name)
    if(name==mod.SHADERS.BLOOM) then
        return {
            ShouldActivateIn = 0.0,
        }
    end
end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, getShaderParams)
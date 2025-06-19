

local function getShaderParams(_, name)
    if(name==ToyboxMod.SHADERS.BLOOM) then
        return {
            ShouldActivateIn = 0.0,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, getShaderParams)
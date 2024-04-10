local mod = MilcomMOD

--! SEPARATE THIS INTO TWO ITEMS (rainbow key)

local PREV_INTENSITY = 0.25

local TEARSMULT = 0.7
local DAMAGEMULT = 1.075

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

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE_EYESTRAIN)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE_EYESTRAIN)

    if(flag==CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*(DAMAGEMULT^mult)
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = player.MaxFireDelay*(TEARSMULT^mult)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)
local mod = MilcomMOD
local sfx = SFXManager()

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)

    mod:setEntityData(player, "HEARTBURN_MODE", (isHorse and 2 or 1))

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED or SoundEffect.SOUND_THUMBS_DOWN))
    player:AnimatePill(color)
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_HEARTBURN)

local function postNewRoom(_, player)
    mod:setEntityData(player, "HEARTBURN_MODE", 0)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)

if(CustomHealthAPI==nil) then
    local function reduceHealing(_, player, amount, type)
        local heartburn = mod:getEntityData(player, "HEARTBURN_MODE")
        if(heartburn==0 or (heartburn==1 and type==AddHealthType.MAX)) then return end

        if(heartburn==1 and amount>0) then
            sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.66)
            return amount-1
        end
        if(heartburn==2 and amount>0) then
            sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.66)
            return 0
        end
    end
    mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, -math.huge, reduceHealing)
else
    local function addHealth(p, k, n)
        --print(k)

        local heartburn = mod:getEntityData(p, "HEARTBURN_MODE")
        if(heartburn==0 or (heartburn==1 and k=="EMPTY_HEART")) then return end

        if(heartburn==1 and n>0) then
            sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.66)
            return k, n-1
        end
        if(heartburn==2 and n>0) then
            sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.66)
            return k, 0
        end
    end
    CustomHealthAPI.Library.AddCallback(mod, CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH, -math.huge, addHealth)
end
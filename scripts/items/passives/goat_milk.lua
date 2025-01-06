local mod = MilcomMOD

local ENUM_FIREDELAY_MULT = 0.5
local ENUM_SKEW_MNMX = {Min=0.45,Max=1.35}

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE_GOAT_MILK)) then return end
    local mult = player:GetCollectibleNum(mod.COLLECTIBLE_GOAT_MILK)

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(player, ENUM_FIREDELAY_MULT*mult)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function skewWeaponFiredelay(fd, rng, num)
    local randFl = rng:RandomFloat()
    if(num>1) then
        randFl = (randFl-0.5)*2
        randFl = mod:sign(randFl)*math.abs(randFl)^(1/(num*2-1))
        randFl = randFl/2+0.5
    end
    --print(randFl)

    local fireDelayMult = randFl*(ENUM_SKEW_MNMX.Max-ENUM_SKEW_MNMX.Min)+ENUM_SKEW_MNMX.Min
    return math.max(0, fd*fireDelayMult)
end

local function playerAttack(_, ent, weap, dir, cMod)
    local p = ent:ToPlayer()
    if(ent.Type==EntityType.ENTITY_FAMILIAR and ent:ToFamiliar().Player) then p = ent:ToFamiliar().Player:ToPlayer() end

    if(p and p:HasCollectible(mod.COLLECTIBLE_GOAT_MILK) and weap:GetFireDelay()>0) then
        weap:SetFireDelay(skewWeaponFiredelay(weap:GetFireDelay(), p:GetCollectibleRNG(mod.COLLECTIBLE_GOAT_MILK), p:GetCollectibleNum(mod.COLLECTIBLE_GOAT_MILK)))
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, playerAttack)
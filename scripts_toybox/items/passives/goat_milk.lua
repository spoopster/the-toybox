local ENUM_SKEW_MNMX = {Min=0.45,Max=1.35}

local function skewWeaponFiredelay(fd, rng, num)
    local randFl = rng:RandomFloat()
    if(num>1) then
        randFl = (randFl-0.5)*2
        randFl = ToyboxMod:sign(randFl)*math.abs(randFl)^(1/(num*2-1))
        randFl = randFl/2+0.5
    end
    --print(randFl)

    local fireDelayMult = randFl*(ENUM_SKEW_MNMX.Max-ENUM_SKEW_MNMX.Min)+ENUM_SKEW_MNMX.Min
    return math.max(0, fd*fireDelayMult)
end

local function playerAttack(_, ent, weap, dir, cMod)
    local p = ent:ToPlayer()
    if(ent.Type==EntityType.ENTITY_FAMILIAR and ent:ToFamiliar().Player) then p = ent:ToFamiliar().Player:ToPlayer() end

    if(p and p:HasCollectible(ToyboxMod.COLLECTIBLE_GOAT_MILK) and weap:GetFireDelay()>0) then
        weap:SetFireDelay(skewWeaponFiredelay(weap:GetFireDelay(), p:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_GOAT_MILK), p:GetCollectibleNum(ToyboxMod.COLLECTIBLE_GOAT_MILK)))
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, playerAttack)
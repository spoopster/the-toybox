local METEOR_DMG = 35

local METEOR_FREQUENCY = {30*2, 30*4}
local METEOR_MIN_FREQ = 15

local function postUpdate(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_METEOR_SHOWER)) then return end
    if(ToyboxMod:isRoomClear()) then return end

    local room = Game():GetRoom()

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_METEOR_SHOWER)) then
            local cnt = ToyboxMod:getEntityData(pl, "METEOR_SHOWER_COOLDOWN") or 0

            if(cnt==0) then
                local pos = ToyboxMod:getRandomFreePos(20)
                local meteor = Isaac.Spawn(EntityType.ENTITY_EFFECT, ToyboxMod.EFFECT_VARIANT.METEOR, 0, pos, Vector.Zero, pl):ToEffect()
                meteor.CollisionDamage = METEOR_DMG

                local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_METEOR_SHOWER)
                local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_METEOR_SHOWER)
                mult = mult+(room:GetGridWidth()>15 and 0.5 or 0)+(room:GetGridHeight()>9 and 0.5 or 0)

                cnt = math.max(METEOR_MIN_FREQ, rng:RandomInt(METEOR_FREQUENCY[1], METEOR_FREQUENCY[2])//mult)
            else
                cnt = cnt-1
            end

            ToyboxMod:setEntityData(pl, "METEOR_SHOWER_COOLDOWN", cnt)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

local function resetCooldown(_)
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        ToyboxMod:setEntityData(pl, "METEOR_SHOWER_COOLDOWN", 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, resetCooldown)
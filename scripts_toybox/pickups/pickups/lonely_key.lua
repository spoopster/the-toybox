local REPLACE_CHANCE = 1/60

---@param pickup EntityPickup
local function replaceKeys(_, pickup, var, sub, rvar, rsub, rng)
    if(not (var==PickupVariant.PICKUP_KEY and sub==KeySubType.KEY_NORMAL) or not (rvar==0 or rsub==0)) then return end

    if(rng:RandomFloat()<REPLACE_CHANCE) then
        return {ToyboxMod.PICKUP_LONELY_KEY, 0, true}
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, replaceKeys)

---@param pickup EntityPickup
---@param coll Entity
local function makeUnhidden(_, pickup, coll, _)
    if(pickup.SubType~=0) then return end

    if(coll and coll:ToPlayer()) then
        pickup.SubType = 1

        local sp = pickup:GetSprite()
        local ogAnim, ogFrame = sp:GetAnimation(), sp:GetFrame()
        sp:Load("gfx_tb/pickups/pickup_lonely_key_real.anm2", true)
        sp:Play(ogAnim, true)
        sp:SetFrame(ogFrame)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, makeUnhidden, ToyboxMod.PICKUP_LONELY_KEY)
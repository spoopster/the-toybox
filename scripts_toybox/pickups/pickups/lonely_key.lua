local REPLACE_CHANCE = 1/60

---@param pickup EntityPickup
local function replaceKey(_, pickup)
    if(pickup.SubType==KeySubType.KEY_NORMAL and pickup:GetDropRNG():RandomFloat()<REPLACE_CHANCE) then
        pickup:Morph(EntityType.ENTITY_PICKUP,ToyboxMod.PICKUP_LONELY_KEY,0,true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, replaceKey, PickupVariant.PICKUP_KEY)

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
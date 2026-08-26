local bossPools = {
    [ItemPoolType.POOL_BOSS] = true,
    [ItemPoolType.POOL_GREED_BOSS] = true,
}

local ITEM_HEAL = 3*2 -- 3 hearts

---@param item CollectibleType
---@param firstTime boolean
---@param pl EntityPlayer
local function addCollectibleHp(_, item, _, firstTime, _, _, pl)
    if(not firstTime) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_FOOD_STAMPS)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_FOOD_STAMPS)-(item==ToyboxMod.COLLECTIBLE_FOOD_STAMPS and 1 or 0)
    if(mult<=0) then return end

    if(ToyboxMod.GAME:GetRoom():GetType()==RoomType.ROOM_BOSS) then
        pl:AddMaxHearts(2*mult)
        pl:AddHearts(2*mult)
    end
    pl:AddHearts(ITEM_HEAL*mult)--(pl:GetEffectiveMaxHearts())
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addCollectibleHp)
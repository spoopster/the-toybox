local NUM_COPIES = 1
local COPY_DURATION = 60*30

local MULT_DURATION_INCREASE = 30*30

---@param pl EntityPlayer
---@param id CollectibleType
---@param firstTime boolean
local function tryCopyCollectible(_, id, _, firstTime, _, _, pl)
    if(not pl:HasTrinket(ToyboxMod.TRINKET_MISPRINT)) then return end

    if(firstTime and Isaac.GetItemConfig():GetCollectible(id).Type~=ItemType.ITEM_ACTIVE) then
        local tmult = pl:GetTrinketMultiplier(ToyboxMod.TRINKET_MISPRINT)
        local mult = NUM_COPIES*tmult

        ToyboxMod:addTemporaryItem(pl, id, COPY_DURATION+tmult*MULT_DURATION_INCREASE, mult)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, tryCopyCollectible)
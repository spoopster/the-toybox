

local SIZE_UP = 4
local SPEED_UP = -2

---@param pl EntityPlayer
---@param flag CacheFlag
local function cacheEval(_, pl, flag)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_SUPER_HAMBURGER)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SUPER_HAMBURGER)

    if(flag==CacheFlag.CACHE_SPEED) then
        pl.MoveSpeed = pl.MoveSpeed+SPEED_UP*mult
    elseif(flag==CacheFlag.CACHE_SIZE) then
        pl.SpriteScale = pl.SpriteScale*(SIZE_UP^mult)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cacheEval)

---@param pl EntityPlayer
local function getItem(_, _, _, _, _, _, pl)
    pl:AddCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_BUCKET_OF_LARD), false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, getItem, ToyboxMod.COLLECTIBLE_SUPER_HAMBURGER)
local mod = ToyboxMod

function mod:getClassByQuality(phdval, qual)
    if(phdval==mod.PHD_TYPE.NONE) then
        if(qual<=1) then return mod.PHD_TYPE.GOOD
        elseif(qual<=2) then return mod.PHD_TYPE.NEUTRAL
        else return mod.PHD_TYPE.BAD end
    elseif(phdval==mod.PHD_TYPE.GOOD) then
        if(qual<=2) then return mod.PHD_TYPE.GOOD
        else return mod.PHD_TYPE.NEUTRAL end
    elseif(phdval==mod.PHD_TYPE.BAD) then
        if(qual<=1) then return mod.PHD_TYPE.NEUTRAL
        else return mod.PHD_TYPE.BAD end
    elseif(phdval==mod.PHD_TYPE.NEUTRAL) then return mod.PHD_TYPE.NEUTRAL end
end

---@param player EntityPlayer
local function postAddItem(_, item, _, firstTime, _, _, player)
    if(firstTime~=true) then return end

    if(item==mod.COLLECTIBLE.HORSE_TRANQUILIZER) then
        local pill = Isaac.Spawn(5,70,0,Game():GetRoom():FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,nil):ToPickup()
        pill:Morph(5,70,pill.SubType|PillColor.PILL_GIANT_FLAG)
    elseif(player:HasCollectible(mod.COLLECTIBLE.HORSE_TRANQUILIZER)) then
        local config = Isaac.GetItemConfig():GetCollectible(item)
        if(config==nil) then return end

        local cl = mod:getClassByQuality(mod:getPlayerPhdMask(player), config.Quality)
        --print(cl==mod.PHD_TYPE.GOOD, cl==mod.PHD_TYPE.NEUTRAL, cl==mod.PHD_TYPE.BAD)

        local effect = mod:getRandomPillEffect(mod:generateRng(), player, mod:getClassByQuality(mod:getPlayerPhdMask(player), config.Quality))
        local usedPillCol = Game():GetItemPool():GetPill(math.max(Random(),1))|PillColor.PILL_GIANT_FLAG
        player:UsePill(effect, usedPillCol, 0)
        player:AnimatePill(usedPillCol)
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem)
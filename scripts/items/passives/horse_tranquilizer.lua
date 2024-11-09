local mod = MilcomMOD

function mod:getClassByQuality(phdval, qual)
    if(phdval==mod.PILL_PHDTYPE.NONE) then
        if(qual<=1) then return mod.PILL_PHDTYPE.GOOD
        elseif(qual<=2) then return mod.PILL_PHDTYPE.NEUTRAL
        else return mod.PILL_PHDTYPE.BAD end
    elseif(phdval==mod.PILL_PHDTYPE.GOOD) then
        if(qual<=2) then return mod.PILL_PHDTYPE.GOOD
        else return mod.PILL_PHDTYPE.NEUTRAL end
    elseif(phdval==mod.PILL_PHDTYPE.BAD) then
        if(qual<=1) then return mod.PILL_PHDTYPE.NEUTRAL
        else return mod.PILL_PHDTYPE.BAD end
    elseif(phdval==mod.PILL_PHDTYPE.NEUTRAL) then return mod.PILL_PHDTYPE.NEUTRAL end
end

---@param player EntityPlayer
local function postAddItem(_, item, _, firstTime, _, _, player)
    if(firstTime~=true) then return end

    if(item==mod.COLLECTIBLE_HORSE_TRANQUILIZER) then
        local pill = Isaac.Spawn(5,70,0,Game():GetRoom():FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,nil):ToPickup()
        pill:Morph(5,70,pill.SubType|PillColor.PILL_GIANT_FLAG)
    elseif(player:HasCollectible(mod.COLLECTIBLE_HORSE_TRANQUILIZER)) then
        local config = Isaac.GetItemConfig():GetCollectible(item)
        if(config==nil) then return end

        local cl = mod:getClassByQuality(mod:getPlayerPhdMask(player), config.Quality)
        --print(cl==mod.PILL_PHDTYPE.GOOD, cl==mod.PILL_PHDTYPE.NEUTRAL, cl==mod.PILL_PHDTYPE.BAD)

        local effect = mod:getRandomPillEffect(mod:generateRng(), player, mod:getClassByQuality(mod:getPlayerPhdMask(player), config.Quality))
        local usedPillCol = Game():GetItemPool():GetPill(math.max(Random(),1))|PillColor.PILL_GIANT_FLAG
        player:UsePill(effect, usedPillCol, 0)
        player:AnimatePill(usedPillCol)
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem)
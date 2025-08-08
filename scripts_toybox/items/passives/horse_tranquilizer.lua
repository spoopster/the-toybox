

function ToyboxMod:getClassByQuality(phdval, qual)
    if(phdval==ToyboxMod.PHD_TYPE.NONE) then
        if(qual<=1) then return ToyboxMod.PHD_TYPE.GOOD
        elseif(qual<=2) then return ToyboxMod.PHD_TYPE.NEUTRAL
        else return ToyboxMod.PHD_TYPE.BAD end
    elseif(phdval==ToyboxMod.PHD_TYPE.GOOD) then
        if(qual<=2) then return ToyboxMod.PHD_TYPE.GOOD
        else return ToyboxMod.PHD_TYPE.NEUTRAL end
    elseif(phdval==ToyboxMod.PHD_TYPE.BAD) then
        if(qual<=1) then return ToyboxMod.PHD_TYPE.NEUTRAL
        else return ToyboxMod.PHD_TYPE.BAD end
    elseif(phdval==ToyboxMod.PHD_TYPE.NEUTRAL) then return ToyboxMod.PHD_TYPE.NEUTRAL end
end

---@param player EntityPlayer
local function postAddItem(_, item, _, firstTime, _, _, player)
    if(firstTime~=true) then return end

    if(item==ToyboxMod.COLLECTIBLE_HORSE_TRANQUILIZER) then
        local pill = Isaac.Spawn(5,70,0,Game():GetRoom():FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,nil):ToPickup()
        pill:Morph(5,70,pill.SubType|PillColor.PILL_GIANT_FLAG)
    elseif(player:HasCollectible(ToyboxMod.COLLECTIBLE_HORSE_TRANQUILIZER)) then
        local config = Isaac.GetItemConfig():GetCollectible(item)
        if(config==nil) then return end

        --local cl = ToyboxMod:getClassByQuality(ToyboxMod:getPlayerPhdMask(player), config.Quality)
        --print(cl==ToyboxMod.PHD_TYPE.GOOD, cl==ToyboxMod.PHD_TYPE.NEUTRAL, cl==ToyboxMod.PHD_TYPE.BAD)

        local effect = ToyboxMod:getRandomPillEffect(nil, player, ToyboxMod:getClassByQuality(ToyboxMod:getPlayerPhdMask(player), config.Quality))
        local usedPillCol = Game():GetItemPool():GetPillColor(effect)
        if(usedPillCol==-1) then usedPillCol = Game():GetItemPool():GetPill(math.max(1,Random())) end
        usedPillCol = usedPillCol | PillColor.PILL_GIANT_FLAG

        player:UsePill(effect, usedPillCol, 0)
        player:AnimatePill(usedPillCol)
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem)
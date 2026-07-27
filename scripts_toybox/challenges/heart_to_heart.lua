print(ToyboxMod.CHALLENGE_HEART_TO_HEART)

---@param pl EntityPlayer
local function playerInit(_, pl)
    if(ToyboxMod.GAME.Challenge==ToyboxMod.CHALLENGE_HEART_TO_HEART) then
        pl:BlockCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
        pl:AddInnateCollectible(ToyboxMod.COLLECTIBLE_GLASS_VESSEL, 1, "HeartToHeart", nil, true)
        pl:AddCollectibleEffect(ToyboxMod.COLLECTIBLE_GLASS_VESSEL, true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, playerInit, PlayerType.PLAYER_THELOST)
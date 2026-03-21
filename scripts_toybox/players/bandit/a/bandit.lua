local BOMB_MODIFIER_WEIGHT = 3

---@param pl EntityPlayer
local function banditInit(_, pl)
    if(pl:GetPlayerType()==ToyboxMod.PLAYER_BANDIT_A and pl.FrameCount==0) then
        Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
        pl:AddInnateCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
        pl:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_DR_FETUS))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, banditInit, PlayerVariant.PLAYER)

---@param itemConf ItemConfigItem
---@param pl EntityPlayer
local function banditCancelCostume(_, itemConf, pl)
    if(pl:GetPlayerType()==ToyboxMod.PLAYER_BANDIT_A and itemConf:IsCollectible()) then
        if(itemConf.ID==CollectibleType.COLLECTIBLE_KAMIKAZE or itemConf.ID==CollectibleType.COLLECTIBLE_DR_FETUS) then
            return true
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_COSTUME, banditCancelCostume)
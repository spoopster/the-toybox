local NUM_COPIES = 4

ToyboxMod:registerInnateKey("ForRoom_Fate")

---@param pl EntityPlayer
---@param id Card
---@param flags UseFlag
local function useFate(_, id, pl, flags)
    --if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    pl:AddInnateCollectible(ToyboxMod.COLLECTIBLE_METEOR_SHOWER, NUM_COPIES, "ForRoom_Fate")

    ToyboxMod:setExtraData("FATE_ACTIVE", (ToyboxMod:getExtraData("FATE_ACTIVE") or 0)+1)

    ToyboxMod.SFX:Play(ToyboxMod.SFX_BELL)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useFate, ToyboxMod.CARD_FATE)

local function resetCooldown(_)
    ToyboxMod:setExtraData("FATE_ACTIVE", nil)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, resetCooldown)
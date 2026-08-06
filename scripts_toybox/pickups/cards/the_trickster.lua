local HELL_GAME_CHANCE = 0.02

---@param pl EntityPlayer
---@param id Card
---@param flags UseFlag
local function useTheTrickster(_, id, pl, flags)
    --if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    local rng = pl:GetCardRNG(id)
    local room = ToyboxMod.GAME:GetRoom()

    local pos = room:FindFreePickupSpawnPosition(pl.Position, 40)
    local var = SlotVariant.SHELL_GAME
    if(Isaac.GetPersistentGameData():Unlocked(Achievement.HELL_GAME) and rng:RandomFloat()<HELL_GAME_CHANCE) then
        var = SlotVariant.HELL_GAME
    end

    local slot = Isaac.Spawn(6,var,0,pos,Vector.Zero,nil):ToSlot()
    local poof = Isaac.Spawn(1000,15,0,slot.Position,Vector.Zero,nil)

    ToyboxMod.SFX:Play(SoundEffect.SOUND_SUMMONSOUND)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheTrickster, ToyboxMod.CARD_THE_TRICKSTER)
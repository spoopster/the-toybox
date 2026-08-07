---@param player EntityPlayer
---@param slot ActiveSlot
local function useTwistedHeart(_, _, rng, player, flags, slot)
    local numHearts = math.max(1, math.ceil(player:GetHearts()/2))
    player:AddHearts(-player:GetHearts())
    player:AddHearts(2)

    if(ToyboxMod:isAtlasA(player)) then
        local totalHp = ToyboxMod:getTotalMantleHP(player)
        if(totalHp>1) then
            ToyboxMod:addMantleHp(player, -(totalHp-1))
        end
    end

    local room = ToyboxMod.GAME:GetRoom()
    for i=1, numHearts do
        local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
        local heart = Isaac.Spawn(5,PickupVariant.PICKUP_HEART,0,pos,Vector.Zero,nil):ToPickup()
        heart:SetDropDelay((numHearts*2>10) and (10*(i/numHearts))//1 or (i*2))
    end

    ToyboxMod.SFX:Play(SoundEffect.SOUND_BLOBBY_WIGGLE)
    ToyboxMod.SFX:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.5, nil, nil, 1.2)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useTwistedHeart, ToyboxMod.COLLECTIBLE_TWISTED_HEART)
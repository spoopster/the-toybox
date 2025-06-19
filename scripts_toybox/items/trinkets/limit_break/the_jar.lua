
--* When full, using it gives a full heart container

---@param player EntityPlayer
local function theJarPreUse(_, item, rng, player, flags, slot, vdata)
    ToyboxMod:setEntityData(player, "JAR_HEARTS_NUM", player:GetJarHearts())
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, theJarPreUse, CollectibleType.COLLECTIBLE_THE_JAR)

---@param player EntityPlayer
local function theJarUse(_, item, rng, player, flags, slot, vdata)
    if(not ToyboxMod:playerHasLimitBreak(player)) then return end
    local heartsNum = (ToyboxMod:getEntityData(player, "JAR_HEARTS_NUM") or 0)
    
    if(heartsNum==8) then
        for _, heart in ipairs(Isaac.FindByType(5,10)) do
            if(heart.FrameCount==0 and heart.SpawnerEntity and GetPtrHash(heart.SpawnerEntity)==GetPtrHash(player)) then
                heart:Remove()
            end
        end
        player:AddMaxHearts(2)
        player:AddHearts(2)

        Isaac.Spawn(1000,16,3,player.Position,Vector.Zero,nil)
        Isaac.Spawn(1000,16,4,player.Position,Vector.Zero,nil)
        sfx:Play(SoundEffect.SOUND_VAMP_GULP)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, theJarUse, CollectibleType.COLLECTIBLE_THE_JAR)
local sfx = SFXManager()

---@param player Entity
local function healPlayer(_, player, _, flags, source)
    player = player:ToPlayer()
    if(not player:HasTrinket(ToyboxMod.TRINKET_CITRUSBERRY)) then return end

    if(player:GetHearts()<player:GetEffectiveMaxHearts()/2) then
        local mult = player:GetTrinketMultiplier(ToyboxMod.TRINKET_CITRUSBERRY)
        local toheal = math.max(2, math.ceil(mult*player:GetEffectiveMaxHearts()/4))

        player:AddHearts(toheal)
        player:AddSoulHearts(2)

        sfx:Play(SoundEffect.SOUND_VAMP_GULP)

        for i=0,2 do
            if(i==2) then
                local desc = player:GetSmeltedTrinketDesc(ToyboxMod.TRINKET_CITRUSBERRY)
                if(desc.trinketAmount>0 or desc.goldenTrinketAmount>0) then
                    local isgold = (desc.goldenTrinketAmount>0)
                    player:TryRemoveSmeltedTrinket(ToyboxMod.TRINKET_CITRUSBERRY | (isgold and TrinketType.TRINKET_GOLDEN_FLAG or 0))
                    player:AddSmeltedTrinket(ToyboxMod.TRINKET_CITRUSBERRY_CONSUMED | (isgold and TrinketType.TRINKET_GOLDEN_FLAG or 0), false)
                    
                    break
                end
            else
                local tr = player:GetTrinket(i)
                if(tr==ToyboxMod.TRINKET_CITRUSBERRY or tr==(ToyboxMod.TRINKET_CITRUSBERRY | TrinketType.TRINKET_GOLDEN_FLAG)) then
                    local isgold = (tr==(ToyboxMod.TRINKET_CITRUSBERRY | TrinketType.TRINKET_GOLDEN_FLAG))
                    player:TryRemoveTrinket(tr)
                    player:AddTrinket(ToyboxMod.TRINKET_CITRUSBERRY_CONSUMED | (isgold and TrinketType.TRINKET_GOLDEN_FLAG or 0), false)

                    break
                end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, healPlayer, EntityType.ENTITY_PLAYER)

---@param pl EntityPlayer
local function refillFruits(_, pl)
    if(pl.FrameCount==0) then return end
    if(not pl:HasTrinket(ToyboxMod.TRINKET_CITRUSBERRY_CONSUMED)) then return end

    while(pl:HasTrinket(ToyboxMod.TRINKET_CITRUSBERRY_CONSUMED)) do
        for i=0,2 do
            if(i==2) then
                local desc = pl:GetSmeltedTrinketDesc(ToyboxMod.TRINKET_CITRUSBERRY_CONSUMED)
                if(desc.trinketAmount>0 or desc.goldenTrinketAmount>0) then
                    local isgold = (desc.goldenTrinketAmount>0)
                    pl:TryRemoveSmeltedTrinket(ToyboxMod.TRINKET_CITRUSBERRY_CONSUMED | (isgold and TrinketType.TRINKET_GOLDEN_FLAG or 0))
                    pl:AddSmeltedTrinket(ToyboxMod.TRINKET_CITRUSBERRY | (isgold and TrinketType.TRINKET_GOLDEN_FLAG or 0), false)
                    
                    break
                end
            else
                local tr = pl:GetTrinket(i)
                if(tr==ToyboxMod.TRINKET_CITRUSBERRY_CONSUMED or tr==(ToyboxMod.TRINKET_CITRUSBERRY_CONSUMED | TrinketType.TRINKET_GOLDEN_FLAG)) then
                    local isgold = (tr==(ToyboxMod.TRINKET_CITRUSBERRY_CONSUMED | TrinketType.TRINKET_GOLDEN_FLAG))
                    pl:TryRemoveTrinket(tr)
                    pl:AddTrinket(ToyboxMod.TRINKET_CITRUSBERRY | (isgold and TrinketType.TRINKET_GOLDEN_FLAG or 0), false)

                    break
                end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, refillFruits)
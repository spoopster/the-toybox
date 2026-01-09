local sfx = SFXManager()

---@param player EntityPlayer
local function useColoringBook(_, _, rng, player, flags)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ToyboxMod:isValidEnemy(ent) and not ent:IsBoss() and not ent:IsDead() and ent:Exists()) then
            local npc = ent:ToNPC() ---@type EntityNPC

            local checkChamp = (PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_MALICE) or EntityConfig.GetEntity(npc.Type,npc.Variant,npc.SubType):CanBeChampion())

            if(checkChamp and not (npc:IsChampion() or ToyboxMod:isModChampion(npc))) then
                if(npc:GetDropRNG():RandomFloat()<ToyboxMod.CONFIG.MOD_CHAMPION_CHANCE) then
                    npc = ToyboxMod:MakeModChampion(npc, nil, false)
                else
                    npc:MakeChampion(math.max(Random(),1), -1, false)
                end

                npc:SetColor(Color(1,1,1,1,1,1,1), 5, 0, true, false)

                local poof = Isaac.Spawn(1000, EffectVariant.POOF02, 0, npc.Position, Vector.Zero, nil):ToEffect()
                poof.SpriteOffset = Vector(0,-12)
                poof.SpriteScale = Vector(0.8,1)*1.2
                poof.Rotation = math.random(1,360)
                poof.Color = Color(0,0,0,0.75,1,1,1)
                poof.DepthOffset = 5
            end
        end
    end

    sfx:Play(ToyboxMod.SFX_HYPNOSIS)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useColoringBook, ToyboxMod.COLLECTIBLE_COLORING_BOOK)
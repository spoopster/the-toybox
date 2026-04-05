
local sfx = SFXManager()

local copyingFamiliar

---@param fam EntityFamiliar
local function familiarCopy(_, fam)
    if(Isaac.GetPlayer().FrameCount==0) then return end
    if(not fam.Player:HasCollectible(ToyboxMod.COLLECTIBLE_FISH)) then return end

    if(copyingFamiliar) then return end
    copyingFamiliar = true

    local famCopy = Isaac.Spawn(fam.Type,fam.Variant,fam.SubType,fam.Position,fam.Velocity,fam.SpawnerEntity):ToFamiliar()
    famCopy.Player = fam.Player
    famCopy.Target = fam.Target
    famCopy:ClearEntityFlags(famCopy:GetEntityFlags())
    famCopy:AddEntityFlags(fam:GetEntityFlags())
    famCopy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    copyingFamiliar = false
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiarCopy, FamiliarVariant.BLUE_SPIDER)
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiarCopy, FamiliarVariant.BLUE_FLY)

---@param pl Entity
local function playerHurtAddBlueFam(_, pl, _, flags, source)
    pl = pl:ToPlayer()
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_FISH)) then return end

    pl:AddBlueFlies(1, pl.Position, nil)
    pl:AddBlueSpider(pl.Position)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, playerHurtAddBlueFam, EntityType.ENTITY_PLAYER)

---@param pl EntityPlayer
local function checkTrinketCombo(_, pl, trAdded, firstTime)
    local fishHeadNum = 0
    local fishTailNum = 0

    for i=0,1 do
        local tr = (pl:GetTrinket(i) & ~TrinketType.TRINKET_GOLDEN_FLAG)
        if(tr==TrinketType.TRINKET_FISH_HEAD) then
            fishHeadNum = fishHeadNum+1
        elseif(tr==TrinketType.TRINKET_FISH_TAIL) then
            fishTailNum = fishTailNum+1
        end
    end

    local smelted = pl:GetSmeltedTrinkets()
    fishHeadNum = fishHeadNum+smelted[TrinketType.TRINKET_FISH_HEAD].trinketAmount+smelted[TrinketType.TRINKET_FISH_HEAD].goldenTrinketAmount
    fishTailNum = fishTailNum+smelted[TrinketType.TRINKET_FISH_TAIL].trinketAmount+smelted[TrinketType.TRINKET_FISH_TAIL].goldenTrinketAmount

    while(fishHeadNum>0 and fishTailNum>0) do
        pl:TryRemoveTrinket(TrinketType.TRINKET_FISH_HEAD)
        pl:TryRemoveTrinket(TrinketType.TRINKET_FISH_TAIL)
        pl:AddCollectible(ToyboxMod.COLLECTIBLE_FISH)

        fishHeadNum = fishHeadNum-1
        fishTailNum = fishTailNum-1

        pl:AnimateCollectible(ToyboxMod.COLLECTIBLE_FISH)
        sfx:Play(SoundEffect.SOUND_POWERUP1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, checkTrinketCombo)
local mod = MilcomMOD
local sfx = SFXManager()

local copyingFamiliar

---@param fam EntityFamiliar
local function familiarCopy(_, fam)
    if(Isaac.GetPlayer().FrameCount==0) then return end
    if(not fam.Player:HasCollectible(mod.COLLECTIBLE_FISH)) then return end

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
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiarCopy, FamiliarVariant.BLUE_SPIDER)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiarCopy, FamiliarVariant.BLUE_FLY)

---@param pl Entity
local function playerHurtAddBlueFam(_, pl, _, flags, source)
    pl = pl:ToPlayer()
    if(not pl:HasCollectible(mod.COLLECTIBLE_FISH)) then return end

    pl:AddBlueFlies(1, pl.Position, nil)
    pl:AddBlueSpider(pl.Position)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, playerHurtAddBlueFam, EntityType.ENTITY_PLAYER)

---@param pl EntityPlayer
local function checkTrinketCombo(_, pl, trAdded, firstTime)
    while(pl:HasTrinket(TrinketType.TRINKET_FISH_HEAD) and pl:HasTrinket(TrinketType.TRINKET_FISH_TAIL)) do
        pl:TryRemoveTrinket(TrinketType.TRINKET_FISH_HEAD)
        pl:TryRemoveTrinket(TrinketType.TRINKET_FISH_TAIL)
        pl:AddCollectible(mod.COLLECTIBLE_FISH)

        pl:AnimateCollectible(mod.COLLECTIBLE_FISH)
        sfx:Play(SoundEffect.SOUND_POWERUP1)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, checkTrinketCombo)
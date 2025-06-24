
local sfx = SFXManager()

local SHOTSPEED_UP = 0.16
--local BOSS_DMG = 80

local SLIPPER_SPRITE = Sprite("gfx/ui/tb_ui_slipper.anm2", true)
SLIPPER_SPRITE:Play("Idle", true)

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(flag~=CacheFlag.CACHE_SHOTSPEED) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_DADS_SLIPPER)) then return end

    pl.ShotSpeed = pl.ShotSpeed+SHOTSPEED_UP*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_DADS_SLIPPER)
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl Entity
---@param source EntityRef
local function postTakeDmg(_, pl, dmg, flags, source, countdown)
    if(not source.Entity) then return end

    pl = pl:ToPlayer() ---@cast pl EntityPlayer
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_DADS_SLIPPER)) then return end

    local ent = source.Entity
    if(not ent:ToNPC() and ent.SpawnerEntity) then
        ent = ent.SpawnerEntity
    end
    ent = ent:ToNPC() ---@cast ent EntityNPC

    if(ent and ToyboxMod:isValidEnemy(ent) and not ent:IsBoss()) then
        ent:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
        ent:BloodExplode()
        ent:Die()

        sfx:Play(ToyboxMod.SOUND_EFFECT.SLIPPER_WHIP, 1.2)
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TAKE_DMG, postTakeDmg, EntityType.ENTITY_PLAYER)

---@param pickup EntityPickup
local function replaceItemSprite(_, pickup)
    if(pickup.SubType~=ToyboxMod.COLLECTIBLE_DADS_SLIPPER) then return end

    local sp = pickup:GetSprite()
    if(sp:GetLayer(1):GetSpritesheetPath()=="gfx/items/collectibles/tb_dads_slipper.png") then
        local anim, oAnim, oFrame = sp:GetAnimation(), sp:GetOverlayAnimation(), sp:GetOverlayFrame()

        sp:Load("gfx/pickups/tb_pickup_dads_slipper.anm2", true)
        sp:Play(anim, true)
        sp:PlayOverlay(oAnim, true)
        sp:SetOverlayFrame(oFrame)
        sp:StopOverlay()

        sp:GetLayer(1):SetColor(ToyboxMod.CONFIG.DADS_SLIPPER_COLOR)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, replaceItemSprite, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
local function updateSlipperColor(_, pickup)
    if(pickup.SubType~=ToyboxMod.COLLECTIBLE_DADS_SLIPPER) then return end

    local sp = pickup:GetSprite()
    if(sp:GetLayer(1):GetSpritesheetPath()=="gfx/pickups/tb_pickup_dads_slipper.png") then
        sp:GetLayer(1):SetColor(ToyboxMod.CONFIG.DADS_SLIPPER_COLOR)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, updateSlipperColor, PickupVariant.PICKUP_COLLECTIBLE)

---@param pl EntityPlayer
local function updateSlipperSprite(_, pl)
    if(not pl:IsHeldItemVisible()) then return end

    local sp = pl:GetHeldSprite()
    if(sp:GetFilename()=="gfx/005.100_Collectible.anm2") then
        if(sp:GetLayer(1):GetSpritesheetPath()=="gfx/items/collectibles/tb_dads_slipper.png") then
            local anim, oAnim, oFrame = sp:GetAnimation(), sp:GetOverlayAnimation(), sp:GetOverlayFrame()

            sp:Load("gfx/pickups/tb_pickup_dads_slipper.anm2", true)
            sp:Play(anim, true)
            sp:PlayOverlay(oAnim, true)

            sp:GetLayer(1):SetColor(ToyboxMod.CONFIG.DADS_SLIPPER_COLOR)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateSlipperSprite)
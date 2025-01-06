local mod = MilcomMOD
local sfx = SFXManager()

local heartSprite, test = Sprite("gfx/ui/tb_ui_glassvessel_heart.anm2", true)
heartSprite:Play("Idle", true)

function mod:renderGlassVesselSprite(player, pos)
    local vesselState = (player:GetEffects():HasCollectibleEffect(mod.COLLECTIBLE_GLASS_VESSEL) and 0 or 1)
    heartSprite:SetFrame(vesselState+((player:GetHealthType()==HealthType.COIN) and 2 or 0))
    heartSprite:Render(pos)
end

---@param pl EntityPlayer
local function renderVessel(_, offset, sprite, pos, x, pl)
    if(not (pl and pl:HasCollectible(mod.COLLECTIBLE_GLASS_VESSEL))) then return end
    if(pl:GetPlayerIndex()==-1) then return end

    local idx = pl:GetPlayerIndex()
    local hud = Game():GetHUD():GetPlayerHUD(idx)
    local h = hud:GetHearts()
    local sp = Game():GetHUD():GetHeartsSprite()

    local numHeartsPerLine = 6
    if(idx==1 or idx>3) then numHeartsPerLine = 3 end
    local mult = Vector(12,10)

    local heartLimit = math.ceil(pl:GetHeartLimit()/2)
    local numHeartsDone=0
    for i, heartData in pairs(h) do
        if(heartData:IsVisible()) then numHeartsDone = numHeartsDone+1
        else break end
    end

    if(pl:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) then numHeartsDone = numHeartsDone+1 end
    local positionOffset = Vector(numHeartsDone%numHeartsPerLine, (numHeartsDone//numHeartsPerLine))

    if(numHeartsDone>=heartLimit and heartLimit>=12) then
        if(numHeartsDone==heartLimit) then
            positionOffset = Vector((numHeartsDone-1)%numHeartsPerLine+0.5, ((numHeartsDone-1)//numHeartsPerLine)) -- exceeds max health either by having containers equal to limit or by limit-1 and you have mantle
        elseif(numHeartsDone==heartLimit+1) then
            positionOffset = Vector((numHeartsDone-2)%numHeartsPerLine+1, ((numHeartsDone-2)//numHeartsPerLine)) -- max containers + holy mantle
        end
    end
    
    mod:renderGlassVesselSprite(pl, pos+positionOffset*mult)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS, renderVessel)

---@param pl EntityPlayer
local function imposeCostumeAnimation(_, pl)
    if(not pl:GetEffects():HasCollectibleEffect(mod.COLLECTIBLE_GLASS_VESSEL)) then
        pl:RemoveCostume(Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE_GLASS_VESSEL))
    else
        local mapData = pl:GetCostumeLayerMap()[4] -- body1 layer
        if(mapData.costumeIndex~=-1) then
            local costumeData = pl:GetCostumeSpriteDescs()[mapData.costumeIndex+1]
            if(costumeData:GetItemConfig().ID==mod.COLLECTIBLE_GLASS_VESSEL and costumeData:GetItemConfig().Type==ItemType.ITEM_PASSIVE) then
                costumeData:GetSprite():Play("Shimmer", false)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, imposeCostumeAnimation)

---@param player EntityPlayer
local function addVessel(_, _, _, firstTime, slot, vData, player)
    if(not firstTime) then return end

    player:GetEffects():AddCollectibleEffect(mod.COLLECTIBLE_GLASS_VESSEL, true, 1)
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addVessel, mod.COLLECTIBLE_GLASS_VESSEL)

---@param pl EntityPlayer
local function cancelVesselDamage(_, pl, damage, flags, source, count)
    if(pl:GetDamageCooldown()>0) then return end
    if(not (pl and pl:HasCollectible(mod.COLLECTIBLE_GLASS_VESSEL))) then return end

    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end
    
    if(pl:GetEffects():HasCollectibleEffect(mod.COLLECTIBLE_GLASS_VESSEL)) then
        pl:GetEffects():RemoveCollectibleEffect(mod.COLLECTIBLE_GLASS_VESSEL, -1)
        pl:SetMinDamageCooldown(60*(pl:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE)+1))

        sfx:Play(SoundEffect.SOUND_HOLY_MANTLE)
        Game():ShakeScreen(10)
        local shatter = Isaac.Spawn(1000, mod.EFFECT_VESSEL_BREAK, 0, pl.Position, Vector.Zero, pl):ToEffect()
        shatter.DepthOffset = 100
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, cancelVesselDamage, 0)

local redHeartSubTypes = {
    [HeartSubType.HEART_HALF] = 0,
    [HeartSubType.HEART_FULL] = 0,
    [HeartSubType.HEART_DOUBLEPACK] = 0,
    [HeartSubType.HEART_BLENDED] = 0,
    [HeartSubType.HEART_ROTTEN] = 0,
}

---@param pickup EntityPickup
---@param pl Entity
local function consumeHeart(_, pickup, pl)
    if(not (redHeartSubTypes[pickup.SubType])) then return end
    if(not (pl and pl:ToPlayer() and pl:ToPlayer():HasCollectible(mod.COLLECTIBLE_GLASS_VESSEL))) then return end
    pl = pl:ToPlayer() ---@cast pl EntityPlayer

    local hpType = pl:ToPlayer():GetHealthType()
    if(hpType==HealthType.COIN) then return end

    local data = mod:getEntityDataTable(pl)

    if(not pl:GetEffects():HasCollectibleEffect(mod.COLLECTIBLE_GLASS_VESSEL)) then
        pickup:PlayPickupSound()
        pickup:GetSprite():Play("Collect", true)
        pickup:Die()

        sfx:Play(SoundEffect.SOUND_URN_OPEN)
        pl:GetEffects():AddCollectibleEffect(mod.COLLECTIBLE_GLASS_VESSEL, true, 1)

        return true
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.IMPORTANT, consumeHeart, PickupVariant.PICKUP_HEART)

---@param pickup EntityPickup
---@param pl Entity
local function consumeCoin(_, pickup, pl)
    if(not (pl and pl:ToPlayer() and pl:ToPlayer():HasCollectible(mod.COLLECTIBLE_GLASS_VESSEL))) then return end
    local hpType = pl:ToPlayer():GetHealthType()
    if(not (hpType==HealthType.COIN)) then return end

    local data = mod:getEntityDataTable(pl)

    if(data.GLASS_VESSEL_MANTLESTATE~=0) then
        pickup:PlayPickupSound()
        pickup:GetSprite():Play("Collect", true)
        pickup:Die()

        sfx:Play(SoundEffect.SOUND_URN_OPEN)
        data.GLASS_VESSEL_MANTLESTATE = 0

        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, consumeCoin, PickupVariant.PICKUP_COIN)
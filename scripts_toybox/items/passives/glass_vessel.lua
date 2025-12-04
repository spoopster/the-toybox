
local sfx = SFXManager()

local heartSprite, test = Sprite("gfx_tb/ui/ui_glassvessel_heart.anm2", true)
heartSprite:Play("Idle", true)

function ToyboxMod:renderGlassVesselSprite(player, pos)
    
end

---@param pl EntityPlayer
local function renderVessel(_, offset, sprite, pos, x, pl)
    if(Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= 0) then return end  
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GLASS_VESSEL))) then return end
    if(pl:GetPlayerIndex()==-1) then return end

    local playerHud = nil
    for i=0, 7 do
        playerHud = Game():GetHUD():GetPlayerHUD(i)

        if(playerHud:GetPlayer() and playerHud:GetPlayer():GetPlayerIndex()==pl:GetPlayerIndex()) then
            break
        end
    end

    local heartsPerLine = 6
    local hpLimit = (pl:GetHeartLimit()+1)//2
    local numHearts = 0

    if(playerHud:GetPlayer()) then
        for i, heart in ipairs(playerHud:GetHearts()) do
            if(heart:IsVisible()) then
                numHearts = i
            end
        end
    else
        heartsPerLine = 3
        numHearts = (pl:GetMaxHearts()+1)//2+(pl:GetBoneHearts()+1)//2+(pl:GetSoulHearts()+1)//2
    end

    if(pl:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) then
        numHearts = numHearts+1
    end

    local mult = Vector(12,10)
    if(playerHud:GetPlayer()) then
        if(pos.X>Isaac.GetScreenWidth()/2) then mult.X = -mult.X end
    end

    local posOffset = Vector(0,0)
    if(hpLimit>=12) then
        posOffset = math.max(0, numHearts-hpLimit+1)*Vector(0.5, 0)
        numHearts = math.min(numHearts, hpLimit-1)
    end
    local heartPos = Vector(numHearts%heartsPerLine, numHearts//heartsPerLine)
    
    local vesselState = (pl:GetEffects():HasCollectibleEffect(ToyboxMod.COLLECTIBLE_GLASS_VESSEL) and 0 or 1)
    heartSprite:SetFrame(vesselState+((pl:GetHealthType()==HealthType.COIN) and 2 or 0))
    heartSprite:Render(pos+(heartPos+posOffset)*mult)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS, renderVessel)

---@param pl EntityPlayer
local function imposeCostumeAnimation(_, pl)
    if(not pl:GetEffects():HasCollectibleEffect(ToyboxMod.COLLECTIBLE_GLASS_VESSEL)) then
        pl:RemoveCostume(Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_GLASS_VESSEL))
    else
        local mapData = pl:GetCostumeLayerMap()[4] -- body1 layer
        if(mapData.costumeIndex~=-1) then
            local costumeData = pl:GetCostumeSpriteDescs()[mapData.costumeIndex+1]
            if(costumeData:GetItemConfig().ID==ToyboxMod.COLLECTIBLE_GLASS_VESSEL and costumeData:GetItemConfig().Type==ItemType.ITEM_PASSIVE) then
                costumeData:GetSprite():Play("Shimmer", false)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, imposeCostumeAnimation)

---@param player EntityPlayer
local function addVessel(_, _, _, firstTime, slot, vData, player)
    if(not firstTime) then return end

    player:GetEffects():AddCollectibleEffect(ToyboxMod.COLLECTIBLE_GLASS_VESSEL, true, 1)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addVessel, ToyboxMod.COLLECTIBLE_GLASS_VESSEL)

---@param pl EntityPlayer
local function cancelVesselDamage(_, pl, damage, flags, source, count)
    if(pl:GetDamageCooldown()~=0) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_GLASS_VESSEL)) then return end

    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    if(pl:GetEffects():HasCollectibleEffect(ToyboxMod.COLLECTIBLE_GLASS_VESSEL)) then
        pl:GetEffects():RemoveCollectibleEffect(ToyboxMod.COLLECTIBLE_GLASS_VESSEL, -1)
        pl:SetMinDamageCooldown(60*(pl:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE)+1))

        sfx:Play(SoundEffect.SOUND_HOLY_MANTLE)
        Game():ShakeScreen(10)
        local shatter = Isaac.Spawn(1000, ToyboxMod.EFFECT_VARIANT.VESSEL_BREAK, 0, pl.Position, Vector.Zero, pl):ToEffect()
        shatter.DepthOffset = 100
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, cancelVesselDamage, 0)

---@param pickup EntityPickup
---@param pl Entity
local function consumeHeart(_, pickup, pl)
    if(not ToyboxMod.RED_HEART_SUBTYPES[pickup.SubType]) then return end
    if(not (pl and pl:ToPlayer() and pl:ToPlayer():HasCollectible(ToyboxMod.COLLECTIBLE_GLASS_VESSEL))) then return end
    pl = pl:ToPlayer() ---@cast pl EntityPlayer

    local hpType = pl:ToPlayer():GetHealthType()
    if(hpType==HealthType.COIN) then return end

    local data = ToyboxMod:getEntityDataTable(pl)

    if(not pl:GetEffects():HasCollectibleEffect(ToyboxMod.COLLECTIBLE_GLASS_VESSEL)) then
        pl:GetEffects():AddCollectibleEffect(ToyboxMod.COLLECTIBLE_GLASS_VESSEL, true, 1)

        --pickup:PlayPickupSound()
        pickup:GetSprite():Play("Collect", true)
        pickup:Die()

        sfx:Play(SoundEffect.SOUND_URN_OPEN)

        return true
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.IMPORTANT, consumeHeart, PickupVariant.PICKUP_HEART)

---@param pickup EntityPickup
---@param pl Entity
local function consumeCoin(_, pickup, pl)
    if(not (pl and pl:ToPlayer() and pl:ToPlayer():HasCollectible(ToyboxMod.COLLECTIBLE_GLASS_VESSEL))) then return end
    pl = pl:ToPlayer() ---@cast pl EntityPlayer

    local hpType = pl:ToPlayer():GetHealthType()
    if(not (hpType==HealthType.COIN)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)

    if(not pl:GetEffects():HasCollectibleEffect(ToyboxMod.COLLECTIBLE_GLASS_VESSEL)) then
        pickup:PlayPickupSound()
        pickup:GetSprite():Play("Collect", true)
        pickup:Die()

        sfx:Play(SoundEffect.SOUND_URN_OPEN)
        pl:GetEffects():AddCollectibleEffect(ToyboxMod.COLLECTIBLE_GLASS_VESSEL, true, 1)

        return true
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, consumeCoin, PickupVariant.PICKUP_COIN)
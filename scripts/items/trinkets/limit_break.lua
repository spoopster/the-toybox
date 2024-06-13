local mod = MilcomMOD
local sfx = SFXManager()

function mod:playerHasLimitBreak(player)
    return player:HasTrinket(mod.TRINKET_LIMIT_BREAK)
end
function mod:anyPlayerHasLimitBreak()
    for i=0, Game():GetNumPlayers()-1 do
        if(mod:playerHasLimitBreak(Isaac.GetPlayer(i))) then return true end
    end
    return false
end

--#region The Wiz
--* Reduced spread
local WIZ_ANGLE_MULT = 0.3

---@param player EntityPlayer
local function getWizParams(_, player)
    if(not mod:playerHasLimitBreak(player)) then return end
    player = player:ToPlayer()

    if(player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ)) then
        local weap = player:GetWeapon(1)
        if(not weap) then return end

        local params = player:GetMultiShotParams(weap:GetWeaponType())
        params:SetMultiEyeAngle(params:GetMultiEyeAngle()*WIZ_ANGLE_MULT)
        return params
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, getWizParams)
--#endregion

--#region Little C.H.A.D.
--* Spawns full red hearts instead of half red hearts

---@param pickup EntityPickup
local function CHADHeartInit(_, pickup)
    if(pickup.SubType~=HeartSubType.HEART_HALF) then return end
    local sp = pickup.SpawnerEntity
    if(sp and sp.Type==EntityType.ENTITY_FAMILIAR and sp.Variant==FamiliarVariant.LITTLE_CHAD) then
        if(not mod:playerHasLimitBreak(sp:ToFamiliar().Player)) then return end

        local newSubType = HeartSubType.HEART_FULL
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, newSubType)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, CHADHeartInit, PickupVariant.PICKUP_HEART)
--#endregion

--#region Curse of The Tower / Anarchist Cookbook
--* Troll bombs spawned by the item(s) do not damage the player that spawned them

---@param player EntityPlayer
---@param source EntityRef
local function COTTcancelTrollBombDamage(_, player, dmg, flags, source)
    if(not mod:playerHasLimitBreak(player)) then return end
    local ent = source.Entity
    if(not (ent and ent.Type==EntityType.ENTITY_BOMB and ent.Variant==BombVariant.BOMB_TROLL)) then return end

    if(ent.SpawnerEntity and GetPtrHash(ent.SpawnerEntity)==GetPtrHash(player)) then return false end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, COTTcancelTrollBombDamage)
--#endregion

--#region Boom!
--* Super Troll Bombs devolve into Troll Bombs, Troll Bombs have a chance to never explode
local DUD_CHANCE = 0.15

---@param bomb EntityBomb
local function boomDevolveSuperTroll(_, bomb)
    if(not (PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BOOM) and mod:anyPlayerHasLimitBreak())) then return end
    local newBomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_TROLL, 0, bomb.Position, bomb.Velocity, bomb.SpawnerEntity):ToBomb()
    newBomb.Flags = bomb.Flags
    newBomb.ExplosionDamage = bomb.ExplosionDamage
    newBomb:SetExplosionCountdown(bomb:GetExplosionCountdown())

    bomb:Remove()
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_BOMB_INIT, CallbackPriority.IMPORTANT, boomDevolveSuperTroll, BombVariant.BOMB_SUPERTROLL)

---@param bomb EntityBomb
local function boomMakeDudTroll(_, bomb)
    if(not (PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BOOM) and mod:anyPlayerHasLimitBreak())) then return end
    
    if(bomb:GetDropRNG():RandomFloat()<DUD_CHANCE) then
        mod:setEntityData(bomb, "IS_TROLL_DUD", true)
        bomb:SetExplosionCountdown(100000000)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, boomMakeDudTroll, BombVariant.BOMB_TROLL)

---@param bomb EntityBomb
local function boomUpdateDudTroll(_, bomb)
    if(mod:getEntityData(bomb, "IS_TROLL_DUD")==true and bomb:GetExplosionCountdown()<=120) then
        bomb:SetExplosionCountdown(100000000)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, boomUpdateDudTroll, BombVariant.BOMB_TROLL)
--#endregion

--#region Kamikaze
--* Explosion inherits bomb effects

---@param player EntityPlayer
local function kamikazeUse(_, item, rng, player)
    if(not mod:playerHasLimitBreak(player)) then return end
    
    local bomb = player:FireBomb(player.Position, Vector.Zero, player)
    bomb.Visible = false
    bomb:SetExplosionCountdown(0)
    bomb.ExplosionDamage = 0
    bomb:Update()
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, kamikazeUse, CollectibleType.COLLECTIBLE_KAMIKAZE)
--#endregion

--#region Shade
--* When hitting enemies, Shade has a chance to apply fear to them
--* When killing enemies, Shade has a chance to spawn a shadow charger
local SHADE_FEARCHANCE = 1/6
local SHADE_CHARGERCHANCE = 1/2

---@param ent Entity
local function shadeDealDamage(_, ent, amount, flags, source)
    if(not (source.Entity and source.Entity.Type==EntityType.ENTITY_FAMILIAR and source.Entity.Variant==FamiliarVariant.SHADE)) then return end
    local sh = source.Entity:ToFamiliar()
    if(not (sh.Player and mod:playerHasLimitBreak(sh.Player))) then return end
    local rng = sh.Player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SHADE)

    if(amount>=ent.HitPoints) then
        if(rng:RandomFloat()<SHADE_CHARGERCHANCE) then
            local charger = Isaac.Spawn(23,0,1,ent.Position,Vector.Zero,nil):ToNPC()
            charger:AddCharmed(EntityRef(sh.Player), -1)
        end
    elseif(rng:RandomFloat()<SHADE_FEARCHANCE) then
        ent:AddFear(EntityRef(sh.Player), 90)
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, shadeDealDamage)
--#endregion

--#region The Jar
--* On full Jar, using it gives a full heart container

---@param player EntityPlayer
local function theJarPreUse(_, item, rng, player, flags, slot, vdata)
    mod:setEntityData(player, "JAR_HEARTS_NUM", player:GetJarHearts())
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, theJarPreUse, CollectibleType.COLLECTIBLE_THE_JAR)

---@param player EntityPlayer
local function theJarUse(_, item, rng, player, flags, slot, vdata)
    if(not mod:playerHasLimitBreak(player)) then return end
    local heartsNum = (mod:getEntityData(player, "JAR_HEARTS_NUM") or 0)
    
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
mod:AddCallback(ModCallbacks.MC_USE_ITEM, theJarUse, CollectibleType.COLLECTIBLE_THE_JAR)
--#endregion

--#region Obsessed Fan
--* When hitting enemies, Shade has a chance to apply charm to them
local OBSFAN_CHARMCHANCE = 1/4

---@param ent Entity
local function obsessedFanDealDamage(_, ent, amount, flags, source)
    if(not (source.Entity and source.Entity.Type==EntityType.ENTITY_FAMILIAR and source.Entity.Variant==FamiliarVariant.OBSESSED_FAN)) then return end
    local sh = source.Entity:ToFamiliar()
    if(not (sh.Player and mod:playerHasLimitBreak(sh.Player))) then return end
    local rng = sh.Player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_OBSESSED_FAN)

    if(amount<ent.HitPoints and rng:RandomFloat()<OBSFAN_CHARMCHANCE) then
        ent:AddCharmed(EntityRef(sh.Player), 90)
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, obsessedFanDealDamage)
--#endregion

--#region Missing Page 2
--* Using an active has a chance to trigger the Necronomicon effect

---@param player EntityPlayer
local function missingPage2UseActive(_, player, item, slot)
    if(item and item==CollectibleType.COLLECTIBLE_NECRONOMICON) then return end
    if(not (player and player:HasCollectible(CollectibleType.COLLECTIBLE_MISSING_PAGE_2) and mod:playerHasLimitBreak(player))) then return end
    local iConfig = Isaac.GetItemConfig():GetCollectible(item)
    if(not iConfig) then return end

    local chance = 0.1
    if(iConfig.ChargeType==0) then 
        local charges = iConfig.MaxCharges
        if(charges<=0) then chance = 0.0
        elseif(charges<=5) then chance = (charges+1)*0.05
        elseif(charges<=12) then chance = (charges-6)*0.1+0.4
        else chance = 1.0 end
    end

    if(player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MISSING_PAGE_2):RandomFloat()<chance) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON)
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.USE_ACTIVE_ITEM, missingPage2UseActive)
--#endregion

--#region Bum Friend / Bumbo / Super Bum (coin var)
--* Coins count as double value when picked up by them

local function coinBumPostFamiliarColl(_, familiar, collider)
    if(not (familiar.Variant==FamiliarVariant.BUM_FRIEND or familiar.Variant==FamiliarVariant.BUMBO or familiar.Variant==FamiliarVariant.SUPER_BUM)) then return end
    if(not (collider.Type==5 and collider.Variant==20)) then return end
    if(not (familiar.Player and mod:playerHasLimitBreak(familiar.Player))) then return end

    familiar.Coins = familiar.Coins + collider:ToPickup():GetCoinValue()
end
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, coinBumPostFamiliarColl)

--#endregion
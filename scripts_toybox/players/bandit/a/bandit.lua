local BOMB_MODIFIER_WEIGHT = 3

local KEY_REPLACE_CHANCE = 0.2
local COIN_HEART_REPLACE_CHANCE = 0.1

local BIRTHRIGHT_BOMBS_ADD_COLLECTIBLE = 3

---@param pl EntityPlayer
local function banditInit(_, pl)
    if(pl:GetPlayerType()==ToyboxMod.PLAYER_BANDIT_A and pl.FrameCount==0) then
        Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
        pl:AddInnateCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
        pl:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_DR_FETUS))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, banditInit, PlayerVariant.PLAYER)

---@param itemConf ItemConfigItem
---@param pl EntityPlayer
local function banditCancelCostume(_, itemConf, pl)
    if(pl:GetPlayerType()==ToyboxMod.PLAYER_BANDIT_A and itemConf:IsCollectible()) then
        if(itemConf.ID==CollectibleType.COLLECTIBLE_KAMIKAZE or itemConf.ID==CollectibleType.COLLECTIBLE_DR_FETUS) then
            return true
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_COSTUME, banditCancelCostume)

---@param bomb EntityBomb
local function banditPostFireBomb(_, bomb)
    local pl = ToyboxMod:getPlayerFromEnt(bomb)
    if(pl and pl:GetPlayerType()==ToyboxMod.PLAYER_BANDIT_A) then
        if(pl:GetNumBombs()>0 or pl:HasGoldenBomb()) then
            bomb.ExplosionDamage = bomb.ExplosionDamage*1.66
            bomb.RadiusMultiplier = bomb.RadiusMultiplier*1.25
            bomb:SetScale(bomb:GetScale()*1.25)

            local hasBirthright = pl:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
            if(hasBirthright) then
                ToyboxMod:addInnateCollectible(pl, CollectibleType.COLLECTIBLE_NANCY_BOMBS, 1, "ToyboxBanditBirthrightNancy")
            end
            local flags = pl:GetBombFlags()
            bomb:AddTearFlags(flags)

            pl:ClearInnateItemGroup("ToyboxBanditBirthrightNancy")

            if(not pl:HasGoldenBomb()) then
                pl:AddBombs(-1)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, banditPostFireBomb)


---@param id CollectibleType
---@param firstTime boolean
---@param pl EntityPlayer
local function addBombsBirthright(_, id, _, firstTime, _, _, pl)
    if(not firstTime) then return end

    if(pl:GetPlayerType()==ToyboxMod.PLAYER_BANDIT_A and pl:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        pl:AddBombs(BIRTHRIGHT_BOMBS_ADD_COLLECTIBLE)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addBombsBirthright)



---@param pl EntityPlayer
local function banditPreUseKamikaze(_, _, _, pl)
    if(pl and pl:GetPlayerType()==ToyboxMod.PLAYER_BANDIT_A) then
        ToyboxMod:setEntityData(pl, "BANDIT_KAMIKAZE_USED", true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, banditPreUseKamikaze, CollectibleType.COLLECTIBLE_KAMIKAZE)

---@param pl EntityPlayer
local function banditPostUseKamikaze(_, _, _, pl)
    if(pl and pl:GetPlayerType()==ToyboxMod.PLAYER_BANDIT_A) then
        ToyboxMod:setEntityData(pl, "BANDIT_KAMIKAZE_USED", nil)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, banditPostUseKamikaze, CollectibleType.COLLECTIBLE_KAMIKAZE)

---@param ent Entity
---@param flags DamageFlag
---@param source EntityRef
local function banditTakeKamikazeDmg(_, ent, dmg, flags, source, cnt)
    if(not (source.Entity and source.Entity:ToPlayer())) then return end

    local pl = ent and ent:ToPlayer()
    if(pl and pl:GetPlayerType()==ToyboxMod.PLAYER_BANDIT_A and ToyboxMod:getEntityData(pl, "BANDIT_KAMIKAZE_USED")) then
        return {
            Damage = dmg,
            DamageFlags = flags | DamageFlag.DAMAGE_RED_HEARTS,
            DamageCountdown = cnt,
        }
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, banditTakeKamikazeDmg, EntityType.ENTITY_PLAYER)

---@param pickup EntityPickup
local function pickupReplaceWithBombInit(_, pickup)
    if(not PlayerManager.AnyoneIsPlayerType(ToyboxMod.PLAYER_BANDIT_A)) then return end

    if(pickup.Variant==PickupVariant.PICKUP_KEY) then
        local rng = ToyboxMod:generateRng(pickup.InitSeed)
        if(rng:RandomFloat()<KEY_REPLACE_CHANCE) then
            pickup:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BOMB,0)
        end
    elseif(pickup.Variant==PickupVariant.PICKUP_COIN or pickup.Variant==PickupVariant.PICKUP_HEART) then
        local rng = ToyboxMod:generateRng(pickup.InitSeed)
        if(rng:RandomFloat()<COIN_HEART_REPLACE_CHANCE) then
            pickup:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BOMB,0)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, pickupReplaceWithBombInit)
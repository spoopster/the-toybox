local mod = ToyboxMod
local sfx = SFXManager()

--- !!! TODO: update toybox to rep+ to use rgon nightly TriggerRestock feature

local HEART_UPGRADE_CHANCE = 1--0.25

local HEART_UPGRADE_TABLE = {
    [HeartSubType.HEART_HALF] = HeartSubType.HEART_FULL,
    [HeartSubType.HEART_FULL] = HeartSubType.HEART_DOUBLEPACK,
    [HeartSubType.HEART_HALF_SOUL] = HeartSubType.HEART_SOUL,

    [HeartSubType.HEART_DOUBLEPACK] = mod.PICKUP_SUBTYPE.HEART_QUAD,
    [HeartSubType.HEART_SOUL] = mod.PICKUP_SUBTYPE.HEART_SOUL_DOUBLE,
    [HeartSubType.HEART_BLACK] = mod.PICKUP_SUBTYPE.HEART_BLACK_DOUBLE,
    [HeartSubType.HEART_ROTTEN] = mod.PICKUP_SUBTYPE.HEART_ROTTEN_DOUBLE,
    [HeartSubType.HEART_ETERNAL] = mod.PICKUP_SUBTYPE.HEART_ETERNAL_FULL,
    [HeartSubType.HEART_BLENDED] = mod.PICKUP_SUBTYPE.HEART_BLENDED_DOUBLE,
    [HeartSubType.HEART_GOLDEN] = mod.PICKUP_SUBTYPE.HEART_GOLD_DOUBLE,
    [HeartSubType.HEART_BONE] = mod.PICKUP_SUBTYPE.HEART_BONE_DOUBLE,
}

local UPGRADED_HEART_LOGIC = {
    [mod.PICKUP_SUBTYPE.HEART_QUAD] = {
        ---@param pl EntityPlayer
        Condition=function(pl)
            return pl:CanPickRedHearts() or pl:HasTrinket(TrinketType.TRINKET_APPLE_OF_SODOM)
        end,
        ---@param pl EntityPlayer
        ---@param val number
        ---@param pickup EntityPickup
        AddFunc=function(pl, val, pickup)
            if(pl:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW)) then
                val = val*2
            end

            local rng = pl:GetTrinketRNG(TrinketType.TRINKET_APPLE_OF_SODOM)
            local shouldSodom = pl:HasTrinket(TrinketType.TRINKET_APPLE_OF_SODOM) and ((not pl:CanPickRedHearts()) or rng:RandomFloat()<0.5)

            if(shouldSodom) then
                pickup:BloodExplode()
                Game():ButterBeanFart(pickup.Position, 1, pickup, true, false)

                local numSpiders = math.floor(1.5*val)+rng:RandomInt(3)
                for _=1, numSpiders do
                    pl:ThrowBlueSpider(pickup.Position, pickup.Position+rng:RandomVector()*40*(0.8+rng:RandomFloat()*0.4))
                end
            else
                pl:AddHearts(val)
            end
        end,
        AddVal=8, Sfx=SoundEffect.SOUND_BOSS2_BUBBLES},
    [mod.PICKUP_SUBTYPE.HEART_SOUL_DOUBLE] = {Condition="CanPickSoulHearts", AddFunc="AddSoulHearts", AddVal=4, Sfx=SoundEffect.SOUND_HOLY},
    [mod.PICKUP_SUBTYPE.HEART_BLACK_DOUBLE] = {
        Condition="CanPickBlackHearts",
        ---@param pl EntityPlayer
        ---@param val number
        AddFunc=function(pl, val)
            pl:AddBlackHearts(val)

            local eff = pl:GetEffects()
            if(eff:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_REDEMPTION)==1 and Game():GetRoom():GetType()==RoomType.ROOM_DEVIL) then
                for _, effect in ipairs(Isaac.FindByType(1000,EffectVariant.REDEMPTION)) do
                    if(effect.Parent and GetPtrHash(effect.Parent)==GetPtrHash(pl)) then
                        effect.State = 3
                        effect:GetSprite():Play("Fail", true)
                    end
                end
                eff:AddCollectibleEffect(CollectibleType.COLLECTIBLE_REDEMPTION)
                sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
            end
        end,
        AddVal=4, Sfx=SoundEffect.SOUND_UNHOLY},
    [mod.PICKUP_SUBTYPE.HEART_ROTTEN_DOUBLE] = {Condition="CanPickRottenHearts", AddFunc="AddRottenHearts", AddVal=4, Sfx=SoundEffect.SOUND_ROTTEN_HEART},
    [mod.PICKUP_SUBTYPE.HEART_ETERNAL_FULL] = {AddFunc="AddEternalHearts", AddVal=2, Sfx=SoundEffect.SOUND_SUPERHOLY},
    [mod.PICKUP_SUBTYPE.HEART_BLENDED_DOUBLE] = {
        ---@param pl EntityPlayer
        Condition=function(pl)
            return pl:CanPickRedHearts() or pl:CanPickSoulHearts()
        end,
        ---@param pl EntityPlayer
        ---@param val number
        AddFunc=function(pl, val)
            local mult = (pl:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) and 2 or 1)

            local emtpyRedHealth = pl:GetEffectiveMaxHearts()-pl:GetHearts()
            local redToAdd = math.min(val*mult, emtpyRedHealth)

            pl:AddHearts(redToAdd)
            pl:AddSoulHearts(val-math.ceil(redToAdd/mult))

            if(redToAdd>0) then sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES) end
            if(redToAdd<val*mult) then sfx:Play(SoundEffect.SOUND_HOLY) end
        end,
        AddVal = 4,
    },
    [mod.PICKUP_SUBTYPE.HEART_GOLD_DOUBLE] = {Condition="CanPickGoldenHearts", AddFunc="AddGoldenHearts", AddVal=2, DropSfx=466, Sfx=SoundEffect.SOUND_GOLD_HEART},
    [mod.PICKUP_SUBTYPE.HEART_BONE_DOUBLE] = {Condition="CanPickBoneHearts", AddFunc="AddBoneHearts", AddVal=2, DropSfx=467, Sfx=SoundEffect.SOUND_BONE_HEART},
}

---@param pl EntityPlayer
---@param pickup EntityPickup
local function canCollectPickup(pl, pickup)
    if(pickup.Wait>0) then return false end
    if(pickup:IsShopItem()) then
        if(not pl:IsExtraAnimationFinished()) then return false end

        if(pickup.Price>0) then
            return pl:GetNumCoins()>=pickup.Price
        end
    end

    return true
end

---@param pl EntityPlayer
---@param pickup EntityPickup
local function tryCollectPickup(pl, pickup)
    if(pickup:IsShopItem()) then
        local price = pickup.Price
        if(price>=0 or price==PickupPrice.PRICE_FREE or price==PickupPrice.PRICE_SPIKES) then
            if(price==PickupPrice.PRICE_SPIKES) then
                local tookDmg = pl:TakeDamage(2, DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(nil), 30)
                if(not tookDmg) then
                    return false
                end
            elseif(price>=0) then
                pl:AddCoins(-price)
            elseif(price==PickupPrice.PRICE_FREE and PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_STORE_CREDIT)) then
                local creditOwner = pl
                if(not pl:HasTrinket(TrinketType.TRINKET_STORE_CREDIT)) then
                    for i=0, Game():GetNumPlayers()-1 do
                        local otherPl = Isaac.GetPlayer(i)
                        if(otherPl:HasTrinket(TrinketType.TRINKET_STORE_CREDIT)) then
                            creditOwner = otherPl
                            break
                        end
                    end
                end

                if(creditOwner:HasGoldenTrinket(TrinketType.TRINKET_STORE_CREDIT)) then
                    local goldSub = TrinketType.TRINKET_STORE_CREDIT | TrinketType.TRINKET_GOLDEN_FLAG
                    if(creditOwner:GetTrinketRNG(TrinketType.TRINKET_STORE_CREDIT):RandomFloat()<0.25) then
                        local isSmelted = not (creditOwner:GetTrinket(0)==goldSub or creditOwner:GetTrinket(1)==goldSub)

                        local removed = creditOwner:TryRemoveTrinket(goldSub)
                        if(removed) then
                            if(isSmelted) then
                                creditOwner:AddSmeltedTrinket(TrinketType.TRINKET_STORE_CREDIT, false)
                            else
                                creditOwner:AddTrinket(TrinketType.TRINKET_STORE_CREDIT, false)
                            end
                        end
                    end
                else
                    creditOwner:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
                end
            end

            pl:AnimatePickup(pickup:GetSprite(), true)
            pickup:Remove()
            --restock function later
        end
    else
        pickup:GetSprite():Play("Collect", true)
        pickup:Die()
    end

    if(pickup.OptionsPickupIndex~=0) then
        for _, other in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
            other = other:ToPickup()

            if(other.OptionsPickupIndex==pickup.OptionsPickupIndex and GetPtrHash(other)~=GetPtrHash(pickup)) then
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT,14,0, other.Position, Vector.Zero, nil):ToEffect()
                other:Remove()
            end
        end
    end

    return true
end

local UPGRADING_HEART = false
---@param pickup EntityPickup
local function heartInit(_, pickup)
    if(UPGRADING_HEART) then return end
    if(not HEART_UPGRADE_TABLE[pickup.SubType]) then return end

    if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.CARAMEL_APPLE)) then return end
    if(pickup:GetSprite():GetAnimation()~="Appear") then return end

    if(pickup:GetDropRNG():RandomFloat()<HEART_UPGRADE_CHANCE) then
        UPGRADING_HEART = true
        pickup:Morph(pickup.Type,pickup.Variant,HEART_UPGRADE_TABLE[pickup.SubType],true,true)
        UPGRADING_HEART = false
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, heartInit, PickupVariant.PICKUP_HEART)

local function heartUpdate(_, pickup)
    if(not UPGRADED_HEART_LOGIC[pickup.SubType]) then return end

    if(pickup:GetSprite():IsEventTriggered("DropSound")) then
        local soundToPlay = UPGRADED_HEART_LOGIC[pickup.SubType].DropSfx
        if(soundToPlay) then
            sfx:Stop(SoundEffect.SOUND_MEAT_FEET_SLOW0)
            sfx:Play(soundToPlay)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, heartUpdate, PickupVariant.PICKUP_HEART)

---@param pickup EntityPickup
---@param coll Entity
local function preHeartCollision(_, pickup, coll, low)
    if(not UPGRADED_HEART_LOGIC[pickup.SubType]) then return end
    if(not (coll and coll:ToPlayer())) then return end
    if(not canCollectPickup(coll:ToPlayer(), pickup)) then return pickup:IsShopItem() end

    local pl = coll:ToPlayer() ---@type EntityPlayer
    local sub = pickup.SubType
    local logicTable = UPGRADED_HEART_LOGIC[sub]

    local collectHeart = true
    if(logicTable.Condition) then
        if(type(logicTable.Condition)=="function") then
            collectHeart = logicTable.Condition(pl)
        else
            collectHeart = pl[logicTable.Condition](pl)
        end
    end

    if(not collectHeart) then return end
    if(not tryCollectPickup(pl, pickup)) then
        return pickup:IsShopItem()
    end

    if(logicTable.AddFunc) then
        if(type(logicTable.AddFunc)=="function") then
            logicTable.AddFunc(pl, logicTable.AddVal or 0, pickup)
        else
            pl[logicTable.AddFunc](pl, logicTable.AddVal or 0)
        end
    end
    if(logicTable.Sfx) then
        sfx:Play(logicTable.Sfx)
    end

    Game():GetLevel():SetHeartPicked()
    Game():ClearStagesWithoutHeartsPicked()
    Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)

    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, preHeartCollision, PickupVariant.PICKUP_HEART)

if(FiendFolio) then
    local FIEND_FOLIO_UPGRADE_TABLE = {
        [FiendFolio.PICKUP.VARIANT.HALF_BLACK_HEART] = HeartSubType.HEART_BLACK,
        [FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART] = mod.PICKUP_SUBTYPE.HEART_BLENDEDBLACK_DOUBLE,
        [FiendFolio.PICKUP.VARIANT.IMMORAL_HEART] = mod.PICKUP_SUBTYPE.HEART_IMMORAL_DOUBLE,
        [FiendFolio.PICKUP.VARIANT.HALF_IMMORAL_HEART] = FiendFolio.PICKUP.VARIANT.IMMORAL_HEART,
        [FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART] = mod.PICKUP_SUBTYPE.HEART_BLENDEDIMMORAL_DOUBLE,
        [FiendFolio.PICKUP.VARIANT.MORBID_HEART] = mod.PICKUP_SUBTYPE.HEART_MORBID_DOUBLE,
        [FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART] = mod.PICKUP_SUBTYPE.HEART_MORBID_FOURTHIRDS,
        [FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART] = FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART,
    }

    ---@param pickup EntityPickup
    local function ffHeartInit(_, pickup)
        if(UPGRADING_HEART) then return end
        if(not FIEND_FOLIO_UPGRADE_TABLE[pickup.Variant]) then return end

        if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.CARAMEL_APPLE)) then return end
        if(pickup:GetSprite():GetAnimation()~="Appear") then return end

        if(pickup:GetDropRNG():RandomFloat()<HEART_UPGRADE_CHANCE) then
            UPGRADING_HEART = true
            pickup:Morph(pickup.Type,PickupVariant.PICKUP_HEART,FIEND_FOLIO_UPGRADE_TABLE[pickup.Variant],true,true)
            UPGRADING_HEART = false
        end
    end
    mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, ffHeartInit)

    ---@param pickup EntityPickup
    local function redRibbonUpdate(_, pickup)
        if(pickup.SubType~=mod.PICKUP_SUBTYPE.HEART_ETERNAL_FULL) then return end

        local sp = pickup:GetSprite()
        local ribbonEffect = math.min(PlayerManager.GetTotalTrinketMultiplier(TrinketType.TRINKET_RED_RIBBON), 2)

        if(pickup:GetData().isFullFromRR~=ribbonEffect and (sp:IsPlaying("Idle") or sp:IsPlaying("Appear"))) then
            local newSheet
            if(ribbonEffect==1) then newSheet = "gfx/pickups/tb_pickup_eternal_double.png"
            elseif(ribbonEffect==2) then newSheet = "gfx/pickups/tb_pickup_eternal_quad.png"
            else newSheet = "gfx/pickups/tb_pickup_double_hearts.png" end

            sp:ReplaceSpritesheet(0, newSheet)
            sp:ReplaceSpritesheet(1, newSheet)
            sp:LoadGraphics()

            if(not sp:IsPlaying("Appear") and pickup.FrameCount>0) then
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, 15, 0, pickup.Position, Vector.Zero, nil):ToEffect()
                poof.Color = Color(5,5,5,1,0,0,0)
                poof:Update()
            end

            pickup:GetData().isFullFromRR = ribbonEffect
        end
    end
    mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, redRibbonUpdate, PickupVariant.PICKUP_HEART)

    ---@param pl EntityPlayer
    ---@param val integer
    UPGRADED_HEART_LOGIC[mod.PICKUP_SUBTYPE.HEART_ETERNAL_FULL].AddFunc = function(pl, val)
        local ribbonEffect = math.min(PlayerManager.GetTotalTrinketMultiplier(TrinketType.TRINKET_RED_RIBBON), 2)
        local toAdd = val*(1<<ribbonEffect)

        pl:AddEternalHearts(toAdd)
    end

    UPGRADED_HEART_LOGIC[mod.PICKUP_SUBTYPE.HEART_BLENDEDBLACK_DOUBLE] = {
        ---@param pl EntityPlayer
        Condition=function(pl)
            return pl:CanPickRedHearts() or pl:CanPickBlackHearts()
        end,
        ---@param pl EntityPlayer
        ---@param val number
        AddFunc=function(pl, val)
            local mult = (pl:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) and 2 or 1)

            local emtpyRedHealth = pl:GetEffectiveMaxHearts()-pl:GetHearts()
            local redToAdd = math.min(val*mult, emtpyRedHealth)

            pl:AddHearts(redToAdd)
            pl:AddBlackHearts(val-math.ceil(redToAdd/mult))

            if(redToAdd>0) then sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES) end
            if(redToAdd<val*mult) then sfx:Play(SoundEffect.SOUND_UNHOLY) end
        end,
        AddVal = 4,
    }
    UPGRADED_HEART_LOGIC[mod.PICKUP_SUBTYPE.HEART_IMMORAL_DOUBLE] = {
        ---@param pl EntityPlayer
        Condition=function(pl)
            return FiendFolio:CanPickImmoralHearts(pl)
        end,
        ---@param pl EntityPlayer
        ---@param val number
        AddFunc=function(pl, val)
            FiendFolio:AddImmoralHearts(pl, val)
        end,
        AddVal = 4, Sfx=FiendFolio.Sounds.FiendHeartPickup, DropSfx=FiendFolio.Sounds.FiendHeartDrop,
    }
    UPGRADED_HEART_LOGIC[mod.PICKUP_SUBTYPE.HEART_BLENDEDIMMORAL_DOUBLE] = {
        ---@param pl EntityPlayer
        Condition=function(pl)
            return pl:CanPickRedHearts() or FiendFolio:CanPickImmoralHearts(pl)
        end,
        ---@param pl EntityPlayer
        ---@param val number
        AddFunc=function(pl, val)
            local mult = (pl:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) and 2 or 1)

            local emtpyRedHealth = pl:GetEffectiveMaxHearts()-pl:GetHearts()
            local redToAdd = math.min(val*mult, emtpyRedHealth)

            pl:AddHearts(redToAdd)
            FiendFolio:AddImmoralHearts(pl, val-math.ceil(redToAdd/mult))

            if(redToAdd>0) then sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES) end
            if(redToAdd<val*mult) then sfx:Play(FiendFolio.Sounds.FiendHeartPickup) end
        end,
        AddVal = 4, DropSfx=FiendFolio.Sounds.FiendHeartDrop,
    }
    UPGRADED_HEART_LOGIC[mod.PICKUP_SUBTYPE.HEART_MORBID_DOUBLE] = {
        ---@param pl EntityPlayer
        Condition=function(pl)
            return FiendFolio:CanPickMorbidHearts(pl)
        end,
        ---@param pl EntityPlayer
        ---@param val number
        AddFunc=function(pl, val)
            FiendFolio:AddMorbidHearts(pl, val)
        end,
        AddVal = 6, Sfx=SoundEffect.SOUND_ROTTEN_HEART,
    }
    UPGRADED_HEART_LOGIC[mod.PICKUP_SUBTYPE.HEART_MORBID_FOURTHIRDS] = {
        ---@param pl EntityPlayer
        Condition=function(pl)
            return FiendFolio:CanPickMorbidHearts(pl)
        end,
        ---@param pl EntityPlayer
        ---@param val number
        AddFunc=function(pl, val)
            FiendFolio:AddMorbidHearts(pl, val)
        end,
        AddVal = 4, Sfx=SoundEffect.SOUND_ROTTEN_HEART,
    }
end

--]]

--[[] ]

local ENUM_BONUSHEALTH_CHANCE = 1/3

local ENUM_REDHEART_COL = Color(1,1,1,1)
local ENUM_SOULHEART_COL = Color(1,1,1,1)
ENUM_SOULHEART_COL:SetColorize(1.5,1.5,3,1)
local ENUM_BLACKHEART_COL = Color(1,1,1,1)
ENUM_BLACKHEART_COL:SetColorize(0.8,0.8,0.8,1)
local ENUM_ETERNALHEART_COL = Color(1,1,1,1)
ENUM_ETERNALHEART_COL:SetColorize(10,10,10,1)
local ENUM_GOLDHEART_COL = Color(1,1,1,1)
ENUM_GOLDHEART_COL:SetColorize(5,5,0.7,1)
local ENUM_ROTTENHEART_COL = Color(1,1,1,1)
ENUM_ROTTENHEART_COL:SetColorize(1.5,2,1,1)

local ENUM_HEARTS = {
    [HeartSubType.HEART_FULL] = {
        Color = ENUM_REDHEART_COL,
        TestFunc = function(player)
            return player:CanPickRedHearts()
        end,
        AddFunc = function(player)
            player:AddHearts(1)
        end,
    },
    [HeartSubType.HEART_HALF] = {
        Color = ENUM_REDHEART_COL,
        TestFunc = function(player)
            return player:CanPickRedHearts()
        end,
        AddFunc = function(player)
            player:AddHearts(1)
        end,
    },
    [HeartSubType.HEART_SOUL] = {
        Color = ENUM_SOULHEART_COL,
        TestFunc = function(player)
            return player:CanPickSoulHearts()
        end,
        AddFunc = function(player)
            player:AddSoulHearts(1)
        end,
    },
    [HeartSubType.HEART_ETERNAL] = {
        Color = ENUM_ETERNALHEART_COL,
        TestFunc = function(player)
            return true
        end,
        AddFunc = function(player)
            player:AddEternalHearts(1)
        end,
    },
    [HeartSubType.HEART_DOUBLEPACK] = {
        Color = ENUM_REDHEART_COL,
        TestFunc = function(player)
            return player:CanPickRedHearts()
        end,
        AddFunc = function(player)
            player:AddHearts(1)
        end,
    },
    [HeartSubType.HEART_BLACK] = {
        Color = ENUM_BLACKHEART_COL,
        TestFunc = function(player)
            return player:CanPickBlackHearts()
        end,
        AddFunc = function(player)
            player:AddBlackHearts(1)
        end,
    },
    [HeartSubType.HEART_GOLDEN] = {
        Color = ENUM_GOLDHEART_COL,
        TestFunc = function(player)
            return player:CanPickGoldenHearts()
        end,
        AddFunc = function(player)
            player:AddGoldenHearts(1)
        end,
    },
    [HeartSubType.HEART_HALF_SOUL] = {
        Color = ENUM_SOULHEART_COL,
        TestFunc = function(player)
            return player:CanPickSoulHearts()
        end,
        AddFunc = function(player)
            player:AddSoulHearts(1)
        end,
    },
    [HeartSubType.HEART_SCARED] = {
        Color = ENUM_REDHEART_COL,
        TestFunc = function(player)
            return player:CanPickRedHearts()
        end,
        AddFunc = function(player)
            player:AddHearts(1)
        end,
    },
    [HeartSubType.HEART_BLENDED] = {
        Color = {ENUM_REDHEART_COL, ENUM_SOULHEART_COL},
        TestFunc = function(player)
            return (player:CanPickRedHearts() or player:CanPickSoulHearts())
        end,
        AddFunc = function(player)
            player:AddHearts(1)
            player:AddSoulHearts(1)
        end,
    },
    [HeartSubType.HEART_BONE] = {
        Color = ENUM_ETERNALHEART_COL,
        TestFunc = function(player)
            return player:CanPickBoneHearts()
        end,
        AddFunc = function(player)
            player:AddBoneHearts(1)
        end,
    },
    [HeartSubType.HEART_ROTTEN] = {
        Color = ENUM_ROTTENHEART_COL,
        TestFunc = function(player)
            return player:CanPickRottenHearts()
        end,
        AddFunc = function(player)
            player:AddRottenHearts(2)
        end,
    },
}

function mod:addCaramelAppleHeart(heartSubType, color, testFunc, addFunc)
    ENUM_HEARTS[heartSubType] = {
        Color = color,
        TestFunc = testFunc,
        AddFunc = addFunc,
    }
end

if(FiendFolio) then
    local ENUM_IMMORALHEART_COL = Color(1,1,1,1)
    ENUM_IMMORALHEART_COL:SetColorize(5,0.7,5,1)
    local ENUM_MORBIDHEART_COL = Color(1,1,1,1)
    ENUM_MORBIDHEART_COL:SetColorize(0.8,1.2,0.8,1)

    mod:addCaramelAppleHeart(
        FiendFolio.PICKUP.VARIANT.HALF_BLACK_HEART,
        ENUM_BLACKHEART_COL,
        function(player)
            return player:CanPickBlackHearts()
        end,
        function(player)
            player:AddBlackHearts(1)
        end
    )
    mod:addCaramelAppleHeart(
        FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART,
        {ENUM_REDHEART_COL, ENUM_BLACKHEART_COL},
        function(player)
            return (player:CanPickRedHearts() or player:CanPickBlackHearts())
        end,
        function(player)
            player:AddHearts(1)
            player:AddBlackHearts(1)
        end
    )
    mod:addCaramelAppleHeart(
        FiendFolio.PICKUP.VARIANT.IMMORAL_HEART,
        ENUM_IMMORALHEART_COL,
        function(player)
            return player:CanPickSoulHearts()
        end,
        function(player)
            FiendFolio:AddImmoralHearts(player, 1)
        end
    )
    mod:addCaramelAppleHeart(
        FiendFolio.PICKUP.VARIANT.HALF_IMMORAL_HEART,
        ENUM_IMMORALHEART_COL,
        function(player)
            return player:CanPickSoulHearts()
        end,
        function(player)
            FiendFolio:AddImmoralHearts(player, 1)
        end
    )
    mod:addCaramelAppleHeart(
        FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART,
        ENUM_IMMORALHEART_COL,
        function(player)
            return (player:CanPickRedHearts() or player:CanPickSoulHearts())
        end,
        function(player)
            player:AddHearts(1)
            FiendFolio:AddImmoralHearts(player, 1)
        end
    )
    mod:addCaramelAppleHeart(
        FiendFolio.PICKUP.VARIANT.MORBID_HEART,
        ENUM_MORBIDHEART_COL,
        function(player)
            return player:CanPickRottenHearts()
        end,
        function(player)
            FiendFolio:AddMorbidHearts(player, 1)
        end
    )
    mod:addCaramelAppleHeart(
        FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART,
        ENUM_MORBIDHEART_COL,
        function(player)
            return player:CanPickRottenHearts()
        end,
        function(player)
            FiendFolio:AddMorbidHearts(player, 1)
        end
    )
    mod:addCaramelAppleHeart(
        FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART,
        ENUM_MORBIDHEART_COL,
        function(player)
            return player:CanPickRottenHearts()
        end,
        function(player)
            FiendFolio:AddMorbidHearts(player, 1)
        end
    )
end

---@param pickup EntityPickup
---@param player EntityPlayer?
local function collideWithHearts(_, pickup, player)
    if(not (player and player:ToPlayer() and player:ToPlayer():HasCollectible(mod.COLLECTIBLE.CARAMEL_APPLE))) then return end
    player = player:ToPlayer()

    local data = mod:getEntityDataTable(player)

    if((pickup.Variant==10 and ENUM_HEARTS[pickup.SubType]) or (pickup.Variant>12 and ENUM_HEARTS[pickup.Variant])) then
        data.CARAMEL_APPLE_DATA = data.CARAMEL_APPLE_DATA or {}
        data.CARAMEL_APPLE_DATA[#data.CARAMEL_APPLE_DATA+1] = (pickup.Variant==10 and pickup.SubType or pickup.Variant)
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.EARLY, collideWithHearts)

---@param player EntityPlayer
local function addHeartEffects(_, player)
    if(not player:HasCollectible(mod.COLLECTIBLE.CARAMEL_APPLE)) then return end
    local hpData = mod:getEntityData(player, "CARAMEL_APPLE_DATA") or {}

    local addedHearts = {}

    for k, st in pairs(hpData) do
        local hTable = ENUM_HEARTS[st]
        if(hTable) then
            if(hTable.TestFunc(player) and player:GetCollectibleRNG(mod.COLLECTIBLE.CARAMEL_APPLE):RandomFloat()<ENUM_BONUSHEALTH_CHANCE) then
                if(type(hTable.Color)=="table") then
                    for _, col in ipairs(hTable.Color) do addedHearts[#addedHearts+1] = col end
                else
                    addedHearts[#addedHearts+1] = hTable.Color
                end
    
                hTable.AddFunc(player)
            end
        end

        hpData[k] = nil
    end

    mod:setEntityData(player, "CARAMEL_APPLE_DATA", hpData)

    for i, c in ipairs(addedHearts) do
        local offset = ((i-1/2)-(#addedHearts/2))

        local gulpEffect = Isaac.Spawn(1000, 49, 0, player.Position, Vector.Zero, nil):ToEffect()
        gulpEffect.Color = c
        gulpEffect.SpriteOffset = Vector(19*offset, -35+3*math.abs(offset))
        gulpEffect.DepthOffset = 1000
        gulpEffect:FollowParent(player)
    end
    if(#addedHearts~=0) then
        sfx:Play(SoundEffect.SOUND_VAMP_GULP)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, addHeartEffects)
--]]
local mod = MilcomMOD
local sfx = SFXManager()

local ENUM_BONUSHEALTH_CHANCE = 1

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

if(FiendFolio) then
    local ENUM_IMMORALHEART_COL = Color(1,1,1,1)
    ENUM_IMMORALHEART_COL:SetColorize(5,0.7,5,1)
    local ENUM_MORBIDHEART_COL = Color(1,1,1,1)
    ENUM_MORBIDHEART_COL:SetColorize(0.8,1.2,0.8,1)

    ENUM_HEARTS[FiendFolio.PICKUP.VARIANT.HALF_BLACK_HEART] = {
        Color = ENUM_BLACKHEART_COL,
        TestFunc = function(player)
            return player:CanPickBlackHearts()
        end,
        AddFunc = function(player)
            player:AddBlackHearts(1)
        end,
    }
    ENUM_HEARTS[FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART] = {
        Color = {ENUM_REDHEART_COL, ENUM_BLACKHEART_COL},
        TestFunc = function(player)
            return (player:CanPickRedHearts() or player:CanPickBlackHearts())
        end,
        AddFunc = function(player)
            player:AddHearts(1)
            player:AddBlackHearts(1)
        end,
    }
    ENUM_HEARTS[FiendFolio.PICKUP.VARIANT.IMMORAL_HEART] = {
        Color = ENUM_IMMORALHEART_COL,
        TestFunc = function(player)
            return player:CanPickSoulHearts()
        end,
        AddFunc = function(player)
            FiendFolio:AddImmoralHearts(player, 1)
        end,
    }
    ENUM_HEARTS[FiendFolio.PICKUP.VARIANT.HALF_IMMORAL_HEART] = {
        Color = ENUM_IMMORALHEART_COL,
        TestFunc = function(player)
            return player:CanPickSoulHearts()
        end,
        AddFunc = function(player)
            FiendFolio:AddImmoralHearts(player, 1)
        end,
    }
    ENUM_HEARTS[FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART] = {
        Color = ENUM_IMMORALHEART_COL,
        TestFunc = function(player)
            return (player:CanPickRedHearts() or player:CanPickSoulHearts())
        end,
        AddFunc = function(player)
            player:AddHearts(1)
            FiendFolio:AddImmoralHearts(player, 1)
        end,
    }
    ENUM_HEARTS[FiendFolio.PICKUP.VARIANT.MORBID_HEART] = {
        Color = ENUM_MORBIDHEART_COL,
        TestFunc = function(player)
            return player:CanPickRottenHearts()
        end,
        AddFunc = function(player)
            FiendFolio:AddMorbidHearts(player, 1)
        end,
    }
    ENUM_HEARTS[FiendFolio.PICKUP.VARIANT.TWOTHIRDS_MORBID_HEART] = {
        Color = ENUM_MORBIDHEART_COL,
        TestFunc = function(player)
            return player:CanPickRottenHearts()
        end,
        AddFunc = function(player)
            FiendFolio:AddMorbidHearts(player, 1)
        end,
    }
    ENUM_HEARTS[FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART] = {
        Color = ENUM_MORBIDHEART_COL,
        TestFunc = function(player)
            return player:CanPickRottenHearts()
        end,
        AddFunc = function(player)
            FiendFolio:AddMorbidHearts(player, 1)
        end,
    }
end

---@param player EntityPlayer
local function postAddItem(_, item, _, firstTime, _, _, player)
    if(firstTime~=true) then return end
    if(not player:HasCollectible(mod.COLLECTIBLE_CARAMEL_APPLE)) then return end

    local config = Isaac.GetItemConfig():GetCollectible(item)
    if(config==nil) then return end

    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_CARAMEL_APPLE)

    local addedHearts = {}
    
    if(config.AddHearts>0 and player:CanPickRedHearts() and rng:RandomFloat()<ENUM_BONUSHEALTH_CHANCE) then
        player:AddHearts(1)
        addedHearts[#addedHearts+1] = ENUM_REDHEART_COL
    end
    if(config.AddSoulHearts>0 and player:CanPickSoulHearts() and rng:RandomFloat()<ENUM_BONUSHEALTH_CHANCE) then
        player:AddSoulHearts(1)
        addedHearts[#addedHearts+1] = ENUM_SOULHEART_COL
    end
    if(config.AddBlackHearts>0 and player:CanPickBlackHearts() and rng:RandomFloat()<ENUM_BONUSHEALTH_CHANCE) then
        player:AddBlackHearts(1)
        addedHearts[#addedHearts+1] = ENUM_BLACKHEART_COL
    end

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
--mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem)

---@param pickup EntityPickup
---@param player EntityPlayer?
local function collideWithHearts(_, pickup, player)
    if(not (player and player:ToPlayer() and player:ToPlayer():HasCollectible(mod.COLLECTIBLE_CARAMEL_APPLE))) then return end
    player = player:ToPlayer()

    local data = mod:getDataTable(player)

    if((pickup.Variant==10 and ENUM_HEARTS[pickup.SubType]) or (pickup.Variant>12 and ENUM_HEARTS[pickup.Variant])) then
        data.CARAMEL_APPLE_DATA = data.CARAMEL_APPLE_DATA or {}
        data.CARAMEL_APPLE_DATA[#data.CARAMEL_APPLE_DATA+1] = (pickup.Variant==10 and pickup.SubType or pickup.Variant)
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.EARLY, collideWithHearts)

---@param player EntityPlayer
local function addHeartEffects(_, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_CARAMEL_APPLE)) then return end
    local hpData = mod:getData(player, "CARAMEL_APPLE_DATA") or {}

    local addedHearts = {}

    for k, st in pairs(hpData) do
        local hTable = ENUM_HEARTS[st]
        if(hTable) then
            if(hTable.TestFunc(player) and player:GetCollectibleRNG(mod.COLLECTIBLE_CARAMEL_APPLE):RandomFloat()<ENUM_BONUSHEALTH_CHANCE) then
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

    mod:setData(player, "CARAMEL_APPLE_DATA", hpData)

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
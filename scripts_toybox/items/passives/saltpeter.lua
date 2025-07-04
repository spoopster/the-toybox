
local sfx = SFXManager()

local AOE_DMG_MULT = 0.5
local AOE_RADIUS = 40*2

local EXPLODE_CHANCE = 0.05
local EXPLODE_STACK_CHANCE = 0.05
local EXPLODE_DMG = 30
local EXPLODE_COLOR = Color(1.25,1.25,1.2,1,0.12,0.12,0.09)

---@param ent Entity
local function dealAOEdmg(_, ent, dmg, flags, source, cooldown)
    if(flags & DamageFlag.DAMAGE_CLONES ~= 0) then return end

    local numSaltpeters = PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_SALTPETER)
    if(numSaltpeters<=0) then return end

    local dmgMult = AOE_DMG_MULT*numSaltpeters
    for _, near in ipairs(Isaac.FindInRadius(ent.Position, AOE_RADIUS, EntityPartition.ENEMY)) do
        if(GetPtrHash(near)~=GetPtrHash(ent)) then
            near:TakeDamage(dmg*dmgMult, flags | DamageFlag.DAMAGE_CLONES, source, cooldown)
            near:SetColor(EXPLODE_COLOR, 10, 5, true, false)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, dealAOEdmg)


---@param player EntityPlayer
local function getTriggerChance(player, chancemult)
    local itemNum = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SALTPETER)
    if(itemNum<=0) then return 0 end
    return chancemult*math.min(1, EXPLODE_CHANCE+(itemNum-1)*EXPLODE_STACK_CHANCE)
end

---@param ent Entity
local function saltpeterExplode(_, ent, amount, flags, ref, frames)
    if(flags & DamageFlag.DAMAGE_CLONES ~= 0) then return end
    if(not (ref.Entity and ToyboxMod:getEntityData(ref.Entity, "SALTPETER_EXPLODE"))) then return end

    Isaac.Explode(ent.Position, nil, EXPLODE_DMG)
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, saltpeterExplode)

--#region --! TEARS

---@param tear EntityTear
---@param player EntityPlayer
local function saltFireTear(_, tear, player, isLudo)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_SALTPETER)) then return end
    local rng = player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_SALTPETER)

    if(rng:RandomFloat()>=getTriggerChance(player, (isLudo and 0.75 or 1))) then return end

    tear.Color = EXPLODE_COLOR
    ToyboxMod:setEntityData(tear, "SALTPETER_EXPLODE", true)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, saltFireTear)

local function resetLudoData(_, tear)
    ToyboxMod:setEntityData(tear, "SALTPETER_EXPLODE", false)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.RESET_LUDOVICO_DATA, resetLudoData)

--#endregion

--#region --! BOMBS

---@param bomb EntityBomb
---@param player EntityPlayer
local function saltFireBomb(_, bomb, player)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_SALTPETER)) then return end
    local rng = player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_SALTPETER)

    if(rng:RandomFloat()>=getTriggerChance(player, 1.5)) then return end

    bomb.Color = EXPLODE_COLOR
    ToyboxMod:setEntityData(bomb, "SALTPETER_EXPLODE", true)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_BOMB, saltFireBomb)

---@param bomb EntityBomb
---@param player EntityPlayer
local function saltBombExplode(_, bomb, player, isIncubus)
    if(not ToyboxMod:getEntityData(bomb, "SALTPETER_EXPLODE")) then return end

    Isaac.Explode(bomb.Position, player, EXPLODE_DMG)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_PLAYER_BOMB_DETONATE, saltBombExplode)

---@param bomb EntityBomb
---@param ogbomb EntityBomb
local function saltCopyScatterData(_, bomb, ogbomb)
    ToyboxMod:setEntityData(bomb, "SALTPETER_EXPLODE", ToyboxMod:getEntityData(ogbomb, "SALTPETER_EXPLODE"))
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.COPY_SCATTER_BOMB_DATA, saltCopyScatterData)

--#endregion

--#region --! ROCKETS

---@param rocket EntityEffect
---@param player EntityPlayer
local function saltFireRocket(_, rocket, player)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_SALTPETER)) then return end
    local rng = player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_SALTPETER)

    if(rng:RandomFloat()>=getTriggerChance(player, 1.5)) then return end

    ToyboxMod:setEntityData(rocket, "SALTPETER_EXPLODE", true)
    ToyboxMod:setEntityData(rocket, "EXPLOSION_COLOR", EXPLODE_COLOR)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_ROCKET, saltFireRocket)
---@param rocket EntityEffect
---@param target EntityEffect
local function saltCopyTargetData(_, rocket, target)
    ToyboxMod:setEntityData(rocket, "SALTPETER_EXPLODE", ToyboxMod:getEntityData(target, "SALTPETER_EXPLODE"))
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.ROCKET_COPY_TARGET_DATA, saltCopyTargetData)

---@param rocket EntityEffect
---@param player EntityPlayer
local function saltRocketExplode(_, rocket, expl, player)
    if(not ToyboxMod:getEntityData(rocket, "SALTPETER_EXPLODE")) then return end
    if(not (rocket.Position:Distance(expl.Position)<0.01)) then return end

    Isaac.Explode(bomb.Position, player, EXPLODE_DMG)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_ROCKET_EXPLODE, saltRocketExplode)

--#endregion

--#region --! LASER/KNIFE

---@param player EntityPlayer
---@param ent Entity
local function postLaserDamage(_, dmgtype, player, ent, dmg, flags)
    if(not (dmgtype==ToyboxMod.DAMAGE_TYPE.LASER or dmgtype==ToyboxMod.DAMAGE_TYPE.KNIFE)) then return end

    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_SALTPETER)) then return end
    local rng = player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_SALTPETER)
    if(rng:RandomFloat()>=getTriggerChance(player, 0.8)) then return end

    Isaac.Explode(bomb.Position, player, EXPLODE_DMG)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_PLAYER_EXTRA_DMG, postLaserDamage)

--#endregion
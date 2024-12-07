local mod = MilcomMOD

local TINTED_COLOR = Color(0.9,0.8,0.9,1,0,0,0,0.6,0.49,0.72,0.6)

local TINTED_MORPHS = {
    {
        ORIGINAL = {{5,10,0}}, -- hearts
        MORPH = {{5,10,6, 1.0}},  -- black heart
    },
    {
        ORIGINAL = {{5,30,0}}, -- keys
        MORPH = {{5,40,3, 0.55}, {5,70,0, 0.45}}, -- troll bombs / pills
    },
    {
        ORIGINAL = {{5,60,0},{5,50,0}}, -- chests
        MORPH = {{5,360,0, 1.0}}, -- red chest
    },
    {
        ORIGINAL = {{5,100,0}}, -- item
        MORPH = {{5,100,mod.COLLECTIBLE_OBSIDIAN_CHUNK, 1.0}}, -- obsidian chunk
    },
}

local BLEED_DURATION = math.floor(30*3)

local BLEED_CHANCE = 0.075
local BLEED_MAXCHANCE = 0.2
local BLEED_MAXLUCK = 18

local SHARD_TEARCOLOR = Color(0.9,0.8,0.9,1)
SHARD_TEARCOLOR:SetColorize(0.6,0.49,0.72,0.6)

--#region  The tinted rock part
local function getMorph(ent, rng)
    for _, data in ipairs(TINTED_MORPHS) do
        local passThis = true
        for _, pData in ipairs(data.ORIGINAL) do
            if((pData[1]==0 or ent.Type==pData[1]) and (pData[2]==0 or ent.Variant==pData[2]) and (pData[3]==0 or ent.SubType==pData[3])) then
                passThis = false
            end
        end

        if(not passThis) then
            local maxWeight = 0
            for _, pData in ipairs(data.MORPH) do maxWeight = maxWeight+pData[4] end

            local selWeight = rng:RandomFloat()*maxWeight
            local curWeight = 0
            for _, pData in ipairs(data.MORPH) do
                curWeight = curWeight+pData[4]
                if(selWeight<curWeight) then return pData end
            end
        end
    end

    return TINTED_MORPHS[1].MORPH[1]
end

---@param rock GridEntityRock
local function rockUpdate(_, rock)
    if(PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_OBSIDIAN_SHARD) and rock:GetType()==GridEntityType.GRID_ROCKT) then
        if(mod:getGridEntityData(rock, "DARK_TINTED_ROCK")~=true) then
            mod:setGridEntityData(rock, "DARK_TINTED_ROCK", true)
        end
    end
    if(mod:getGridEntityData(rock, "DARK_TINTED_ROCK")==true) then
        local sp = rock:GetSprite()
        if(sp.Color.R ~= TINTED_COLOR.R) then
            sp.Color = TINTED_COLOR
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_ROCK_UPDATE, rockUpdate)

---@param rock GridEntityRock
local function destroyTintedRock(_, rock, type, immediate)
    if(mod:getGridEntityData(rock, "DARK_TINTED_ROCK")~=true) then return end

    local rng = mod:generateRng(rock:GetSaveState().SpawnSeed)
    for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
        if(pickup.Position:Distance(rock.Position)<10 and pickup.FrameCount==0) then
            local newData = getMorph(pickup, rng)
            pickup:ToPickup():Morph(newData[1], newData[2], newData[3])
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, destroyTintedRock, GridEntityType.GRID_ROCKT)

--#region OBSIDIAN SPIDER LOGIC

---@param ent EntityNPC
local function tintedSpiderUpdate(_, ent)
    if(ent.Variant~=1) then return end

    if(ent.FrameCount==1 and PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_OBSIDIAN_SHARD)) then mod:setEntityData(ent, "OBSIDIAN_SPIDER", true) end
    local isObsSpider = mod:getEntityData(ent, "OBSIDIAN_SPIDER")

    if(isObsSpider) then
        if(ent.FrameCount==1) then
            local sp = ent:GetSprite()
            sp:ReplaceSpritesheet(0, "gfx/enemies/tb_obsidian_spider.png")
            sp:LoadGraphics()
            
            local newCol = Color(TINTED_COLOR.R,TINTED_COLOR.G,TINTED_COLOR.B)
            newCol:SetColorize(1,1,1,1)
            ent.SplatColor = newCol
        end
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, tintedSpiderUpdate, EntityType.ENTITY_ROCK_SPIDER)

local function preTintedSpiderUpdate(_, ent)
    if(ent.Variant~=1) then return end

    if(ent.FrameCount==1 and PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_OBSIDIAN_SHARD)) then mod:setEntityData(ent, "OBSIDIAN_SPIDER", true) end
    local isObsSpider = mod:getEntityData(ent, "OBSIDIAN_SPIDER")

    if(isObsSpider and ent:IsDead()) then
        local blackHeart = Isaac.Spawn(5,10,6,ent.Position,ent.Velocity,ent):ToPickup()

        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preTintedSpiderUpdate, EntityType.ENTITY_ROCK_SPIDER)

--#endregion

--#endregion

local function getTriggerChance(luckval, chancemult)
    return mod:getLuckAffectedChance(luckval, BLEED_CHANCE*chancemult, BLEED_MAXLUCK/chancemult, BLEED_MAXCHANCE)
end

---@param ent Entity
local function applyShardBleed(_, ent, amount, flags, ref, frames)
    if(not (ref.Entity and mod:getEntityData(ref.Entity, "OBSIDIAN_SHARD_TEAR"))) then return end

    ent:AddBleeding(ref, math.max(0, BLEED_DURATION-ent:GetBleedingCountdown()))
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, applyShardBleed)

---@param tear EntityTear
---@param player EntityPlayer
local function shardFireTear(_, tear, player, isLudo)
    if(not player:HasCollectible(mod.COLLECTIBLE_OBSIDIAN_SHARD)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_OBSIDIAN_SHARD)

    if(rng:RandomFloat()>=getTriggerChance(player.Luck, (isLudo and 0.75 or 1))) then return end

    tear.Color = SHARD_TEARCOLOR
    mod:setEntityData(tear, "OBSIDIAN_SHARD_TEAR", true)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, shardFireTear)
local function resetLudoData(_, tear)
    mod:setEntityData(tear, "OBSIDIAN_SHARD_TEAR", false)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.RESET_LUDOVICO_DATA, resetLudoData)

---@param bomb EntityBomb
---@param player EntityPlayer
local function shardFireBomb(_, bomb, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_OBSIDIAN_SHARD)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_OBSIDIAN_SHARD)

    if(rng:RandomFloat()>=getTriggerChance(player.Luck, 1.5)) then return end

    bomb.Color = SHARD_TEARCOLOR
    mod:setEntityData(bomb, "OBSIDIAN_SHARD_TEAR", true)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_BOMB, shardFireBomb)

---@param rocket EntityEffect
---@param player EntityPlayer
local function shardFireRocket(_, rocket, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_OBSIDIAN_SHARD)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_OBSIDIAN_SHARD)

    if(rng:RandomFloat()>=getTriggerChance(player.Luck, 1.5)) then return end

    mod:setEntityData(rocket, "OBSIDIAN_SHARD_TEAR", true)
    mod:setEntityData(rocket, "EXPLOSION_COLOR", SHARD_TEARCOLOR)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_ROCKET, shardFireRocket)
---@param rocket EntityEffect
---@param target EntityEffect
local function shardCopyTargetData(_, rocket, target)
    mod:setEntityData(rocket, "OBSIDIAN_SHARD_TEAR", mod:getEntityData(target, "OBSIDIAN_SHARD_TEAR"))
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.ROCKET_COPY_TARGET_DATA, shardCopyTargetData)

---@param player EntityPlayer
---@param ent Entity
local function laserKnifeDamage(_, dmgtype, player, ent)
    if(not (dmgtype==mod.DAMAGE_TYPE.LASER or dmgtype==mod.DAMAGE_TYPE.KNIFE)) then return end

    if(not player:HasCollectible(mod.COLLECTIBLE_OBSIDIAN_SHARD)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_OBSIDIAN_SHARD)
    if(rng:RandomFloat()>=getTriggerChance(player.Luck, 0.8)) then return end

    ent:AddBleeding(EntityRef(player), math.max(0, BLEED_DURATION-ent:GetBleedingCountdown()))
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_EXTRA_DMG, laserKnifeDamage)
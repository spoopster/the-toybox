local mod = ToyboxMod
local sfx = SFXManager()

--* needs some polish

local BONE_NUM = 8
local BONE_SPEED = 12
local BONE_DMG = 5
local BONESPUR_SPAWNCHANCE = 0.10
local MISSINGMANTLES_TEARS = 0.6

--! REGULAR MANTLE
---@param player EntityPlayer
local function spawnBoney(_, player, mantle)
    if(not mod:isAtlasA(player)) then return end

    local bone = Isaac.Spawn(227,0,0,Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true),Vector.Zero,player):ToNPC()
    bone:AddCharmed(EntityRef(player),-1)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, spawnBoney, mod.MANTLE_DATA.BONE.ID)

local function mantleKill(_, entity)
    if(entity.MaxHitPoints<1) then return end
    if(not entity:IsEnemy()) then return end
    if(not mod:isAnyPlayerAtlasA()) then return end

    local rng = entity:GetDropRNG()
    local numTransformations = 0
    local allAtlas = mod:getAllAtlasA()

    local randAtlas = allAtlas[rng:RandomInt(#allAtlas)+1]:ToPlayer()
    for _, p in ipairs(allAtlas) do
        numTransformations = numTransformations+mod:getNumMantlesByType(p:ToPlayer(), mod.MANTLE_DATA.BONE.ID)/mod:getAtlasAData(p:ToPlayer(), "HP_CAP")
    end

    if(rng:RandomFloat()<BONESPUR_SPAWNCHANCE*numTransformations/Game():GetNumPlayers()) then
        randAtlas:AddBoneOrbital(entity.Position)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mantleKill)

--! TRANSFORMATION
---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not mod:isAtlasA(player)) then return end
    if(not mod:atlasHasTransformation(player, mod.MANTLE_DATA.BONE.ID)) then return end
    local data = mod:getAtlasATable(player)
    local numMantlesMissing = data.HP_CAP-mod:getRightmostMantleIdx(player)

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(player, MISSINGMANTLES_TEARS*numMantlesMissing)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function mantleDamage(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    if(not mod:isAtlasA(player)) then return end
    if(not mod:atlasHasTransformation(player, mod.MANTLE_DATA.BONE.ID)) then return end

    local rng = player:GetCardRNG(mod.CONSUMABLE.MANTLE_BONE)
    local bones = BONE_NUM*dmg
    for i=1, bones do
        local v = Vector(BONE_SPEED,0):Rotated(360*i/bones+(rng:RandomFloat()-1/2)*25)
        local boneTear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BONE, 0, player.Position,v,player):ToTear()
        boneTear.CollisionDamage = BONE_DMG
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1e12-2+(CustomHealthAPI and (-1e12-1e3) or 0), mantleDamage, EntityType.ENTITY_PLAYER)
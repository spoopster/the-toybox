
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
    if(not ToyboxMod:isAtlasA(player)) then return end

    local bone = Isaac.Spawn(227,0,0,Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true),Vector.Zero,player):ToNPC()
    bone:AddCharmed(EntityRef(player),-1)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, spawnBoney, ToyboxMod.MANTLE_DATA.BONE.ID)

local function mantleKill(_, entity)
    if(entity.MaxHitPoints<1) then return end
    if(not entity:IsEnemy()) then return end
    if(not ToyboxMod:isAnyPlayerAtlasA()) then return end

    local rng = entity:GetDropRNG()
    local numTransformations = 0
    local allAtlas = ToyboxMod:getAllAtlasA()

    local randAtlas = allAtlas[rng:RandomInt(#allAtlas)+1]:ToPlayer()
    for _, p in ipairs(allAtlas) do
        numTransformations = numTransformations+ToyboxMod:getNumMantlesByType(p:ToPlayer(), ToyboxMod.MANTLE_DATA.BONE.ID)/ToyboxMod:getAtlasAData(p:ToPlayer(), "HP_CAP")
    end

    if(rng:RandomFloat()<BONESPUR_SPAWNCHANCE*numTransformations/Game():GetNumPlayers()) then
        randAtlas:AddBoneOrbital(entity.Position)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mantleKill)

--! TRANSFORMATION
---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not ToyboxMod:isAtlasA(player)) then return end
    if(not ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.BONE.ID)) then return end
    local data = ToyboxMod:getAtlasATable(player)
    local numMantlesMissing = data.HP_CAP-ToyboxMod:getRightmostMantleIdx(player)

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(player, MISSINGMANTLES_TEARS*numMantlesMissing)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function mantleDamage(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    if(not ToyboxMod:isAtlasA(player)) then return end
    if(not ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.BONE.ID)) then return end

    local rng = player:GetCardRNG(ToyboxMod.CONSUMABLE.MANTLE_BONE)
    local bones = BONE_NUM*dmg
    for i=1, bones do
        local v = Vector(BONE_SPEED,0):Rotated(360*i/bones+(rng:RandomFloat()-1/2)*25)
        local boneTear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BONE, 0, player.Position,v,player):ToTear()
        boneTear.CollisionDamage = BONE_DMG
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1e12-2+(CustomHealthAPI and (-1e12-1e3) or 0), mantleDamage, EntityType.ENTITY_PLAYER)
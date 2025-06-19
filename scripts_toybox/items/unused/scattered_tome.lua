

local NUM_TOMES = 1
local PAPER_SPAWN_FREQ = 90
local PAPER_SPAWN_FREQ_BFFS = 65
local PAPER_TEAR_DMG = 5
local PAPER_TEAR_HOMESPEED = 10
local PAPER_TEAR_SPAWNSPEED = 4

local BLOCK_PROJ_PAPERNUM = 1
local BLOCK_PROJ_PAPERNUM_BFFS = 2
local PAPER_TEAR_BLOCKSPEED = 8
local PAPER_TEAR_BLOCKARC = 40

local ANGLE_SPEED = 2.3
local ORBIT_DIST = Vector(60,45)

local function spawnPaper(fam, vel)
    local paper = Isaac.Spawn(EntityType.ENTITY_TEAR, ToyboxMod.TEAR_VARIANT.PAPER, 0, fam.Position, vel, fam):ToTear()
    paper.FallingAcceleration = -0.075
    paper:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    paper.CollisionDamage = PAPER_TEAR_DMG

    return paper
end

---@param player EntityPlayer
local function checkFamiliars(_, player, cacheFlag)
    player:CheckFamiliar(
        ToyboxMod.FAMILIAR_VARIANT.TOME,
        NUM_TOMES*(player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SCATTERED_TOME)+player:GetEffects():GetCollectibleEffectNum(ToyboxMod.COLLECTIBLE_SCATTERED_TOME)),
        player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_SCATTERED_TOME),
        Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_SCATTERED_TOME)
    )
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_SCATTERED_TOME)) then
        local tomes = {}
        local plaerHash = GetPtrHash(player)
        for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_VARIANT.TOME)) do
            if(GetPtrHash(ent:ToFamiliar().Player)==plaerHash) then table.insert(tomes, ent) end
        end

        for i, tome in ipairs(tomes) do
            if(not ToyboxMod:getEntityData(tome, "STUPID_POS")) then
                ToyboxMod:setEntityData(tome, "TOME_ANGLE_OFFSET", 360*i/#tomes)
                ToyboxMod:setEntityData(tome, "TOME_ANGLE", 0)
                ToyboxMod:setEntityData(tome, "TOME_FRAMES", 0)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, checkFamiliars, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function postTomeInit(_, familiar)
    local sprite = familiar:GetSprite()
    sprite:Play("Idle", true)
    sprite.Offset = Vector(0, -22)

    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    local data = ToyboxMod:getEntityDataTable(familiar)

    data.TOME_ANGLE = 0
    data.TOME_ANGLE_OFFSET = 0
    data.TOME_FRAMES = 0
    data.STUPID_POS = false
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, postTomeInit, ToyboxMod.FAMILIAR_VARIANT.TOME)

---@param familiar EntityFamiliar
local function postTomeUpdate(_, familiar)
    local data = ToyboxMod:getEntityDataTable(familiar)
    local player = (familiar.Player or Isaac.GetPlayer()):ToPlayer()

    local hasBffs = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    local hasSpin2Win = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIN_TO_WIN)>0

    if(hasSpin2Win) then
        local shouldTint = (math.sin(math.rad(familiar.FrameCount*40))+1)/2
        local tint = 0.4*shouldTint
        familiar:SetColor(Color(1,1,1,1,tint,tint,tint),2,1,false,false)
    end

    if(data.STUPID_POS) then
        familiar.Velocity = Vector.Zero
        familiar.Position = Vector.FromAngle(data.TOME_ANGLE+(data.TOME_ANGLE_OFFSET or 0))*ORBIT_DIST+player.Position+player.Velocity
        data.STUPID_POS = false
    else
        data.TOME_ANGLE = (data.TOME_ANGLE or 0)+ANGLE_SPEED*(hasSpin2Win and 5 or 1)
        local pos = Vector.FromAngle(data.TOME_ANGLE+(data.TOME_ANGLE_OFFSET or 0))*ORBIT_DIST+player.Position+player.Velocity
        familiar.Velocity = ToyboxMod:lerp(familiar.Velocity, pos-familiar.Position, 0.75)
    end

    familiar.SpriteRotation = data.TOME_ANGLE+(data.TOME_ANGLE_OFFSET or 0)

    local spawnFreq = (hasBffs and PAPER_SPAWN_FREQ_BFFS or PAPER_SPAWN_FREQ)
    if((data.TOME_FRAMES or 0)>0 and (data.TOME_FRAMES+math.floor(spawnFreq*(data.TOME_ANGLE_OFFSET or 0)/360))%spawnFreq==0) then
        spawnPaper(familiar, (familiar.Position-player.Position):Resized(PAPER_TEAR_SPAWNSPEED))
    end

    for _, proj in ipairs(Isaac.FindInRadius(familiar.Position, familiar.Size+2, EntityPartition.BULLET)) do
        for _=1, (hasBffs and BLOCK_PROJ_PAPERNUM_BFFS or BLOCK_PROJ_PAPERNUM) do
            spawnPaper(familiar, proj.Velocity:Resized(PAPER_TEAR_BLOCKSPEED):Rotated(familiar:GetDropRNG():RandomInt(PAPER_TEAR_BLOCKARC)-PAPER_TEAR_BLOCKARC/2))
        end

        proj:Die()
    end

    data.TOME_FRAMES = (data.TOME_FRAMES or 0)+1
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, postTomeUpdate, ToyboxMod.FAMILIAR_VARIANT.TOME)

local function doShittyPosStuffToMakeItNotJitterIHateYouStupidGame(_)
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_VARIANT.TOME)) do
        ToyboxMod:setEntityData(ent, "STUPID_POS", true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, doShittyPosStuffToMakeItNotJitterIHateYouStupidGame)

---@param tear EntityTear
local function paperTearUpdate(_, tear)
    local nearestEnemy = ToyboxMod:closestEnemy(tear.Position)
    local vel
    if(nearestEnemy==nil) then vel=Vector.Zero
    else vel=(nearestEnemy.Position-tear.Position):Resized(PAPER_TEAR_HOMESPEED) end

    tear.Velocity = ToyboxMod:lerp(tear.Velocity, vel, 0.04)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, paperTearUpdate, ToyboxMod.TEAR_VARIANT.PAPER)
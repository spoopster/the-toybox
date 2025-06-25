

local GRID_SIZE = 40

local QUAKE_TIMER = 6
local QUAKE_LAYERS = 2

local FETUS_QUAKE_CHANCE = 0.25

---@param bomb EntityBomb
local function replaceAnm2(bomb)
    if(not ToyboxMod:getEntityData(bomb, "QUAKE_BOMB")) then return end

    local sp = bomb:GetSprite()
    
    local name = sp:GetFilename()
    name = string.gsub(name, "gfx_tb/items/pick ups/bombs/", "")
    name = string.gsub(name, ".anm2", "")

    if(string.sub(name,1,-2)=="bomb") then
        sp:ReplaceSpritesheet(0, "gfx_tb/bombs/quake_bomb.png", true)
    end
end

---@param pl EntityPlayer
---@param bomb EntityBomb
local function fireQuakeBomb(_, bomb, pl, isScatter)
    if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_QUAKE_BOMBS) and not isScatter) then
        if(pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_QUAKE_BOMBS):RandomFloat()<FETUS_QUAKE_CHANCE) then
            ToyboxMod:setEntityData(bomb, "QUAKE_BOMB", true)
            if(pl:HasCollectible(CollectibleType.COLLECTIBLE_BOMBER_BOY)) then
                ToyboxMod:setEntityData(bomb, "QUAKE_BOMBER_BOY", true)
            end
            replaceAnm2(bomb)
        end
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_BOMB, fireQuakeBomb)
---@param bomb EntityBomb
---@param ogbomb EntityBomb
local function copyQuakeData(_, bomb, ogbomb)
    ToyboxMod:setEntityData(bomb, "QUAKE_BOMB", ToyboxMod:getEntityData(ogbomb, "QUAKE_BOMB"))
    ToyboxMod:setEntityData(bomb, "QUAKE_BOMBER_BOY", ToyboxMod:getEntityData(ogbomb, "QUAKE_BOMBER_BOY"))
    replaceAnm2(bomb)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.COPY_SCATTER_BOMB_DATA, copyQuakeData)

---@param pl EntityPlayer
---@param bomb EntityBomb
local function placeQuakeBomb(_, pl, bomb)
    if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_QUAKE_BOMBS)) then
        ToyboxMod:setEntityData(bomb, "QUAKE_BOMB", true)
        if(pl:HasCollectible(CollectibleType.COLLECTIBLE_BOMBER_BOY)) then
            ToyboxMod:setEntityData(bomb, "QUAKE_BOMBER_BOY", true)
        end
        replaceAnm2(bomb)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, placeQuakeBomb)

local destrucibleGrids = {
    [GridEntityType.GRID_ROCK] = true,
    [GridEntityType.GRID_ROCKT] = true,
    [GridEntityType.GRID_ROCK_BOMB] = true,
    [GridEntityType.GRID_ROCK_ALT] = true,
    [GridEntityType.GRID_TNT] = true,
    [GridEntityType.GRID_ROCK_SS] = true,
    [GridEntityType.GRID_ROCK_SPIKED] = true,
    [GridEntityType.GRID_ROCK_ALT2] = true,
    [GridEntityType.GRID_ROCK_GOLD] = true,
    [GridEntityType.GRID_POOP] = true,
}
local function isDestructibleGrid(index)
    local room = Game():GetRoom()

    local grid = room:GetGridEntity(index)
    if(not grid) then return false end
    if(grid and grid:ToRock() and grid.State==2) then return false end
    return (destrucibleGrids[grid:GetType()]==true)
end
local function squareIntersectCircle(pos, radius, posSq)
    local rotAngle = Vector(1,1)*GRID_SIZE/2

    for i=0, 3 do
        rotAngle = rotAngle:Rotated(90)
        if(pos:DistanceSquared(posSq+rotAngle)<=radius*radius) then
            return true
        end
    end
    return false
end

local function destroyQuakedGrids(timer)
    local quakeLayers = ToyboxMod:getEntityData(timer, "QUAKE_TIMER_LAYERS")
    if(not quakeLayers) then return end

    local room = Game():GetRoom()
    local currentLayer = (timer.FrameCount//QUAKE_TIMER)
	--print(currentLayer)
    if(currentLayer<=0) then return end

    quakeLayers[currentLayer] = {}
    if(#quakeLayers[currentLayer-1]==0) then return end

    for _, quakedIndex in ipairs(quakeLayers[currentLayer-1]) do
        local quakedPosition = room:GetGridPosition(quakedIndex)
        for dir=0,3 do
            local indexToQuake = room:GetGridIndex(quakedPosition+Vector.FromAngle(dir*90)*GRID_SIZE)
            if(not quakeLayers.INVALID[indexToQuake] and isDestructibleGrid(indexToQuake)) then
                local grid = room:GetGridEntity(indexToQuake)
                if(grid:Destroy()) then
                    if(grid:ToRock()) then
                        GridEntityRock.SpawnDrops(grid.Position, grid:GetType(), grid:GetVariant(), math.max(Random(), 1), true, room:GetBackdropType())
                        grid:ToRock():RegisterRockDestroyed(grid:GetType())
                    end
                    table.insert(quakeLayers[currentLayer], indexToQuake)
                end
            end
            quakeLayers.INVALID[indexToQuake] = 1
        end
    end
    ToyboxMod:setEntityData(timer, "QUAKE_TIMER_LAYERS", quakeLayers)
end

local function updateStoredGrids()
    local grids = {}

    local room = Game():GetRoom()
    local maxIdx = room:GetGridWidth()*room:GetGridHeight()-1

    for i=0, maxIdx do
        local gridEnt = room:GetGridEntity(i)
        grids[i] = GridEntityType.GRID_NULL
        if(gridEnt) then
            if(gridEnt:ToRock() and gridEnt.State==2) then
                grids[i] = GridEntityType.GRID_NULL
            else
                grids[i] = gridEnt:GetType()
            end
        end
    end
    ToyboxMod:setExtraData("QUAKEBOMBS_GRIDS", grids)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, updateStoredGrids)

---@param bomb EntityBomb
local function quakeBombUpdate(_, bomb)
    if(not ToyboxMod:getEntityData(bomb, "QUAKE_BOMB")) then return end
    
    Game():ShakeScreen(10)

    local quakeLayers = {[0]={}, ["INVALID"]={}}
    local bombRadius = ToyboxMod:getBombRadius(bomb)

    local room = Game():GetRoom()
    local function getInitialGridsToDestroy(pos)
        local gridsRadius = math.ceil(bombRadius/40)
        local gridAlignedPos = room:GetGridPosition(room:GetGridIndex(pos))
        local previousGrids = ToyboxMod:getExtraData("QUAKEBOMBS_GRIDS") or {}

        for x=-gridsRadius, gridsRadius do
            for y=-gridsRadius, gridsRadius do
                local quakePos = gridAlignedPos+Vector(x,y)*40
                local quakeIndex = room:GetGridIndex(quakePos)
                if(not quakeLayers.INVALID[quakeIndex] and squareIntersectCircle(gridAlignedPos, bombRadius, quakePos)) then
                    if(destrucibleGrids[previousGrids[quakeIndex] or 0]) then
                        local grid = room:GetGridEntity(quakeIndex)
                        grid:Destroy()
                        if(grid:ToRock()) then
                            GridEntityRock.SpawnDrops(grid.Position, grid:GetType(), grid:GetVariant(), math.max(Random(), 1), true, room:GetBackdropType())
                            grid:ToRock():RegisterRockDestroyed(grid:GetType())
                        end
                        table.insert(quakeLayers[0], quakeIndex)
                        quakeLayers.INVALID[quakeIndex] = true
                    end
                end
            end
        end
    end

    getInitialGridsToDestroy(bomb.Position)
    if(ToyboxMod:getEntityData(bomb, "QUAKE_BOMBER_BOY")) then
        for i=1, 2 do
            for j=0, 3 do
                getInitialGridsToDestroy(bomb.Position+Vector.FromAngle(j*90)*i*GRID_SIZE*1.5*bomb.RadiusMultiplier)
            end
        end
    end

    local timer = Isaac.CreateTimer(destroyQuakedGrids, QUAKE_TIMER, QUAKE_LAYERS, false)
    ToyboxMod:setEntityData(timer, "QUAKE_TIMER_LAYERS", quakeLayers)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_PLAYER_BOMB_DETONATE, quakeBombUpdate)
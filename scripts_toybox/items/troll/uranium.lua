

local ROCK_DECAY_RADIUS = 40*1.5
local ROCK_DECAY_DURATION = 50

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
    local rotAngle = Vector(1,1)*20

    for i=0, 3 do
        rotAngle = rotAngle:Rotated(90)
        if(pos:DistanceSquared(posSq+rotAngle)<=radius*radius) then
            return true
        end
    end
    return false
end

---@param pl EntityPlayer
local function decayRocks(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_URANIUM)) then return end

    ---ENEMY SMOG
    local plData = ToyboxMod:getEntityDataTable(pl)
    if(not (plData.SMOG_AURA and plData.SMOG_AURA:Exists())) then
        local aura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, pl.Position, pl.Velocity, pl):ToEffect()
        aura:FollowParent(pl)
        aura.Scale = ROCK_DECAY_RADIUS/40
        aura.SpriteScale = Vector(1,1)*aura.Scale

        plData.SMOG_AURA = aura
    end


    ---GRID SMOG
    local room = Game():GetRoom()
    local gridsRadius = math.ceil(ROCK_DECAY_RADIUS/40)
    local gridAlignedPos = room:GetGridPosition(room:GetGridIndex(pl.Position))

    for x=-gridsRadius, gridsRadius do
        for y=-gridsRadius, gridsRadius do
            local quakePos = gridAlignedPos+Vector(x,y)*40
            local rockIdx = room:GetGridIndex(quakePos)
            if(squareIntersectCircle(gridAlignedPos, ROCK_DECAY_RADIUS, quakePos) and isDestructibleGrid(rockIdx)) then
                local isVisibleRock = false
                for i=0, 3 do
                    if(room:CheckLine(gridAlignedPos, quakePos+Vector.FromAngle(i*90)*40,LineCheckMode.RAYCAST)) then
                        isVisibleRock = true
                        break
                    end
                end

                if(isVisibleRock) then
                    local grid = room:GetGridEntity(rockIdx)
                    local gridData = ToyboxMod:getGridEntityDataTable(grid)
                    gridData.DECAY_VAL = (gridData.DECAY_VAL or 0)+1

                    if(gridData.DECAY_VAL>=ROCK_DECAY_DURATION) then
                        if(grid:Destroy() and grid:ToRock()) then
                            grid:ToRock():RegisterRockDestroyed(grid:GetType())
                        end
                    end
                end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, decayRocks)

---@param grid GridEntity
local function postGridUpdate(_, grid)
    if(not ToyboxMod:getGridEntityData(grid, "DECAY_VAL")) then return end
    if(not isDestructibleGrid(grid:GetGridIndex())) then return end

    local decayIntensity = (ToyboxMod:getGridEntityData(grid, "DECAY_VAL")/ROCK_DECAY_DURATION)^5

    local decayColor = Color.Lerp(Color.Default, Color(0.7,1,0.7,1,0.1,0.3,0.1,0,0.5,0,1), decayIntensity)
    local pulseFreq = 4
    if(Game():GetFrameCount()%pulseFreq<pulseFreq/2) then
        decayColor = Color.Lerp(decayColor, Color(1,1,1,0,0,0,0,0,0,0,0), 0.25*decayIntensity)
    end

    grid:GetSprite():GetLayer("layer0"):SetColor(decayColor)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_ROCK_UPDATE, postGridUpdate)
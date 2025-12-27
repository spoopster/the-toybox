local NUM_FAMILIARS = 3

local WALL_CENTER_OFFSET = 18

local FIRE_COOLDOWN = 20
local TEAR_DMG = 4

local NUM_SPRITES = 18

---@param dir Direction
local function dirToVector(dir)
    local angle = 90
    if(dir==Direction.RIGHT) then angle = 0
    elseif(dir==Direction.LEFT) then angle = 180
    elseif(dir==Direction.UP) then angle = 270 end

    return Vector.FromAngle(angle)
end

---@param fam EntityFamiliar
local function pickRandomWallPos(fam)
    local rng = fam:GetDropRNG()

    local validIndexes = {}
    local room = Game():GetRoom()
    for i=0, room:GetGridSize()-1 do
        local pos = room:GetGridPosition(i)
        local coll = room:GetGridCollision(i)

        local isInRoomEdge = (room:IsPositionInRoom(pos, 0) and not room:IsPositionInRoom(pos, 30))
        if(isInRoomEdge) then
            local isValidColl = (coll==GridCollisionClass.COLLISION_NONE or coll==GridCollisionClass.COLLISION_PIT)
            if(isValidColl) then
                local isAdjacentToDoor = false
                local adjacents = {-1, -room:GetGridWidth(), 1, room:GetGridWidth()}
                for _, offset in ipairs(adjacents) do
                    local ent = room:GetGridEntity(i+offset)
                    if(ent and ent:ToDoor()) then
                        isAdjacentToDoor = true
                        break
                    end
                end

                if(not isAdjacentToDoor) then
                    local nearbyBoys = false
                    for _, otherfam in ipairs(Isaac.GetRoomEntities()) do
                        if(otherfam.Position:Distance(pos)<=(WALL_CENTER_OFFSET+5)) then
                            nearbyBoys = true
                            break
                        end
                    end

                    if(not nearbyBoys) then
                        table.insert(validIndexes, i)
                    end
                end
            end
        end
    end

    if(#validIndexes==0) then
        fam:Remove()
        return
    end

    fam.MoveDirection = validIndexes[rng:RandomInt(1, #validIndexes)]

    local adjacentdirections = {}
    local adjacents = {-1, -room:GetGridWidth(), 1, room:GetGridWidth()}
    local directions = {Direction.RIGHT, Direction.DOWN, Direction.LEFT, Direction.UP}
    for i, offset in ipairs(adjacents) do
        local coll = room:GetGridCollision(fam.MoveDirection+offset)
        if(coll==GridCollisionClass.COLLISION_WALL or coll==GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER) then
            table.insert(adjacentdirections, directions[i])
        end
    end

    fam.ShootDirection = adjacentdirections[rng:RandomInt(1,#adjacentdirections)]
    fam.Position = room:GetGridPosition(fam.MoveDirection)-dirToVector(fam.ShootDirection)*WALL_CENTER_OFFSET

    local sp = fam:GetSprite()
    local sheet = "gfx_tb/familiars/familiar_paper_plate_"..math.random(1,NUM_SPRITES)..".png"
    sp:ReplaceSpritesheet(0, sheet, false)
    sp:ReplaceSpritesheet(1, sheet, false)
    sp:LoadGraphics()

    sp:SetFrame("IdleDown", 0)
    fam:GetSprite():Stop()
end

---@param pl EntityPlayer
local function evalCache(_, pl)
    pl:CheckFamiliar(
        ToyboxMod.FAMILIAR_PAPER_PLATE,
        NUM_FAMILIARS*(pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_PAPER_PLATE)+pl:GetEffects():GetCollectibleEffectNum(ToyboxMod.COLLECTIBLE_PAPER_PLATE)),
        pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_PAPER_PLATE),
        Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_PAPER_PLATE)
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_FAMILIARS)

local function evalOnNewRoom(_)
    for _, pl in ipairs(PlayerManager.GetPlayers()) do
        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_PAPER_PLATE)) then
            pl:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        end
    end

    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_PAPER_PLATE)) do
        if(fam:ToFamiliar().Player.FrameCount==0 or (fam.FrameCount>0 and fam:Exists())) then
            pickRandomWallPos(fam:ToFamiliar())
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, evalOnNewRoom)

---@param fam EntityFamiliar
local function initPaperPlate(_, fam)
    fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    fam:RemoveFromFollowers()

    pickRandomWallPos(fam)
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, initPaperPlate, ToyboxMod.FAMILIAR_PAPER_PLATE)

---@param fam EntityFamiliar
local function updatePaperPlate(_, fam)
    local vDir = dirToVector(fam.ShootDirection)

    fam.Velocity = Vector.Zero
    fam.Position = Game():GetRoom():GetGridPosition(fam.MoveDirection)-vDir*WALL_CENTER_OFFSET
    fam.SpriteRotation = vDir:GetAngleDegrees()-90

    local sp = fam:GetSprite()
    local pl = fam.Player

    if(fam.FireCooldown<=0) then
        if(ToyboxMod:isPlayerShooting(pl)) then
            sp:SetFrame(1)

            local tear = pl:FireTear(fam.Position, vDir*10, true, true, false, fam, 1)
            tear.CollisionDamage = TEAR_DMG*fam:GetMultiplier()
            tear.FallingSpeed = tear.FallingSpeed-4
            tear.FallingAcceleration = tear.FallingAcceleration+0.01
            tear.Height = tear.Height+16
            tear.Scale = tear.Scale*0.8
            --tear.Velocity:Resize(10)

            fam.FireCooldown = FIRE_COOLDOWN
        end
    else
        fam.FireCooldown = fam.FireCooldown-(pl:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 2 or 1)
        fam.FireCooldown = math.max(fam.FireCooldown, 0)

        if(sp:GetFrame()==1 and fam.FireCooldown<=FIRE_COOLDOWN/2) then
            sp:SetFrame(0)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, updatePaperPlate, ToyboxMod.FAMILIAR_PAPER_PLATE)

local function rendertest()
    for _=1, 1000 do
        local room = Game():GetRoom()

        local margin1 = 0
        local margin2 = 20
        local point = nil
        while(not (point and not room:IsPositionInRoom(point, margin2))) do
            point = room:GetRandomPosition(margin1)
        end

        local pos = Isaac.WorldToRenderPosition(point)+room:GetRenderScrollOffset()

        Isaac.RenderText(tostring(room:GetGridIndex(point)), pos.X, pos.Y, 1,1,1,1)
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_POST_RENDER, rendertest)
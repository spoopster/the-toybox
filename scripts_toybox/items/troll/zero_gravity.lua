local mod = ToyboxMod

local DMG_UP = 1.5
local MOVE_DELAY = 60*2

local TRAIL_OFFSET = Vector(0,-1)

local CROSSHAIR_COLOR = Color(212/255, 172/255, 104/255, 0.5)

local dirString = {
    [Direction.DOWN] = "Down",
    [Direction.UP] = "Up",
    [Direction.LEFT] = "Left",
    [Direction.RIGHT] = "Right",
}

---@param player EntityPlayer
local function evalCache(_, player, flags)
    if(not player:HasCollectible(mod.COLLECTIBLE.ZERO_GRAVITY)) then return end

    local num = player:GetCollectibleNum(mod.COLLECTIBLE.ZERO_GRAVITY)
    mod:addBasicDamageUp(player, DMG_UP*num)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_DAMAGE)

local function validGridColl(pl, coll)
    if(pl.CanFly and coll==GridCollisionClass.COLLISION_WALL) then
        return false
    elseif(pl.CanFly==false and coll~=0) then
        return false
    end

    return true
end

---@param pl EntityPlayer
local function zeroGravPlUpdate(_, pl)
    local data = mod:getEntityDataTable(pl)
    if(not pl:HasCollectible(mod.COLLECTIBLE.ZERO_GRAVITY)) then
        if(data.ZEROGRAV_CROSSHAIR and data.ZEROGRAV_CROSSHAIR:Exists()) then
            data.ZEROGRAV_CROSSHAIR:Remove()
            data.ZEROGRAV_CROSSHAIR = nil
        end
        return
    end

    local crosshair = data.ZEROGRAV_CROSSHAIR
    if(not (crosshair and crosshair:Exists())) then
        crosshair = Isaac.Spawn(1000, mod.EFFECT_VARIANT.ZERO_GRAV_CROSSHAIR, 0, pl.Position, Vector.Zero, pl):ToEffect()

        crosshair.Size = pl.Size
        crosshair.SizeMulti = pl.SizeMulti
        crosshair.Friction = pl.Friction

        data.ZEROGRAV_MOVEMENT_INPUTS = {}
        for _=1, MOVE_DELAY do
            table.insert(data.ZEROGRAV_MOVEMENT_INPUTS, {pl.Position, Vector.Zero, })
        end

        data.ZEROGRAV_CROSSHAIR = crosshair
    end

    local moveVector = pl:GetMovementVector()
    if(moveVector:Length()<0.01 and pl.Position:Distance(crosshair.Position)>5) then
        pl:Teleport(crosshair.Position, true, false)
        pl.Velocity = Vector.Zero
        crosshair:Remove()

        local nearbyDoor
        local room = Game():GetRoom()
        for _, slot in pairs(DoorSlot) do
            local door = room:GetDoor(slot)
            if(door and (nearbyDoor==nil or door.Position:Distance(pl.Position)<nearbyDoor.Position:Distance(pl.Position))) then
                nearbyDoor = door
            end
        end
        if(nearbyDoor and nearbyDoor.Position:Distance(pl.Position)<30) then
            pl.Position = nearbyDoor.Position
        end
    elseif(moveVector:Length()>=0.01) then
        local sp = crosshair:GetSprite()
        if(data.ZEROGRAV_MOVEMENT_INPUTS[1][2]:Length()>0.01 and sp:GetAnimation()~="Blink") then
            sp:Play("Blink", true)
        end
        
        local maxlength = 0.513935*(pl.MoveSpeed^4)-1.19424*(pl.MoveSpeed^3)+1.71604*(pl.MoveSpeed^2)+0.862579*(pl.MoveSpeed)+2.52133
        crosshair.Velocity = mod:lerp(crosshair.Velocity, pl:GetMovementVector()*maxlength*2, 0.25)

        local validVel = Vector.Zero

        local room = Game():GetRoom()
        local steps = 10
        local fraq = crosshair.Velocity/10
        
        for i=steps, 1, -1 do
            if(validGridColl(pl, room:GetGridCollisionAtPos(crosshair.Position+i*fraq))) then
                validVel = i*fraq
                break
            end
        end

        local remainingVel = crosshair.Velocity-validVel
        if(remainingVel:Length()>0.001) then
            local smallestDist = remainingVel:Length()*2
            local finalAngle = 0

            for i=1,360 do
                local rot = remainingVel:Rotated(i)
                if(validGridColl(pl, room:GetGridCollisionAtPos(crosshair.Position+validVel+rot))) then
                    local dt = rot:DistanceSquared(crosshair.Position+validVel+remainingVel)
                    if(dt<smallestDist) then
                        finalAngle = i
                        smallestDist = dt
                    end
                end
            end

            if(finalAngle~=0) then
                validVel = validVel+remainingVel:Rotated(finalAngle)
            end
        end

        crosshair.Velocity = validVel

        table.insert(data.ZEROGRAV_MOVEMENT_INPUTS, {crosshair.Position, crosshair.Velocity})
    
        local currentPosVel = data.ZEROGRAV_MOVEMENT_INPUTS[1]
        pl.Position = currentPosVel[1]
        pl.Velocity = currentPosVel[2]
        table.remove(data.ZEROGRAV_MOVEMENT_INPUTS, 1)
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_UPDATE, zeroGravPlUpdate, PlayerVariant.PLAYER)

---@param effect EntityEffect
local function crosshairInit(_, effect)
    local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, effect.Position+effect.PositionOffset+TRAIL_OFFSET, Vector.Zero, effect):ToEffect()
    trail:FollowParent(effect)
    trail.ParentOffset = effect.PositionOffset+TRAIL_OFFSET
    trail.MinRadius = 0.15/(5*MOVE_DELAY/60)
    mod:setEntityData(trail, "ZEROGRAV_TRAIL", effect)

    trail:Update()

    effect.DepthOffset = -1000
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, crosshairInit, mod.EFFECT_VARIANT.ZERO_GRAV_CROSSHAIR)

local function trailRender(_, effect, offset)
    local trailParent = mod:getEntityData(effect, "ZEROGRAV_TRAIL")
    if(not trailParent) then return end

    if(trailParent:Exists()) then
        effect.ParentOffset = trailParent.PositionOffset+TRAIL_OFFSET
        effect.Color = CROSSHAIR_COLOR
        effect.DepthOffset = -10000
    else
        effect.Color = Color(1,0,0,0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, trailRender, EffectVariant.SPRITE_TRAIL)
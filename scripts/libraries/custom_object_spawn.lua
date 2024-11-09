local mod = MilcomMOD
--! make circle type use a timer for delayed circle spawn
--! make line and circleline have a second extrafunction for the timer effect

--[[
--! all of the funcs will use a "spawner data" table that can contain the following entries

--* SpawnType (string) = the type of pattern to spawn objects in (optional, defaults to SINGLE)
    --? LINE = spawns the objects in a line
    --? SINGLE = same as LINE, but forces Amount to be 1, which means Distance, Delay and AngleVariation have no effect
    --? CIRCLE = spawns the objects in an ellipse. Distance, Delay, Amount and AngleVariation have no effect
    --? CIRCLELINE = spawns multiple ellipses of objects in a growing manner.

--* SpawnData (array[number,number,number])= the type, variant and subtype of object to spawn (optional, defaults to {EntityType.ENTITY_EFFECT, EffectVariant.FIRE_JET, 0})
--* SpawnerEntity (Entity) = the spawner entity (optional, defaults to nil)
--* Position (Vector) = the position to spawn at (optional, defaults to the room center)
--* Amount (number) = the number of object to spawn (optional, defaults to 1) (if 1, it will spawn the singular object, otherwise it spawns a timer effect that spawns the objects)
--* Damage (number) = the damage of the spawned object (sets collision damage) (optional, defaults to 3.5)
--* Color (Color()) = the color of the spawned object (optional, defaults to Color.Default)
--* PlayerFriendly (bool) = should the object hurt players? (optional, defaults to false)
--* ExtraFunction (function(obj, objIndex, radiusIndex)) = function for doing extra stuff to spawned object, gives the object's spawn index as a parameter (optional, defaults to nil)
    --? only gives radiusIndex as param if SpawnType CIRCLELINE
--* TimerExtraFunction (function(timer, objIndex, radiusIndex)) = function for doing extra stuff to spawner tiemr, gives the current object's index as a paramter (optional, defaults to nil)
    --? only gives radiusIndex as param if SpawnType CIRCLELINE
    --? only applies to LINE and CIRCLELINE SpawnTypes

--* Distance (Vector) = the position difference between 2 objects spawned (optional, defaults to Vector(40,0))
--* Delay (number) = the delay between 2 objects spawned (optional, defaults to 5)
--* AngleVariation (number) = the angle arc which Distance can randomly be rotated by (optional, defaults to 0)

--* Radius (Vector) = the radius of the ellipse, only applies to SpawnType CIRCLE and SpawnType CIRCLELINE (optional, defaults to Vector(40,40))
--* RadiusCount (number) = the number of objects in the ellipse ring, only applies to SpawnType CIRCLE and SpawnType CIRCLELINE (optional, defaults to 4)

--! ONLY APPLIES TO SHOCKWAVES!!!
--* DamageCooldown (number) = number of frames to wait before it can deal damage again (optional, defaults to 10)
--* DestroyGrid (number) = should the object break grids? (optional, defaults to 0)

--]]

local VALID_ROCK_TYPES = {
    [2]=true,
    [4]=true,
    [5]=true,
    [6]=true,
    [12]=true,
    [14]=true,
    [25]=true,
    [26]=true,
    [27]=true,
}
local BAD_ROCK_TYPES = {
    [3]=true,
    [11]=true,
    [7]=true,
    [21]=true,
    [24]=true,
}
local function getGridColl(pos)
    if(not Game():GetRoom():IsPositionInRoom(pos, 0)) then return 2 end

    local gridEnt = Game():GetRoom():GetGridEntityFromPos(pos)
    if(gridEnt==nil) then return 0 end
    local eType = gridEnt:GetType()
    if(BAD_ROCK_TYPES[eType]) then return 2 end
    if(VALID_ROCK_TYPES[eType]) then return 1 end
    return 0
end

function mod:spawnCustomObjects(objData)
    objData = objData or {}
    local newData = {
        SpawnType = objData.SpawnType or "SINGLE",
        SpawnData = objData.SpawnData or {EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0},
        SpawnerEntity = objData.SpawnerEntity,
        Position = objData.Position or Game():GetRoom():GetCenterPos(),
        Amount = math.max(1, objData.Amount or 1),
        Damage = math.max(0, objData.Damage or 3.5),
        Color = objData.Color or Color(1,1,1,1),
        PlayerFriendly = objData.PlayerFriendly or false,
        ExtraFunction = objData.ExtraFunction,
        TimerExtraFunction = objData.TimerExtraFunction,
        Distance = objData.Distance or Vector(40,40),
        Delay = math.max(0, objData.Delay or 5),
        AngleVariation = math.max(0, objData.AngleVariation or 0),
        Radius = objData.Radius or Vector(40,40),
        RadiusCount = math.max(0, objData.RadiusCount or 4),
        DamageCooldown = math.max(0, objData.DamageCooldown or 10),
        DestroyGrid = (objData.DestroyGrid or 0),

        Index = objData.Index or 0,
        CircleIndex = objData.CircleIndex or 0,
        OGPosition = objData.OGPosition or objData.Position or Game():GetRoom():GetCenterPos(),
        OGRadius = objData.OGRadius or objData.Radius or Vector(40,40),
        CooldownFrames = objData.CooldownFrames or 0,
    }

    if(newData.Amount==1 and newData.SpawnType=="LINE") then newData.SpawnType = "SINGLE"
    elseif(newData.Amount>1 and newData.SpawnType=="SINGLE") then newData.Amount = 1 end

    if(newData.Amount==1 and newData.SpawnType=="CIRCLELINE") then newData.SpawnType = "CIRCLE"
    elseif(newData.Amount>1 and newData.SpawnType=="CIRCLE") then newData.Amount = 1 end

    if(newData.SpawnType=="SINGLE") then
        mod:spawnSingleObject(newData)
    elseif(newData.SpawnType=="LINE") then
        local function timerLogic(effect)
            local rng = effect:GetDropRNG()
            local oData = mod:getEntityData(effect, "COBJ_DATA")
            if(oData==nil) then
                effect:Remove()
                return
            end

            if(oData.Index>0) then oData.Position = oData.Position+oData.Distance:Rotated( (rng:RandomFloat()-0.5)*oData.AngleVariation ) end
            local c = getGridColl(oData.Position)
            if(c<=oData.DestroyGrid) then
                local obj = mod:spawnSingleObject(oData)

                if(oData.TimerExtraFunction) then oData.TimerExtraFunction(effect, oData.Index, oData.CircleIndex) end
                oData.Index = oData.Index+1
                if(oData.Delay==0 and oData.Index<oData.Amount) then effect:Update() end
            else
                effect:Remove()
                return
            end
            mod:setEntityData(effect, "COBJ_DATA", oData)
        end
        local t =  Isaac.CreateTimer(timerLogic, newData.Delay, newData.Amount, false)
        mod:setEntityData(t, "COBJ_DATA", newData)
        t:Update()
    elseif(newData.SpawnType=="CIRCLE") then
        mod:spawnCircleObject(newData)
    elseif(newData.SpawnType=="CIRCLELINE") then
        local function timerLogic(effect)
            local rng = effect:GetDropRNG()
            local oData = mod:getEntityData(effect, "COBJ_DATA")
            if(oData==nil) then
                effect:Remove()
                return
            end

            if(oData.CircleIndex>0) then oData.Radius = oData.Radius+oData.Distance end
            local c = getGridColl(oData.OGPosition)
            if(c<=oData.DestroyGrid) then
                local obj = mod:spawnCircleObject(oData)

                if(oData.TimerExtraFunction) then oData.TimerExtraFunction(effect, oData.Index, oData.CircleIndex) end
                oData.CircleIndex = oData.CircleIndex+1
                if(oData.Delay==0 and oData.CircleIndex<oData.Amount) then effect:Update() end
            else
                effect:Remove()
                return
            end
            mod:setEntityData(effect, "COBJ_DATA", oData)
        end
        local t = Isaac.CreateTimer(timerLogic, newData.Delay, newData.Amount, false)
        mod:setEntityData(t, "COBJ_DATA", newData)
        t:Update()
    end
end

function mod:spawnSingleObject(objData)
    local c = getGridColl(objData.Position)
    if(c<=objData.DestroyGrid) then
        local obj = Isaac.Spawn(objData.SpawnData[1], objData.SpawnData[2], objData.SpawnData[3], objData.Position, Vector(0,0), objData.SpawnerEntity)
        obj.CollisionDamage = objData.Damage
        obj.Color = objData.Color

        local data = mod:getEntityDataTable(obj)
        data.COBJ_DATA = mod:cloneTable(objData)
        if(data.COBJ_DATA.ExtraFunction) then data.COBJ_DATA.ExtraFunction(obj, data.COBJ_DATA.Index, data.COBJ_DATA.CircleIndex) end

        data.COBJ_CUSTOM_OBJ = true
    end
end
function mod:spawnCircleObject(objData)
    local rng = mod:generateRng()
    objData.Index = 0
    for i=0, objData.RadiusCount-1 do
        local pos = objData.OGPosition+objData.Radius*Vector.FromAngle(360*(objData.Index/objData.RadiusCount)+(rng:RandomFloat()-0.5)*objData.AngleVariation)
        if(Game():GetRoom():IsPositionInRoom(pos, 0) and Game():GetRoom():GetGridCollisionAtPos(pos)==GridCollisionClass.COLLISION_NONE) then
            objData.Position = pos
            mod:spawnSingleObject(objData)
        end

        objData.Index = objData.Index+1
    end
end

local function customObjDamage(_, tookDmg, _, _, source)
    if(not (source.Entity)) then return end

    local e = source.Entity
    local data = mod:getEntityData(e, "COBJ_DATA")
    if(data) then
        if(e.SpawnerEntity and GetPtrHash(e.SpawnerEntity)==GetPtrHash(tookDmg)) then return false end
        if(data.PlayerFriendly and tookDmg.Type==EntityType.ENTITY_PLAYER) then return false end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, customObjDamage)

local function customObjPlayerDamage(_, tookDmg, _, _, source)
    if(not (source.Entity)) then return end

    local e = source.Entity
    local data = mod:getEntityData(e, "COBJ_DATA")
    if(data) then
        if(e.SpawnerEntity and GetPtrHash(e.SpawnerEntity)==GetPtrHash(tookDmg)) then return false end
        if(data.PlayerFriendly) then return false end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, customObjPlayerDamage)



--! SPECIAL SHOCKWAVE LOGIC!!!
local function specialShockwaveUpdate(_, effect)
    local objData = mod:getEntityDataTable(effect).COBJ_DATA
    if(not objData) then return end

    if(objData.DestroyGrid and objData.DestroyGrid>=1) then
        if(getGridColl(effect.Position)==1) then
            local room = Game():GetRoom()
            room:DestroyGrid(room:GetGridIndex(effect.Position), true)
        end
    end

    if(objData.CooldownFrames==0) then
        local dealtDamage = false
        for _, enemy in ipairs(Isaac.FindInRadius(effect.Position, effect.Size, EntityPartition.ENEMY | EntityPartition.PLAYER)) do
            if(effect.SpawnerEntity and GetPtrHash(effect.SpawnerEntity)==GetPtrHash(enemy)) then goto continue end
            if(objData.PlayerFriendly and enemy.Type==EntityType.ENTITY_PLAYER) then goto continue end

            enemy:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), 0)

            ::continue::
        end

        if(dealtDamage) then objData.CooldownFrames = objData.DamageCooldown end
    else
        objData.CooldownFrames = objData.CooldownFrames-1
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, specialShockwaveUpdate, EffectVariant.ROCK_EXPLOSION)
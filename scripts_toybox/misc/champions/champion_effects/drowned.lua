

local function angle2Dir(x)
    return math.floor((x+225)%360/90)
end
local function dir2Angle(x)
    if(x==Direction.DOWN) then return 90
    elseif(x==Direction.LEFT) then return 180
    elseif(x==Direction.UP) then return 270
    else return 0 end
end

---@param npc EntityNPC
local function drownedChampionDie(_, npc)
    ToyboxMod.DENY_CHAMP_ROLL = true
    local drownedCharger = Isaac.Spawn(23,1,0,npc.Position,Vector.Zero,npc):ToNPC()
    drownedCharger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    local target = drownedCharger:GetPlayerTarget()

    local chargeSpeed = 1.17
    local chargeDir = Vector(0,1)
    if(target) then
        local angle = (target.Position-drownedCharger.Position):GetAngleDegrees()
        chargeDir = Vector.FromAngle(dir2Angle(angle2Dir(angle)))
    end

    -- make it work properly
    drownedCharger.State = NpcState.STATE_ATTACK
    drownedCharger.V2 = drownedCharger.Position
    drownedCharger.V1 = chargeDir:Resized(chargeSpeed)

    ToyboxMod.DENY_CHAMP_ROLL = false

    local projParams = ProjectileParams()
    npc:FireProjectilesEx(npc.Position,Vector(12,0),ProjectileMode.CROSS,projParams)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_CUSTOM_CHAMPION_DEATH, drownedChampionDie, ToyboxMod.CUSTOM_CHAMPIONS.DROWNED.Idx)
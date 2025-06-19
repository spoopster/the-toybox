

local ELECTRIFIED_LASER_FREQ = 14
local ELECTRIFIED_LASER_LENGTH = {Min=70, Max=130}
local ELECTRIFIED_LASER_TIMEOUT = 2
local ELECTRIFIED_LASER_DAMAGE = 2
local ELECTRIFIED_LASER_RANGE = 40

local ELECTRIFIED_LASER_VAR = LaserVariant.ELECTRIC
local function convBool(b)
    return (b and 1 or 0)
end

---@param player EntityPlayer?
function ToyboxMod:addElectrified(npc, player, amount, damage, rng)
    local d = ToyboxMod:getEntityDataTable(npc)
    local oldData = d.STATUS_ELECTRIFIED_DATA or {}
    player = player or oldData.PLAYER or Isaac.GetPlayer()

    local dmgMult = 1+0.5*(convBool(player:HasCollectible(CollectibleType.COLLECTIBLE_SHARP_PLUG))+convBool(player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)))
    local rangeMult = 1+0.5*(convBool(player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT))+convBool(player:HasTrinket(TrinketType.TRINKET_WATCH_BATTERY))+convBool(player:HasTrinket(TrinketType.TRINKET_HAIRPIN)))
    local sparkFreqMod = 1-0.25*(convBool(player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY))+convBool(player:HasCollectible(CollectibleType.COLLECTIBLE_JUMPER_CABLES))+convBool(player:HasTrinket(TrinketType.TRINKET_AAA_BATTERY)))
    local numSparks = 1+(convBool(player:HasTrinket(TrinketType.TRINKET_OLD_CAPACITOR)))

    d.STATUS_ELECTRIFIED_DATA = {
        DURATION = (oldData.DURATION or 0)+amount,
        PLAYER = player,
        DAMAGE = damage or oldData.DAMAGE or ELECTRIFIED_LASER_DAMAGE,
        ACTIVE_LASER_ENT = oldData.ACTIVE_LASER_ENT,
        RANGE = (range or oldData.RANGE or ELECTRIFIED_LASER_RANGE),
        RNG = rng or ToyboxMod:generateRng(),
        DAMAGE_MULT = dmgMult,
        DIST_MULT = rangeMult,
        FREQ_MULT = sparkFreqMod,
        NUM_SPARKS = numSparks,
    }
end
function ToyboxMod:hasElectrified(npc)
    local d = ToyboxMod:getEntityData(npc, "STATUS_ELECTRIFIED_DATA")
    return (d and d.DURATION>0)
end

ToyboxMod:addCustomStatusEffect(
    "Electrified",
    Color(1,1,1,1,0.15,0.15,0.35),
    function(npc)
        return ToyboxMod:hasElectrified(npc)
    end
)

local function postNpcUpdate(_, npc)
    local d = ToyboxMod:getEntityData(npc, "STATUS_ELECTRIFIED_DATA")
    if(d==nil) then return end

    if(npc.FrameCount%math.max(1,math.floor(ELECTRIFIED_LASER_FREQ*d.FREQ_MULT))==0) then
        for _=1, (d.NUM_SPARKS or 1) do
            local angl = d.RNG:RandomInt(360)
            local laser = EntityLaser.ShootAngle(ELECTRIFIED_LASER_VAR, npc.Position, angl, ELECTRIFIED_LASER_TIMEOUT, Vector(0, -10), d.PLAYER)
            laser.Parent = d.PLAYER
            laser.CollisionDamage = d.DAMAGE*d.DAMAGE_MULT
            laser.MaxDistance = npc.Size+(ELECTRIFIED_LASER_LENGTH.Min+d.RNG:RandomInt(ELECTRIFIED_LASER_LENGTH.Max-ELECTRIFIED_LASER_LENGTH.Min))*d.DIST_MULT
            laser.OneHit = true
            laser.Mass = 0

            laser:Update()
        end
    end

    d.DURATION = d.DURATION-1
    if(d.DURATION<=0) then
        d=nil
    end
    ToyboxMod:setEntityData(npc, "STATUS_ELECTRIFIED_DATA", d)
end
ToyboxMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, postNpcUpdate)

---@param laser EntityLaser
local function postLaserUpdate(_, laser)
    if(laser:IsDead()) then return end
    if(not ToyboxMod:getEntityData(laser, "ELECTRIFIED_LASER")) then return end
    local ent = ToyboxMod:getEntityData(laser, "ELECTRIFIED_LASER_ENEMYPARENT")
    if(not (ent and ent:Exists())) then laser:Die() end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, postLaserUpdate)
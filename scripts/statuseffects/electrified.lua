local mod = MilcomMOD

local ELECTRIFIED_LASER_FREQ = 7
local ELECTRIFIED_LASER_LENGTH = {Min=70, Max=130}
local ELECTRIFIED_LASER_TIMEOUT = 2
local ELECTRIFIED_LASER_DAMAGE = 0.5

local ELECTRIFIED_LASER_VAR = LaserVariant.ELECTRIC

function mod:addElectrified(npc, player, amount, damage, rng)
    local d = mod:getEntityDataTable(npc)

    local oldData = d.STATUS_ELECTRIFIED_DATA or {}
    d.STATUS_ELECTRIFIED_DATA = {
        DURATION = (oldData.DURATION or 0)+amount,
        PLAYER = player or oldData.PLAYER or Isaac.GetPlayer(),
        DAMAGE = damage or oldData.DAMAGE or ELECTRIFIED_LASER_DAMAGE,
        RNG = rng or mod:generateRng(),
    }
end
function mod:hasElectrified(npc)
    local d = mod:getEntityData(npc, "STATUS_ELECTRIFIED_DATA")
    return (d and d.DURATION>0)
end

mod:addCustomStatusEffect(
    "Electrified",
    Color(1,1,1,1,0.15,0.15,0.35),
    function(npc)
        return mod:hasElectrified(npc)
    end
)

local function postNpcUpdate(_, npc)
    local d = mod:getEntityData(npc, "STATUS_ELECTRIFIED_DATA")
    if(d==nil) then return end

    if(npc.FrameCount%ELECTRIFIED_LASER_FREQ==0) then
        local angl = d.RNG:RandomInt(360)
        local laser = EntityLaser.ShootAngle(ELECTRIFIED_LASER_VAR, npc.Position, angl, ELECTRIFIED_LASER_TIMEOUT, Vector(0, -10), d.PLAYER)
        laser.Parent = d.PLAYER
        laser.CollisionDamage = d.DAMAGE
        laser.MaxDistance = npc.Size+(ELECTRIFIED_LASER_LENGTH.Min+d.RNG:RandomInt(ELECTRIFIED_LASER_LENGTH.Max-ELECTRIFIED_LASER_LENGTH.Min))
        laser.OneHit = true
        laser.Mass = 0

        laser:Update()
    end

    d.DURATION = d.DURATION-1
    if(d.DURATION<=0) then d=nil end
    mod:setEntityData(npc, "STATUS_ELECTRIFIED_DATA", d)
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, postNpcUpdate)
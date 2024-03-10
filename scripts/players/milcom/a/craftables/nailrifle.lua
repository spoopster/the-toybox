local mod = MilcomMOD

local NAIL_SPEED_FRAMES = 4
local NAIL_DMGMOD = 1.5

local function setData(_, player, craftable)
    local data = mod:getMilcomATable(player)

    data.NAILGUN_MAXFIRERATEMULT = 4
    data.NAILGUN_FIREDELAY = 0
    data.NAILGUN_RANGEMULT = 1
    data.NAILGUN_FIREFUNC = function(p, e)
        local dir = (e.Position-p.Position)/NAIL_SPEED_FRAMES

        local nail = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.NAIL, 0, p.Position, dir, p):ToTear()
        nail.CollisionDamage = p.Damage*NAIL_DMGMOD
        nail.Mass = nail.Mass/10
        nail:AddTearFlags(TearFlags.TEAR_PIERCING)
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_MILCOM_CRAFT_CRAFTABLE, setData, "NAILRIFLE")
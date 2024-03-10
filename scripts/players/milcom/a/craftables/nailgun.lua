local mod = MilcomMOD

local NAIL_SPEED = 20
local NAIL_DMGMOD = 1

local function setData(_, player, craftable)
    local data = mod:getMilcomATable(player)

    data.NAILGUN_MAXFIRERATEMULT = 4
    data.NAILGUN_FIREDELAY = 0
    data.NAILGUN_RANGEMULT = 0.5
    data.NAILGUN_FIREFUNC = function(p, e)
        local dir = (e.Position-p.Position):Normalized()

        local nail = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.NAIL, 0, p.Position, dir*NAIL_SPEED, p):ToTear()
        nail.CollisionDamage = p.Damage*NAIL_DMGMOD
        nail.Mass = nail.Mass/10
        nail:AddTearFlags(TearFlags.TEAR_PIERCING)
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_MILCOM_CRAFT_CRAFTABLE, setData, "NAILGUN")

local function updateNailgunLogic(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    if(not mod:playerHasCraftable(player, "NAILGUN")) then return end
    local data = mod:getMilcomATable(player)

    if(data.NAILGUN_FIREDELAY==nil) then data.NAILGUN_FIREDELAY=0 end

    if(data.NAILGUN_FIREDELAY<=0) then
        local c = mod:closestEnemy(player.Position)
        if(c and (c.Position-player.Position):Length()<=player.TearRange*(data.NAILGUN_RANGEMULT or 1)) then
            data.NAILGUN_FIREFUNC(player, c)

            data.NAILGUN_FIREDELAY = data.NAILGUN_FIREDELAY+player.MaxFireDelay*(data.NAILGUN_MAXFIRERATEMULT or 1)*2
        end
    else
        data.NAILGUN_FIREDELAY = data.NAILGUN_FIREDELAY-1
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateNailgunLogic)
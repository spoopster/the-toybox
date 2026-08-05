local KNOCKBACK_STRENGTH = 1.1

local STACK_KNOCKBACK_INCR = 0.2

---@param dir Vector
---@param amount number
---@param owner Entity
---@param weapon Weapon
local function postTriggerWeaponFired(_, dir, amount, owner, weapon)
    local weapType = weapon:GetWeaponType()
    if(weapType==WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then return end

    local pl = ToyboxMod:getPlayerFromEnt(owner)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GUNPOWDER))) then return end

    dir = (dir:Length()>0.01 and dir or weapon:GetDirection())

    local knockbackMult = KNOCKBACK_STRENGTH+STACK_KNOCKBACK_INCR*(pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_GUNPOWDER)-1)
    pl:AddVelocity(-dir*pl.ShotSpeed*knockbackMult*(pl.Damage/3.5)^0.85)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, postTriggerWeaponFired)
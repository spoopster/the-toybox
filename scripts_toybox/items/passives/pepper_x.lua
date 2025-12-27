local BREATH_CHANCE = 0.05
local BREATH_MAXCHANCE = 0.5
local BREATH_MAXLUCK = 20

---@param dir Vector
---@param amount number
---@param ent Entity
---@param weap Weapon
local function onFireWeapon(_, dir, amount, ent, weap)
    local pl = ToyboxMod:getPlayerFromEnt(ent)
    if(not (ent and pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_PEPPER_X))) then return end

    local c = ToyboxMod:getLuckAffectedChance(pl.Luck, BREATH_CHANCE, BREATH_MAXLUCK, BREATH_MAXCHANCE)
    if(pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_PEPPER_X):RandomFloat()<c) then
        local data = ToyboxMod:getEntityDataTable(ent)
        if(not (data.PEPPERX_FLAME_TIMER and data.PEPPERX_FLAME_TIMER:Exists() and not data.PEPPERX_FLAME_TIMER:IsDead())) then
            local helper = Isaac.Spawn(EntityType.ENTITY_EFFECT, ToyboxMod.EFFECT_FLAME_BREATH_HELPER, 0, ent.Position, dir, ent):ToEffect()
            data.PEPPERX_FLAME_TIMER = helper
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, onFireWeapon)
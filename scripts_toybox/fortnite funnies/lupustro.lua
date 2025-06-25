

---@param npc EntityNPC
local function postMonstroInit(_, npc)
    npc:GetSprite():ReplaceSpritesheet(0, "gfx_tb/bosses/lupustro.png", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postMonstroInit, EntityType.ENTITY_MONSTRO)

local function postProjectileRender(_, proj)
    local sp = proj.SpawnerEntity
    if(not (sp and sp.Type==EntityType.ENTITY_MONSTRO)) then return end

    proj:AddProjectileFlags(ProjectileFlags.EXPLODE)
    proj.Color = Color(1,1,1,1,0,0.5,0,0,1,0,1)
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_RENDER, postProjectileRender)
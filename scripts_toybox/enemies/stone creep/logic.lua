

---@param npc EntityNPC
local function redMegalodonInit(_, npc)
    if(not (npc.Variant==ToyboxMod.NPC_STONE_CREEP_VAR)) then return end

    npc:GetSprite():Play("Walk")
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, redMegalodonInit, EntityType.ENTITY_WALL_CREEP)

---@param npc EntityNPC
local function aaaaahhhh(_, npc)
    if(not (npc.Variant==ToyboxMod.NPC_STONE_CREEP_VAR)) then return end

    if(Game():GetRoom():IsClear() and not npc:IsDead()) then
        npc:Die()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, aaaaahhhh, EntityType.ENTITY_WALL_CREEP)

---@param npc EntityNPC
local function enhhnh(_, npc, amount, flags, source, frames)
    if(not (npc.Variant==ToyboxMod.NPC_STONE_CREEP_VAR)) then return end
    
    return false
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, enhhnh, EntityType.ENTITY_WALL_CREEP)
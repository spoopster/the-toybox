local mod = MilcomMOD

mod.DENY_CHAMP_ROLL = false

---@param npc EntityNPC
local function tryMakeModChampion(_, npc)
    if(mod.DENY_CHAMP_ROLL) then return end
    if(not EntityConfig.GetEntity(npc.Type, npc.Variant, npc.SubType):CanBeChampion()) then return end

    local vanillaChance = mod:getVanillaChampionChance()
    local chanceDif = mod:getChampionChance()-vanillaChance
    if(npc:GetDropRNG():RandomFloat()<chanceDif/(1-vanillaChance)) then
        npc:MakeChampion(math.max(Random(),1), -1, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, tryMakeModChampion)
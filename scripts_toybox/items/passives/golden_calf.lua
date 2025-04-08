local mod = Fakebox

local RESPAWN_CHANCE = 0.1
local BOSS_CHANCE_MOD = 1/1000

local HP_MOD = 0.5

---@param npc EntityNPC
local function resummonOnKill(_, npc)
    if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.GOLDEN_CALF)) then return end
    if(npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then return end

    local pl = PlayerManager.FirstCollectibleOwner(mod.COLLECTIBLE.GOLDEN_CALF)
    local rng = pl:GetCollectibleRNG(mod.COLLECTIBLE.GOLDEN_CALF)

    if(rng:RandomFloat()<RESPAWN_CHANCE*(npc:IsBoss() and BOSS_CHANCE_MOD or 1)) then
        local newNpc = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, Vector.Zero, pl):ToNPC()
        newNpc:AddCharmed(EntityRef(pl), -1)

        newNpc.HitPoints = newNpc.HitPoints*HP_MOD
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, resummonOnKill)
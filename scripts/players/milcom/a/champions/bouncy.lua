local mod = MilcomMOD
local sfx = SFXManager()

local BOUNCE_SPEED = 11
local KNOCKBACK_DUR = 8

local function makeBounce(npc, dir)
    sfx:Play(SoundEffect.SOUND_JELLY_BOUNCE)

    npc:AddKnockback(EntityRef(nil), dir, KNOCKBACK_DUR, false)
end

---@param npc EntityNPC
local function bouncyCollision(_, npc, coll, low)
    if(mod:getEntityData(npc, "CUSTOM_CHAMPION_IDX")~=mod.CUSTOM_CHAMPIONS.JELLY.Idx) then return end

    local dir = -(coll.Position-npc.Position):Resized(BOUNCE_SPEED)
    makeBounce(npc, dir)
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, bouncyCollision)

---@param npc EntityNPC
local function bouncyGridCollision(_, npc, idx, gridEnt)
    if(mod:getEntityData(npc, "CUSTOM_CHAMPION_IDX")~=mod.CUSTOM_CHAMPIONS.JELLY.Idx) then return end

    local dir = -(gridEnt.Position-npc.Position):Resized(BOUNCE_SPEED)
    makeBounce(npc, dir)
end
mod:AddCallback(ModCallbacks.MC_NPC_GRID_COLLISION, bouncyGridCollision)

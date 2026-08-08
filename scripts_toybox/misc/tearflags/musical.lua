local EARWORM_DURATION = 7*30
local TEARFLAG_COLOR = Color(0.90,0.77,1,1,0.27,0.23,0.3,0.9,0.77,1,1)

---@param entity Entity
---@param player EntityPlayer
local function preAddTearFlag(_, entity, player, _, weaponFlag, tearFlag)
    if(TearFlagsLib.HasTearFlags(entity, tearFlag)) then return true end
end
--ToyboxMod:AddCallback(TearFlagsLib.Callback.PRE_ADD_TEARFLAG, preAddTearFlag, ToyboxMod.TEARFLAGS.MUSICAL)

---@param entity Entity
---@param player EntityPlayer
local function postAddTearFlag(_, entity, player, _, weaponFlag)
    if(ToyboxMod.WEAPONFLAGS_NO_COLOR[weaponFlag]) then return end
    entity.Color = entity.Color*TEARFLAG_COLOR
end
ToyboxMod:AddCallback(TearFlagsLib.Callback.POST_ADD_TEARFLAG, postAddTearFlag, ToyboxMod.TEARFLAGS.MUSICAL)

---@param npc EntityNPC
---@param player EntityPlayer
local function applyTearFlagEffect(_, npc, player, source, weapon, params)
    ToyboxMod:applyEarworm(npc, -EARWORM_DURATION, EntityRef(source), false)
end
ToyboxMod:AddCallback(TearFlagsLib.Callback.APPLY_TEARFLAG_EFFECT, applyTearFlagEffect, ToyboxMod.TEARFLAGS.MUSICAL)
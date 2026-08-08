local BLEED_DURATION = 4*30
local TEARFLAG_COLOR = Color(1.3,0.9,0.9,1,0.1,0,0)

---@param entity Entity
---@param player EntityPlayer
local function preAddTearFlag(_, entity, player, _, weaponFlag, tearFlag)
    if(TearFlagsLib.HasTearFlags(entity, tearFlag)) then return true end
end
--ToyboxMod:AddCallback(TearFlagsLib.Callback.PRE_ADD_TEARFLAG, preAddTearFlag, ToyboxMod.TEARFLAGS.BLOODY)

---@param entity Entity
---@param player EntityPlayer
local function postAddTearFlag(_, entity, player, _, weaponFlag)
    if(ToyboxMod.WEAPONFLAGS_NO_COLOR[weaponFlag]) then return end
    entity.Color = entity.Color*TEARFLAG_COLOR
    if(entity:ToTear()) then
        local var = ToyboxMod:getBloodTearVariant(entity.Variant)
        if(var) then
            entity:ChangeVariant(var)
        end
    end
end
ToyboxMod:AddCallback(TearFlagsLib.Callback.POST_ADD_TEARFLAG, postAddTearFlag, ToyboxMod.TEARFLAGS.BLOODY)

---@param ent Entity
---@param offset Vector
local function spawnTrail(ent, offset)
    local trail = Isaac.Spawn(1000,EffectVariant.HAEMO_TRAIL,0,ent.Position,Vector.Zero,nil):ToEffect()
    trail.DepthOffset = ent.DepthOffset-1
    trail.SpriteOffset = trail.SpriteOffset+offset
    trail.SpriteScale = trail.SpriteScale*0.7*(ent and ent:ToTear() and ent:ToTear().Scale or 1)
end

---@param tear EntityTear
local function bloodyPostTearUpdate(_, tear)
    if(not TearFlagsLib.HasTearFlags(tear, ToyboxMod.TEARFLAGS.BLOODY)) then return end

    if(tear.FrameCount%3==0) then
        local trail = Isaac.Spawn(1000,EffectVariant.HAEMO_TRAIL,0,tear.Position,Vector.Zero,nil):ToEffect()
        trail.DepthOffset = tear.DepthOffset-1000
        trail.SpriteOffset = trail.SpriteOffset+tear.PositionOffset*0.67
        trail.SpriteScale = trail.SpriteScale*0.7*tear.Scale
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, bloodyPostTearUpdate)

---@param bomb EntityBomb
local function bloodyPostBombUpdate(_, bomb)
    if(not TearFlagsLib.HasTearFlags(bomb, ToyboxMod.TEARFLAGS.BLOODY)) then return end

    if(bomb.FrameCount%3==0) then
        local trail = Isaac.Spawn(1000,EffectVariant.HAEMO_TRAIL,0,bomb.Position,Vector.Zero,nil):ToEffect()
        trail.DepthOffset = bomb.DepthOffset-1000
        trail.SpriteOffset = trail.SpriteOffset+bomb.SpriteOffset-Vector(0,4)*bomb:GetScale()
        trail.SpriteScale = trail.SpriteScale*1*(bomb:GetScale()^0.5)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, bloodyPostBombUpdate)


---@param npc EntityNPC
---@param player EntityPlayer
local function applyTearFlagEffect(_, npc, player, source, weapon, params)
    npc:AddBleeding(EntityRef(player), math.max(0, BLEED_DURATION-npc:GetBleedingCountdown()))
end
ToyboxMod:AddCallback(TearFlagsLib.Callback.APPLY_TEARFLAG_EFFECT, applyTearFlagEffect, ToyboxMod.TEARFLAGS.BLOODY)
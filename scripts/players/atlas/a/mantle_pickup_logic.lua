local mod = MilcomMOD

mod.ATLAS_A_MANTLESUBTYPES = {}

local function postMantleInit(_, pickup)
    if(mod.ATLAS_A_MANTLESUBTYPES[pickup.SubType]~=true) then return end
end
--mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postMantleInit, 300)

local function postMantleUpdate(_, pickup)
    if(mod.ATLAS_A_MANTLESUBTYPES[pickup.SubType]~=true) then return end

    local sprite = pickup:GetSprite()
    if(sprite:IsFinished("Appear")) then
        sprite:Play("Idle", true)
    end
    if(sprite:IsFinished("Collect")) then
        pickup:Remove()
    end
end
--mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postMantleUpdate, 300)

local function preMantleCollision(_, pickup, collider, low)
    if(mod.ATLAS_A_MANTLESUBTYPES[pickup.SubType]~=true) then return end
    if(collider.Type==5) then return false end
    if(collider.Type~=1) then return true end

    local sprite = pickup:GetSprite()
    local anim = sprite:GetAnimation()
    if(anim=="Appear" or (anim=="Collect" and sprite:GetFrame()>4)) then return true end
    if(anim~="Idle") then return true end
    if(not collider:ToPlayer():IsExtraAnimationFinished()) then return nil end

    sprite:Play("Collect", true)
    --
    pickup:Die()
end
--mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, preMantleCollision, 300)
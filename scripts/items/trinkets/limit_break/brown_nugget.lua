local mod = ToyboxMod
--* Damage buff, copies your tear effects

---@param familiar EntityFamiliar
local function familiarUpdate(_, familiar)
    if(not (familiar.Player and mod:playerHasLimitBreak(familiar.Player))) then return end
    local sprite = familiar:GetSprite()
    if(sprite:IsFinished("Appear")) then sprite:Play("Fly") end
    if(sprite:IsFinished("Attack")) then sprite:Play("Fly") end

    if(sprite:GetAnimation()=="Fly" and sprite:GetFrame()==16) then
        local target = mod:closestEnemy(familiar.Position)
        if(target and target.Position:DistanceSquared(familiar.Position)<120*120) then
            familiar.Target = target
            sprite:Play("Attack", true)
        end
    end
    if(sprite:IsEventTriggered("Shoot")) then
        local target = familiar.Target

        if(target) then
            local dir = (target.Position-familiar.Position):Normalized()

            local tear = familiar.Player:FireTear(familiar.Position, dir*10,true,true,false,familiar)
            tear.CollisionDamage = 5
        end
    end

    familiar.Velocity = Vector.Zero

    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, familiarUpdate, FamiliarVariant.BROWN_NUGGET_POOTER)
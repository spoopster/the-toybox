local mod = ToyboxMod
local sfx = SFXManager()

---@param pl EntityPlayer
local function hasFinalBlackHeart(pl)
    local maxIdx = math.ceil(pl:GetSoulHearts()/2)+pl:GetBoneHearts()
    while(maxIdx>0 and pl:IsBoneHeart(maxIdx-1)) do
        maxIdx = maxIdx-1
    end

    return pl:IsBlackHeart(maxIdx*2-1)
end

---@param pickup EntityPickup
---@param pl Entity
local function consumeHeart(_, pickup, pl)
    if(not (pl and pl:ToPlayer() and pl:ToPlayer():HasCollectible(mod.COLLECTIBLE.HEMOLYMPH))) then return end
    if(not mod.RED_HEART_SUBTYPES[pickup.SubType]) then return end

    pl = pl:ToPlayer() ---@cast pl EntityPlayer
    if(pl:CanPickRedHearts()) then return end

    local canBlue = (pl:GetSoulHearts()%2==1) or (pl:GetSoulHearts()==0)

    if(canBlue) then
        pl:AddSoulHearts(1)

        --pickup:PlayPickupSound()
        pickup:GetSprite():Play("Collect", true)
        pickup:Die()
        
        local sub = (hasFinalBlackHeart(pl) and 5 or 4)
        local notif = Isaac.Spawn(1000, EffectVariant.HEART, sub, pl.Position, Vector.Zero, pl):ToEffect()
        notif:FollowParent(pl)
        notif.SpriteOffset = Vector(0, -40)

        sfx:Play(SoundEffect.SOUND_VAMP_GULP)

        return true
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.IMPORTANT, consumeHeart, PickupVariant.PICKUP_HEART)
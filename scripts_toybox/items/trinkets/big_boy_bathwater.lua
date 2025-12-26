
local sfx = SFXManager()

local CREEP_COLOR = Color(0,0,0,1,141/255,145/255,159/255)

---@param pl EntityPlayer
local function evalCache(_, pl)
    pl:CheckFamiliar(
        ToyboxMod.FAMILIAR_BATH_WATER,
        pl:GetTrinketMultiplier(ToyboxMod.TRINKET_BATH_WATER),
        pl:GetTrinketRNG(ToyboxMod.TRINKET_BATH_WATER),
        Isaac.GetItemConfig():GetTrinket(ToyboxMod.TRINKET_BATH_WATER)
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_FAMILIARS)

---@param fam EntityFamiliar
local function bathwaterInit(_, fam)
    fam:GetSprite():Play("Float", true)
    fam.State = 0
    fam:AddToFollowers()
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, bathwaterInit, ToyboxMod.FAMILIAR_BATH_WATER)

---@param fam EntityFamiliar
local function bathwaterUpdate(_, fam)
    if(fam:GetSprite():IsFinished("Appear")) then
        fam:GetSprite():Play("Float", true)
    end

    if(fam.State==1) then
        fam.Velocity = Vector.Zero
        fam:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        fam:RemoveFromFollowers()

        if(fam:GetSprite():IsEventTriggered("Drop")) then
            local puddle = Isaac.Spawn(1000,EffectVariant.PLAYER_CREEP_LEMON_MISHAP,0,fam.Position,Vector.Zero,fam.Player):ToEffect()
            puddle.CollisionDamage = 8
            puddle.Timeout = 9*30+5
            puddle.Color = CREEP_COLOR
            ToyboxMod:setEntityData(puddle, "BATHWATER_CREEP", true)

            sfx:Play(SoundEffect.SOUND_GLASS_BREAK)
            fam:SetShadowSize(0)
        end
    else
        fam:FollowParent()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, bathwaterUpdate, ToyboxMod.FAMILIAR_BATH_WATER)

---@param pl EntityPlayer
local function resetBathwater(_, pl)
    for _, fam in ipairs(Isaac.FindByType(3,ToyboxMod.FAMILIAR_BATH_WATER)) do
        fam = fam:ToFamiliar()
        if(fam.State~=0 and GetPtrHash(fam.Player)==GetPtrHash(pl)) then
            fam.Visible = true
            fam.State = 0
            fam:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
            fam:GetSprite():Play("Appear", true)
            fam:AddToFollowers()
            fam:SetShadowSize(0.13)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, resetBathwater)

---@param player Entity
local function breakBathwater(_, player, _, flags, source)
    player = player:ToPlayer()
    for _, fam in ipairs(Isaac.FindByType(3,ToyboxMod.FAMILIAR_BATH_WATER)) do
        fam = fam:ToFamiliar()
        if(fam.State==0 and GetPtrHash(fam.Player)==GetPtrHash(player)) then
            fam.State = 1
            fam:GetSprite():Play("Drop", true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, breakBathwater, EntityType.ENTITY_PLAYER)



local function hfhhgh(_, effect)
    if(ToyboxMod:getEntityData(effect, "BATHWATER_CREEP")) then
        effect.Color = CREEP_COLOR
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, hfhhgh, EffectVariant.PLAYER_CREEP_RED)
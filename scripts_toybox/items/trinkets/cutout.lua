local sfx = SFXManager()

local TARGET_DIST = 4*40

local MULTIPLIER_COLLDAMAGE = 1

---@param pl EntityPlayer
local function trinketDrop(_, id, pos, pl, isgold)
    if(ToyboxMod:isRoomClear()) then return end

    local mult = pl:GetTrinketMultiplier(id)
    local finalmult = ((mult==0 and pl:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX)) and 1 or 0)+mult+(isgold and 2 or 1)

    local fam = Isaac.Spawn(3,ToyboxMod.FAMILIAR_DECOY,(isgold and 1 or 0),pos,Vector.Zero,pl):ToFamiliar()
    if(finalmult>1) then
        fam:GetSprite():SetFrame(1)
        fam.CollisionDamage = MULTIPLIER_COLLDAMAGE*(finalmult-1)
    end

    sfx:Play(ToyboxMod.SOUND_EFFECT.POOF)

    for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, id | (isgold and TrinketType.TRINKET_GOLDEN_FLAG or 0))) do
        if(pickup.FrameCount==0 and pickup.Position:Distance(pos)<1) then
            pickup:Remove()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_DROP_TRINKET, trinketDrop, ToyboxMod.TRINKET_CUTOUT)

---@param eff EntityFamiliar
local function decoyInit(_, eff)
    local sp = eff:GetSprite()
    sp:Play("Idle", true)
    sp:Stop()

    eff:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, decoyInit, ToyboxMod.FAMILIAR_DECOY)

---@param eff EntityFamiliar
local function decoyUpdate(_, eff)
    if(ToyboxMod:isRoomClear()) then
        eff:Kill()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, decoyUpdate, ToyboxMod.FAMILIAR_DECOY)

local function tryOverrideTarget(_, npc)
    local nearest
    local dist = 2^32
    for _, fam in ipairs(Isaac.FindInRadius(npc.Position, TARGET_DIST, EntityPartition.FAMILIAR)) do
        if(fam.Variant==ToyboxMod.FAMILIAR_DECOY) then
            local d = fam.Position:Distance(npc.Position)
            if(d<dist) then
                dist = d
                nearest = fam
            end
        end
    end

    if(nearest) then
        return nearest
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_NPC_PICK_TARGET, tryOverrideTarget)

local function replaceRemovedDecoy(_, ent)
    if(ent.Variant==ToyboxMod.FAMILIAR_DECOY) then
        local sub = ToyboxMod.TRINKET_CUTOUT | (ent.SubType>0 and TrinketType.TRINKET_GOLDEN_FLAG or 0)
        local trinket = Isaac.Spawn(5,350,sub,ent.Position,ent.Velocity,nil)
        trinket:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        local sp = trinket:GetSprite()
        while(sp:GetAnimation()=="Appear" and not sp:IsEventTriggered("DropSound")) do
            sp:Update()
        end

        local poof = Isaac.Spawn(1000,15,2,ent.Position,Vector.Zero,nil):ToEffect()
        sfx:Play(ToyboxMod.SOUND_EFFECT.POOF)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, replaceRemovedDecoy, EntityType.ENTITY_FAMILIAR)

local function removeDecoysOnExit(_)
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_DECOY)) do
        ent:Kill()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, removeDecoysOnExit)
local sfx = SFXManager()

local PETRIFY_DURATION = 4*30

local SMOG_FREQ = 10

---@param ent Entity
---@return boolean
local function isValidForLadybug(ent)
    ent = ent:ToNPC()
    return ent~=nil and ToyboxMod:isValidEnemy(ent) and (ent:IsChampion() or ToyboxMod:isModChampion(ent) or ent:IsBoss())
end

---@param pl EntityPlayer
local function use4StarredLadybug(_, _, pl, _)
    local plRef = EntityRef(pl)

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(isValidForLadybug(ent)) then
            ent:AddFreeze(plRef, PETRIFY_DURATION)

            for i=1, 9 do
                local vel = (i==1 and Vector.Zero or Vector.FromAngle(math.random(1,360))*(2+math.random(0,3)))
                local dust = Isaac.Spawn(1000,EffectVariant.DUST_CLOUD,0,ent.Position,vel,ent):ToEffect()
                dust.DepthOffset = -100
                dust.Color=Color(85/255,60/255,111/255,1,0,0,0)
                dust:SetTimeout(30)
                dust.SpriteScale = Vector(0.015,0.015)
            end
        end
    end

    ToyboxMod:setExtraData("4STAR_LADYBUG_ACTIVE", true)
    ToyboxMod:setExtraData("4STAR_LADYBUG_REF", plRef)

    Game():ShakeScreen(12)
    sfx:Play(ToyboxMod.SOUND_EFFECT.HAZE, 1.2, nil, nil, 0.9+math.random()*0.3)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, use4StarredLadybug, ToyboxMod.CONSUMABLE.FOUR_STARRED_LADYBUG)

---@param npc EntityNPC
local function updateLadybugNpc(_, npc)
    if(not ToyboxMod:getExtraData("4STAR_LADYBUG_ACTIVE")) then return end
    if(not isValidForLadybug(npc)) then return end

    npc:AddWeakness(ToyboxMod:getExtraData("4STAR_LADYBUG_PLAYER") or EntityRef(Isaac.GetPlayer()), 30, true)

    if(npc.FrameCount%SMOG_FREQ==1) then
        local vel = Vector.Zero
        local dust = Isaac.Spawn(1000,EffectVariant.DUST_CLOUD,0,npc.Position,vel,npc):ToEffect()
        dust:FollowParent(npc)
        dust.DepthOffset = -100
        dust.Color=Color(85/255,60/255,111/255,1,0,0,0)
        dust:SetTimeout(20)
        dust.SpriteScale = Vector(0.7,0.7)*(npc.Size*npc.SizeMulti/13)
        dust.SpriteOffset = Vector(0,-15)
    end 
end
ToyboxMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, updateLadybugNpc)

local function deactivateLadybugEffect(_)
    ToyboxMod:setExtraData("4STAR_LADYBUG_ACTIVE", nil)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, deactivateLadybugEffect)
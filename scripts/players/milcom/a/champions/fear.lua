local mod = MilcomMOD

local AURA_SCALE_POW = 0.3
local BASE_AURA_SIZE = 13
local BASE_AURA_RADIUS = 2*40
local FEAR_DURATION = math.floor(30*1.5)

local ACTIVE_DURATION = 60
local INACTIVE_DURATION = 60
local FADE_DURATION = 5

---@param npc EntityNPC
local function addFearAuraVisual(_, npc)
    local aura = Isaac.Spawn(1000, mod.EFFECT_AURA, mod.EFFECT_AURA_SUBTYPE.ENEMY_FEAR, npc.Position, Vector.Zero, npc):ToEffect()
    aura.DepthOffset = -1000
    aura:FollowParent(npc)
    aura:GetSprite():GetLayer(0):GetBlendMode():SetMode(BlendType.OVERLAY)

    aura.Scale = (npc.Size/BASE_AURA_SIZE)^AURA_SCALE_POW
    aura.SpriteScale = Vector(1,1)*aura.Scale*BASE_AURA_RADIUS/(2*40)

    aura:GetSprite():Play("Appear", true)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_CUSTOM_CHAMPION_INIT, addFearAuraVisual, mod.CUSTOM_CHAMPIONS.FEAR.Idx)

---@param npc EntityNPC
local function toggleFearColor(_, npc)
    if(mod:getEntityData(npc, "CUSTOM_CHAMPION_IDX")~=mod.CUSTOM_CHAMPIONS.FEAR.Idx) then return end

    local totalTimer = ACTIVE_DURATION+INACTIVE_DURATION
    local modVal = npc.FrameCount%totalTimer

    if(modVal>=ACTIVE_DURATION-FADE_DURATION and modVal<=ACTIVE_DURATION+FADE_DURATION) then
        local lerpVal = (ACTIVE_DURATION-modVal)/(2*FADE_DURATION)+0.5

        npc.Color = Color.Lerp(Color(1,1,1), mod.CUSTOM_CHAMPIONS.FEAR.Color, lerpVal)

        --print(lerpVal)
    elseif(modVal>=totalTimer-FADE_DURATION or modVal<=FADE_DURATION) then
        local lerpVal = 1-(modVal+2*FADE_DURATION)%totalTimer/(2*FADE_DURATION)+0.5

        npc.Color = Color.Lerp(mod.CUSTOM_CHAMPIONS.FEAR.Color, Color(1,1,1), lerpVal)
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, toggleFearColor)

---@param effect EntityEffect
local function fearAuraLogic(_, effect)
    if(effect.SubType~=mod.EFFECT_AURA_SUBTYPE.ENEMY_FEAR) then return end

    local sp = effect:GetSprite()
    if(sp:IsFinished("Appear")) then
        sp:Play("Idle", true)
    end

    local alpha = 0.5

    local totalTimer = ACTIVE_DURATION+INACTIVE_DURATION
    local modVal = effect.FrameCount%totalTimer

    effect.State = 0
    if(modVal>=ACTIVE_DURATION-FADE_DURATION and modVal<=ACTIVE_DURATION+FADE_DURATION) then
        local lerpVal = (ACTIVE_DURATION-modVal)/(2*FADE_DURATION)+0.5

        alpha = alpha*mod:lerp(0,1,lerpVal)
    elseif(modVal>=totalTimer-FADE_DURATION or modVal<=FADE_DURATION) then
        local lerpVal = 1-(modVal+2*FADE_DURATION)%totalTimer/(2*FADE_DURATION)+0.5

        alpha = alpha*mod:lerp(1,0,lerpVal)

        effect.State = 1
    elseif(modVal>ACTIVE_DURATION+FADE_DURATION and modVal<totalTimer-FADE_DURATION) then
        alpha = 0
        effect.State = 1
    end
    
    if(sp:GetAnimation()=="Idle") then
        alpha = alpha*(1+0.1*math.sin(math.rad(effect.FrameCount-sp:GetAnimationData("Appear"):GetLength())*15))

        if(effect.State==0) then
            for _, pl in ipairs(Isaac.FindInRadius(effect.Position, BASE_AURA_RADIUS*effect.Scale, EntityPartition.PLAYER)) do
                pl = pl:ToPlayer()
                pl:AddFear(EntityRef(effect), math.max(0, FEAR_DURATION-pl:GetFearCountdown()))
            end
        end
    end
    effect.Color = Color(1,1,1,alpha)

    if(effect:Exists() and not (effect.Parent and effect.Parent:Exists())) then
        if(sp:GetAnimation()~="Disappear") then
            sp:Play("Disappear")
        end
        if(sp:IsFinished("Disappear")) then
            effect:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, fearAuraLogic, mod.EFFECT_AURA)
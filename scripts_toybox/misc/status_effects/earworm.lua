local EARWORM_BOSS_DURATION = 30*6
local EARWORM_SPEED_MULT = 1.5
local EARWORM_DMG_MULT = 1.5

ToyboxMod:addOverlayEffect("Earworm", "Earworm", nil, nil, 100)

local STATUS_COLOR_BLUE = Color((167/233),(212/233),(233/233),1,0.2*(167/233),0.2*(212/233),0.2*(233/233))
local STATUS_COLOR_PINK = Color((205/227),(175/227),(227/227),1,0.2*(205/227),0.2*(175/227),0.2*(227/227))

---@param ent Entity
---@param duration integer Negative makes it a setter instead of additive
---@param source EntityRef
---@param ignoreBoss? boolean Default: false
function ToyboxMod:applyEarworm(ent, duration, source, ignoreBoss)
    ToyboxMod:applyStatusEffect(ent, "Earworm", duration, source, false, ignoreBoss)
end

---@param npc EntityNPC
local function earwormUpdate(_, npc)
    if(not ToyboxMod:hasStatusEffect(npc, "Earworm")) then return end

    npc:SetSpeedMultiplier(npc:GetSpeedMultiplier()*EARWORM_SPEED_MULT)

    local statusCycleDuration = 20
    local clampedFrame = (npc.FrameCount)%(statusCycleDuration*2)
    local color = STATUS_COLOR_BLUE--Color.Lerp(STATUS_COLOR_BLUE, STATUS_COLOR_PINK, (clampedFrame/statusCycleDuration)^8)
    if(clampedFrame>=statusCycleDuration) then
        color = STATUS_COLOR_PINK--Color.Lerp(STATUS_COLOR_PINK, STATUS_COLOR_BLUE, ((clampedFrame-statusCycleDuration)/statusCycleDuration)^8)
    end
    npc:SetColor(color,2,100,false,true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, earwormUpdate)

---@param ent Entity
local function earwormTakeDmg(_, ent, dmg, flags, source, cooldown)
    if(not ToyboxMod:hasStatusEffect(ent, "Earworm")) then return end

    return
    {
        Damage = dmg*EARWORM_DMG_MULT,
        DamageFlags = flags,
        DamageCountdown = cooldown,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, earwormTakeDmg)
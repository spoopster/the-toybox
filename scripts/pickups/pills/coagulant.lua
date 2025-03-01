local mod = MilcomMOD
local sfx = SFXManager()

local HORSE_INVINCIBILITY = 3*60

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)

    for i=1, (isHorse and 3 or 1) do
        local pos = Vector.FromAngle(math.random(360))*4
        local clot = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLOOD_BABY, 0, player.Position, pos, player):ToFamiliar()
        clot.Parent = player
        clot.Player = player

        clot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end

    sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER)
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
    player:AnimateHappy()
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_COAGULANT)

local function coagReduce(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    local coagMode = mod:getEntityData(player, "COAGULANT_MODE")
    if(coagMode==0) then return end

    if(dmg>0) then
        mod:setEntityData(player, "COAGULANT_MODE", 0)
        if(coagMode==1) then
            sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1.5)
            sfx:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT, 0.5, 3)

            return {
                Damage=dmg-1,
                DamageFlags=flags,
                DamageCountdown=frames
            }
        elseif(coagMode==2) then -- horse effect
            mod:setEntityData(player, "COAGULANT_MODE", 3)
            sfx:Play(SoundEffect.SOUND_VAMP_DOUBLE, 1.5)
            sfx:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT, 0.5, 3)

            return {
                Damage=0,
                DamageFlags=flags,
                DamageCountdown=frames
            }
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, coagReduce, EntityType.ENTITY_PLAYER)

---@param player Entity
local function postCoagReduce(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    local coagMode = mod:getEntityData(player, "COAGULANT_MODE")
    if(coagMode==3) then
        player:SetMinDamageCooldown(HORSE_INVINCIBILITY)
        mod:setEntityData(player, "COAGULANT_MODE", 0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, postCoagReduce, EntityType.ENTITY_PLAYER)

local sfx = SFXManager()

local CLOUD_DURATION = 20*30
local CREEP_DURATION = 20*30
local CREEP_DAMAGE = 4

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)

    local fart = Game():Fart(player.Position, 85, player)
    
    local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, player.Position, Vector.Zero, nil):ToEffect()
    if(isHorse) then
        cloud:SetTimeout(-1)
        cloud.SpriteScale = Vector(1,1)*3

        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, player.Position, Vector.Zero, nil):ToEffect()
        creep.SpriteScale = Vector(1,1)*3.5
        creep:SetTimeout(CREEP_DURATION)
        creep.CollisionDamage = CREEP_DAMAGE
    else
        cloud:SetTimeout(CLOUD_DURATION)
        cloud.SpriteScale = Vector(1,1)*2
    end

    cloud:ClearEntityFlags(EntityFlag.FLAG_PERSISTENT)
    ToyboxMod:setEntityData(cloud, "KILL_ON_ROOM_EXIT", true)

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED or SoundEffect.SOUND_THUMBS_DOWN))
    player:AnimateSad()
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_FOOD_POISONING)

local function removeCloudsOnExit(_)
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD)) do
        if(ToyboxMod:getEntityData(ent, "KILL_ON_ROOM_EXIT")) then
            ent:Remove()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, removeCloudsOnExit)
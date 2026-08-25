local KILLS_FOR_SHIELD = 20
local STACK_KILL_REDUCTION = 5
local MIN_KILLS = 5

local CREEP_DMG = 3
local CREEP_DURATION = 30*5

---@param npc EntityNPC
local function tryGiveMantle(_, npc)
    local pl = PlayerManager.GetRandomCollectibleOwner(ToyboxMod.COLLECTIBLE_LEATHERFACE, npc:GetDropRNG():Next())
    if(not pl) then return end

    local killsReq = math.max(MIN_KILLS, KILLS_FOR_SHIELD-STACK_KILL_REDUCTION*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_LEATHERFACE))

    local data = ToyboxMod:getEntityDataTable(pl)
    data.LEATHERFACE_KILLS = (data.LEATHERFACE_KILLS or 0)+1
    if(data.LEATHERFACE_KILLS>=killsReq) then
        data.LEATHERFACE_KILLS = 0
        if(not pl:GetEffects():HasNullEffect(NullItemID.ID_HOLY_CARD)) then
            pl:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true)
            pl:AddNullItemEffect(NullItemID.ID_HOLY_CARD, true)
        end

        local maxdist = npc.Position:Distance(pl.Position)
        local dir = (pl.Position-npc.Position):Normalized()
        local pos = npc.Position
        while(pos:Distance(pl.Position)>20) do
            local particle = Isaac.Spawn(1000,111,0,pos,Vector.Zero,nil):ToEffect()
            particle.SpriteScale = Vector.One*((1-pos:Distance(pl.Position)/maxdist)*0.6+0.1)
            particle.Color = Color(0,0,0,1,200/255,0,0,2)
            particle:GetSprite():SetCustomShader("shaders_tb/pixelate")

            pos = pos+dir*20
        end

        local eff = Isaac.Spawn(1000,ToyboxMod.EFFECT_BLOOD_COLLECT,0,npc.Position,Vector.Zero,nil)
        
        local poof = Isaac.Spawn(1000,16,5,pl.Position,Vector.Zero,nil)
        poof.SpriteScale = Vector(1,1)*0.5
        poof.Color = Color(0,0,0,1,200/255,0,0,2)
        poof:GetSprite().PlaybackSpeed = 1.25
        poof:GetSprite():SetCustomShader("shaders_tb/pixelate")
        
        ToyboxMod.SFX:Play(SoundEffect.SOUND_MEAT_JUMPS)
    end

    local creep = Isaac.Spawn(1000,EffectVariant.PLAYER_CREEP_RED,0,npc.Position,Vector.Zero,player):ToEffect()
    creep.CollisionDamage = CREEP_DMG
    creep:SetTimeout(CREEP_DURATION)
    creep.SpriteScale = Vector(1,1)*npc.Size*npc.SizeMulti/13

    ToyboxMod.SFX:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, tryGiveMantle)
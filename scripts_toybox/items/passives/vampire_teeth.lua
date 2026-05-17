local sfx = SFXManager()

local BLEED_CHANCE = 0.10
local BLEED_MAXCHANCE = 0.5
local BLEED_MAXLUCK = 20

local BLEED_DURATION = 3*30

ToyboxMod:addTearFlagEnum(
    "VAMPIRETEETH_BLEED",
    ---@param npc EntityNPC
    ---@param source Entity
    function(npc, flag, source, pos, dmg, key)
        npc:AddBleeding(EntityRef(ToyboxMod:getPlayerFromEnt(source)), math.max(0, BLEED_DURATION-npc:GetBleedingCountdown()))
    end,
    TearVariant.BLOOD,
    Color(1.3,0.9,0.9,1,0.1,0,0)
)

---@param pl EntityPlayer
local function giveTearflag(_, pl, _)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_VAMPIRE_TEETH)) then return end

    ToyboxMod:addTearFlag(
        pl,
        "VAMPIRETEETH_BLEED",
        ---@param player EntityPlayer
        function(player)
            return ToyboxMod:getLuckAffectedChance(player.Luck, BLEED_CHANCE, BLEED_MAXLUCK, BLEED_MAXCHANCE)
        end,
        ToyboxMod.COLLECTIBLE_VAMPIRE_TEETH
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, giveTearflag, CacheFlag.CACHE_TEARFLAG)

---@param npc EntityNPC
local function healOnBleedKill(_, npc)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_VAMPIRE_TEETH)) then return end
    if(not npc:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT)) then return end

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_VAMPIRE_TEETH)) then
            pl:AddHearts(1)


            local maxdist = npc.Position:Distance(pl.Position)
            local dir = (pl.Position-npc.Position):Normalized()
            local pos = npc.Position
            while(pos:Distance(pl.Position)>20) do
                local particle = Isaac.Spawn(1000,111,0,pos,Vector.Zero,nil):ToEffect()
                particle.SpriteScale = Vector.One*((1-pos:Distance(pl.Position)/maxdist)*0.6+0.1)
                particle.Color = Color(0,0,0,1,200/255,0,0,2)
                particle:GetSprite():SetCustomShader("spriteshaders/pixelateshader")

                pos = pos+dir*20
            end

            local gulpEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, pl.Position, Vector.Zero, nil):ToEffect()
            gulpEffect.SpriteOffset = Vector(0, -14)

            sfx:Play(SoundEffect.SOUND_MEAT_JUMPS)
            sfx:Play(SoundEffect.SOUND_VAMP_GULP)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, healOnBleedKill)
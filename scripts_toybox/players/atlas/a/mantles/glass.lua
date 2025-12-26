
local sfx = SFXManager()

local MANTLE_DMG_UP = 0.5
local TRANSF_DMG_MULT = 1.5
local SHOTSPEED_UP = 0.1

local SHATTER_CHANCE = 0.9

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not ToyboxMod:isAtlasA(player)) then return end
    local numMantles = ToyboxMod:getNumMantlesByType(player, ToyboxMod.MANTLE_DATA.GLASS.ID)

    if(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(player, MANTLE_DMG_UP*numMantles)
        if(ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.GLASS.ID)) then
            player.Damage = player.Damage*TRANSF_DMG_MULT
        end
    end
    if(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+SHOTSPEED_UP*numMantles
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function destroyGlassMantles(_, player, mantle)
    if(not ToyboxMod:isAtlasA(player)) then return end
    if(ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.GLASS.ID)) then return end
    local data = ToyboxMod:getAtlasATable(player)

    for i=1, data.HP_CAP do
        if(data.MANTLES[i].TYPE==ToyboxMod.MANTLE_DATA.GLASS.ID) then
            data.MANTLES[i] = {
                TYPE = ToyboxMod.MANTLE_DATA.NONE.ID,
                HP = ToyboxMod.MANTLE_DATA.NONE.HP,
                MAXHP = ToyboxMod.MANTLE_DATA.NONE.HP,
            }
        end
    end
    sfx:Play(ToyboxMod.SOUND_EFFECT.ATLASA_GLASSBREAK)

    local poof = Isaac.Spawn(1000,16,1,player.Position,Vector.Zero,nil):ToEffect()
    poof.Color = Color(1,1,1,1,0.5,0.5,0.5)
    poof.SpriteScale = Vector(1,1)*0.5
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, destroyGlassMantles, ToyboxMod.MANTLE_DATA.GLASS.ID)

local function shatterMantles(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    if(not ToyboxMod:isAtlasA(player)) then return end
    if(not ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.GLASS.ID)) then return end
    local data = ToyboxMod:getAtlasATable(player)
    local rng = player:GetCardRNG(ToyboxMod.CARD_MANTLE_GLASS)

    if(rng:RandomFloat()>=SHATTER_CHANCE) then
        return
        {
            Damage = 0,
            DamageFlags = flags,
            DamageCountdown = frames,
        }
    end

    for i=1, data.HP_CAP do
        if(data.MANTLES[i].TYPE~=ToyboxMod.MANTLE_DATA.NONE.ID) then
            data.MANTLES[i] = {
                TYPE = ToyboxMod.MANTLE_DATA.NONE.ID,
                HP = ToyboxMod.MANTLE_DATA.NONE.HP,
                MAXHP = ToyboxMod.MANTLE_DATA.NONE.HP,
            }
        end
    end
    ToyboxMod:updateMantles(player)

    sfx:Play(ToyboxMod.SOUND_EFFECT.ATLASA_GLASSBREAK)

    local poof = Isaac.Spawn(1000,16,1,player.Position,Vector.Zero,nil):ToEffect()
    poof.Color = Color(1,1,1,1,0.5,0.5,0.5)
    poof.SpriteScale = Vector(1,1)*0.5

    return
    {
        Damage = 0,
        DamageFlags = flags,
        DamageCountdown = frames,
    }
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1e12-2+(CustomHealthAPI and (-1e12-1e3) or 0), shatterMantles, EntityType.ENTITY_PLAYER)
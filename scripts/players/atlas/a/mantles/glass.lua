local mod = MilcomMOD
local sfx = SFXManager()

if(mod.ATLAS_A_MANTLESUBTYPES) then
    mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_GLASS] = true
end

local function useMantle(_, _, player, _)
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
        mod:giveMantle(player, mod.MANTLE_DATA.GLASS.ID)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_GLASS)

local ENUM_DAMAGE_BONUS = 1/6
local ENUM_TRANSF_DMG_BONUS = 0.5
local ENUM_SHOTSPEED_BONUS = 0.1

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    local numMantles = mod:getNumMantlesByType(player, mod.MANTLE_DATA.GLASS.ID)

    if(flag==CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*(1+ENUM_DAMAGE_BONUS*numMantles+ENUM_TRANSF_DMG_BONUS*(mod:atlasHasTransformation(player, mod.MANTLE_DATA.GLASS.ID) and 1 or 0))
    end
    if(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+ENUM_SHOTSPEED_BONUS*numMantles
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function destroyGlassMantles(_, player, mantle)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)
    if(mod:atlasHasTransformation(player, mod.MANTLE_DATA.GLASS.ID)) then return end

    for i=1, data.HP_CAP do
        if(data.MANTLES[i].TYPE==mod.MANTLE_DATA.GLASS.ID) then
            data.MANTLES[i] = {
                TYPE = mod.MANTLE_DATA.NONE.ID,
                HP = mod.MANTLE_DATA.NONE.HP,
                MAXHP = mod.MANTLE_DATA.NONE.HP,
            }
        end
    end

    sfx:Play(mod.SFX_ATLASA_GLASSBREAK)

    local poof = Isaac.Spawn(1000,16,1,player.Position,Vector.Zero,nil):ToEffect()
    poof.Color = Color(1,1,1,1,0.5,0.5,0.5)
    poof.SpriteScale = Vector(1,1)*0.75
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, destroyGlassMantles, mod.MANTLE_DATA.GLASS.ID)

---@param player EntityPlayer
local function destroyAllMantles(_, player, mantle)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)
    if(not mod:atlasHasTransformation(player, mod.MANTLE_DATA.GLASS.ID)) then return end

    for i=1, data.HP_CAP do
        if(data.MANTLES[i].TYPE~=mod.MANTLE_DATA.NONE.ID) then
            data.MANTLES[i] = {
                TYPE = mod.MANTLE_DATA.NONE.ID,
                HP = mod.MANTLE_DATA.NONE.HP,
                MAXHP = mod.MANTLE_DATA.NONE.HP,
            }
        end
    end

    sfx:Play(mod.SFX_ATLASA_GLASSBREAK)

    local poof = Isaac.Spawn(1000,16,1,player.Position,Vector.Zero,nil):ToEffect()
    poof.Color = Color(1,1,1,1,0.5,0.5,0.5)
    poof.SpriteScale = Vector(1,1)*0.75
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, destroyAllMantles)
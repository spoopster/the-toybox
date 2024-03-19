local mod = MilcomMOD

--* TODO:
-- polish mantle effects a bit
-- hopefully wait for 1.0.6 to add player healing hook

--#region DATA
local ATLAS_A_BASEDATA = {
    CHARACTER_SIDE = "A",

    HP_CAP = 3,
    MANTLES = {
        { TYPE=mod.MANTLES.DEFAULT, HP=mod.MANTLES_HP.DEFAULT, MAXHP=mod.MANTLES_HP.DEFAULT, COLOR=Color(1,1,1,1), },
        { TYPE=mod.MANTLES.DEFAULT, HP=mod.MANTLES_HP.DEFAULT, MAXHP=mod.MANTLES_HP.DEFAULT, COLOR=Color(1,1,1,1), },
        { TYPE=mod.MANTLES.DEFAULT, HP=mod.MANTLES_HP.DEFAULT, MAXHP=mod.MANTLES_HP.DEFAULT, COLOR=Color(1,1,1,1), },
    },
    TRANSFORMATION = mod.MANTLES.DEFAULT,
    BIRTHRIGHT_TRANSFORMATION = mod.MANTLES.NONE,
    TIME_HAS_BEEN_IN_TRANSFORMATION = 0,
    MANTLE_SHARDS = {},

    BOOK_OF_SHADOWS_BUBBLE = nil,

    SALT_AUTOTARGET_ENABLED = false,
}

mod.ATLAS_A_BASEDATA = ATLAS_A_BASEDATA
mod.ATLAS_A_DATA = {}

---@param player EntityPlayer
local function postAtlasInit(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)

    mod:updateMantles(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postAtlasInit)

---@param player EntityPlayer
local function postAtlasUpdate(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)
    local isTar = mod:atlasHasTransformation(player, mod.MANTLES.TAR)

    if(data.BOOK_OF_SHADOWS_BUBBLE and isTar) then
        data.BOOK_OF_SHADOWS_BUBBLE:Remove()
        data.BOOK_OF_SHADOWS_BUBBLE = nil
    end
    if(data.BOOK_OF_SHADOWS_BUBBLE and not data.BOOK_OF_SHADOWS_BUBBLE:Exists()) then data.BOOK_OF_SHADOWS_BUBBLE=nil end

    if(not isTar) then
        local e = player:GetEffects():GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
        if(e and data.BOOK_OF_SHADOWS_BUBBLE==nil) then
            local bubble = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECT_ATLAS_BOOKOFSHADOWS_BUBBLE, 0, player.Position, player.Velocity, player):ToEffect()
            bubble:FollowParent(player)

            data.BOOK_OF_SHADOWS_BUBBLE = bubble
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postAtlasUpdate)

---@param player EntityPlayer
local function postAtlasRender(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    --! FOR TESTING PURPOSES, DELETE ON RELEASE
    if(mod.ATLAS_A_DATA[player.InitSeed]==nil) then mod.ATLAS_A_DATA[player.InitSeed] = mod:cloneTable(mod.ATLAS_A_BASEDATA) end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postAtlasRender)

-- [[
local function replaceAtlasPeeStain(_, effect)
    if(not PlayerManager.AnyoneIsPlayerType(mod.PLAYER_ATLAS_A)) then return end
    if(effect.FrameCount~=0) then return end

    local tint = effect:GetColor():GetOffset()
    local isYellow = (tint.R>0.001 and tint.G>0.001 and math.abs(tint.R-tint.G)<0.001) and (tint.B<0.001)

    if(isYellow and math.abs(tint.R-244/255)<0.001) then
        if(mod:anyAtlasAHasTransformation(mod.MANTLES.TAR)) then effect.Color = Color(0,0,0)
        elseif(mod:anyAtlasAHasTransformation(mod.MANTLES.POOP)) then effect.Color = Color(0,0,0,1,124/255,86/255,52/255)
        else effect:Remove() end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, replaceAtlasPeeStain, EffectVariant.BLOOD_SPLAT)
-- ]]

local function cancelHeartCollision(_, pickup, player)
    if(not (player and player:ToPlayer() and player:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end
    return false
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, -1e12+1, cancelHeartCollision, PickupVariant.PICKUP_HEART)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT,
function(_, effect)
    local s = effect:GetSprite()

    s:Load("gfx/characters/058_book of shadows.anm2", true)
    s:Play("WalkDown", true)

    effect.DepthOffset = 5
end,
mod.EFFECT_ATLAS_BOOKOFSHADOWS_BUBBLE)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE,
function(_, effect)
    local p = Isaac.GetPlayer()
    if(effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer()) then p = effect.SpawnerEntity:ToPlayer() end

    local e = p:GetEffects():GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
    if(e and e.Cooldown<=90) then
        if(e.Cooldown%15>=8) then effect.Visible = false
        else effect.Visible = true end
    end
    if(not e) then effect:Remove() end
end,
mod.EFFECT_ATLAS_BOOKOFSHADOWS_BUBBLE)
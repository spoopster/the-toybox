
local sfx = SFXManager()

local NUM_BULLETS = 5

local BASE_BULLET_DMG = 15
local BASE_BULLET_SPREAD = 5
local FOAMBULLET_DMGMOD = 1.5

local FOAM_BULLET_SPAWNCHANCE = 0.2

local BULLET_SPEED = 20

ToyboxMod:registerThrowableActive(ToyboxMod.COLLECTIBLE_TOY_GUN, false, false)

local function useToyGun(_, item, player, rng, flags, slot)
    local data = player:GetActiveItemDesc(slot)
    if(data.VarData>0) then
        if(Game():GetDebugFlags() & DebugFlag.INFINITE_ITEM_CHARGES == 0) then
            data.VarData = data.VarData-1
        end

        local v = Vector.FromAngle(player:GetAimDirection():GetAngleDegrees()+(rng:RandomFloat()-0.5)*spr)*BULLET_SPEED
        local bullet = Isaac.Spawn(2, ToyboxMod.TEAR_VARIANT.BULLET, 0, player.Position, v, nil):ToTear()

        bullet.CollisionDamage = BASE_BULLET_DMG+FOAMBULLET_DMGMOD*bStacks
        bullet.Scale = 2.5
        bullet.SpriteScale = bullet.SpriteScale*(1/bullet.Scale)
        bullet:AddTearFlags(TearFlags.TEAR_KNOCKBACK | TearFlags.TEAR_PUNCH)
        bullet.KnockbackMultiplier=3

        sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
        sfx:Play(ToyboxMod.SOUND_EFFECT.BULLET_FIRE)
    else
        sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.USE_THROWABLE_ACTIVE, useToyGun, ToyboxMod.COLLECTIBLE_TOY_GUN)

---@param player EntityPlayer
local function postAddItem(_, _, _, firstTime, slot, vData, player)
    if(firstTime~=true) then return end
    player:GetActiveItemDesc(slot).VarData = NUM_BULLETS
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem, ToyboxMod.COLLECTIBLE_TOY_GUN)

local f = Font("font/pftempestasevencondensed.fnt")

---@param player EntityPlayer
local function renderCounter(_, player, slot, offset, alpha, scale)
    if(slot==1) then return end
    local item = player:GetActiveItem(slot)
    if(item~=ToyboxMod.COLLECTIBLE_TOY_GUN) then return end
    f:DrawString("x"..player:GetActiveItemDesc(slot).VarData,offset.X, offset.Y+18,KColor(1,1,1,alpha))
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderCounter)
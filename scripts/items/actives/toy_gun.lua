local mod = MilcomMOD

local MAXCHARGES = 5
local BATTERY_MAXCHARGES = 10
local FOAMBULLET_CHARGEMOD = 1

local BASE_BULLET_DMG = 15
local BASE_BULLET_SPREAD = 5
local FOAMBULLET_DMGMOD = 1.5

local FOAM_BULLET_SPAWNCHANCE = 0.2

local CARBATTERY_BULLETSPREAD = 20
local CARBATTERY_BULLETS = 3

local BULLET_SPEED = 20

mod:registerThrowableActive(mod.COLLECTIBLE_TOY_GUN, false, false)

local function useToyGun(_, item, player, rng, flags, slot)
    local data = player:GetActiveItemDesc(slot)
    if(data.VarData>0) then
        if(Game():GetDebugFlags() & DebugFlag.INFINITE_ITEM_CHARGES == 0) then
            data.VarData = data.VarData-1
            if(data.Charge==Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE_TOY_GUN).MaxCharges) then
                data.VarData = data.VarData-1
            end
        end

        local bStacks = player:GetTrinketMultiplier(mod.TRINKET_FOAM_BULLET)
        local hasCarBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)

        local spr = (hasCarBattery and CARBATTERY_BULLETSPREAD or BASE_BULLET_SPREAD)
        for i=1, (hasCarBattery and CARBATTERY_BULLETS or 1) do
            local v = Vector.FromAngle(player:GetShootingJoystick():GetAngleDegrees()+(rng:RandomFloat()-0.5)*spr)*BULLET_SPEED
            local bullet = Isaac.Spawn(2, mod.TEAR_BULLET, 0, player.Position, v, nil):ToTear()

            bullet.CollisionDamage = BASE_BULLET_DMG+FOAMBULLET_DMGMOD*bStacks
            bullet.Scale = 2.5
            bullet.SpriteScale = bullet.SpriteScale*(1/bullet.Scale)
            bullet:AddTearFlags(TearFlags.TEAR_KNOCKBACK | TearFlags.TEAR_PUNCH)
            bullet.KnockbackMultiplier=3
        end
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.USE_THROWABLE_ACTIVE, useToyGun, mod.COLLECTIBLE_TOY_GUN)

---@param player EntityPlayer
local function postAddItem(_, _, _, firstTime, slot, vData, player)
    if(firstTime~=true) then return end
    player:GetActiveItemDesc(slot).VarData = 0
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem, mod.COLLECTIBLE_TOY_GUN)

---@param player EntityPlayer
local function toyGunLogic(_, player)
    local cIdx = player.ControllerIndex
    local bStacks = player:GetTrinketMultiplier(mod.TRINKET_FOAM_BULLET)

    for _, i in pairs(ActiveSlot) do
        local data = player:GetActiveItemDesc(i)

        if(data.Item==mod.COLLECTIBLE_TOY_GUN) then
            local mCharge = Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE_TOY_GUN).MaxCharges
            local maxCharges = (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and BATTERY_MAXCHARGES or MAXCHARGES)+bStacks*FOAMBULLET_CHARGEMOD

            local isUsingPrimary = (i==ActiveSlot.SLOT_PRIMARY and Input.IsActionTriggered(ButtonAction.ACTION_ITEM, cIdx))
            local isUsingPocket = (i==ActiveSlot.SLOT_POCKET and Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, cIdx))
            if(data.Charge<mCharge and data.VarData>0 and (isUsingPrimary or isUsingPocket)) then
                player:UseActiveItem(mod.COLLECTIBLE_TOY_GUN, 0, i)
            end

            if(data.Charge<mCharge) then
                local toAdd = 1
                if(player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT)) then toAdd=2 end

                data.Charge = math.min(mCharge, data.Charge+toAdd)
            end
            if(data.VarData<maxCharges and data.Charge==mCharge) then
                data.Charge=0
                data.VarData = data.VarData+1
            end
        end
    end

    if(player:HasCollectible(mod.COLLECTIBLE_TOY_GUN)) then
        for i=0,1 do
            local t = player:GetTrinket(i)
            if(t==mod.TRINKET_FOAM_BULLET or t==mod.TRINKET_FOAM_BULLET+TrinketType.TRINKET_GOLDEN_FLAG) then
                player:AddSmeltedTrinket(t, false)
                player:TryRemoveTrinket(t)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, toyGunLogic)

local f = Font("font/pftempestasevencondensed.fnt")

---@param player EntityPlayer
local function renderCounter(_, player, slot, offset, alpha, scale)
    if(slot==1) then return end
    local item = player:GetActiveItem(slot)
    if(item~=mod.COLLECTIBLE_TOY_GUN) then return end
    f:DrawString("x"..player:GetActiveItemDesc(slot).VarData,offset.X, offset.Y+18,KColor(1,1,1,alpha))
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderCounter)


local function replaceTrinket(_, trinket, rng)
    if(PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_TOY_GUN) and rng:RandomFloat()<FOAM_BULLET_SPAWNCHANCE) then
        return mod.TRINKET_FOAM_BULLET
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_GET_TRINKET, CallbackPriority.LATE, replaceTrinket)
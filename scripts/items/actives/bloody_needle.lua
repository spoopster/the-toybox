local mod = MilcomMOD

local ENUM_TEARSTOADD = 0.3

---@param player EntityPlayer
local function useBloodyNeedle(_, _, rng, player, flags)
    player:ResetDamageCooldown()
    player:TakeDamage(1, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(nil), 30)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useBloodyNeedle, mod.COLLECTIBLE_BLOODY_NEEDLE)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:GetEffects():GetCollectibleEffect(mod.COLLECTIBLE_BLOODY_NEEDLE)) then return end

    local mult = player:GetEffects():GetCollectibleEffect(mod.COLLECTIBLE_BLOODY_NEEDLE).Count
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)) then mult=mult*1.5 end

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = player.MaxFireDelay/(1+mult*ENUM_TEARSTOADD)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local itemSprite = Sprite("gfx/ui/tb_custom_active_renders.anm2", true)
itemSprite:Play("Bloody Needle", true)

---@param player EntityPlayer
local function renderOver(_, player, slot, offset, a, scale)
    if(not ((slot==ActiveSlot.SLOT_PRIMARY or slot==ActiveSlot.SLOT_POCKET) and player:GetActiveItem(slot)==mod.COLLECTIBLE_BLOODY_NEEDLE)) then return end

    itemSprite.Scale = Vector(scale,scale)
    itemSprite.Color = Color(1,1,1,a)

    itemSprite:Render(offset+Vector(16,16))
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderOver)
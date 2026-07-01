
local sfx = SFXManager()

local TEARSTOADD = 0.7
local TEARSTOADD_BATTERY = 1
local TEARS_PRICE = 5

---@param player EntityPlayer
local function useSunkCosts(_, _, rng, player, flags)
    if(player:GetNumCoins()>=TEARS_PRICE) then
        player:AddCoins(-TEARS_PRICE)
        sfx:Play(SoundEffect.SOUND_CASH_REGISTER)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    else
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useSunkCosts, ToyboxMod.COLLECTIBLE_SUNK_COSTS)

---@param pl EntityPlayer
local function evalColorCache(_, pl)
    local eff = pl:GetEffects()
    if(not eff:HasCollectibleEffect(ToyboxMod.COLLECTIBLE_SUNK_COSTS)) then return end
    local mult = eff:GetCollectibleEffectNum(ToyboxMod.COLLECTIBLE_SUNK_COSTS)
    pl.Color = pl.Color*Color(1,1,1,1,0,0,0,1,1,0,math.min(1,mult*0.2))
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalColorCache, CacheFlag.CACHE_COLOR)


local itemSprite = Sprite("gfx_tb/ui/custom_active_renders.anm2", false)
itemSprite:Play("ActiveSilhouette", true)
local itemGfxPath = Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_SUNK_COSTS).GfxFileName
for i=0, 5 do
    itemSprite:ReplaceSpritesheet(i, itemGfxPath, false)
end
itemSprite:LoadGraphics()

---@param player EntityPlayer
local function renderUnder(_, player, slot, offset, a, scale)
    if(player:GetNumCoins()>=TEARS_PRICE) then
        return {
            HideItem = true,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, renderUnder, ToyboxMod.COLLECTIBLE_SUNK_COSTS)

---@param player EntityPlayer
local function renderOver(_, player, slot, offset, a, scale)
    if(player:GetNumCoins()>=TEARS_PRICE) then
        itemSprite.Color = Color(1,1,1,a)
        itemSprite.Scale = Vector(scale, scale)
        itemSprite:Render(offset+Vector(16,16)*scale)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderOver, ToyboxMod.COLLECTIBLE_SUNK_COSTS)

local sfx = SFXManager()

local TEARSTOADD = 0.7
local TEARSTOADD_BATTERY = 1
local TEARS_PRICE = 5

---@param player EntityPlayer
local function preUseSunkCosts(_, _, rng, player, flags)
    if(player:GetNumCoins()<TEARS_PRICE) then return true end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, preUseSunkCosts, ToyboxMod.COLLECTIBLE_SUNK_COSTS)

---@param player EntityPlayer
local function useSunkCosts(_, _, rng, player, flags)
    player:AddCoins(-TEARS_PRICE)
    sfx:Play(SoundEffect.SOUND_CASH_REGISTER)

    local mult = 0
    if(player:GetEffects():GetCollectibleEffect(ToyboxMod.COLLECTIBLE_SUNK_COSTS)) then
        mult = player:GetEffects():GetCollectibleEffect(ToyboxMod.COLLECTIBLE_SUNK_COSTS).Count
    end
    mult = mult+1

    local col = player.Color
    col:SetColorize(1,1,0,math.min(1, mult*0.2))
    player.Color = col

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useSunkCosts, ToyboxMod.COLLECTIBLE_SUNK_COSTS)

---@param player EntityPlayer
local function postNewRoom(_, player)
    local col = player.Color
    col:SetColorize(1,1,1,0)
    player.Color = col
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)


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
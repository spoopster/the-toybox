
local sfx = SFXManager()

local showingItemName = 0

local trinketToShow = 0
local isGoldTrinket = false
local trueName = ""
local isShowingTrinketName = false

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)

    local tr = Game():GetItemPool():GetTrinket()
    if(isHorse) then tr = tr | TrinketType.TRINKET_GOLDEN_FLAG end
    player:AddSmeltedTrinket(tr, true)

    isShowingTrinketName = true
    Game():GetHUD():ShowItemText(player, Isaac.GetItemConfig():GetTrinket(tr))
    isShowingTrinketName = false

    Game():GetHUD():ShowItemText("Capsule!", "You got... "..tostring(trueName)..((tr & TrinketType.TRINKET_GOLDEN_FLAG~=0) and "!!!!!" or "!"))

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
    player:AnimateHappy()
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_EFFECT.CAPSULE)

local function showStreakText(_, title, subtitle, issticky, iscurse)
    if(isShowingTrinketName) then
        trueName = title
        return false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ITEM_TEXT_DISPLAY, showStreakText)
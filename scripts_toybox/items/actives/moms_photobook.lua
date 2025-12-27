
local sfx = SFXManager()

local CONFUSION_DURATION = 30*4

---@param pl EntityPlayer
local function momsPhotobookUse(_, item, rng, pl, flags, slot, vdata)
    local playerRef = EntityRef(pl)

    for _, enemy in ipairs(Isaac.GetRoomEntities()) do
        if(enemy:ToNPC() and enemy:ToNPC():IsEnemy()) then
            enemy:AddConfusion(playerRef, CONFUSION_DURATION, false)
        end
    end

    ItemOverlay.Show(ToyboxMod.GIANTBOOK_MOMS_PHOTOBOOK, 3, pl)
    sfx:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, momsPhotobookUse, ToyboxMod.COLLECTIBLE_MOMS_PHOTOBOOK)
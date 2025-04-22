local mod = ToyboxMod
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

    ItemOverlay.Show(mod.GIANTBOOK.MOMS_PHOTOBOOK, 3, pl)
    sfx:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, momsPhotobookUse, mod.COLLECTIBLE.MOMS_PHOTOBOOK)
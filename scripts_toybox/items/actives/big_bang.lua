local mod = ToyboxMod
local sfx = SFXManager()

---@param rng RNG
---@param pl EntityPlayer
local function bigBangUse(_, _, rng, pl, flags, slot, vdata)
    local conf = Isaac.GetItemConfig()
    local pool = Game():GetItemPool()

    local numItems = #conf:GetCollectibles()
    for i=1, numItems-1 do
        if(conf:GetCollectible(i)) then
            pool:ResetCollectible(i)
        end
    end

    ItemOverlay.Show(mod.GIANTBOOK.BIG_BANG, 3, pl)
    sfx:Play(SoundEffect.SOUND_DOGMA_BRIMSTONE_SHOOT)
    
    return {
        Discharge = true,
        ShowAnim = true,
        Remove = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, bigBangUse, mod.COLLECTIBLE.BIG_BANG)
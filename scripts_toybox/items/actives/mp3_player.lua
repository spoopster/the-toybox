local sfx = SFXManager()

local EARWORM_DURATION = 30*12

---@param rng RNG
---@param pl EntityPlayer
local function mp3PlayerUse(_, _, rng, pl, flags, slot, vdata)
    local playerRef = EntityRef(pl)

    for _, enemy in ipairs(Isaac.GetRoomEntities()) do
        if(enemy:ToNPC() and enemy:ToNPC():IsEnemy()) then
            ToyboxMod:applyEarworm(enemy, -EARWORM_DURATION, playerRef)
        end
    end

    local mus = MusicManager()
    mus:PitchSlide(mus:GetCurrentPitch()*1.3)

    Isaac.CreateTimer(function()
        mus:PitchSlide(mus:GetCurrentPitch()/1.3)
    end,EARWORM_DURATION,1,false)

    sfx:Play(ToyboxMod.SFX_MP3_PLAYER, 1, 2, false, 0.95+math.random()*0.1)

    return {
        Discharge = true,
        ShowAnim = true,
        Remove = false,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, mp3PlayerUse, ToyboxMod.COLLECTIBLE_MP3_PLAYER)
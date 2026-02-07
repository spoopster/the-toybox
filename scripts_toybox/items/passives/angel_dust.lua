local sfx = SFXManager()

local FEAR_FREQ = 30*10
local FEAR_DURATION = 30*2
local FEAR_INIT_OFFSET = 30*3

local FEAR_PULSE = 18
local FEAR_PULSE_TICKS = 3

---@param pl EntityPlayer
local function postPeffectUpdate(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_ANGEL_DUST)) then return end
    if(ToyboxMod:isRoomClear()) then return end
    
    local roomFreqMod = Game():GetRoom():GetFrameCount()%FEAR_FREQ
    if(roomFreqMod==FEAR_INIT_OFFSET) then
        pl:AddFear(EntityRef(nil), FEAR_DURATION)
        if(pl:GetFearCountdown()>FEAR_FREQ*0.7) then
            pl:SetFearCountdown((FEAR_FREQ*0.7)//1)
        end
        sfx:Play(SoundEffect.SOUND_ABYSS, 1, 4, false, 0.9)
    elseif(roomFreqMod<FEAR_INIT_OFFSET and roomFreqMod>=FEAR_INIT_OFFSET-FEAR_PULSE*FEAR_PULSE_TICKS) then
        local normalizedmod = roomFreqMod-FEAR_INIT_OFFSET+FEAR_PULSE*FEAR_PULSE_TICKS
        if(normalizedmod%FEAR_PULSE==0) then
            pl:SetColor(Color(0.75,0.45,0.75,1,0,0,0,0,0,0,0), 5, 0, true, false)

            sfx:Play(SoundEffect.SOUND_BOOMERANG_THROW, 0.7, 4, false, 0.85+0.075*normalizedmod/FEAR_PULSE)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate)
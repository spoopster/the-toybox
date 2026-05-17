local sfx = SFXManager()

local TIMER_BASE_REQ = 10*30*60
local TIMER_REQ_INCREASE = 5*30*60

local function checkY2KTimer(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_Y2K)) then return end

    local timerSize = TIMER_BASE_REQ
    local y2kPlayers = {}
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_Y2K)) then
            table.insert(y2kPlayers, pl)
        end
        timerSize = timerSize+pl:GetEffects():GetCollectibleEffectNum(ToyboxMod.COLLECTIBLE_Y2K)*TIMER_REQ_INCREASE
    end

    if(Game().TimeCounter>=timerSize) then
        for _, pl in ipairs(y2kPlayers) do ---@cast pl EntityPlayer
            pl:AddSoulHearts(2)
            pl:AddCollectibleEffect(ToyboxMod.COLLECTIBLE_Y2K)
            pl:QueueExtraAnimation("Glitch")

            Isaac.CreateTimer(function()
                local vel = Vector.FromAngle(math.random(-135,-45))*5
                local eff = Isaac.Spawn(1000,EffectVariant.FIREWORKS,1,pl.Position,vel,nil):ToEffect()
                eff:SetTimeout(10+math.random(-1,3))
            end,15,3,false)
        end
        Game().TimeCounter = 0

        sfx:Play(SoundEffect.SOUND_EDEN_GLITCH)
        sfx:Play(ToyboxMod.SFX_REWIND)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, checkY2KTimer)
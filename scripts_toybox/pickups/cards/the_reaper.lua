local sfx = SFXManager()

local DAMAGE_DEALT = 20
local DMG_INTERVAL = 30*5

local SLOW_INTENSITY = 0.7

---@param pl EntityPlayer
local function useTheReaper(_, _, pl, flags)
    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    ToyboxMod:setExtraData("REAPER_DATA", {pl, (flags & UseFlag.USE_CARBATTERY ~= 0 and 2 or 1), 0})
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheReaper, ToyboxMod.CARD_THE_REAPER)

local function reaperUpdate(_)
    local rData = ToyboxMod:getExtraDataTable().REAPER_DATA
    if(not rData) then return end
    
    if(rData[3]%DMG_INTERVAL==0) then
        local validents = {}
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if(ToyboxMod:isValidEnemy(ent)) then
                table.insert(validents, ent)
            end
        end

        local numents = #validents
        if(numents>0) then
            local rng = rData[1]:GetCardRNG(ToyboxMod.CARD_THE_REAPER)
            local ent = validents[rng:RandomInt(1,numents)]

            ent:TakeDamage(DAMAGE_DEALT, 0, EntityRef(rData[1]), 0)
            if(rData[2]==2) then
                ent:AddWeakness(EntityRef(rData[1]), -DMG_INTERVAL)
                
            else
                local toAdd = math.max(0, DMG_INTERVAL-ent:GetSlowingCountdown())
                ent:AddSlowing(EntityRef(rData[1]), toAdd, SLOW_INTENSITY, Color(1,1,1.3,1,0.16,0.16,0.16))
            end

            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil):ToEffect()
            if(rData[2]==2) then
                poof.Color = Color(0.4,0.25,0.35,1,0.2,0,0.2)
            else
                poof.Color = Color(0.25,0.25,0.25,1)
            end

            sfx:Play(SoundEffect.SOUND_BLACK_POOF)
        end
    end

    rData[3] = rData[3]+1
    ToyboxMod:setExtraData("REAPER_DATA", rData)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, reaperUpdate)
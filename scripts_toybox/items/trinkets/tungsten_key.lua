local BREAK_CHANCE = 0.5
local MULT_CHANCE_DEC = 0.25

---@param player EntityPlayer
local function addTrinket(_, player)
    ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", true)
    player:AddGoldenKey()
    ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", nil)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, addTrinket, ToyboxMod.TRINKET_TUNGSTEN_KEY)

---@param player EntityPlayer
local function removeTrinket(_, player)
    ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", true)
    if(not ToyboxMod:getExtraData("GOLDEN_KEY_STATE")) then
        player:RemoveGoldenKey()
    end
    ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", nil)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, removeTrinket, ToyboxMod.TRINKET_TUNGSTEN_KEY)

---@param pl EntityPlayer
local function tryEnforceGoldenKey(_, pl)
    if(not pl:HasTrinket(ToyboxMod.TRINKET_TUNGSTEN_KEY)) then return end

    if(not pl:HasGoldenKey()) then
        ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", true)
        pl:AddGoldenKey()
        ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", nil)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, tryEnforceGoldenKey)

---@param pl EntityPlayer
local function maybeRemoveTrinket(_, pl)
    if(pl.FrameCount==0) then return end

    if(pl:HasTrinket(ToyboxMod.TRINKET_TUNGSTEN_KEY)) then
        local chance = BREAK_CHANCE-MULT_CHANCE_DEC*(pl:GetTrinketMultiplier(ToyboxMod.TRINKET_TUNGSTEN_KEY)-1)
        local rng = pl:GetTrinketRNG(ToyboxMod.TRINKET_TUNGSTEN_KEY)
        if(rng:RandomFloat()<chance) then
            pl:TryRemoveTrinket(ToyboxMod.TRINKET_TUNGSTEN_KEY)

            Isaac.CreateTimer(function(eff) ---@param eff EntityEffect
                if(eff.FrameCount>0) then
                    ToyboxMod.SFX:Play(SoundEffect.SOUND_THUMBS_DOWN)
                    ToyboxMod.SFX:Play(SoundEffect.SOUND_METAL_BLOCKBREAK)

                    for _=1, 4 do
                        local gib = Isaac.Spawn(1000,86,0,pl.Position,RandomVector()*(1.5+rng:RandomFloat()*2),nil)
                    end
                end
            end, 5, 2, true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, maybeRemoveTrinket)


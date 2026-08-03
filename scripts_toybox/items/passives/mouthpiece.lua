local EARWORM_CHANCE = 0.05
local EARWORM_MAXCHANCE = 0.30
local EARWORM_MAXLUCK = 10
local STACK_MULT = 1

---@param entity Entity
---@param player EntityPlayer
local function pollTearflags(_, entity, player, weapon)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_MOUTHPIECE)) then
        local mult = 1+STACK_MULT*(player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_MOUTHPIECE)-1)
        local rng = player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_MOUTHPIECE)
        local chance = TearFlagsLib.GetChance(TearFlagsLib.GetRealLuck(player, entity)*mult, EARWORM_CHANCE, EARWORM_MAXCHANCE, EARWORM_MAXLUCK, 1)

        if(rng:RandomFloat()<chance) then
            TearFlagsLib.AddTearFlags(entity, ToyboxMod.TEARFLAGS.MUSICAL)
        end
    end
end
ToyboxMod:AddCallback(TearFlagsLib.Callback.POLL_TEARFLAGS, pollTearflags)
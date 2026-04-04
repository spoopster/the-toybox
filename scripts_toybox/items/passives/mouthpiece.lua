



local EARWORM_CHANCE = 0.05
local EARWORM_MAXCHANCE = 0.30
local EARWORM_MAXLUCK = 10
local STACK_LUCK = 2

local EARWORM_DURATION = 7*30
local STATUS_COLOR_PINK = Color(1,1,1,1,0.2*(205/227),0.2*(175/227),0.2*(227/227),(205/227),(175/227),(227/227),2)

ToyboxMod:addTearFlagEnum(
    "MOUTHPIECE_EARWORM",
    ---@param npc EntityNPC
    ---@param source Entity
    function(npc, flag, source, pos, dmg, key)
        ToyboxMod:applyEarworm(npc, -EARWORM_DURATION, EntityRef(source), false)
    end,
    nil,
    STATUS_COLOR_PINK
)

---@param pl EntityPlayer
local function giveTearflag(_, pl, _)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_MOUTHPIECE)) then return end

    ToyboxMod:addTearFlag(
        pl,
        "MOUTHPIECE_EARWORM",
        ---@param player EntityPlayer
        function(player)
            local num = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_MOUTHPIECE)
            return ToyboxMod:getLuckAffectedChance(player.Luck+STACK_LUCK*(num-1), EARWORM_CHANCE, EARWORM_MAXLUCK, EARWORM_MAXCHANCE)
        end,
        ToyboxMod.COLLECTIBLE_MOUTHPIECE
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, giveTearflag, CacheFlag.CACHE_TEARFLAG)
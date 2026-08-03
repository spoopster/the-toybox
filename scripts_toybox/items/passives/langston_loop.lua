---@param entity Entity
---@param player EntityPlayer
local function pollTearflags(_, entity, player, weapon)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_LANGTON_LOOP)) then
        TearFlagsLib.AddTearFlags(entity, ToyboxMod.TEARFLAGS.LANGTON)
    end
end
ToyboxMod:AddCallback(TearFlagsLib.Callback.POLL_TEARFLAGS, pollTearflags)
ToyboxMod:AddCallback(TearFlagsLib.Callback.POLL_CHANCELESS_TEARFLAGS, pollTearflags)

---@param entity Entity
---@param player EntityPlayer
local function cancelRemoveFromLudo(_, entity, player, _)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_LANGTON_LOOP)) then return end

    if(not ToyboxMod:getEntityData(entity, "LANGTON_BLACKLIST")) then
        return true
    end
end
ToyboxMod:AddCallback(TearFlagsLib.Callback.PRE_REMOVE_TEARFLAG, cancelRemoveFromLudo, ToyboxMod.TEARFLAGS.LANGTON)
---@param pl EntityPlayer
local function useTheGate(_, _, pl, flags)
    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    local data = ToyboxMod:getExtraDataTable()
    data.THEGATE_STATE = math.max(data.THEGATE_STATE or 0, (flags & UseFlag.USE_CARBATTERY ~= 0) and 2 or 1)

    ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", true)
    pl:AddGoldenKey()
    ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", nil)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheGate, ToyboxMod.CARD_THE_GATE)

---@param pl EntityPlayer
local function tryUseHeldCandle(_, pl)
    local st = ToyboxMod:getExtraData("THEGATE_STATE")
    if(not (st and st>0)) then return end

    if(not pl:HasGoldenKey()) then
        ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", true)
        pl:AddGoldenKey()
        ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", nil)
    end
    if(st>1 and not pl:HasGoldenBomb()) then
        ToyboxMod:setExtraData("GOLDEN_BOMB_OVERRIDE", true)
        pl:AddGoldenBomb()
        ToyboxMod:setExtraData("GOLDEN_BOMB_OVERRIDE", nil)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, tryUseHeldCandle)

local function deactivatePoisonRain(_)
    if(ToyboxMod:getExtraData("THEGATE_STATE")) then
        local pl = PlayerManager.GetPlayers()[1]

        if(pl:HasGoldenKey()) then
            ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", true)
            if(not ToyboxMod:getExtraData("GOLDEN_KEY_STATE")) then
                pl:RemoveGoldenKey()
            end
            ToyboxMod:setExtraData("GOLDEN_KEY_OVERRIDE", nil)
        end
        if(pl:HasGoldenBomb()) then
            ToyboxMod:setExtraData("GOLDEN_BOMB_OVERRIDE", true)
            if(not ToyboxMod:getExtraData("GOLDEN_BOMB_STATE")) then
                pl:RemoveGoldenBomb()
            end
            ToyboxMod:setExtraData("GOLDEN_BOMB_OVERRIDE", nil)
        end

        ToyboxMod:setExtraData("THEGATE_STATE", 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, deactivatePoisonRain)
local NUM_ROTTEN_HEARTS = 1

---@param player EntityPlayer
---@param firstTime boolean
local function addRottenHp(_, _, _, firstTime, _, _, player)
    if(not firstTime) then return end

    player:AddRottenHearts(NUM_ROTTEN_HEARTS*2)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addRottenHp, ToyboxMod.COLLECTIBLE_CARRION)

--local function 
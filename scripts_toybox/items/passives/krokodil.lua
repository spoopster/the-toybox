--- Code by  : split!

---@param player EntityPlayer
---@param firstTime boolean
local function turnHpRotten(_, _, _, firstTime, _, _, player)
    if(not firstTime) then return end

    local redhearts= player:GetHearts()
    player:AddHearts(-redhearts)
    player:AddRottenHearts(redhearts)
end

ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, turnHpRotten, ToyboxMod.COLLECTIBLE_KROKODIL)


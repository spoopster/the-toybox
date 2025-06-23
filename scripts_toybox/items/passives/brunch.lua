local NUM_LOCSTS = 1

---@param pl EntityPlayer
---@param firstTime boolean
local function addBrunch(_, _, _, firstTime, _, _, pl)
    if(not firstTime) then return end

    pl:AddRottenHearts(2)
    
    local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 2, pl.Position, Vector.Zero, pl):ToFamiliar()
    fly.Player = pl

    fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addBrunch, ToyboxMod.COLLECTIBLE_BRUNCH)


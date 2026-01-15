

ToyboxMod.MILCOM_CHAMPION_CHANCE_INC = 1--0.5

ToyboxMod.MILCOM_BOMB_VALUE = 4
ToyboxMod.MILCOM_KEY_VALUE = 7

ToyboxMod.MILCOM_BOMB_VALUE_BIRTHRIGHT = 3
ToyboxMod.MILCOM_KEY_VALUE_BIRTHRIGHT = 5

--#region DATA
local MILCOM_A_BASEDATA = {
    --JUMPING STUFF
    CURRENT_JUMPHEIGHT = 0,
    MAX_JUMPHEIGHT = 11,

    JUMP_FRAMES = 0,
    MAX_JUMPDURATION = 18,
}

ToyboxMod.MILCOM_A_BASEDATA = MILCOM_A_BASEDATA

--#endregion

---@param player EntityPlayer
local function postMilcomInit(_, player)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_MILCOM_A) then return end
    local data = ToyboxMod:getMilcomATable(player)

    player:GetSprite():Load("gfx_tb/characters/character_milcom_a.anm2", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postMilcomInit)

---@param player EntityPlayer
local function postMilcomUpdate(_, player)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_MILCOM_A) then return end
    local data = ToyboxMod:getMilcomATable(player)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postMilcomUpdate)

---@param pickup EntityPickup
local function rerollBombOrKeyInit(_, pickup)
    if(not PlayerManager.AnyoneIsPlayerType(ToyboxMod.PLAYER_MILCOM_A)) then return end
    
    if(not pickup:IsShopItem()) then return end
    if(not (pickup.Variant==PickupVariant.PICKUP_BOMB or pickup.Variant==PickupVariant.PICKUP_KEY)) then return end

    local id = pickup.ShopItemId
    local new = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_SHOPITEM, 0, pickup.Position, Vector.Zero, nil):ToPickup()
    new:MakeShopItem(id)
    pickup:Remove()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, rerollBombOrKeyInit)
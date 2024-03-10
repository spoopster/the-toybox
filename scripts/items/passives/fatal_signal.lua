local mod = MilcomMOD
local sfx = SFXManager()

local function getGlitchedItem(player)
    return ProceduralItemManager.CreateProceduralItem(player:GetCollectibleRNG(mod.COLLECTIBLE_FATAL_SIGNAL):RandomInt(2^32-1)+1, 0)
end

---@param player EntityPlayer
local function postAddItem(_, item, charge, firstTime, slot, vData, player)
    if(firstTime~=true) then return end
    if(item<0) then return end

    local id=getGlitchedItem(player)
    while(Isaac.GetItemConfig():GetCollectible(id) and Isaac.GetItemConfig():GetCollectible(id).Type==ItemType.ITEM_ACTIVE) do
        id = getGlitchedItem(player)
    end
    player:AddCollectible(id)

    sfx:Play(SoundEffect.SOUND_EDEN_GLITCH)
    sfx:Play(SoundEffect.SOUND_STATIC)
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem, mod.COLLECTIBLE_FATAL_SIGNAL)
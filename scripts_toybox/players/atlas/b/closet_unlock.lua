

---@param pickup EntityPickup
local function replaceCollectibleInCloset(_, pickup)
    local roomConfig = Game():GetLevel():GetCurrentRoomDesc().Data

    if(roomConfig.Type==1 and roomConfig.Variant==6 and roomConfig.Subtype==11) then
        if(ToyboxMod:isAtlasA(Isaac.GetPlayer()) and Isaac.GetPersistentGameData():Unlocked(ToyboxMod.ACHIEVEMENT_ATLAS_B)==false) then
            Isaac.Spawn(6,14,0,pickup.Position,Vector.Zero,nil)
            pickup:Remove()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, replaceCollectibleInCloset, PickupVariant.PICKUP_COLLECTIBLE)

---@param npc EntityNPC
local function replaceShopkeeperInCloset(_, npc)
    local roomConfig = Game():GetLevel():GetCurrentRoomDesc().Data

    if(roomConfig.Type==1 and roomConfig.Variant==6 and roomConfig.Subtype==11) then
        if(ToyboxMod:isAtlasA(Isaac.GetPlayer()) and Isaac.GetPersistentGameData():Unlocked(ToyboxMod.ACHIEVEMENT_ATLAS_B)==false) then
            Isaac.Spawn(6,14,0,npc.Position,Vector.Zero,nil)
            npc:Remove()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, replaceShopkeeperInCloset, EntityType.ENTITY_SHOPKEEPER)

---@param slot EntitySlot
local function postMilcomSecretUpdate(_, slot)
    local sprite = slot:GetSprite()
    if(not (sprite:GetAnimation()=="PayPrize" and sprite:IsFinished("PayPrize"))) then return end

    if(ToyboxMod:isAtlasA(Isaac.GetPlayer()) and Isaac.GetPersistentGameData():Unlocked(ToyboxMod.ACHIEVEMENT_ATLAS_B)==false) then
        ToyboxMod:unlock(ToyboxMod.ACHIEVEMENT_ATLAS_B)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, postMilcomSecretUpdate, SlotVariant.HOME_CLOSET_PLAYER)
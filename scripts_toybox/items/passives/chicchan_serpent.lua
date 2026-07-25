local ACTIVE_COSTUME = Isaac.GetCostumeIdByPath("gfx_tb/characters/costume_chicchan_serpent_active.anm2")

---@param pl EntityPlayer
local function enterBossRoom(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_CHICCHAN_SERPENT)) then return end

    local roomType = ToyboxMod.GAME:GetRoom():GetType()
    if(roomType==RoomType.ROOM_BOSS or roomType==RoomType.ROOM_MINIBOSS or roomType==RoomType.ROOM_BOSSRUSH) then
        pl:AddNullCostume(ACTIVE_COSTUME)

        local eff = pl:GetEffects()
        eff:AddCollectibleEffect(ToyboxMod.COLLECTIBLE_CHICCHAN_SERPENT, true, pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_CHICCHAN_SERPENT))
    else
        pl:TryRemoveNullCostume(ACTIVE_COSTUME)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, enterBossRoom)

---@param ent Entity
local function addEffectStats(_, ent)
    local pl = ent:ToPlayer()
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_CHICCHAN_SERPENT))) then return end

    local roomType = ToyboxMod.GAME:GetRoom():GetType()
    if(roomType==RoomType.ROOM_BOSS or roomType==RoomType.ROOM_MINIBOSS or roomType==RoomType.ROOM_BOSSRUSH) then
        pl:AddCollectibleEffect(ToyboxMod.COLLECTIBLE_CHICCHAN_SERPENT)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, addEffectStats, EntityType.ENTITY_PLAYER)
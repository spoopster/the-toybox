
local sfx = SFXManager()

local SPUR_CHANCE = 0.67

local CARBATTERY_SPUR_CHANCE = 1

---@param player EntityPlayer
---@param flags UseFlag
local function useMantle(_, _, player, flags)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_CONGLOMERATE) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.BONE.ID)
    else
        if(flags & UseFlag.USE_CARBATTERY ~= 0) then
            ToyboxMod:addInnateCollectible(player, ToyboxMod.COLLECTIBLE_BONE_BOY, 1, "ForLevel_BoneMantleCard", true)
        else
            local bone = Isaac.Spawn(227,0,0,player.Position,Vector.Zero,player):ToNPC()
            bone:AddCharmed(EntityRef(player),-1)
        end

        local data = ToyboxMod:getEntityDataTable(player)
        data.MANTLEBONE_ACTIVE = (data.MANTLEBONE_ACTIVE or 0)+1
        if(flags & UseFlag.USE_CARBATTERY ~= 0) then
            if(data.MANTLEBONE_ACTIVE==data.MANTLEBONE_ACTIVE//1) then
                data.MANTLEBONE_ACTIVE = data.MANTLEBONE_ACTIVE+0.5
            end
        end
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_BONE)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_BONE)

---@param player EntityPlayer
local function postNewRoom(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    if(data.MANTLEBONE_ACTIVE and data.MANTLEBONE_ACTIVE>0) then data.MANTLEBONE_ACTIVE = 0 end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)

local function postNpcDeath(_, npc)
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local rng = pl:GetCardRNG(ToyboxMod.CARD_MANTLE_BONE)
        local data = ToyboxMod:getEntityDataTable(pl)
        if(data.MANTLEBONE_ACTIVE and data.MANTLEBONE_ACTIVE>0) then
            for _=1, data.MANTLEBONE_ACTIVE//1 do
                if(rng:RandomFloat()<(data.MANTLEBONE_ACTIVE~=data.MANTLEBONE_ACTIVE//1 and CARBATTERY_SPUR_CHANCE or SPUR_CHANCE)) then pl:AddBoneOrbital(npc.Position) end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_BONE] = true end
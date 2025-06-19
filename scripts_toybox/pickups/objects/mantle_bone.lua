
local sfx = SFXManager()

local SPUR_CHANCE = 0.67

local function useMantle(_, _, player, _)
    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.BONE.ID)
    else
        local bone = Isaac.Spawn(227,0,0,player.Position,Vector.Zero,player):ToNPC()
        bone:AddCharmed(EntityRef(player),-1)

        local data = ToyboxMod:getEntityDataTable(player)
        data.MANTLEBONE_ACTIVE = (data.MANTLEBONE_ACTIVE or 0)+1
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_BONE)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CONSUMABLE.MANTLE_BONE)

---@param player EntityPlayer
local function postNewRoom(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    if(data.MANTLEBONE_ACTIVE and data.MANTLEBONE_ACTIVE>0) then data.MANTLEBONE_ACTIVE = 0 end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)

local function postNpcDeath(_, npc)
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local rng = pl:GetCardRNG(ToyboxMod.CONSUMABLE.MANTLE_BONE)
        local data = ToyboxMod:getEntityDataTable(pl)
        if(data.MANTLEBONE_ACTIVE and data.MANTLEBONE_ACTIVE>0) then
            for _=1, data.MANTLEBONE_ACTIVE do
                if(rng:RandomFloat()<SPUR_CHANCE) then pl:AddBoneOrbital(npc.Position) end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CONSUMABLE.MANTLE_BONE] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(ToyboxMod.CONSUMABLE.MANTLE_BONE).Weight = (ToyboxMod.CONFIG.MANTLE_WEIGHT or 0.5)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)
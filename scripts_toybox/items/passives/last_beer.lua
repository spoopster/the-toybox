local mod = ToyboxMod

local CHANCE_PER_KILL = 0.1

local function postNpcDeath(_, npc)
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local data = mod:getEntityDataTable(pl)

        if(pl:HasCollectible(mod.COLLECTIBLE.LAST_BEER) and (data.LAST_BEER_COUNTER or 0)<1/CHANCE_PER_KILL) then
            data.LAST_BEER_COUNTER = (data.LAST_BEER_COUNTER or 0)+1
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)

---@param pl EntityPlayer
local function beerTearParams(_, pl)
    if(not pl:HasCollectible(mod.COLLECTIBLE.LAST_BEER)) then return end
    local data = mod:getEntityDataTable(pl)

    local rng = pl:GetCollectibleRNG(mod.COLLECTIBLE.LAST_BEER)
    if(rng:RandomFloat()<(data.LAST_BEER_COUNTER or 0)*CHANCE_PER_KILL) then
        local params = pl:GetMultiShotParams(pl:GetWeapon(1):GetWeaponType())
        local tearsToAdd = pl:GetCollectibleNum(mod.COLLECTIBLE.LAST_BEER)

        params:SetNumLanesPerEye(params:GetNumLanesPerEye()+tearsToAdd)
        params:SetNumTears(params:GetNumTears()+params:GetNumEyesActive()*tearsToAdd)

        return params
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, beerTearParams)

local function postNewRoom(_)
    if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.LAST_BEER)) then return end

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)

        mod:setEntityData(pl, "LAST_BEER_COUNTER", 0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)
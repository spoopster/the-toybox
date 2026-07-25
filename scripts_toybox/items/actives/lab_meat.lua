--[[
local UPGRADE_CHANCE = 1/2

---@param fam EntityFamiliar
local function blueInsectInit(_, fam)
    if(not fam.Player:HasCollectible(ToyboxMod.COLLECTIBLE_UNSTABLE_DNA)) then return end

    local mult = fam.Player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_UNSTABLE_DNA)

    print("Mango2")

    local rng = ToyboxMod:generateRng(fam.InitSeed)
    local type = ToyboxMod:getBlueInsectTypeCol(fam)
    if(type==0 and rng:RandomFloat()<(1-(1-UPGRADE_CHANCE)^mult)) then
        fam.SubType = ToyboxMod:makeRandomUpgradedInsect(fam)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_INIT, 1, blueInsectInit, FamiliarVariant.BLUE_FLY)
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_INIT, 1, blueInsectInit, FamiliarVariant.BLUE_SPIDER)
]]

local MIN_SPAWN_NUM = 4
local MAX_SPAWN_NUM = 7

---@param rng RNG
---@param player EntityPlayer
local function useLabMeat(_, _, rng, player, flags)
    local numSpawns = rng:RandomInt(MIN_SPAWN_NUM, MAX_SPAWN_NUM)

    for _=1, numSpawns do
        if(rng:RandomInt(2)==0) then
            player:AddBlueFlies(1, player.Position, nil)
        else
            player:AddBlueSpider(player.Position)
        end
    end

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ent.Type==EntityType.ENTITY_FAMILIAR and (ent.Variant==FamiliarVariant.BLUE_FLY or ent.Variant==FamiliarVariant.BLUE_SPIDER)) then
            ToyboxMod:makeRandomUpgradedInsect(ent:ToFamiliar(), true)
        end
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useLabMeat, ToyboxMod.COLLECTIBLE_LAB_MEAT)
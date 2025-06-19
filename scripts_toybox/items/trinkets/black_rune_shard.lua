

local REPLACE_CHANCE = 0.33

---@param familiar EntityFamiliar
local function replaceBlueFlySpider(_, familiar)
    if(Isaac.GetPlayer().FrameCount==0) then return end

    local pl = familiar.Player
    local trinketScale = pl:GetTrinketMultiplier(ToyboxMod.TRINKET_BLACK_RUNE_SHARD)
    if(trinketScale==0) then return end

    local chance = REPLACE_CHANCE*trinketScale--1-(1-REPLACE_CHANCE)^trinketScale
    local rng = pl:GetTrinketRNG(ToyboxMod.TRINKET_BLACK_RUNE_SHARD)
    if(rng:RandomFloat()<chance) then
        --print("hell yes")
        local dir = Vector.FromAngle(rng:RandomInt(360))*3
        local coin = Isaac.Spawn(5,20,1,familiar.Position,dir,pl):ToPickup()
        familiar:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, replaceBlueFlySpider, FamiliarVariant.BLUE_FLY)
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, replaceBlueFlySpider, FamiliarVariant.BLUE_SPIDER)

if(FiendFolio) then
    ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, replaceBlueFlySpider, FamiliarVariant.ATTACK_SKUZZ)
end
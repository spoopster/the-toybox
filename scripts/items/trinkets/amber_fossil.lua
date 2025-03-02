local mod = MilcomMOD

local LOCUST_CHANCE = 1/3

local function blueFlyInit(_, familiar)
    if(Isaac.GetPlayer().FrameCount==0) then return end
    if(familiar.SubType~=0) then return end

    local pl = familiar.Player or Isaac.GetPlayer()
    local rng = familiar:GetDropRNG()
    if(rng:RandomFloat()<LOCUST_CHANCE*pl:GetTrinketMultiplier(mod.TRINKET.AMBER_FOSSIL)) then
        local sub = rng:RandomInt(5)+1
        local numLocusts = 1
        if(sub==LocustSubtypes.LOCUST_OF_CONQUEST) then numLocusts = rng:RandomInt(4)+1 end

        for i=1, numLocusts do
            local locust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR,FamiliarVariant.BLUE_FLY,sub,familiar.Position,familiar.Velocity,familiar.SpawnerEntity):ToFamiliar()
            locust.Player = familiar.Player
            locust.Target = familiar.Target
            locust:ClearEntityFlags(locust:GetEntityFlags())
            locust:AddEntityFlags(familiar:GetEntityFlags())
            locust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end

        familiar:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, blueFlyInit, FamiliarVariant.BLUE_FLY)
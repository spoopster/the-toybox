local mod = MilcomMOD
local sfx = SFXManager()

local SPAWN_PENNY_CHANCE = 1/3
local DMG_INCREASE = 0.05

local function incrementMammonsOfferingCounter(player, amount, incrementPermaBonus)
    if(incrementPermaBonus==true) then
        mod:setData(player, "MAMMONS_OFFERING_PERMABONUS", (mod:getData(player, "MAMMONS_OFFERING_PERMABONUS") or 0)+amount )
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
    else
        mod:setData(player, "MAMMONS_OFFERING_BONUS", (mod:getData(player, "MAMMONS_OFFERING_BONUS") or 0)+amount )
    end
end

---@param player EntityPlayer
local function setPermaBonus(_, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_MAMMONS_OFFERING)) then return end

    incrementMammonsOfferingCounter(player, mod:getData(player, "MAMMONS_OFFERING_BONUS") or 0, true)
    mod:setData(player, "MAMMONS_OFFERING_BONUS", 0)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, setPermaBonus)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    local bonus = mod:getData(player, "MAMMONS_OFFERING_PERMABONUS") or 0

    if(bonus~=0 and flag==CacheFlag.CACHE_DAMAGE) then
        local dmgIncrease = bonus*DMG_INCREASE
        dmgIncrease = math.max(dmgIncrease, -0.5)

        player.Damage = player.Damage*(1+dmgIncrease)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param npc EntityNPC
---@param player EntityPlayer
local function npcDeath(_, npc, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_MAMMONS_OFFERING)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_MAMMONS_OFFERING)

    if(rng:RandomFloat()<SPAWN_PENNY_CHANCE) then
        local penny = Isaac.Spawn(5, mod.PICKUP_MAMMONS_OFFERING_PENNY, 0, npc.Position, Vector.Zero, player)
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_KILL_NPC, npcDeath)

--! PICKUP LOGIC

---@param pickup EntityPickup
local function postPennyInit(_, pickup)
    if(not (pickup:GetSprite():GetAnimation()=="Appear")) then return end
    if(not (pickup.SpawnerEntity and pickup.SpawnerEntity:ToPlayer())) then return end
    local p = pickup.SpawnerEntity:ToPlayer()
    incrementMammonsOfferingCounter(p, 1)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPennyInit, mod.PICKUP_MAMMONS_OFFERING_PENNY)

---@param pickup EntityPickup
local function postPennyUpdate(_, pickup)
    local sprite = pickup:GetSprite()
    if(sprite:IsFinished("Collect")) then pickup:Remove() end
    if(sprite:IsFinished("Appear")) then sprite:Play("Idle", true) end
    if(sprite:IsEventTriggered("DropSound")) then sfx:Play(233) end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postPennyUpdate, mod.PICKUP_MAMMONS_OFFERING_PENNY)

---@param pickup EntityPickup
---@param collider Entity
local function prePennyCollision(_, pickup, collider, low)
    if(pickup.Wait>0) then return true end
    if(collider.Type==5) then return false end
    if(collider.Type~=1) then return end
    local sprite = pickup:GetSprite()
    if(sprite:GetAnimation()~="Idle") then return true end

    local player = collider:ToPlayer()
    player:AddCoins(2)
    --if(player:HasCollectible(mod.COLLECTIBLE_MAMMONS_OFFERING)) then
        incrementMammonsOfferingCounter(player, -1)
        incrementMammonsOfferingCounter(player, -0.5, true)
    --end

    pickup:Die()
    sprite:Play("Collect", true)
    sfx:Play(234)
    sfx:Play(80)

    -- [[
    local rng = pickup:GetDropRNG()
    local room = Game():GetRoom()
    if(player:HasTrinket(TrinketType.TRINKET_BLOODY_PENNY) and rng:RandomFloat()>0.75) then
        local heart = Isaac.Spawn(5,10,2,room:FindFreePickupSpawnPosition(pickup.Position,0),Vector.Zero,pickup)
    end
    if(player:HasTrinket(TrinketType.TRINKET_BURNT_PENNY) and rng:RandomFloat()>0.75) then
        local bomb = Isaac.Spawn(5,40,1,room:FindFreePickupSpawnPosition(pickup.Position,0),Vector.Zero,pickup)
    end
    if(player:HasTrinket(TrinketType.TRINKET_BUTT_PENNY)) then
        Game():Fart(player.Position)
    end
    if(player:HasTrinket(TrinketType.TRINKET_COUNTERFEIT_PENNY) and rng:RandomFloat()>0.5) then
        player:AddCoins(1)
    end
    if(player:HasTrinket(TrinketType.TRINKET_FLAT_PENNY) and rng:RandomFloat()>0.75) then
        local key = Isaac.Spawn(5,30,1,room:FindFreePickupSpawnPosition(pickup.Position,0),Vector.Zero,pickup)
    end
    if(player:HasTrinket(TrinketType.TRINKET_ROTTEN_PENNY)) then
        player:AddBlueFlies(1, player.Position, player)
    end
    if(player:HasTrinket(TrinketType.TRINKET_BLESSED_PENNY) and rng:RandomFloat()>(5/6)) then
        local soul = Isaac.Spawn(5,10,8,room:FindFreePickupSpawnPosition(pickup.Position,0),Vector.Zero,pickup)
    end
    if(player:HasTrinket(TrinketType.TRINKET_CHARGED_PENNY) and player:NeedsCharge() and rng:RandomFloat()<coinsToAdd/6) then
        local charge = player:GetActiveCharge()
        player:SetActiveCharge(charge + 1)
    end
    if(player:HasTrinket(TrinketType.TRINKET_CURSED_PENNY) and not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, UseFlag.USE_NOANIM)
    end
    --]]

    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, prePennyCollision, mod.PICKUP_MAMMONS_OFFERING_PENNY)

mod:AddCallback(ModCallbacks.MC_POST_RENDER,
function(_)
    --Isaac.RenderText(tostring(mod:getData(Isaac.GetPlayer(),"MAMMONS_OFFERING_BONUS")), 100, 30,1,1,1,1)

    --Isaac.RenderText(tostring(mod:getData(Isaac.GetPlayer(),"MAMMONS_OFFERING_PERMABONUS")), 100, 40,1,1,1,1)
end
)
local mod = ToyboxMod
local sfx = SFXManager()

local PICKUP_CHANCE = 1/2

---@param pl EntityPlayer
local function evalCache(_, pl)
    local numBlocked = mod:getEntityData(pl, "EFFIGY_BLOCKS") or 0

    pl:CheckFamiliar(
        mod.FAMILIAR_VARIANT.EFFIGY,
        pl:GetCollectibleNum(mod.COLLECTIBLE.EFFIGY)-numBlocked,
        pl:GetCollectibleRNG(mod.COLLECTIBLE.EFFIGY),
        Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE.EFFIGY)
    )
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_FAMILIARS)

---@param fam EntityFamiliar
local function familiarInit(_, fam)
    fam:AddToFollowers()
    fam.State = 0
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiarInit, mod.FAMILIAR_VARIANT.EFFIGY)

---@param fam EntityFamiliar
local function familiarUpdate(_, fam)
    if(Game():GetRoom():GetFrameCount()==4) then
        local conf = EntityConfig
        local validEnemies = {}
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if(ent:ToNPC() and mod:isValidEnemy(ent:ToNPC()) and not mod:getEntityData(ent, "EFFIGY_BLOCKED")) then
                local npc = ent:ToNPC()
                local entConf = conf.GetEntity(npc.Type, npc.Variant, npc.SubType)
                if(entConf:CanBeChampion()) then
                    table.insert(validEnemies, npc)
                end
            end
        end

        if(validEnemies[1]) then
            local idx = fam:GetDropRNG():RandomInt(#validEnemies)+1
            fam.Target = validEnemies[idx]
            fam.State = 1
            mod:setEntityData(fam, "EFFIGY_TARGET_DATA",{
                Position = fam.Target.Position,
                Type = fam.Target.Type,
                Variant = fam.Target.Variant,
                SubType = fam.Target.SubType,
            })
            mod:setEntityData(fam.Target, "EFFIGY_BLOCKED", true)

            fam:GetSprite():Play("Copy", true)
            fam:RemoveFromFollowers()
        else
            fam.State = 0
            fam:AddToFollowers()
            fam:GetSprite():Play("Idle", true)
        end
    end

    if(fam.State==1) then
        local data = mod:getEntityData(fam, "EFFIGY_TARGET_DATA")

        fam.Velocity = (data.Position-fam.Position)*0.15
        if(fam:GetSprite():IsFinished("Copy")) then
            local plData = mod:getEntityDataTable(fam.Player)
            plData.EFFIGY_BLOCKS = (plData.EFFIGY_BLOCKS or 0)+1

            local newEnemy = Isaac.Spawn(data.Type, data.Variant, data.SubType, fam.Position, Vector.Zero, fam):ToNPC()
            newEnemy:MakeChampion(math.random(2^32-1), -1, true)
            newEnemy.HitPoints = newEnemy.MaxHitPoints

            newEnemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

            newEnemy.SpawnerEntity = fam
            newEnemy.SpawnerType = fam.Type
            newEnemy.SpawnerVariant = fam.Variant

            mod:setEntityData(newEnemy, "EFFIGY_CHAMPION")
            fam:Remove()

            sfx:Play(SoundEffect.SOUND_SUMMONSOUND)
        end
    else
        fam:FollowParent()
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiarUpdate, mod.FAMILIAR_VARIANT.EFFIGY)

local function postNewRoom(_)
    if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.EFFIGY)) then return end

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)

        mod:setEntityData(pl, "EFFIGY_BLOCKS", 0)
        pl:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function effigyEnemyDeath(_, npc)
    if(not (npc.SpawnerType==EntityType.ENTITY_FAMILIAR and npc.SpawnerVariant==mod.FAMILIAR_VARIANT.EFFIGY)) then return end

    local rng = npc:GetDropRNG()
    if(rng:RandomFloat()<PICKUP_CHANCE) then
        local dir = rng:RandomVector()*5
        local pickupDrop = Isaac.Spawn(5,0,NullPickupSubType.NO_COLLECTIBLE_TRINKET_CHEST,npc.Position,dir,npc):ToPickup()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, effigyEnemyDeath)
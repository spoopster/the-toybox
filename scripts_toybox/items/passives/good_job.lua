local sfx = SFXManager()

local SPEED_UP = 0.1
local DMG_UP = 0.5
local LUCK_UP = 1

local STACK_MULT = 1.5

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_GOOD_JOB)) then return end
    local mult = (ToyboxMod:getEntityData(player, "GOOD_JOB_CLEARS") or 0)
    local stacks = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_GOOD_JOB)

    mult = mult*((STACK_MULT-1)*(stacks-1)+1)

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+SPEED_UP*mult
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(player, DMG_UP*mult)
    elseif(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+LUCK_UP*mult
    --[[]]
    elseif(flag==CacheFlag.CACHE_FAMILIARS) then
        player:CheckFamiliar(
            ToyboxMod.FAMILIAR_GOOD_JOB_STAR,
            (ToyboxMod:getEntityData(player, "GOOD_JOB_FLAWLESS")~=nil and 1 or 0),
            player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_GOOD_JOB)
        )
    --]]
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
local function enterBossRoom(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_GOOD_JOB)) then return end

    ToyboxMod:setEntityData(pl, "GOOD_JOB_FLAWLESS", nil)
    pl:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)

    local room = Game():GetRoom()
    if(room:GetType()==RoomType.ROOM_BOSS and not room:IsClear()) then
        ToyboxMod:setEntityData(pl, "GOOD_JOB_FLAWLESS", true)
    else
        ToyboxMod:setEntityData(pl, "GOOD_JOB_FLAWLESS", nil)
    end
    pl:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, enterBossRoom)

---@param player Entity
local function loseFlawlessStatus(_, player, _, flags, source)
    player = player:ToPlayer()
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_GOOD_JOB)) then return end

    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    if(ToyboxMod:getEntityData(player, "GOOD_JOB_FLAWLESS")) then
        ToyboxMod:setEntityData(player, "GOOD_JOB_FLAWLESS", false)

        --[[]]
        local plhash = GetPtrHash(player)
        for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_GOOD_JOB_STAR)) do
            if(GetPtrHash(fam:ToFamiliar().Player)==plhash and fam:GetSprite():GetAnimation()=="FloatDown") then
                fam:GetSprite():Play("Explode", true)
            end
        end
        --]]

        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, loseFlawlessStatus, EntityType.ENTITY_PLAYER)

---@param pl EntityPlayer
local function clearRoomFlawless(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_GOOD_JOB)) then return end
    
    local data = ToyboxMod:getEntityDataTable(pl)
    if(data.GOOD_JOB_FLAWLESS) then
        pl:AnimateHappy()

        local room = Game():GetRoom()
        local spawnPos = room:FindFreePickupSpawnPosition(pl.Position, 40)
        local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, spawnPos, Vector.Zero, nil):ToPickup()

        data.GOOD_JOB_CLEARS = (data.GOOD_JOB_CLEARS or 0)+1
        pl:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_LUCK, true)

        data.GOOD_JOB_FLAWLESS = false

        --[[]]
        local plhash = GetPtrHash(pl)
        for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_GOOD_JOB_STAR)) do
            if(GetPtrHash(fam:ToFamiliar().Player)==plhash and fam:GetSprite():GetAnimation()=="FloatDown") then
                fam:GetSprite():Play("FloatDownHappy", true)
            end
        end
        --]]
        pl:AnimateHappy()
        sfx:Play(SoundEffect.SOUND_THUMBSUP)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, clearRoomFlawless)

--[[]]

---@param fam EntityFamiliar
local function familiarInit(_, fam)
    fam:AddToFollowers()

    fam:GetSprite():Play("FloatDown", true)
    fam:GetSprite():PlayOverlay("Sparkles", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiarInit, ToyboxMod.FAMILIAR_GOOD_JOB_STAR)

---@param fam EntityFamiliar
local function familiarUpdate(_, fam)
    local sp = fam:GetSprite()
    if(sp:GetAnimation()=="Explode") then
        fam:RemoveFromFollowers()
        fam.Velocity = fam.Velocity*0.8

        if(sp:IsFinished()) then
            if(fam.State==0) then
                fam.State = 1
                local rng = fam:GetDropRNG()
                for _=1, 5 do
                    local vel = rng:RandomVector()*4
                    local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, fam.Position, vel, nil):ToEffect()
                    gib:GetSprite():ReplaceSpritesheet(0, "gfx_tb/effects/effect_goodjob_gibs.png", true)
                end
                sfx:Play(SoundEffect.SOUND_BONE_BREAK)
            end

            fam.Visible = false
        end
    else
        fam:FollowParent()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiarUpdate, ToyboxMod.FAMILIAR_GOOD_JOB_STAR)
--]]
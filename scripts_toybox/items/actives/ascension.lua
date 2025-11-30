
local sfx = SFXManager()
--* add ghost costume
--* add dead player on ground dead dead dead

local ASCENSION_DURATION = 3*60
local END_INVINCIBILITY = 1*60

local SHADER_PLAYER = nil
local SHADER_VAL = 0
local GRAYING_VAL = 0

---@param player EntityPlayer
local function stopAscension(player)
    local bibleNum2 = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BIBLE)

    local data = ToyboxMod:getEntityDataTable(player)
    if(data.ASCENSION_ISACTIVE~=true) then return end

    local soulEffect = Isaac.Spawn(1000,16,10,player.Position,Vector.Zero,player)
    player.Position = (data.ASCENSION_ORIGINALPOS or player.Position)
    sfx:Play(SoundEffect.SOUND_LAZARUS_FLIP_DEAD, 0.5)
    player:SetColor(Color(1,1,1,1,0.5,0.5,0.5),5,99,true,false)
    if(data.ASCENSION_EFFECT) then data.ASCENSION_EFFECT:Remove() end

    data.ASCENSION_ISACTIVE = false
    data.ASCENSION_LENGTH = 0
    data.ASCENSION_ORIGINALPOS = nil
    data.ASCENSION_EFFECT = nil
    SHADER_PLAYER = nil

    local effects = player:GetEffects()
    local bibleEffectNum = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BIBLE)
    effects:RemoveCollectibleEffect(ToyboxMod.COLLECTIBLE_ASCENSION, -1)

    --print(bibleNum2, bibleEffectNum, effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BIBLE))

    if(bibleEffectNum~=effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BIBLE)) then
        effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_BIBLE)
    end
    
    player:SetMinDamageCooldown(END_INVINCIBILITY)
end

---@param player EntityPlayer
local function useAscenson(_, _, rng, player, flags)
    if(flags & UseFlag.USE_CARBATTERY == 0) then
        local isCarbattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)

        local data = ToyboxMod:getEntityDataTable(player)
        if(data.ASCENSION_ISACTIVE~=true) then
            data.ASCENSION_ISACTIVE = true
            data.ASCENSION_LENGTH = ASCENSION_DURATION*(isCarbattery and 2 or 1)
            data.ASCENSION_ORIGINALPOS = player.Position
            data.ASCENSION_JUSTUSEDASCENSION = true

            data.ASCENSION_EFFECT = Isaac.Spawn(1000,ToyboxMod.EFFECT_VARIANT.ASCENSION_PLAYER_DEATH,0,player.Position,Vector.Zero,player):ToEffect()
            data.ASCENSION_EFFECT:GetSprite():Load(player:GetSprite():GetFilename(), true)
            data.ASCENSION_EFFECT:GetSprite():ReplaceSpritesheet(12, EntityConfig.GetPlayer(player:GetPlayerType()):GetSkinPath(), true)
            data.ASCENSION_EFFECT:GetSprite():GetLayer("ghost"):SetVisible(false)
            data.ASCENSION_EFFECT:GetSprite():Play("Death", true)
            
            local soulEffect = Isaac.Spawn(1000,16,10,player.Position,Vector.Zero,player)
            player:SetColor(Color(1,1,1,1,0.5,0.5,0.5),5,99,true,false)
            sfx:Play(SoundEffect.SOUND_LAZARUS_FLIP_ALIVE, 0.5)

            SHADER_PLAYER = player
            GRAYING_VAL = 1
        end
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = false,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useAscenson, ToyboxMod.COLLECTIBLE_ASCENSION)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(ToyboxMod:getEntityData(player, "ASCENSION_ISACTIVE")~=true) then return end

    if(flag==CacheFlag.CACHE_FLYING) then
        player.CanFly = true
    elseif(flag==CacheFlag.CACHE_TEARFLAG) then
        player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function updateAscension(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    if(data.ASCENSION_ISACTIVE~=true) then return end
    if(data.ASCENSION_JUSTUSEDASCENSION==true) then
        data.ASCENSION_JUSTUSEDASCENSION = nil
        return
    end

    data.ASCENSION_LENGTH = (data.ASCENSION_LENGTH or 0)-1
    if(data.ASCENSION_LENGTH<=0) then stopAscension(player) end

    local isUsingPrimaryAscension = (Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)==ToyboxMod.COLLECTIBLE_ASCENSION)
    local isUsingPocketAscension = (Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, player.ControllerIndex) and player:GetActiveItem(ActiveSlot.SLOT_POCKET)==ToyboxMod.COLLECTIBLE_ASCENSION)

    if(data.ASCENSION_ISACTIVE==true and (isUsingPrimaryAscension or isUsingPocketAscension)) then
        --print("Yuh", player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BIBLE))

        stopAscension(player)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateAscension, 0)

local function postNewRoom()
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_ASCENSION)) then return end

    for i=0, Game():GetNumPlayers() do
        local pl = Isaac.GetPlayer(i)
        ToyboxMod:setEntityData(pl, "ASCENSION_ORIGINALPOS", nil)
        stopAscension(pl)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function getShaderParams(_, name)
    if(name==ToyboxMod.SHADERS.ASCENSION) then
        if(SHADER_PLAYER==nil and math.abs(SHADER_VAL)<=0.01) then return {ShouldActivateIn=0.0,IntensityIn=0.0,GrayingIn=0.0} end

        if(SHADER_PLAYER and ToyboxMod:getEntityData(SHADER_PLAYER, "ASCENSION_ISACTIVE")==true) then
            local data = ToyboxMod:getEntityDataTable(SHADER_PLAYER)
            local fl = (-1+data.ASCENSION_LENGTH/(ASCENSION_DURATION*(SHADER_PLAYER:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and 2 or 1)))
            local t = 0.04
            if(fl>=-t) then
                GRAYING_VAL = -(fl+t)/t
            elseif(fl>=-1.0) then
                GRAYING_VAL = math.abs(fl+t)/(1-t)
            end

            fl = -(1-(1-math.abs(fl))^2)
            SHADER_VAL = ToyboxMod:lerp(SHADER_VAL,fl-0.1,0.1)
        else
            SHADER_VAL = ToyboxMod:lerp(SHADER_VAL,0,0.3)
            if(math.abs(SHADER_VAL)<=0.01) then SHADER_VAL = 0 end

            GRAYING_VAL = SHADER_VAL
        end

        return {
            ShouldActivateIn = 1.0,
            IntensityIn = SHADER_VAL,
            GrayingIn = GRAYING_VAL,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, getShaderParams)

--! removes ascension from the pool when anyone is playing as the losts!!
--* not rlly needed

---@param player EntityPlayer
local function initRemoveAscension(_, player)
    if(player:GetPlayerType()==PlayerType.PLAYER_THELOST or player:GetPlayerType()==PlayerType.PLAYER_THELOST_B) then
        Game():GetItemPool():RemoveCollectible(ToyboxMod.COLLECTIBLE_ASCENSION)
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, initRemoveAscension, 0)
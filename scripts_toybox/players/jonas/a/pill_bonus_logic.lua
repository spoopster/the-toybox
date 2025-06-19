
local sfx = SFXManager()

local STAT_SPRITE = Sprite("gfx/ui/tb_ui_pill_bonus.anm2", true)
STAT_SPRITE:Play("Idle", true)

local PILLBONUS_FONT = Font()
PILLBONUS_FONT:Load("font/pftempestasevencondensed.fnt")

---@param player EntityPlayer
local function resetPillBonus(player, forcesfx)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_TYPE.JONAS_A) then return end
    local data = ToyboxMod:getJonasATable(player)

    local hadBonus = ((data.PILLS_POPPED or 0)>=1)
    data.PILLS_POPPED = 0
    data.RESET_BOOST_ROOMS = 0

    if(hadBonus) then
        player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK, true)
        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
        player:AnimateSad()
    end
end

---@param player EntityPlayer
local function renderStat(_, player, offset)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_TYPE.JONAS_A) then return end
    local data = ToyboxMod:getJonasATable(player)

    local lerpVal = 0.3
    data.HELD_MAP_ALPHA = data.HELD_MAP_ALPHA or 0
    if(Minimap:GetState()==MinimapState.EXPANDED) then
        data.HELD_MAP_ALPHA = ToyboxMod:lerp(data.HELD_MAP_ALPHA, 1, lerpVal)
    else
        data.HELD_MAP_ALPHA = ToyboxMod:lerp(data.HELD_MAP_ALPHA, 0, lerpVal)
    end

    if(data.HELD_MAP_ALPHA<=0.01) then return end

    local toRender = math.floor(data.PILLS_POPPED or 0)

    local renderPos = Isaac.WorldToRenderPosition(player.Position)+Vector(0,10)+offset+Game().ScreenShakeOffset

    STAT_SPRITE.Color = Color(1,1,1,data.HELD_MAP_ALPHA)
    STAT_SPRITE:Render(renderPos+Vector(-5,0)-Game().ScreenShakeOffset)

    local boxWidth = 250
    PILLBONUS_FONT:DrawString((toRender<10 and "0" or "")..tostring(toRender), renderPos.X-boxWidth+2.5, renderPos.Y-8.5, KColor(1,1,1,data.HELD_MAP_ALPHA),boxWidth*2,true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, renderStat)

---@param player EntityPlayer
local function addPillBonus(_, pillEffect, player, flags, pillColor)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_TYPE.JONAS_A) then return end
    local data = ToyboxMod:getJonasATable(player)

    local bonusInc = 1
    if(pillColor & PillColor.PILL_GIANT_FLAG ~= 0) then bonusInc = bonusInc*(data.PILBONUS_HORSE_MULT or 2) end
    if((pillColor & ~PillColor.PILL_GIANT_FLAG) == PillColor.PILL_GOLD) then bonusInc = bonusInc*(data.PILBONUS_GOLD_MULT or 0.2) end

    data.PILLS_POPPED = data.PILLS_POPPED or 0
    local isBonus = math.floor(data.PILLS_POPPED)<math.floor(data.PILLS_POPPED+bonusInc)
    data.PILLS_POPPED = data.PILLS_POPPED+bonusInc
    data.RESET_BOOST_ROOMS = 0

    if(isBonus) then
        player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK, true)
        sfx:Play(SoundEffect.SOUND_THUMBSUP)
        --player:AnimateHappy()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, addPillBonus)

---@param player EntityPlayer
local function addCardBonus(_, _, player, _)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_TYPE.JONAS_A) then return end
    if(not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then return end
    local data = ToyboxMod:getJonasATable(player)

    data.PILLS_POPPED = data.PILLS_POPPED or 0
    local isBonus = math.floor(data.PILLS_POPPED)<math.floor(data.PILLS_POPPED+1)
    data.PILLS_POPPED = data.PILLS_POPPED+1
    data.RESET_BOOST_ROOMS = 0

    if(isBonus) then
        player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK, true)
        sfx:Play(SoundEffect.SOUND_THUMBSUP)
        --player:AnimateHappy()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, addCardBonus)

---@param pl EntityPlayer
local function incrementBonusReset(_, pl)
    local data = ToyboxMod:getJonasATable(pl)

    if((data.PILLS_POPPED or 0)>0) then
        data.RESET_BOOST_ROOMS = data.RESET_BOOST_ROOMS+1
        if(data.RESET_BOOST_ROOMS>=(Game():IsGreedMode() and data.RESET_BOOST_ROOMSREQ_GREED or data.RESET_BOOST_ROOMSREQ)) then
            resetPillBonus(pl)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, incrementBonusReset)

local function resetBonusNewLevel(_, player)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_TYPE.JONAS_A) then return end
    if(player.FrameCount==0) then return end
    local data = ToyboxMod:getJonasATable(player)

    local oldBonus = (data.PILLS_POPPED or 0)
    data.PILLS_POPPED = (data.PILLS_POPPED or 0)*(data.NEWFLOOR_MULT or 0.33)
    if(math.floor(oldBonus)~=math.floor(data.PILLS_POPPED)) then
        player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK, true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, resetBonusNewLevel)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalBonus(_, player, flag)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_TYPE.JONAS_A) then return end
    local data = ToyboxMod:getJonasATable(player)
    if(math.floor(data.PILLS_POPPED or 0)<=0) then return end
    local mult = math.floor(data.PILLS_POPPED or 0)^data.PILLBONUS_DIMINISHING_POW

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+(data.PILLBONUS_SPEED or 0.1)*mult
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(player, (data.PILLBONUS_TEARS or 0.2)*mult)
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(player, (data.PILLBONUS_DMG or 0.3)*mult)
    elseif(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+40*(data.PILLBONUS_RANGE or 0.3)*mult
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+(data.PILLBONUS_SHOTSPEED or 0.05)*mult
    elseif(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+(data.PILLBONUS_LUCK or 0.6)*mult
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalBonus)

--he starts shaking when close to losing bonus
---@param player EntityPlayer
local function ahhIAmExperiencingWithdrawalPleaseHelp(_, player, offset)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_TYPE.JONAS_A) then return end
    local data = ToyboxMod:getJonasATable(player)
    if(not (data and data.PILLS_POPPED and data.PILLS_POPPED>0)) then return end
    
    local dif = (data.RESET_BOOST_ROOMSREQ or 0)-(data.RESET_BOOST_ROOMS or 0)
    if(dif<=(data.RESET_BOOST_SHAKECLOSENESS or 2)) then
        dif = (data.RESET_BOOST_SHAKECLOSENESS or 2)-dif+1
        return Vector((player.FrameCount%2-0.5)*2*dif*(data.RESET_BOOST_SHAKEINTENSITY or 1), 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, ahhIAmExperiencingWithdrawalPleaseHelp)
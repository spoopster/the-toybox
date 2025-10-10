
local sfx = SFXManager()

local SHIELD_FRAMES_MULT = 0.25

local function getReadHearts(pl)
    if(CustomHealthAPI) then
        return CustomHealthAPI.PersistentData.OverriddenFunctions.GetHearts(pl)
    else
        return pl:GetHearts()
    end
end
local function getSoulHearts(pl)
    if(CustomHealthAPI) then
        return CustomHealthAPI.PersistentData.OverriddenFunctions.GetSoulHearts(pl)
    else
        return pl:GetSoulHearts()
    end
end
local function getBoneHearts(pl)
    if(CustomHealthAPI) then
        return CustomHealthAPI.PersistentData.OverriddenFunctions.GetBoneHearts(pl)
    else
        return pl:GetBoneHearts()
    end
end

---@param pl EntityPlayer
function ToyboxMod:getSoulShieldMask(pl)
    return (ToyboxMod:getEntityData(pl, "STEELSOUL_SHIELDMASK") or 0)
end
---@param pl EntityPlayer
function ToyboxMod:setSoulShieldBit(pl, idx, val)
    local data = ToyboxMod:getEntityDataTable(pl)

    if(val==0) then data.STEELSOUL_SHIELDMASK = (data.STEELSOUL_SHIELDMASK or 0) & (~(1<<idx))
    else data.STEELSOUL_SHIELDMASK = (data.STEELSOUL_SHIELDMASK or 0) | (1<<idx) end
end
---@param pl EntityPlayer
function ToyboxMod:getSoulShieldBit(pl, idx)
    local data = ToyboxMod:getEntityDataTable(pl)
    return ((data.STEELSOUL_SHIELDMASK or 0) & (1<<idx) ~= 0) and 1 or 0
end
---@param pl EntityPlayer
function ToyboxMod:getMaxExtraHeartIdx(pl)
    return math.ceil(getSoulHearts(pl)/2)+getBoneHearts(pl)-1
end

---@param firstTime boolean
---@param pl EntityPlayer
local function addSteelSoul(_, _, _, firstTime, _, _, pl)
    if(not firstTime) then return end

    local heartIdx = ToyboxMod:getMaxExtraHeartIdx(pl)
    while(heartIdx>=0) do
        if(not pl:IsBoneHeart(heartIdx)) then
            ToyboxMod:setSoulShieldBit(pl, heartIdx, 1)
        end

        heartIdx = heartIdx-1
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addSteelSoul, ToyboxMod.COLLECTIBLE_STEEL_SOUL)

---@param pl EntityPlayer
local function giveSoulShield(_, pl, amount, hpType)
    if(not (hpType==AddHealthType.SOUL or hpType==AddHealthType.BONE)) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_STEEL_SOUL)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.PREV_SOULHP = data.PREV_SOULHP or 0

    local heartDif = getSoulHearts(pl)-(data.PREV_SOULHP-data.PREV_SOULHP%2)
    local heartIdx = ToyboxMod:getMaxExtraHeartIdx(pl)

    if(heartDif>0) then
        while(pl:IsBoneHeart(heartIdx)) do heartIdx = heartIdx-1 end
        if(getSoulHearts(pl)>0 and getSoulHearts(pl)%2~=0) then heartIdx = heartIdx-1 end

        while(heartDif>1 and heartIdx>=0) do
            if(pl:IsBoneHeart(heartIdx)) then
                heartIdx = heartIdx-1
            else
                ToyboxMod:setSoulShieldBit(pl, heartIdx, 1)
                heartDif = heartDif-2
                heartIdx = heartIdx-1
            end
        end
    end
    data.PREV_SOULHP = getSoulHearts(pl)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, math.huge, giveSoulShield)

---@param pl EntityPlayer
local function updateHpData(_, pl)
    ToyboxMod:setEntityData(pl, "PREV_SOULHP", getSoulHearts(pl))
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateHpData, 0)

local heartSprite, test = Sprite("gfx_tb/ui/ui_steelsoul_heart.anm2", true)
heartSprite:Play("Idle", true)

function ToyboxMod:renderSteelSoulSprite(player, pos)
    heartSprite:Render(pos)
end

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")
---@param pl EntityPlayer
local function renderSoulShields(_, offset, sprite, pos, x, pl)
    local idx = pl:GetPlayerIndex()
    if(idx<0) then return end

    local hud = Game():GetHUD():GetPlayerHUD(math.min(7,idx))
    local h = hud:GetHearts()
    local sp = Game():GetHUD():GetHeartsSprite()

    local numMaxReds = math.ceil(pl:GetMaxHearts()/2)
    for i, heartData in pairs(h) do
        if(heartData:IsVisible() and i>numMaxReds) then
            local p = Vector((i-1)%6, ((i-1)//6))*Vector(12,10)+pos+Vector(0,-1)
            local soulBit = ToyboxMod:getSoulShieldBit(pl, i-1-numMaxReds)

            if(soulBit~=0) then
                ToyboxMod:renderSteelSoulSprite(pl, p)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS, renderSoulShields)

---@param pl EntityPlayer
local function destroySoulShields(_, pl, dmg, flags, source, frames)
    pl = pl:ToPlayer()

    if(flags & (DamageFlag.DAMAGE_RED_HEARTS)~=0 and getReadHearts(pl)>0) then return end

    local disposableDmg = dmg
    local numDamageRemoved = 0
    local extraHeartIdx = ToyboxMod:getMaxExtraHeartIdx(pl)

    if(disposableDmg>0 and not pl:IsBoneHeart(extraHeartIdx) and getSoulHearts(pl)%2~=0) then
        disposableDmg = disposableDmg-1
        extraHeartIdx = extraHeartIdx-1
    end

    while(disposableDmg>0 and extraHeartIdx>=0 and not pl:IsBoneHeart(extraHeartIdx)) do
        local soulBit = ToyboxMod:getSoulShieldBit(pl, extraHeartIdx)
        if(soulBit>0) then
            disposableDmg = disposableDmg-1
            numDamageRemoved = numDamageRemoved+1
            ToyboxMod:setSoulShieldBit(pl, extraHeartIdx, 0)
        end
        disposableDmg = disposableDmg-2
        extraHeartIdx = extraHeartIdx-1
    end
    
    if(numDamageRemoved>0) then
        sfx:Play(ToyboxMod.SOUND_EFFECT.ATLASA_METALBLOCK)
        Game():ShakeScreen(5)

        return {
            Damage=dmg-numDamageRemoved,
            DamageFlags=flags,
            DamageCountdown=frames,
        }
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1e12+(CustomHealthAPI and (-1e12-1e3) or 0), destroySoulShields, EntityType.ENTITY_PLAYER)
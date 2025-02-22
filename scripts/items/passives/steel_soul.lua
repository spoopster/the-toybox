local mod = MilcomMOD
local sfx = SFXManager()

local SHIELD_FRAMES_MULT = 0.25

---@param pl EntityPlayer
function mod:getSoulShieldMask(pl)
    return (mod:getEntityData(pl, "STEELSOUL_SHIELDMASK") or 0)
end
---@param pl EntityPlayer
function mod:setSoulShieldBit(pl, idx, val)
    local data = mod:getEntityDataTable(pl)

    if(val==0) then data.STEELSOUL_SHIELDMASK = (data.STEELSOUL_SHIELDMASK or 0) & (~(1<<idx))
    else data.STEELSOUL_SHIELDMASK = (data.STEELSOUL_SHIELDMASK or 0) | (1<<idx) end
end
---@param pl EntityPlayer
function mod:getSoulShieldBit(pl, idx)
    local data = mod:getEntityDataTable(pl)
    return ((data.STEELSOUL_SHIELDMASK or 0) & (1<<idx) ~= 0) and 1 or 0
end
---@param pl EntityPlayer
function mod:getMaxExtraHeartIdx(pl)
    return math.ceil(pl:GetSoulHearts()/2)+pl:GetBoneHearts()-1
end

---@param pl EntityPlayer
local function giveSoulShield(_, pl, amount, hpType)
    if(not (hpType==AddHealthType.SOUL or hpType==AddHealthType.BONE)) then return end
    if(not pl:HasCollectible(mod.COLLECTIBLE_STEEL_SOUL)) then return end
    local data = mod:getEntityDataTable(pl)
    data.PREV_SOULHP = data.PREV_SOULHP or 0

    local heartDif = pl:GetSoulHearts()-(data.PREV_SOULHP-data.PREV_SOULHP%2)
    local heartIdx = mod:getMaxExtraHeartIdx(pl)

    if(heartDif>0) then
        while(pl:IsBoneHeart(heartIdx)) do heartIdx = heartIdx-1 end
        if(pl:GetSoulHearts()>0 and pl:GetSoulHearts()%2~=0) then heartIdx = heartIdx-1 end

        while(heartDif>1 and heartIdx>=0) do
            if(pl:IsBoneHeart(heartIdx)) then
                heartIdx = heartIdx-1
            else
                mod:setSoulShieldBit(pl, heartIdx, 1)
                heartDif = heartDif-2
                heartIdx = heartIdx-1
            end
        end
    end
    data.PREV_SOULHP = pl:GetSoulHearts()
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, math.huge, giveSoulShield)

---@param pl EntityPlayer
local function updateHpData(_, pl)
    mod:setEntityData(pl, "PREV_SOULHP", pl:GetSoulHearts())
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateHpData, 0)

local heartSprite, test = Sprite("gfx/ui/tb_ui_steelsoul_heart.anm2", true)
heartSprite:Play("Idle", true)

function mod:renderSteelSoulSprite(player, pos)
    heartSprite:Render(pos)
end

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")
---@param pl EntityPlayer
local function renderSoulShields(_, offset, sprite, pos, x, pl)
    local idx = pl:GetPlayerIndex()
    local hud = Game():GetHUD():GetPlayerHUD(math.min(7,idx))
    local h = hud:GetHearts()
    local sp = Game():GetHUD():GetHeartsSprite()

    local numMaxReds = math.ceil(pl:GetMaxHearts()/2)
    for i, heartData in pairs(h) do
        if(heartData:IsVisible() and i>numMaxReds) then
            local p = Vector((i-1)%6, ((i-1)//6))*Vector(12,10)+pos---Vector(3,8)+Vector(0, 30)
            local soulBit = mod:getSoulShieldBit(pl, i-1-numMaxReds)

            if(soulBit~=0) then
                mod:renderSteelSoulSprite(pl, p)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS, renderSoulShields)

---@param pl EntityPlayer
local function stupidfuckinghackFuckyouCHAPI(_, pl, damage, flags, source, count)
    mod:setEntityData(pl, "STEELSOUL_GETHEARS",
    {
        Red = pl:GetHearts(),
        Soul = pl:GetSoulHearts(),
        Bone = pl:GetBoneHearts(),
    })
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, stupidfuckinghackFuckyouCHAPI, 0)

---@param pl EntityPlayer
local function destroySoulShields(_, pl, dmg, flags, source, frames)
    pl = pl:ToPlayer()
    local heartData = mod:getEntityData(pl, "STEELSOUL_GETHEARS")
    if(not heartData) then return end

    if(flags & (DamageFlag.DAMAGE_RED_HEARTS)~=0 and heartData.Red>0) then return end

    local disposableDmg = dmg
    local numDamageRemoved = 0
    local extraHeartIdx = math.ceil(heartData.Soul/2)+heartData.Bone-1

    if(disposableDmg>0 and not pl:IsBoneHeart(extraHeartIdx) and heartData.Soul%2~=0) then
        disposableDmg = disposableDmg-1
        extraHeartIdx = extraHeartIdx-1
    end

    while(disposableDmg>0 and extraHeartIdx>=0 and not pl:IsBoneHeart(extraHeartIdx)) do
        local soulBit = mod:getSoulShieldBit(pl, extraHeartIdx)
        if(soulBit>0) then
            disposableDmg = disposableDmg-1
            numDamageRemoved = numDamageRemoved+1
            mod:setSoulShieldBit(pl, extraHeartIdx, 0)
        end
        disposableDmg = disposableDmg-2
        extraHeartIdx = extraHeartIdx-1
    end
    
    if(numDamageRemoved>0) then
        sfx:Play(mod.SFX_ATLASA_METALBLOCK)
        Game():ShakeScreen(5)

        return {
            Damage=dmg-numDamageRemoved,
            DamageFlags=flags,
            DamageCountdown=frames,
        }
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1e12+(CustomHealthAPI and (-1e12-1e3) or 0), destroySoulShields, EntityType.ENTITY_PLAYER)
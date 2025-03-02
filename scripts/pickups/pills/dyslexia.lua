local mod = MilcomMOD
local sfx = SFXManager()

local DURATION = 30*60

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = mod:getEntityDataTable(player)
    data.DYSLEXIA_DURATION = DURATION
    data.DYSLEXIA_HORSE = isHorse

    player:AnimateSad()
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED or SoundEffect.SOUND_THUMBS_DOWN))
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_EFFECT.DYSLEXIA)

--! randomeze streings
local function shouldDysxzjejcinz()
    for _, player in ipairs(Isaac.FindByType(1)) do
        if(mod:getEntityData(player, "DYSLEXIA_DURATION")~=0) then return true end
    end
    return false
end
local function dyskecislzeStreng(s)
    local newstr = ""
    for str in string.gmatch(s, "[^%s]+[%s]*") do
        local chars = {}
        local randomizedChars = ""
        for char in string.gmatch(str, "[^%s]") do table.insert(chars, char) end
    
        while(#chars>0) do
            local ridx = math.random(#chars)
            randomizedChars = randomizedChars..chars[ridx]
            table.remove(chars, ridx)
        end
    
        for space in string.gmatch(str, "[%s]*") do randomizedChars = randomizedChars..space end
    
        newstr = newstr..randomizedChars
    end
    return newstr
end

local dyselkxubgzeg = false
local function cancleTxtdispey(_, teete, sutbile, stucky, crse)
    if(stucky or dyselkxubgzeg or not shouldDysxzjejcinz()) then return end
    dyselkxubgzeg = true
    Game():GetHUD():ShowItemText(dyskecislzeStreng(teete), dyskecislzeStreng(sutbile), crse)
    dyselkxubgzeg = false

    return false
end
mod:AddCallback(ModCallbacks.MC_PRE_ITEM_TEXT_DISPLAY, cancleTxtdispey)

--! actolly do the efect
local function getpyaerfromet(ent)
	local player = nil
    local sp = ent.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(fam.Variant==FamiliarVariant.FATES_REWARD or mod.COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

    return player
end
---@param player EntityPlayer
local function getdyselxiaoffset(player)
    local data = mod:getEntityDataTable(player)
    data.DYSLEXIA_DURATION = data.DYSLEXIA_DURATION or 0

    if(data.DYSLEXIA_DURATION<=0) then return 0
    elseif(data.DYSLEXIA_HORSE) then return player:GetPillRNG(mod.PILL_EFFECT.DYSLEXIA):RandomInt(360)
    else return 180 end
end
local function spanrrhasdyselxia(player)
    if(not player) then return false end
    local data = mod:getEntityDataTable(player)
    data.DYSLEXIA_DURATION = data.DYSLEXIA_DURATION or 0
    if(data.DYSLEXIA_DURATION>0) then return true end
    return false
end

---@param player EntityPlayer
local function playrrupate(_, player)
    local data = mod:getEntityDataTable(player)
    data.DYSLEXIA_DURATION = data.DYSLEXIA_DURATION or 0
    if(data.DYSLEXIA_DURATION>0) then data.DYSLEXIA_DURATION = data.DYSLEXIA_DURATION-1 end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, playrrupate, 0)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,
function(_, e)
    local p = getpyaerfromet(e)
    if(not spanrrhasdyselxia(p)) then return end
    e.Position = e.Position-e.Velocity
    e.Velocity = e.Velocity:Rotated(getdyselxiaoffset(p))
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB,
function(_, e)
    local p = getpyaerfromet(e)
    if(not spanrrhasdyselxia(p)) then return end
    e.Velocity = e.Velocity:Rotated(getdyselxiaoffset(p))
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER,
function(_, e)
    local p = getpyaerfromet(e)
    if(not spanrrhasdyselxia(p)) then return end
    e.AngleDegrees = e.AngleDegrees-getdyselxiaoffset(p)
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER,
function(_, e)
    local p = getpyaerfromet(e)
    if(not spanrrhasdyselxia(p)) then return end
    e.Position = e.Position-e.Velocity
    e.Velocity = e.Velocity:Rotated(getdyselxiaoffset(p))
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE,
function(_, e)
    local p = getpyaerfromet(e)
    if(not spanrrhasdyselxia(p)) then return end
    e.AngleDegrees = e.AngleDegrees-getdyselxiaoffset(p)
end
)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE,
function(_, e)
    local p = getpyaerfromet(e)
    if(not spanrrhasdyselxia(p)) then return end
    e.RotationOffset = getdyselxiaoffset(p)
end
)

mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER,
function(_, e)
    local p = getpyaerfromet(e)
    if(not spanrrhasdyselxia(p)) then return end
    local data = mod:getEntityDataTable(e)
    data.DYSLEXIA_PREV_JOYSTICK = mod:lerp((data.DYSLEXIA_PREV_JOYSTICK or p:GetAimDirection()), p:GetAimDirection(), 0.4)
    e.Velocity = data.DYSLEXIA_PREV_JOYSTICK:Rotated(getdyselxiaoffset(p))*40
    return true
end,
EffectVariant.TARGET)
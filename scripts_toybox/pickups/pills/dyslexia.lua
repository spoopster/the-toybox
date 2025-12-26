
local sfx = SFXManager()

local DURATION = 30*60

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = ToyboxMod:getEntityDataTable(player)
    data.DYSLEXIA_DURATION = DURATION
    data.DYSLEXIA_HORSE = isHorse

    player:AnimateSad()
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED or SoundEffect.SOUND_THUMBS_DOWN))
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_DYSLEXIA)

--! randomeze streings
local function shouldDysxzjejcinz()
    for _, player in ipairs(Isaac.FindByType(1)) do
        if(ToyboxMod:getEntityData(player, "DYSLEXIA_DURATION")~=0) then return true end
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
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ITEM_TEXT_DISPLAY, cancleTxtdispey)

--! actolly do the efect
local function getpyaerfromet(ent)
	local player = nil
    local sp = ent.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(fam.Variant==FamiliarVariant.FATES_REWARD or ToyboxMod.TEAR_COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

    return player
end
---@param player EntityPlayer
local function getdyselxiaoffset(player)
    local data = ToyboxMod:getEntityDataTable(player)
    data.DYSLEXIA_DURATION = data.DYSLEXIA_DURATION or 0

    if(data.DYSLEXIA_DURATION<=0) then return 0
    elseif(data.DYSLEXIA_HORSE) then return player:GetPillRNG(ToyboxMod.PILL_DYSLEXIA):RandomInt(360)
    else return 180 end
end
local function spanrrhasdyselxia(player)
    if(not player) then return false end
    local data = ToyboxMod:getEntityDataTable(player)
    data.DYSLEXIA_DURATION = data.DYSLEXIA_DURATION or 0
    if(data.DYSLEXIA_DURATION>0) then return true end
    return false
end

---@param player EntityPlayer
local function playrrupate(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    data.DYSLEXIA_DURATION = data.DYSLEXIA_DURATION or 0
    if(data.DYSLEXIA_DURATION>0) then data.DYSLEXIA_DURATION = data.DYSLEXIA_DURATION-1 end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, playrrupate, 0)

local SHOOT_ACTIONS = {
    [ButtonAction.ACTION_SHOOTUP] = true,
    [ButtonAction.ACTION_SHOOTDOWN] = true,
    [ButtonAction.ACTION_SHOOTLEFT] = true,
    [ButtonAction.ACTION_SHOOTRIGHT] = true,
}

---@param ent Entity
---@param hook InputHook
---@param action ButtonAction
local function inputstuff(_, ent, hook, action)
    if(not (ent and ent:ToPlayer())) then return end
    local pl = ent:ToPlayer() or Isaac.GetPlayer() ---@type EntityPlayer

    if(not SHOOT_ACTIONS[action]) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    if(not (data.DYSLEXIA_DURATION and data.DYSLEXIA_DURATION>0)) then return end

    local plidx = pl.ControllerIndex
    local holdingmouse = (Options.MouseControl and Input.IsMouseBtnPressed(MouseButton.LEFT))
    local isholdinganyshootinput = holdingmouse
    for i, _ in pairs(SHOOT_ACTIONS) do
        isholdinganyshootinput = isholdinganyshootinput or Input.IsActionPressed(i, plidx)
    end
    if(not isholdinganyshootinput) then return end

    local vec = Vector.Zero
    if(data.DYSLEXIA_HORSE) then
        vec = Vector.FromAngle(math.random(1,360))
    else
        if(holdingmouse) then
            vec = (pl.Position-Input.GetMousePosition(true)):Normalized()
        else
            vec = Vector(
                Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, plidx)-Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, plidx),
                Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, plidx)-Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, plidx)
            )
        end
    end

    if(holdingmouse) then
        local dist = (Input.GetMousePosition(true)-pl.Position):Length()
        vec = vec*dist*2
    end

    local valy = (action==ButtonAction.ACTION_SHOOTUP and -1 or 1)*vec.Y
    local valx = (action==ButtonAction.ACTION_SHOOTLEFT and -1 or 1)*vec.X

    if(hook==InputHook.IS_ACTION_PRESSED or hook==InputHook.IS_ACTION_TRIGGERED) then
        if(action==ButtonAction.ACTION_SHOOTUP or action==ButtonAction.ACTION_SHOOTDOWN) then
            return math.abs(valy)>0.01
        else
            return math.abs(valx)>0.01
        end
    elseif(hook==InputHook.GET_ACTION_VALUE) then
        if(action==ButtonAction.ACTION_SHOOTUP or action==ButtonAction.ACTION_SHOOTDOWN) then
            return valy
        else
            return valx
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, inputstuff)
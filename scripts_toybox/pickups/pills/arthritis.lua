
local sfx = SFXManager()

local DURATION = 10*60
local TEARS_MULT = 3
local DMG_UP = 1.5

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = ToyboxMod:getEntityDataTable(player)
    data.ARTHRITIS_DURATION = DURATION*(isHorse and 2 or 1)
    data.ARTHRITIS_HORSE = isHorse
    data.ARTHRITIS_CHOSEN_ANGLE = -1000
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true)

    player:AnimateHappy()
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_ARTHRITIS)

local function cacheEval(_, player, flag)
    local data = ToyboxMod:getEntityDataTable(player)
    if((data.ARTHRITIS_DURATION or 0)<=0) then return end

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = ToyboxMod:toFireDelay(ToyboxMod:toTps(player.MaxFireDelay)*TEARS_MULT)
    elseif(flag==CacheFlag.CACHE_DAMAGE and data.ARTHRITIS_HORSE) then
        ToyboxMod:addBasicDamageUp(player, DMG_UP)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cacheEval)

---@param player EntityPlayer
local function reduceDuration(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    data.ARTHRITIS_DURATION = data.ARTHRITIS_DURATION or 0
    if(data.ARTHRITIS_DURATION>0) then
        if(data.ARTHRITIS_CHOSEN_ANGLE~=-1000) then
            data.ARTHRITIS_DURATION = data.ARTHRITIS_DURATION-1
            if(data.ARTHRITIS_DURATION==0) then player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true) end
        elseif(player:GetAimDirection():Length()>0.01) then
            data.ARTHRITIS_CHOSEN_ANGLE = player:GetAimDirection():GetAngleDegrees()
        end
    else
        data.ARTHRITIS_CHOSEN_ANGLE = -1000
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, reduceDuration, 0)

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

    local angle = ToyboxMod:getEntityData(pl, "ARTHRITIS_CHOSEN_ANGLE") or -1000
    if(angle==-1000) then return end

    local holdingmouse = (Options.MouseControl and Input.IsMouseBtnPressed(MouseButton.LEFT))
    local isholdinganyshootinput = holdingmouse
    for i, _ in pairs(SHOOT_ACTIONS) do
        isholdinganyshootinput = isholdinganyshootinput or Input.IsActionPressed(i, pl.ControllerIndex)
    end
    if(not isholdinganyshootinput) then return end

    local vec = Vector.FromAngle(angle)
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
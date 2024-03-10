local mod = MilcomMOD

--#region DATA

---@param player EntityPlayer
function mod:getMilcomATable(player)
    return mod.MILCOM_A_DATA[player.InitSeed]
end
---@param player EntityPlayer
---@param key string
function mod:getMilcomAData(player, key)
    return mod.MILCOM_A_DATA[player.InitSeed][key]
end
---@param player EntityPlayer
---@param key string
function mod:setMilcomAData(player, key, val)
    mod.MILCOM_A_DATA[player.InitSeed][key] = val
end

--#endregion

--#region PICKUPS

function mod:getNumCardboard()
    --return mod.MILCOM_A_PICKUPS.CARDBOARD
    return mod.MILCOM_A_PICKUPS.CARDBOARD
end
function mod:getNumDuctTape()
    --return mod.MILCOM_A_PICKUPS.DUCT_TAPE
    return mod.MILCOM_A_PICKUPS.DUCT_TAPE
end
function mod:getNumNails()
    --return mod.MILCOM_A_PICKUPS.NAILS
    return mod.MILCOM_A_PICKUPS.NAILS
end

function mod:canMilcomUseCoins()
    if(mod:anyPlayerHasCraftable("CREDIT CARDBOARD")) then return true end
    return false
end
function mod:canMilcomUseBombs()
    if(mod:anyPlayerHasCraftable("MAKESHIFT BOMB")) then return true end
    return false
end
function mod:canMilcomUseKeys()
    if(mod:anyPlayerHasCraftable("MAKESHIFT KEY")) then return true end
    return false
end

function mod:addCardboard(val)
    if(mod:canMilcomUseCoins()) then
        Isaac.GetPlayer():AddCoins(val)
    else
        mod.MILCOM_A_PICKUPS.CARDBOARD = mod:clamp(mod.MILCOM_A_PICKUPS.CARDBOARD+val, 99, 0)
    end
end
function mod:addDuctTape(val)
    if(mod:canMilcomUseBombs()) then
        Isaac.GetPlayer():AddBombs(val)
    else
        mod.MILCOM_A_PICKUPS.DUCT_TAPE = mod:clamp(mod.MILCOM_A_PICKUPS.DUCT_TAPE+val, 99, 0)
    end
end
function mod:addNails(val)
    if(mod:canMilcomUseKeys()) then
        Isaac.GetPlayer():AddKeys(val)
    else
        mod.MILCOM_A_PICKUPS.NAILS = mod:clamp(mod.MILCOM_A_PICKUPS.NAILS+val, 99, 0)
    end
end

--#endregion

function mod:isAnyPlayerMilcomA()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        if(player:ToPlayer():GetPlayerType()==mod.PLAYER_MILCOM_A) then return true end
    end
    return false
end

function mod:getFirstMilcomA()
    for _, player in ipairs(Isaac.FindByType(1,0,mod.PLAYER_MILCOM_A)) do
        return player
    end
    return nil
end

function mod:isMapButtonHeld()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        if(Input.IsActionPressed(ButtonAction.ACTION_MAP, player:ToPlayer().ControllerIndex)) then return true end
    end
    return false
end

function mod:getAllMilcomA()
    local t = {}
    for i=0, Game():GetNumPlayers()-1 do
        local p = Isaac.GetPlayer():ToPlayer()
        if(p:GetPlayerType()==mod.PLAYER_MILCOM_A) then t[#t+1] = p end
    end

    return t
end
function mod:valueExistsInTable(val, t)
    for key, val2 in pairs(t) do
        if(val==val2) then return true end
    end
    return false
end

function mod:getValidCraftingIndex(num)
    return (num-1)%#mod.CRAFTABLE_A_CATEGORIES+1
end
function mod:getValidInventoryIndex(num, mx)
    return mod:clamp(num, mx, 1)
end
function mod:changeMenuLogic(current, change, numCraftables)
    if(current==1 and change>0) then
        if(numCraftables==0) then return {NEWLEVEL=current, PLAYSFX=0}
        else return {NEWLEVEL=2, PLAYSFX=1} end
    elseif(current==1 and change<0) then return {NEWLEVEL=current, PLAYSFX=0}
    elseif(current==2 and change<0) then return {NEWLEVEL=1, PLAYSFX=1}
    elseif(current==2 and change>0) then return {NEWLEVEL=current, PLAYSFX=0} end
    return {NEWLEVEL=current}
end

function mod:playerHasCraftable(player, craftable)
    return mod:valueExistsInTable(craftable, mod:getMilcomAData(player,"OWNED_CRAFTABLES"))
end
function mod:anyPlayerHasCraftable(craftable)
    for _, p in ipairs(mod:getAllMilcomA()) do
        if(mod:playerHasCraftable(p:ToPlayer(), craftable)) then return true end
    end
    return false
end
function mod:addCraftable(player, craftable)
    local data = mod:getMilcomATable(player)
    data.OWNED_CRAFTABLES[#data.OWNED_CRAFTABLES+1] = craftable
end
function mod:hasNextLevel(name)
    for i, d in ipairs(mod.CRAFTABLES_A) do
        if(d.PREV_CRAFTABLE==name) then return true end
    end
    return false
end
function mod:getCraftableIdByName(name)
    for i, d in ipairs(mod.CRAFTABLES_A) do
        if(d.NAME==name) then return i end
    end
    return 1
end

function mod:formatMilcomDescription(f, descTable, maxwidth)
    local formattedDesc = {}
    for _, str in ipairs(descTable) do
        local formattedStr = mod:separateStringIntoLines(f, str, maxwidth)
        for _, s in ipairs(formattedStr) do formattedDesc[#formattedDesc+1] = s end
    end

    return formattedDesc
end
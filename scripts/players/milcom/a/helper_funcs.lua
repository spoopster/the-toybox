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

function mod:addCardboard(val, willUnlockUpgrade)
    if(mod:anyPlayerHasCraftable("CREDIT_CARDBOARD")) then
        Isaac.GetPlayer():AddCoins(val)

        if(willUnlockUpgrade) then mod.MILCOM_A_PICKUPS.CARDBOARD_NOUPGRADE = mod.MILCOM_A_PICKUPS.CARDBOARD+val end
    else
        mod.MILCOM_A_PICKUPS.CARDBOARD = mod:clamp(mod.MILCOM_A_PICKUPS.CARDBOARD+val, 99, 0)
    end
end
function mod:addDuctTape(val, willUnlockUpgrade)
    if(mod:anyPlayerHasCraftable("MAKESHIFT_BOMB")) then
        Isaac.GetPlayer():AddBombs(val)

        if(willUnlockUpgrade) then mod.MILCOM_A_PICKUPS.DUCT_TAPE_NOUPGRADE = mod.MILCOM_A_PICKUPS.DUCT_TAPE+val end
    else
        mod.MILCOM_A_PICKUPS.DUCT_TAPE = mod:clamp(mod.MILCOM_A_PICKUPS.DUCT_TAPE+val, 99, 0)
    end
end
function mod:addNails(val, willUnlockUpgrade)
    if(mod:anyPlayerHasCraftable("MAKESHIFT_KEY")) then
        Isaac.GetPlayer():AddKeys(val)

        if(willUnlockUpgrade) then mod.MILCOM_A_PICKUPS.NAILS_NOUPGRADE = mod.MILCOM_A_PICKUPS.NAILS+val end
    else
        mod.MILCOM_A_PICKUPS.NAILS = mod:clamp(mod.MILCOM_A_PICKUPS.NAILS+val, 99, 0)
    end
end

--#endregion

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
function mod:getCraftableFromCategory(player, category)
    local cTable = mod.CRAFTABLE_A_CATEGORIES[category]
    for i, val in ipairs(cTable) do
        if(not mod:playerHasCraftable(player, val)) then
            return {LEVEL=i, NAME=val, ISMAXED=false}
        end
    end
    return {LEVEL=#cTable, NAME=cTable[#cTable], ISMAXED=true}
end

function mod:formatMilcomDescription(f, descTable, maxwidth)
    local formattedDesc = {}
    for _, str in ipairs(descTable) do
        local formattedStr = mod:separateStringIntoLines(f, str, maxwidth)
        for _, s in ipairs(formattedStr) do formattedDesc[#formattedDesc+1] = s end
    end

    return formattedDesc
end
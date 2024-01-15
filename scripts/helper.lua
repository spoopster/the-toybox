local mod = MilcomMOD

function mod:unlock(unlock, force)
    local pgd = Isaac.GetPersistentGameData()
    if(not force) then
        if(not Game():AchievementUnlocksDisallowed()) then
            if(not pgd:Unlocked(unlock)) then
                pgd:TryUnlock(unlock)
            end
        end
    else
        pgd:TryUnlock(unlock)
    end
end

function mod:cloneTable(t)
    local tClone = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            tClone[key]={}
            for key2, val2 in pairs(mod:cloneTable(val)) do
                tClone[key][key2]=val2
            end
        else
            tClone[key]=val
        end
    end
    return tClone
end
function mod:cloneTableWithoutDeleteing(table1, table2)
    for key, val in pairs(table2) do
        if(type(val)=="table") then
            table1[key] = {}
            mod:cloneTableWithoutDeleteing(table1[key], table2[key])
        else
            table1[key]=val
        end
    end
end

---@param v Vector
function mod:vectorToVectorTable(v)
    return
    {
        X = v.X,
        Y = v.Y,
        IsVectorTable = true,
    }
end
---@param t table
function mod:vectorTableToVector(t)
    return Vector(t.X, t.Y)
end

---@param c Color
function mod:colorToColorTable(c)
    return
    {
        R = c.R,
        G = c.G,
        B = c.B,
        A = c.A,
        RO = c.RO,
        GO = c.GO,
        BO = c.BO,
        IsColorTable = true,
    }
end
---@param t table
function mod:colorTableToColor(t)
    return Color(t.R, t.G, t.B, t.A, t.RO, t.GO, t.BO)
end

---@param player EntityPlayer
function mod:isMilcom(player)
    if(player:GetPlayerType()==mod.PLAYER_MILCOM_A) then return true end
    if(player:GetPlayerType()==mod.PLAYER_MILCOM_B) then return true end
    return false
end
function mod:isAnyPlayerMilcomA()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        if(player:ToPlayer():GetPlayerType()==mod.PLAYER_MILCOM_A) then return true end
    end
    return false
end

---@param val number Value to clamp
---@param upper number Upper bound of the range
---@param lower number Lower bound of the range
---@return number clampedVal The clamped value
---Clamps a given value into a range
function mod:clamp(val, upper, lower)
    return math.min(upper, math.max(val, lower))
end

function mod:lerp(a, b, f)
    return a*(1-f)+b*f
end

---@param t table The table to count
---@return number count The number of elements in the table
---Counts the number of elements in a table
function mod:countElements(t)
    local count = 0
    for key, val in pairs(t) do count = count+1 end

    return count
end

---@param player EntityPlayer
---@return number num
function mod:getPlayerNumFromPlayerEnt(player)
    for i=0, Game():GetNumPlayers()-1 do
        if(GetPtrHash(player)==GetPtrHash(Isaac.GetPlayer(i))) then return i end
    end
    return 0
end

function mod:getScreenCenter()
    return (Game():GetRoom():GetRenderSurfaceTopLeft()*2+Vector(442,286))/2
end
function mod:getScreenBottomRight()
    return Game():GetRoom():GetRenderSurfaceTopLeft()*2+Vector(442,286)
end

function mod:addCustomStrawman(playerType, cIndex)
    playerType=playerType or 0
    cIndex=cIndex or 0
    local LastPlayerIndex=Game():GetNumPlayers()-1
    if LastPlayerIndex>=63 then return nil else
        Isaac.ExecuteCommand('addplayer '..playerType..' '..cIndex)
        local strawman=Isaac.GetPlayer(LastPlayerIndex+1)
        strawman.Parent=Isaac.GetPlayer(0)
        Game():GetHUD():AssignPlayerHUDs()
        return strawman
    end
end

---true players just means they're not strawman-like characters
function mod:getNumberOfTruePlayers()
    local c = 0
    for _, player in ipairs(Isaac.FindByType(1)) do
        if(player.Parent~=nil) then c=c+1 end
    end
    return c
end

---@param f Font
---@param str string
---@param maxlength number
function mod:separateStringIntoLines(f, str, maxlength)
    local fStrings = {}
    local splitStrings = {}

    for s in str:gmatch("([^ ]+)") do
        splitStrings[#splitStrings+1] = s
    end

    local st = ""

    for _, s in ipairs(splitStrings) do
        if(f:GetStringWidth(st.." "..s)>maxlength) then
            fStrings[#fStrings+1] = st
            st=s
        else
            st=st.." "..s
        end
    end

    fStrings[#fStrings+1] = st

    return fStrings
end

---@param pos Vector
function mod:closestPlayer(pos)
	local entities = Isaac.FindByType(1)
	local closestEnt = Isaac.GetPlayer()
	local closestDist = 2^32
	for i = 1, #entities do
		if not entities[i]:IsDead() then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]:ToPlayer()
			end
		end
	end
	return closestEnt
end
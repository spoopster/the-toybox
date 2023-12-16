local mod = MilcomMOD

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
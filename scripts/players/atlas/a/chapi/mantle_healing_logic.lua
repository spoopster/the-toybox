local mod = MilcomMOD

if(CustomHealthAPI) then
    local KEY_TO_MANTLE = {
        ["RED_HEART"] =     mod.MANTLE_DATA.DEFAULT.ID,
        ["SOUL_HEART"] =    mod.MANTLE_DATA.METAL.ID,
        ["BLACK_HEART"] =   mod.MANTLE_DATA.DARK.ID,
        ["ETERNAL_HEART"] = mod.MANTLE_DATA.HOLY.ID,
        ["GOLDEN_HEART"] =  mod.MANTLE_DATA.GOLD.ID,
        ["BONE_HEART"] =    mod.MANTLE_DATA.BONE.ID,
        ["ROTTEN_HEART"] =  mod.MANTLE_DATA.POOP.ID,
    }
    if(FiendFolio) then
        KEY_TO_MANTLE["IMMORAL_HEART"] = mod.MANTLE_DATA.DARK.ID
        KEY_TO_MANTLE["MORBID_HEART"] = mod.MANTLE_DATA.POOP.ID
    end

    local function addHealth(p, k, n)
        if(not mod:isAtlasA(p)) then return end
        if(p.FrameCount==0) then return end
        if(mod:getAtlasATable(p)==nil) then return end

        if(KEY_TO_MANTLE[k] and n~=0) then
            local a = n

            local data = mod:getAtlasATable(p)
            while(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLE_DATA.NONE.ID and a>0) do
                mod:giveMantle(p, KEY_TO_MANTLE[k])
                a = a-2
            end
            if(a>0 and data.TRANSFORMATION~=mod.MANTLE_DATA.TAR.ID) then
                mod:addMantleHp(p, a)
                for i=1, mod:getRightmostMantleIdx(p) do
                    data.MANTLES[i].COLOR = Color(1,1,1,1,1)
                end
            end
        end

        return true
    end
    CustomHealthAPI.Library.AddCallback(mod, CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH, -math.huge, addHealth)

end
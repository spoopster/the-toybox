local mod = MilcomMOD

if(CustomHealthAPI) then
    local KEY_TO_MANTLE = {
        ["RED_HEART"] =     mod.MANTLES.DEFAULT,
        ["SOUL_HEART"] =    mod.MANTLES.METAL,
        ["BLACK_HEART"] =   mod.MANTLES.DARK,
        ["ETERNAL_HEART"] = mod.MANTLES.HOLY,
        ["GOLDEN_HEART"] =  mod.MANTLES.GOLD,
        ["BONE_HEART"] =    mod.MANTLES.BONE,
        ["ROTTEN_HEART"] =  mod.MANTLES.POOP,
    }
    if(FiendFolio) then
        KEY_TO_MANTLE["IMMORAL_HEART"] = mod.MANTLES.DARK
        KEY_TO_MANTLE["MORBID_HEART"] = mod.MANTLES.POOP
    end

    local function addHealth(p, k, n)
        if(p:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
        if(p.FrameCount==0) then return end
        if(mod:getAtlasATable(p)==nil) then return end

        if(KEY_TO_MANTLE[k] and n~=0) then
            local a = n

            local data = mod:getAtlasATable(p)
            while(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLES.NONE and a>0) do
                mod:giveMantle(p, KEY_TO_MANTLE[k])
                a = a-2
            end
            if(a>0 and data.TRANSFORMATION~=mod.MANTLES.TAR) then
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
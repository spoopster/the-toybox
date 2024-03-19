local mod = MilcomMOD

local HEARTS_TO_MANTLETYPE = {
    [AddHealthType.RED] =       mod.MANTLES.DEFAULT,
    --[AddHealthType.MAX] =       mod.MANTLES.DEFAULT,
    [AddHealthType.SOUL] =      mod.MANTLES.METAL,
    [AddHealthType.BLACK] =     mod.MANTLES.DARK,
    [AddHealthType.ETERNAL] =   mod.MANTLES.HOLY,
    [AddHealthType.GOLDEN] =    mod.MANTLES.GOLD,
    [AddHealthType.BONE] =      mod.MANTLES.BONE,
    [AddHealthType.ROTTEN] =    mod.MANTLES.POOP,
}

if(CustomHealthAPI==nil) then
    mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, function() end) --poopy

    ---@param player EntityPlayer
    local function atlasAddMantles(_, player, num, type, arg)
        if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
            local amount = num
            if(HEARTS_TO_MANTLETYPE[type] and amount>0) then
                local data = mod:getAtlasATable(player)

                while(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLES.NONE and amount>0) do
                    --print("ADDING_MANTLE", type, amount)
                    mod:giveMantle(player, HEARTS_TO_MANTLETYPE[type])
                    amount = amount-2
                end
                if(amount~=0 and data.TRANSFORMATION~=mod.MANTLES.TAR) then
                    --print("HEALING", type, amount)
                    mod:addMantleHp(player, amount)
                    for i=1, mod:getRightmostMantleIdx(player) do
                        data.MANTLES[i].COLOR = Color(1,1,1,1,1)
                    end
                end
            end
        end
    end
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, atlasAddMantles)
end
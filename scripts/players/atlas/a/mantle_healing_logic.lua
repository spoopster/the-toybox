local mod = MilcomMOD

local HEARTS_TO_MANTLETYPE = {
    [AddHealthType.RED] =       mod.MANTLE_DATA.DEFAULT.ID,
    --[AddHealthType.MAX] =       mod.MANTLE_DATA.DEFAULT.ID,
    [AddHealthType.SOUL] =      mod.MANTLE_DATA.METAL.ID,
    [AddHealthType.BLACK] =     mod.MANTLE_DATA.DARK.ID,
    [AddHealthType.ETERNAL] =   mod.MANTLE_DATA.HOLY.ID,
    [AddHealthType.GOLDEN] =    mod.MANTLE_DATA.GOLD.ID,
    [AddHealthType.BONE] =      mod.MANTLE_DATA.BONE.ID,
    [AddHealthType.ROTTEN] =    mod.MANTLE_DATA.POOP.ID,
}

if(CustomHealthAPI==nil) then
    local function cancelNegAddition(_, player, num, type, arg)
        if(mod:isAtlasA(player) and mod.IS_DATA_LOADED and player.FrameCount>0) then
            if(num<0) then return 0 end
        end
    end
    mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, cancelNegAddition) --poopy

    ---@param player EntityPlayer
    local function atlasAddMantles(_, player, num, type, arg)
        if(mod:isAtlasA(player) and mod.IS_DATA_LOADED and player.FrameCount>0) then

            --! this is just funny dotn add it in!!!
            --[[
            if(type==AddHealthType.BROKEN) then
                local data = mod:getAtlasATable(player)
                if(data and data.HP_CAP>1) then
                    data.HP_CAP = data.HP_CAP-1
                    mod:updateMantles(player)
                end
            end
            --]]

            --print(type,num)
            
            local amount = num
            if(HEARTS_TO_MANTLETYPE[type] and amount>0) then
                local data = mod:getAtlasATable(player)

                while(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLE_DATA.NONE.ID and amount>0) do
                    mod:giveMantle(player, HEARTS_TO_MANTLETYPE[type])
                    amount = amount-2
                end
                if(amount~=0 and data.TRANSFORMATION~=mod.MANTLE_DATA.TAR.ID) then
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
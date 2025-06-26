ToyboxMod.CALLBACK_BOMBS_FIRED = {}

local function copyScatterData(bomb)
	for _, sBomb in pairs(ToyboxMod.CALLBACK_BOMBS_FIRED) do
        Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.COPY_SCATTER_BOMB_DATA, sBomb, bomb)
		ToyboxMod:setEntityData(sBomb, "IS_SCATTER_BOMB", true)
        ToyboxMod:setEntityData(sBomb, "IS_FIRED_BOMB", ToyboxMod:getEntityData(bomb, "IS_FIRED_BOMB"))
	end

	--ToyboxMod.CALLBACK_BOMBS_FIRED = {}
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
    if(not bomb:IsDead()) then return end

    if(bomb.Flags & (TearFlags.TEAR_SCATTER_BOMB | TearFlags.TEAR_SPLIT | TearFlags.TEAR_PERSISTENT | TearFlags.TEAR_QUADSPLIT) ~= 0) then
        copyScatterData(bomb)
    end
end)
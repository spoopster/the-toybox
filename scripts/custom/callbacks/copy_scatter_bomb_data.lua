local mod = MilcomMOD

local function copyScatterData(bomb)
	for _, sBomb in pairs(mod.CALLBACK_BOMBS_FIRED) do
        Isaac.RunCallback(mod.CUSTOM_CALLBACKS.COPY_SCATTER_BOMB_DATA, sBomb, bomb)
		mod:setEntityData(sBomb, "IS_SCATTER_BOMB", true)
        mod:setEntityData(sBomb, "IS_FIRED_BOMB", mod:getEntityData(bomb, "IS_FIRED_BOMB"))
	end

	--mod.CALLBACK_BOMBS_FIRED = {}
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
    if(not bomb:IsDead()) then return end

    if(bomb.Flags & (TearFlags.TEAR_SCATTER_BOMB | TearFlags.TEAR_SPLIT | TearFlags.TEAR_PERSISTENT | TearFlags.TEAR_QUADSPLIT) ~= 0) then
        copyScatterData(bomb)
    end
end)
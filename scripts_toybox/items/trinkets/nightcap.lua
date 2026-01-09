---@param bomb EntityBomb
local function trollInit(_, bomb)
    if(PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_NIGHTCAP)) then
        local sleepy = Isaac.Spawn(EntityType.ENTITY_BOMB,ToyboxMod.BOMB_SLEEPY_TROLL_BOMB,0,bomb.Position,bomb.Velocity,bomb.SpawnerEntity):ToBomb()

        bomb.Visible = false
        bomb:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, trollInit, BombVariant.BOMB_TROLL)
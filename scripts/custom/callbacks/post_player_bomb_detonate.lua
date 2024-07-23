local mod = MilcomMOD

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE,
function(_, bomb)
    if(bomb:GetSprite():GetAnimation()=="Explode") then
        local p,isIncubus = mod:getPlayerFromTear(bomb)

        if(p) then Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_BOMB_DETONATE, bomb, p, isIncubus) end
    end
end)
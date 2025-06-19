

ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE,
function(_, bomb)
    if(bomb:GetSprite():GetAnimation()=="Explode") then
        local p,isIncubus = ToyboxMod:getPlayerFromTear(bomb)

        if(p) then Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_PLAYER_BOMB_DETONATE, bomb, p, isIncubus) end
    end
end)
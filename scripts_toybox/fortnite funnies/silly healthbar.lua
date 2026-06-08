

---@param pl Entity
local function dsadasdad(_, pl, dmg)
    pl = pl:ToPlayer()
    ToyboxMod:setEntityData(pl, "HURT_INTENSITY", (ToyboxMod:getEntityData(pl, "HURT_INTENSITY") or 0)+dmg)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, CallbackPriority.LATE, dsadasdad, EntityType.ENTITY_PLAYER)

local function postHudRender()
    if(ToyboxMod.GAME:IsPaused()) then return end
    for i=0, ToyboxMod.GAME:GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local hud = ToyboxMod.GAME:GetHUD():GetPlayerHUD(i):GetHUD()

        local data = ToyboxMod:getEntityDataTable(pl)
        data.HURT_INTENSITY = (data.HURT_INTENSITY or 0)*0.9

        local sp = hud:GetHeartsSprite()
        sp.Offset.Y = ToyboxMod:lerp(sp.Offset.Y, math.sin(math.rad(ToyboxMod.GAME:GetFrameCount()*70))*data.HURT_INTENSITY*20, 0.65)
    end
    
end
ToyboxMod:AddCallback(ModCallbacks.MC_HUD_RENDER, postHudRender)
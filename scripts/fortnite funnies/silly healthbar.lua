local mod = MilcomMOD

---@param pl Entity
local function dsadasdad(_, pl, dmg)
    pl = pl:ToPlayer()
    mod:setEntityData(pl, "HURT_INTENSITY", (mod:getEntityData(pl, "HURT_INTENSITY") or 0)+dmg)
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, CallbackPriority.LATE, dsadasdad, EntityType.ENTITY_PLAYER)

local function postHudRender()
    if(Game():IsPaused()) then return end
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local hud = Game():GetHUD():GetPlayerHUD(i):GetHUD()

        local data = mod:getEntityDataTable(pl)
        data.HURT_INTENSITY = (data.HURT_INTENSITY or 0)*0.9

        local sp = hud:GetHeartsSprite()
        sp.Offset.Y = mod:lerp(sp.Offset.Y, math.sin(math.rad(Game():GetFrameCount()*70))*data.HURT_INTENSITY*20, 0.65)
    end
    
end
mod:AddCallback(ModCallbacks.MC_HUD_RENDER, postHudRender)
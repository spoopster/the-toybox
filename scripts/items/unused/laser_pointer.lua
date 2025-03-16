local mod = ToyboxMod

local laserSprite = Sprite("gfx/effects/tb_effect_laser_pointer.anm2", true)
laserSprite:Play("Idle", true)

local ANGLE_DIF_TRIGGER = 25

local function postProjectileRender(_, p)
    if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.LASER_POINTER)) then return end

    local dir = p.Velocity:Normalized()
    local a = dir:GetAngleDegrees()

    local alpha = 0
    -- [[
    for _, player in ipairs(Isaac.FindByType(1)) do
        player = player:ToPlayer() or Isaac.GetPlayer()
        if(player:HasCollectible(mod.COLLECTIBLE.LASER_POINTER)) then
            local aDif = math.abs((player.Position-p.Position):GetAngleDegrees()-a)
            if(aDif<=ANGLE_DIF_TRIGGER) then
                alpha = 1-aDif/ANGLE_DIF_TRIGGER
            end
        end
    end
    if(alpha==0) then return end
    --]]

    local room = Game():GetRoom()

    local pos1 = p.Position
    local pos2 = Vector.Zero

    _, pos2 = room:CheckLine(pos1, dir*10000, 3)
    
    local len = Isaac.WorldToScreen(pos1):Distance(Isaac.WorldToScreen(pos2))

    laserSprite.Scale = Vector(len, 1)
    laserSprite.Rotation = a
    laserSprite.Color = Color(1,1,1,alpha)
    laserSprite:Render(Isaac.WorldToScreen(pos1))
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_RENDER, postProjectileRender)
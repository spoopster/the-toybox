local MAX_ENEMIES = 6
local DMG_PER_ENEMY = 1/3

local STACK_DMG_MULT = 0.5

local ICON_OFFSET = -41

local function checkEnemies(_, player)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_FRANKINCENSE)) then return end

    local data = ToyboxMod:getEntityDataTable(player)

    local numEnemies = 0
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ent:IsEnemy() and ent:IsActiveEnemy(false) and not ent:IsInvincible()) then
            numEnemies = numEnemies+1
        end
    end
    numEnemies = ToyboxMod:clamp(numEnemies, 0, MAX_ENEMIES)

    if(numEnemies~=data.FRANKINCENSE_COUNT) then
        data.FRANKINCENSE_COUNT = numEnemies
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, checkEnemies)

local function evalDamage(_, player, _, val)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_FRANKINCENSE)) then return end

    local data = ToyboxMod:getEntityDataTable(player)
    return val+(data.FRANKINCENSE_COUNT or 0)*DMG_PER_ENEMY*(1+STACK_DMG_MULT*(player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_FRANKINCENSE)-1))
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalDamage, EvaluateStatStage.DAMAGE_UP)

local function postPlayerRender(_, player, offset)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_FRANKINCENSE)) then return end

    local data = ToyboxMod:getEntityDataTable(player)
    if((data.FRANKINCENSE_COUNT or 0)<=0) then return end

    if(not data.FRANKINCENSE_SPRITE) then
        local spr = Sprite("gfx_tb/effects/effect_frankincense.anm2", true)
        spr:Play("Idle", true)
        spr:Stop()

        data.FRANKINCENSE_SPRITE = spr
    end

    local spr = data.FRANKINCENSE_SPRITE

    local animVal = ToyboxMod:clamp(data.FRANKINCENSE_COUNT or 0, 1, MAX_ENEMIES)
    spr:SetFrame(animVal-1)

    spr.Scale = Vector(1,1)--*(1+0.2*math.sin(math.rad(player.FrameCount*360/(30*4))))
    spr.Offset = Vector(0,ICON_OFFSET+0.8*(MAX_ENEMIES-animVal-1)+1.5*math.sin(math.rad(player.FrameCount*360/(30*5))))

    local pos = Isaac.WorldToRenderPosition(player.Position)+offset
    spr:Render(pos)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postPlayerRender)
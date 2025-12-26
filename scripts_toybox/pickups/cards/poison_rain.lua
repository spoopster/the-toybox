local sfx = SFXManager()

local BREAK_GRID_FREQ = 15
local BREAK_GRID_CHANCE = 0.4

local POISON_DMG = 4
local POISON_DURATION = 10*30

local POISON_COLOR_MOD = ColorModifier(0.8,1.25,0.7,0.5,0,1.05)
local BREAK_GRID_DELAY = 2*30

---@param pl EntityPlayer
local function usePoisonRain(_, _, pl, _)
    ToyboxMod:setExtraData("POISON_RAIN_TIME", 0)
    ToyboxMod:setExtraData("POISON_RAIN_PLAYER", pl)

    Game():SetColorModifier(POISON_COLOR_MOD,true,0.035)

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ToyboxMod:isValidEnemy(ent)) then
            ent:AddPoison(EntityRef(pl), POISON_DURATION, POISON_DMG)

            ent:SetColor(Color(0.6,1,0.6,1,0,0.137),POISON_DURATION,1,false,false)
            ent:SetPoisonCountdown(POISON_DURATION)
        end
    end

    sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1.3)
    sfx:Play(SoundEffect.SOUND_THUNDER, 1.2, 2, false, 0.9+math.random()*0.2)
    sfx:Play(ToyboxMod.SOUND_EFFECT.WATER_LOOP, 0.6, 0, true, 0.9)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, usePoisonRain, ToyboxMod.CARD_POISON_RAIN)

local function updatePoisonRain(_)
    local cnt = ToyboxMod:getExtraData("POISON_RAIN_TIME")
    if(not cnt) then return end

    local room = Game():GetRoom()

    local numToSpawn = 1+(room:GetGridWidth()>15 and 1 or 0)+(room:GetGridHeight()>9 and 1 or 0)
    for _=1,numToSpawn do
        local roomPos = room:GetRandomPosition(10)
        
        local raindrop = Isaac.Spawn(1000, EffectVariant.RAIN_DROP, 0, roomPos, Vector.Zero, nil):ToEffect()
        raindrop.Color = Color(128/201,199/205,103/213)
    end

    if(cnt>=BREAK_GRID_DELAY and (cnt-BREAK_GRID_DELAY)%BREAK_GRID_FREQ==0) then
        local rng = (ToyboxMod:getExtraData("POISON_RAIN_PLAYER") or Isaac.GetPlayer()):GetCardRNG(ToyboxMod.CARD_POISON_RAIN)
        if(rng:RandomFloat()<BREAK_GRID_CHANCE) then
            local grids = {}
            for i=0, room:GetGridWidth()*room:GetGridHeight()-1 do
                local grid = room:GetGridEntity(i)
                if(grid and ((grid:IsBreakableRock() and grid.State~=2) or (grid:ToPoop()))) then
                    table.insert(grids, i)
                end
            end

            if(#grids>0) then
                local idx = grids[rng:RandomInt(1,#grids)]
                room:GetGridEntity(idx):Destroy(true)
            end
        end
    end

    ToyboxMod:setExtraData("POISON_RAIN_TIME", cnt+1)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, updatePoisonRain)

local function deactivatePoisonRain(_)
    ToyboxMod:setExtraData("POISON_RAIN_TIME", nil)
    sfx:Stop(ToyboxMod.SOUND_EFFECT.WATER_LOOP)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, deactivatePoisonRain)
local sfx = SFXManager()

local ENEMIES_TO_CONVERT = 3
local BASE_HP = 15

---@param pl EntityPlayer
local function useAlienMind(_, _, pl, _)
    local enemyPicker = WeightedOutcomePicker()
    local validEnemies = {}

    local numEnemies = 0

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ToyboxMod:isValidEnemy(ent) and not ent:IsBoss()) then
            numEnemies = numEnemies+1

            table.insert(validEnemies, ent)
            enemyPicker:AddOutcomeFloat(numEnemies, ent.MaxHitPoints/BASE_HP)
        end
    end

    local rng = pl:GetCardRNG(ToyboxMod.CARD_POISON_RAIN)
    for _=1, math.min(numEnemies, ENEMIES_TO_CONVERT) do
        local idx = enemyPicker:PickOutcome(rng)
        enemyPicker:RemoveOutcome(idx)

        local npc = validEnemies[idx]:ToNPC() ---@cast npc EntityNPC
        npc:AddCharmed(EntityRef(pl), -1)
        npc:SetControllerId(pl.ControllerIndex)

        local poof = Isaac.Spawn(1000, EffectVariant.POOF02, 0, npc.Position, Vector.Zero, nil):ToEffect()
        poof:GetSprite().PlaybackSpeed = 1.5
        poof.SpriteScale = Vector(1,1)*0.8
        poof.Color = Color(0,0,0,0.7,208/255,170/255,192/255)
        poof.DepthOffset = -1000
    end

    local poof = Isaac.Spawn(1000, EffectVariant.POOF02, 0, pl.Position, Vector.Zero, nil):ToEffect()
    poof:GetSprite().PlaybackSpeed = 1.3
    poof.Color = Color(0,0,0,0.7,208/255,170/255,192/255)
    poof.DepthOffset = -1000

    sfx:Play(ToyboxMod.SOUND_EFFECT.HYPNOSIS, nil, nil, nil, 0.85+math.random()*0.3)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useAlienMind, ToyboxMod.CARD_ALIEN_MIND)
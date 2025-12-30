local REPLACE_CHANCE = 0.02

---@param bomb EntityBomb
local function postTrollBombInit(_, bomb)
    if(bomb:GetDropRNG():RandomFloat()<REPLACE_CHANCE) then
        local sleepy = Isaac.Spawn(EntityType.ENTITY_BOMB,ToyboxMod.BOMB_SLEEPY_TROLL_BOMB,0,bomb.Position,bomb.Velocity,bomb.SpawnerEntity):ToBomb()
        sleepy:SetExplosionCountdown(sleepy:GetExplosionCountdown())

        bomb.Visible = false
        bomb:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, postTrollBombInit, BombVariant.BOMB_TROLL)

---@param bomb EntityBomb
local function postSleepyBombInit(_, bomb)
    bomb:SetExplosionCountdown(bomb:GetExplosionCountdown()+35+bomb:GetDropRNG():RandomInt(0,18))

    local sp = bomb:GetSprite()
    if(bomb.SubType==0) then
        sp:Play("Appear", true)
    else
        sp:Play("AppearAwake", true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, postSleepyBombInit, ToyboxMod.BOMB_SLEEPY_TROLL_BOMB)

---@param bomb EntityBomb
local function postBombUpdate(_, bomb)
    local sp = bomb:GetSprite()
    if(bomb.SubType==0) then
        if(sp:IsFinished("Appear") or sp:GetAnimation()~="Appear") then
            sp:Play("Idle", true)
            bomb:SetExplosionCountdown(bomb:GetExplosionCountdown()+1)

            for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
                local otherbomb = ent:ToBomb() ---@type EntityBomb
                if(otherbomb:GetExplosionCountdown()==0) then
                    if(otherbomb.RadiusMultiplier*40*2.5>=otherbomb.Position:Distance(bomb.Position)) then
                        bomb.SubType = 1
                        bomb:GetSprite():Play("HopAwake", true)
                    end
                end
            end
        end
    else
        bomb.Velocity = bomb.Velocity*0.96
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, postBombUpdate, ToyboxMod.BOMB_SLEEPY_TROLL_BOMB)

---@param bomb EntityBomb
---@param coll Entity
local function postBombCollision(_, bomb, coll)
    if(bomb.SubType==0) then
        if(coll:ToPlayer() or coll:ToNPC()) then
            bomb.SubType = 1
            bomb:GetSprite():Play("HopAwake", true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_COLLISION, postBombCollision, ToyboxMod.BOMB_SLEEPY_TROLL_BOMB)
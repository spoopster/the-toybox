
local sfx = SFXManager()

local P_ADD_HP = 2
local P_ADD_MAXHP = 2

local OTHERP_ADD_HP = 1
local ENEMY_ADD_HP = 30

---@param rng RNG
---@param pl EntityPlayer
local function chocolateUse(_, _, rng, pl, flags, slot, vdata)
    local hpToAdd = math.min(P_ADD_MAXHP, pl:GetHeartLimit()-pl:GetMaxHearts())
    if(hpToAdd>0) then
        pl:AddMaxHearts(hpToAdd)

        local data = ToyboxMod:getEntityDataTable(pl)
        data.CHOCOLATE_COUNTER = (data.CHOCOLATE_COUNTER or 0)+hpToAdd
    end
    pl:AddHearts(P_ADD_HP)

    for i=0, Game():GetNumPlayers()-1 do
        local otherPl = Isaac.GetPlayer(i)
        if(GetPtrHash(pl)~=GetPtrHash(otherPl)) then
            otherPl:AddHearts(OTHERP_ADD_HP)
            
            local gulpEffect = Isaac.Spawn(1000, EffectVariant.HEART, 0, otherPl.Position, Vector.Zero, otherPl):ToEffect()
            gulpEffect.SpriteOffset = Vector(0, -38)
            gulpEffect:FollowParent(otherPl)
        end
    end

    for _, enemy in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 800, EntityPartition.ENEMY)) do
        if(enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            enemy:AddHealth(ENEMY_ADD_HP)
            enemy:SetColor(Color(1,1,1,1,0.5,0.1,0.1), 5, 1, true, false)
        end
    end

    sfx:Play(SoundEffect.SOUND_VAMP_GULP)

    return {
        Discharge = true,
        ShowAnim = true,
        Remove = false,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, chocolateUse, ToyboxMod.COLLECTIBLE_CHOCOLATE_BAR)

---@param pl EntityPlayer
local function removeTempHP(_, pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    if(not data.CHOCOLATE_COUNTER) then return end

    local hpToRemove = math.min(data.CHOCOLATE_COUNTER, pl:GetMaxHearts()-2)
    if(hpToRemove>0) then
        pl:AddMaxHearts(-hpToRemove)
    end
    data.CHOCOLATE_COUNTER = nil
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, removeTempHP)
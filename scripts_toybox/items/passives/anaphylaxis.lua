local PUFFED_SCALE = 1.4

local PUFF_DURATION = 30*7
local PUFF_COOLDOWN = 30*5*2

local PUFF_DANGER_DISTANCE = 40*0.8

local PUFF_COSTUME = Isaac.GetCostumeIdByPath("gfx_tb/characters/costume_anaphylaxis_puffed.anm2")

---@param pl EntityPlayer
local function puffUpdate(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_ANAPHYLAXIS)) then return end

    local eff = pl:GetEffects()
    local data = ToyboxMod:getEntityDataTable(pl)
    if(eff:HasCollectibleEffect(ToyboxMod.COLLECTIBLE_ANAPHYLAXIS)) then
        local desScale = PUFFED_SCALE*(1+math.sin(math.rad(pl.FrameCount*3))*0.1)
        data.ANAPHYLAXIS_SCALE = ToyboxMod:lerp(data.ANAPHYLAXIS_SCALE or 1, desScale, 0.09)

        if(eff:GetCollectibleEffect(ToyboxMod.COLLECTIBLE_ANAPHYLAXIS).Cooldown==1) then
            eff:RemoveCollectibleEffect(ToyboxMod.COLLECTIBLE_ANAPHYLAXIS)

            ToyboxMod.SFX:Play(ToyboxMod.SFX_DEFLATE, 1.4, 0, false, 0.95)

            data.ANAPHYLAXIS_COOLDOWN = PUFF_COOLDOWN
        end
    else
        local threshold = 1.1
        local wasSmallEnough = (data.ANAPHYLAXIS_SCALE or 1)<threshold
        data.ANAPHYLAXIS_SCALE = ToyboxMod:lerp(data.ANAPHYLAXIS_SCALE or 1, 1, 0.025)

        if(data.ANAPHYLAXIS_SCALE<1.1 and not wasSmallEnough) then
            pl:TryRemoveNullCostume(PUFF_COSTUME)
        end

        data.ANAPHYLAXIS_COOLDOWN = math.max((data.ANAPHYLAXIS_COOLDOWN or 0)-1, 0)

        if(data.ANAPHYLAXIS_COOLDOWN==0 and data.ANAPHYLAXIS_SCALE<1.05) then
            local dist = PUFF_DANGER_DISTANCE+pl.Size
            local toCheck = Isaac.FindInRadius(pl.Position, dist, EntityPartition.BULLET | EntityPartition.ENEMY)
            local shouldPuff = false

            for _, ent in ipairs(toCheck) do
                if(shouldPuff) then break end

                if(ent:ToProjectile()) then
                    shouldPuff = true
                elseif(ent:IsEnemy() and ent:IsActiveEnemy(false) and ent.CollisionDamage>0) then
                    shouldPuff = true
                end
            end

            if(shouldPuff) then
                eff:AddCollectibleEffect(ToyboxMod.COLLECTIBLE_ANAPHYLAXIS)
                eff:GetCollectibleEffect(ToyboxMod.COLLECTIBLE_ANAPHYLAXIS).Cooldown = PUFF_DURATION
                pl:AddNullCostume(PUFF_COSTUME)

                ToyboxMod.GAME:ButterBeanFart(pl.Position, dist+10, pl, true, true)

                ToyboxMod.SFX:Play(SoundEffect.SOUND_INFLATE, nil, nil, nil, 1.2)
            end
        end
    end

end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, puffUpdate)


-- head scale logic

---@param player EntityPlayer
local function updateHeadScale(player, scale)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_ANAPHYLAXIS)) then return end

    player:GetSprite().Scale = player:GetSprite().Scale*scale

    local costumeMap = player:GetCostumeLayerMap()
    local costumeDescs = player:GetCostumeSpriteDescs()

    for layer, data in ipairs(costumeMap) do
        if(layer-1>=PlayerSpriteLayer.SPRITE_HEAD and layer-1<=PlayerSpriteLayer.SPRITE_HEAD5 and data.costumeIndex~=-1) then
            local desc = costumeDescs[data.costumeIndex+1]
            desc:GetSprite().Scale = desc:GetSprite().Scale*scale
        end
    end

    return Vector(0,(scale-1)*7.5)
end

---@param pl EntityPlayer
local function postRenderHead(_, pl, renderpos)
    return renderpos+(updateHeadScale(pl, (ToyboxMod:getEntityData(pl, "ANAPHYLAXIS_SCALE") or 1)) or Vector(0,0))
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_RENDER_PLAYER_HEAD, postRenderHead)

---@param pl EntityPlayer
local function prePlayerRender(_, pl, offset)
    updateHeadScale(pl, 1/(ToyboxMod:getEntityData(pl, "ANAPHYLAXIS_SCALE") or 1))
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_RENDER_PLAYER_HEAD, prePlayerRender)
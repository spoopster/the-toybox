local COPPER_POOP_CHANCE = 0.01

local COINS_PICKER = WeightedOutcomePicker()
    COINS_PICKER:AddOutcomeWeight(1, 1)
    COINS_PICKER:AddOutcomeWeight(2, 1)
    COINS_PICKER:AddOutcomeWeight(3, 1)

local COPPER_COLOR = Color(255/100,255/59,255/49,1,0,0,0,197/255*0.8,131/255*0.8,70/255*0.8,1)

---@param effect EntityEffect
local function replaceHelper(_, effect)
    if(effect.SubType==ToyboxMod.GRID_COPPER_POOP) then
        effect.Visible = false
        local room = Game():GetRoom()
        local idx = room:GetGridIndex(effect.Position)

        room:RemoveGridEntityImmediate(idx, 0, false)
        local worked = room:SpawnGridEntity(idx, GridEntityType.GRID_POOP, GridPoopVariant.NORMAL, effect.InitSeed)
        if(worked) then
            local poop = room:GetGridEntity(idx)
            if(poop) then
                local data = ToyboxMod:getGridEntityDataTable(poop)
                data.GRID_INIT = nil
                data.COPPER_POOP = true

                poop:Update()

                local sp = poop:GetSprite()
                if(Game():GetRoom():GetFrameCount()~=0) then
                    sp:SetFrame(sp:GetCurrentAnimationData():GetLength()-1)
                end
            end
        end
        effect:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, replaceHelper, ToyboxMod.EFFECT_GRID_HELPER)

---@param poop GridEntityPoop
local function initSprite(_, poop, _, firstinit)
    if(firstinit and not ToyboxMod:getGridEntityData(poop, "COPPER_POOP")) then
        if(poop:GetRNG():RandomFloat()<COPPER_POOP_CHANCE) then
            ToyboxMod:setGridEntityData(poop, "COPPER_POOP", true)
        end
    end

    if(not ToyboxMod:getGridEntityData(poop, "COPPER_POOP")) then return end
    poop:GetSprite():ReplaceSpritesheet(0, "gfx_tb/grid/grid_copper_poop.png", true)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_POOP_INIT, initSprite, GridPoopVariant.NORMAL)

---@param effect EntityEffect
local function gibSpawn(_, effect)
    local ent = Game():GetRoom():GetGridEntityFromPos(effect.Position)
    if(ent and ent:ToPoop()) then
        local isCopper = ToyboxMod:getGridEntityData(ent:ToPoop(), "COPPER_POOP")
        if(isCopper) then
            effect.Color = COPPER_COLOR
            ToyboxMod:setEntityData(effect, "COPPER_GIBS", true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, gibSpawn, EffectVariant.POOP_PARTICLE)
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, gibSpawn, EffectVariant.POOP_EXPLOSION)

---@param effect EntityEffect
local function gibUpdate(_, effect)
    if(not ToyboxMod:getEntityData(effect, "COPPER_GIBS")) then return end

    effect.Color = COPPER_COLOR
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, gibUpdate, EffectVariant.POOP_PARTICLE)

---@param poop GridEntityPoop
local function removeCopperPoopPickup(_, _, poop)
    local data = ToyboxMod:getGridEntityDataTable(poop)
    if(data.COPPER_POOP) then
        local rng = poop:GetRNG()
        local numcoins = COINS_PICKER:PickOutcome(rng)
        for _=1, numcoins do
            local vel = Vector.FromAngle(math.random(1,360))*1.5
            local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, poop.Position, vel, nil):ToPickup()
        end

        return false
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POOP_SPAWN_DROP, removeCopperPoopPickup)
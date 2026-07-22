local DMG_UP = 0.5
local DMG_UP_MULT = 0.5

---@param type CollectibleType
---@param firstTime boolean
---@param pl EntityPlayer
local function preAddCollectible(_, type, _, firstTime, _, _, pl)
    if(not firstTime) then return end
    if(not pl:HasTrinket(ToyboxMod.TRINKET_PINK_DONUT)) then return end

    ToyboxMod:setEntityData(pl, "PINK_DONUT_ACTIVE", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, preAddCollectible)

local function postAddCollectible(_, type, _, firstTime, _, _, pl)
    ToyboxMod:setEntityData(pl, "PINK_DONUT_ACTIVE", nil)

    if(ToyboxMod:getEntityData(pl, "PINK_DONUT_WORKED")) then
        ToyboxMod.SFX:Play(ToyboxMod.SFX_CRUNCH, nil, nil, nil, 0.95+math.random()*0.1)
        
        ToyboxMod:setEntityData(pl, "PINK_DONUT_WORKED", nil)

        ToyboxMod:setEntityData(pl, "PINK_DONUT_ACTIVE_CHAPI", true)
        Isaac.CreateTimer(function()
            ToyboxMod:setEntityData(pl, "PINK_DONUT_ACTIVE_CHAPI", nil)
        end, 1,1, true)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, CallbackPriority.LATE, postAddCollectible)

---@param pl EntityPlayer
---@param amount integer
local function preAddHearts(_, pl, amount)
    if(ToyboxMod:getEntityData(pl, "PINK_DONUT_ACTIVE") and amount~=0) then
        local data = ToyboxMod:getEntityDataTable(pl)
        data.PINK_DONUT_DAMAGE = (data.PINK_DONUT_DAMAGE or 0)+(amount*DMG_UP/2)*(1+DMG_UP_MULT*(pl:GetTrinketMultiplier(ToyboxMod.TRINKET_PINK_DONUT)-1))
        data.PINK_DONUT_WORKED = true

        pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)

        return 0
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, preAddHearts, AddHealthType.MAX)

if(CustomHealthAPI) then
    local function cancelChapiHeal(p, k, n)
        if(k=="EMPTY_HEART" and ToyboxMod:getEntityData(p, "PINK_DONUT_ACTIVE_CHAPI")) then
            return true
        end
    end
    CustomHealthAPI.Library.AddCallback(ToyboxMod, CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH, 0, cancelChapiHeal)
end

---@param pl EntityPlayer
---@param val number
local function evaluateDamage(_, pl, _, val)
    local dmg = (ToyboxMod:getEntityData(pl, "PINK_DONUT_DAMAGE") or 0)
    return val+dmg
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evaluateDamage, EvaluateStatStage.DAMAGE_UP)
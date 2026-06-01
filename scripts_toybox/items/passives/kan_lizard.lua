local DMG_PER_FAM = 0.4
local TEARS_PER_FAM = 0.4

local EXTRA_MULT = 1

---@param pl EntityPlayer
local function setIsaacHeadAdd(_, _, _, firstTime, _, _, pl)
    pl:SetInnateTrinketCount(TrinketType.TRINKET_ISAACS_HEAD, pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_KAN_LIZARD), "ToyboxKanLizardIsaacHead")
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, setIsaacHeadAdd, ToyboxMod.COLLECTIBLE_KAN_LIZARD)

---@param pl EntityPlayer
local function setIsaacHeadRemove(_, pl)
    pl:SetInnateTrinketCount(TrinketType.TRINKET_ISAACS_HEAD, pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_KAN_LIZARD), "ToyboxKanLizardIsaacHead")
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, setIsaacHeadRemove, ToyboxMod.COLLECTIBLE_KAN_LIZARD)

---@param pl EntityPlayer
local function checkNumFamiliars(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_KAN_LIZARD)) then return end

    local lastFamNum = ToyboxMod:getEntityData(pl, "KAN_LIZARD_FAM_NUM") or -1

    local famNum = 0

    local plHash = GetPtrHash(pl)
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
        local fam = (ent and ent:ToFamiliar())
        if(fam and GetPtrHash(fam.Player)==plHash and fam:GetItemConfig()) then
            famNum = famNum+1
        end
    end
    if(lastFamNum~=famNum) then
        ToyboxMod:setEntityData(pl, "KAN_LIZARD_FAM_NUM", famNum)
        pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
        pl:EvaluateItems()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, checkNumFamiliars)

---@param pl EntityPlayer
---@param stage EvaluateStatStage
---@param val number
local function evalStats(_, pl, stage, val)
    if(not (stage==EvaluateStatStage.FLAT_DAMAGE or stage==EvaluateStatStage.FLAT_TEARS)) then return end
    if(not (pl:HasCollectible(ToyboxMod.COLLECTIBLE_KAN_LIZARD))) then return end

    local num = ToyboxMod:getEntityData(pl, "KAN_LIZARD_FAM_NUM") or 0
    if(num<=0) then return end

    num = num*(1+(pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_KAN_LIZARD)-1)*EXTRA_MULT)
    if(stage==EvaluateStatStage.FLAT_TEARS) then
        return val+num*TEARS_PER_FAM
    elseif(stage==EvaluateStatStage.FLAT_DAMAGE) then
        return val+num*DMG_PER_FAM
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStats)
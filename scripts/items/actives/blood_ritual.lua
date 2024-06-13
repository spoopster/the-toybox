local mod = MilcomMOD
local sfx = SFXManager()

--! Make thi shit work daamn!
--? made thi shit work damn!
--* fixed this shi damb!

local ENUM_NUMFAMILIARS = 3
local ENUM_NUMFAMILIARS_EXTRA = 1

local CARBATTERY_NUMFAMILIARS = 5
local CARBATTERY_NUMFAMILIARS_EXTRA = 2

local ENUM_PICKER_WEIGHTFACT = 1000
local ENUM_EVILFAM_PICKER = WeightedOutcomePicker()
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_BROTHER_BOBBY, 0.5, ENUM_PICKER_WEIGHTFACT)
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_SISTER_MAGGY, 0.5, ENUM_PICKER_WEIGHTFACT)
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_DEMON_BABY, 1, ENUM_PICKER_WEIGHTFACT)
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_GHOST_BABY, 0.75, ENUM_PICKER_WEIGHTFACT)
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_ROTTEN_BABY, 1, ENUM_PICKER_WEIGHTFACT)
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_LIL_BRIMSTONE, 1, ENUM_PICKER_WEIGHTFACT)
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_INCUBUS, 1, ENUM_PICKER_WEIGHTFACT)
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_SUCCUBUS, 0.75, ENUM_PICKER_WEIGHTFACT)
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_MULTIDIMENSIONAL_BABY, 0.5, ENUM_PICKER_WEIGHTFACT)
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_LIL_ABADDON, 1, ENUM_PICKER_WEIGHTFACT)
ENUM_EVILFAM_PICKER:AddOutcomeFloat(CollectibleType.COLLECTIBLE_TWISTED_PAIR, 0.75, ENUM_PICKER_WEIGHTFACT)

local ENUM_EVILFAM_ITEM_TO_VAR = {
    [CollectibleType.COLLECTIBLE_BROTHER_BOBBY] = FamiliarVariant.BROTHER_BOBBY,
    [CollectibleType.COLLECTIBLE_SISTER_MAGGY] = FamiliarVariant.SISTER_MAGGY,
    [CollectibleType.COLLECTIBLE_DEMON_BABY] = FamiliarVariant.DEMON_BABY,
    [CollectibleType.COLLECTIBLE_GHOST_BABY] = FamiliarVariant.GHOST_BABY,
    [CollectibleType.COLLECTIBLE_ROTTEN_BABY] = FamiliarVariant.ROTTEN_BABY,
    [CollectibleType.COLLECTIBLE_LIL_BRIMSTONE] = FamiliarVariant.LIL_BRIMSTONE,
    [CollectibleType.COLLECTIBLE_INCUBUS] = FamiliarVariant.INCUBUS,
    [CollectibleType.COLLECTIBLE_SUCCUBUS] = FamiliarVariant.SUCCUBUS,
    [CollectibleType.COLLECTIBLE_MULTIDIMENSIONAL_BABY] = FamiliarVariant.MULTIDIMENSIONAL_BABY,
    [CollectibleType.COLLECTIBLE_LIL_ABADDON] = FamiliarVariant.LIL_ABADDON,
    [CollectibleType.COLLECTIBLE_TWISTED_PAIR] = FamiliarVariant.TWISTED_BABY,
}

local ENUM_ORBIT_DIST = Vector(45,45)
local ENUM_ORBIT_SPEED = 5
local ENUM_ORBIT_LAYER = 1823
local ENUM_ORBIT_EASING = 3

---@param player EntityPlayer
local function useBloodRitual(_, _, rng, player, flags)
    if(flags & UseFlag.USE_CARBATTERY == 0) then
        local isCarbattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)

        local ritualData = mod:getEntityDataTable(player).BLOOD_RITUAL_DATA or {}
        local numFam = (isCarbattery and CARBATTERY_NUMFAMILIARS or ENUM_NUMFAMILIARS)
        if(#ritualData>0) then numFam = (isCarbattery and CARBATTERY_NUMFAMILIARS_EXTRA or ENUM_NUMFAMILIARS_EXTRA) end

        for _=1, numFam do
            table.insert(ritualData, #ritualData+1, ENUM_EVILFAM_PICKER:PickOutcome(rng))
        end
        mod:setEntityData(player, "BLOOD_RITUAL_DATA", ritualData)

        local pentagram = Isaac.Spawn(1000, mod.EFFECT_BLOOD_RITUAL_PENTAGRAM, 0, player.Position, Vector.Zero, player):ToEffect()
        pentagram.DepthOffset = -1000

        sfx:Play(SoundEffect.SOUND_DEVIL_CARD)
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useBloodRitual, mod.COLLECTIBLE_BLOOD_RITUAL)

---@param player EntityPlayer
local function removeBloodRitualEffect(_, player)
    mod:setEntityData(player, "BLOOD_RITUAL_DATA", {})
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, removeBloodRitualEffect)

local function getBloodRitualIndex(rng, num, invalidIds)
    local selIdx = rng:RandomInt(num)+1

    local numVals = 0
    for _, _ in pairs(invalidIds) do numVals=numVals+1 end

    if(numVals==num) then return selIdx end

    while(invalidIds[selIdx]) do
        selIdx = rng:RandomInt(num)+1
    end

    return selIdx
end

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    local ritualData = mod:getEntityDataTable(player).BLOOD_RITUAL_DATA or {}
    if(#ritualData==0) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_BLOOD_RITUAL)

    local itemCounts = {}
    local invalidFIndex = {}

    local numFamiliars = 0
    for _, col in ipairs(ritualData) do
        if(itemCounts[col]==nil) then itemCounts[col]=0 end
        itemCounts[col] = itemCounts[col]+1
        numFamiliars = numFamiliars+(col==CollectibleType.COLLECTIBLE_TWISTED_PAIR and 2 or 1)
    end

    local function addFam(var, i, cNum, num, c, isTwisted)
        local numf = cNum+num
        if(isTwisted) then numf = numf*2 end
        local fams = player:CheckFamiliarEx(var, numf, rng, Isaac.GetItemConfig():GetCollectible(c), -1)
        for fidx, fam in pairs(fams) do
            if(fidx<=numf) then
                local fIndex = getBloodRitualIndex(rng, numFamiliars, invalidFIndex)
                invalidFIndex[fIndex] = true
                mod:setEntityData(fam, "IS_BLOOD_RITUAL_ORBITAL", fIndex/numFamiliars)
            end
        end
    end

    for c, num in pairs(itemCounts) do
        local famVar = ENUM_EVILFAM_ITEM_TO_VAR[c] or FamiliarVariant.BROTHER_BOBBY
        local cNum = player:GetCollectibleNum(c)

        addFam(famVar,-1, cNum, num, c, famVar==FamiliarVariant.TWISTED_BABY)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function bloodRitualOrbit(_, familiar)
    if(not mod:getEntityData(familiar, "IS_BLOOD_RITUAL_ORBITAL")) then return end
    local p = familiar.Player
    local offset = #(mod:getEntityData(p, "BLOOD_RITUAL_DATA") or {})

    if(familiar.OrbitLayer~=ENUM_ORBIT_LAYER) then
        familiar:AddToOrbit(ENUM_ORBIT_LAYER)
    end

    familiar.OrbitDistance = ENUM_ORBIT_DIST
    familiar.OrbitSpeed = ENUM_ORBIT_SPEED

    local orbPos = p.Position+p.Velocity+Vector.FromAngle(familiar.FrameCount*familiar.OrbitSpeed+mod:getEntityData(familiar, "IS_BLOOD_RITUAL_ORBITAL")*360)*familiar.OrbitDistance

    familiar.Velocity = (orbPos-familiar.Position)/ENUM_ORBIT_EASING
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, bloodRitualOrbit)

---@param familiar EntityFamiliar
local function bloodRitualPriority(_, familiar)
    if(not mod:getEntityData(familiar, "IS_BLOOD_RITUAL_ORBITAL")) then return end

    return -100
end
mod:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, bloodRitualPriority)


---@param effect EntityEffect
local function pentagramUpdate(_, effect)
    if(effect:GetSprite():IsFinished("Idle")) then effect:Remove() end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, pentagramUpdate, mod.EFFECT_BLOOD_RITUAL_PENTAGRAM)
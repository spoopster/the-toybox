local mod = ToyboxMod
local sfx = SFXManager()

local function getRandomVal(rng, tb, blacklist)
    local chosenVal
    while(not (chosenVal and blacklist[chosenVal]~=0)) do
        chosenVal = tb[rng:RandomInt(#tb)+1].ID
    end
    return chosenVal
end

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local dataTable = mod:getExtraDataTable()
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)

    mod:calcPillPool(mod:generateRng())

    if(isHorse) then
        local itemConfig = Isaac.GetItemConfig()
        local rng = player:GetPillRNG(effect)
        local pillBlacklists = {GOOD={}, BAD={}}
        local toReroll = {}

        for col, pill in pairs(dataTable.CUSTOM_PILL_POOL) do
            local pdata = itemConfig:GetPillEffect(pill.DEFAULT)
            if(pdata) then
                if(pdata.EffectSubClass==mod.PILL_SUBCLASS.GOOD) then pillBlacklists.GOOD[pill.DEFAULT] = 0
                elseif(pdata.EffectSubClass==mod.PILL_SUBCLASS.BAD) then pillBlacklists.BAD[pill.DEFAULT] = 0
                else
                    toReroll[col] = pill.DEFAULT
                end
            end
        end

        local goodPills = dataTable.PILLS_GOOD or mod:getAllPillEffects(mod.PHD_TYPE.GOOD)
        local badPills = dataTable.PILLS_BAD or mod:getAllPillEffects(mod.PHD_TYPE.BAD)
        for col, pill in pairs(toReroll) do
            local chosenPill
            if(rng:RandomInt(2)==0) then
                chosenPill = getRandomVal(rng, goodPills, pillBlacklists.GOOD)
                pillBlacklists.GOOD[chosenPill] = 0
            else
                chosenPill = getRandomVal(rng, badPills, pillBlacklists.BAD)
                pillBlacklists.BAD[chosenPill] = 0
            end

            dataTable.CUSTOM_PILL_POOL[col].DEFAULT = chosenPill
            dataTable.CUSTOM_PILL_POOL[col].GOOD = mod:convertPhdPillEffect(nil, chosenPill, mod.PHD_TYPE.GOOD, rng)
            dataTable.CUSTOM_PILL_POOL[col].BAD = mod:convertPhdPillEffect(nil, chosenPill, mod.PHD_TYPE.BAD, rng)
        end

        mod:unidentifyPillPool()
    end

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED or SoundEffect.SOUND_THUMBS_DOWN))
    player:AnimateSad()
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_EFFECT.DEMENTIA)
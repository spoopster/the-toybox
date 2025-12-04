local sfx = SFXManager()

local PICKER = WeightedOutcomePicker()
    PICKER:AddOutcomeWeight(1, 40) --q4
    PICKER:AddOutcomeWeight(2, 30) --q0
    PICKER:AddOutcomeWeight(3, 30) --broken heart

---@param player EntityPlayer
local function cursedD6Use(_, item, rng, player, flags, slot, vdata)
    local outcome = PICKER:PickOutcome(rng)

    local pool = Game():GetItemPool()
    local conf = Isaac.GetItemConfig()

    if(outcome==3) then
        player:AddBrokenHearts(1)
    else
        local currentpool = pool:GetLastPool()

        for _, pickup in ipairs(Isaac.FindByType(5,100)) do
            if(pickup.SubType~=0) then
                local chosen
                local failsafe = 1000
                repeat
                    chosen = pool:GetCollectible(currentpool, false)
                    failsafe = failsafe-1
                until(conf:GetCollectible(chosen).Quality==(outcome==1 and 4 or 0) or failsafe<=0)

                pool:RemoveCollectible(chosen)
                pickup:ToPickup():Morph(5,100,chosen)
            end
        end
    end

    sfx:Play(910, nil, nil, nil, 0.5)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, cursedD6Use, ToyboxMod.COLLECTIBLE_CURSED_D6)
local REPLACED_CHARGE = 6

function ToyboxMod:canApplyRetrofall(id)
    local conf = Isaac.GetItemConfig():GetCollectible(id)
    if(not (conf and conf.Type==ItemType.ITEM_ACTIVE and conf.ChargeType==ItemConfig.CHARGE_NORMAL)) then return false end

    --if(conf.MaxCharges==0) then return false end

    return true
end
local function doRetrofallReroll(_)
    --[[
    for _, item in ipairs(Isaac.FindByType(5,100)) do
        item = item:ToPickup() ---@cast item EntityPickup
        if(item.SubType~=0 and item:CanReroll()) then
            item:Morph(5,100,0)
            item:AddEntityFlags(EntityFlag.FLAG_APPEAR)
        end
    end
    --]]
    Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_D6, UseFlag.USE_NOANIM, -1)
end

---@param id CollectibleType
---@param pl EntityPlayer
local function replaceRetroCharge(_, id, pl, vardata, current)
    if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_RETROFALL) and ToyboxMod:canApplyRetrofall(id)) then
        return REPLACED_CHARGE
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, replaceRetroCharge)

local function giveExtraInitialCharge(_, id, charge, firstTime, slot, var, pl)
    if(not (firstTime and pl:HasCollectible(ToyboxMod.COLLECTIBLE_RETROFALL) and ToyboxMod:canApplyRetrofall(id))) then return end

    if(charge==Isaac.GetItemConfig():GetCollectible(id).MaxCharges) then
        return {id, REPLACED_CHARGE, firstTime, slot, var}
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, giveExtraInitialCharge)

--[ [  for when they push the latest ver to launcher ] ] 
local cancelJustInCaseInfiniteLoop = false

---@param item CollectibleType
---@param pl EntityPlayer
---@param slot ActiveSlot
local function rerollOnDischarge(_, item, _, pl, slot)
    if(cancelJustInCaseInfiniteLoop) then return end

    if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_RETROFALL) and ToyboxMod:canApplyRetrofall(item)) then
        cancelJustInCaseInfiniteLoop = true
        doRetrofallReroll()
        cancelJustInCaseInfiniteLoop = false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_DISCHARGE_ACTIVE_ITEM, rerollOnDischarge)
--]]


--[[] ]

--- VANILLA/MODDED NON-THROWABLE ITEMS
--- PROBABLY BREAKS IN SOME SITUATIONS AS IT JUST CHECKS WHETHER ITEM CHARGE IS LOWER THAN IN PRE_USE_ITEM

---@param id CollectibleType
---@param pl EntityPlayer
local function blablabla(_, id, rng, pl, flags, slot, vardata)
    if(slot==-1) then return end
    if(not (pl:HasCollectible(ToyboxMod.COLLECTIBLE_RETROFALL) and ToyboxMod:canApplyRetrofall(id))) then return end

    local data = ToyboxMod:getEntityDataTable(pl)

    data.QUEUED_ITEM_USES = data.QUEUED_ITEM_USES or {}
    table.insert(data.QUEUED_ITEM_USES, {id,slot,flags,pl:GetTotalActiveCharge(slot)})
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, math.huge, blablabla)

---@param pl EntityPlayer
local function nonThrowableReroll(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_RETROFALL)) then
        ToyboxMod:setEntityData(pl, "QUEUED_ITEM_USES", nil)

        return
    end

    local data = ToyboxMod:getEntityDataTable(pl)
    if(not data.QUEUED_ITEM_USES) then return end

    for _, itemData in ipairs(data.QUEUED_ITEM_USES) do
        if(ToyboxMod:canApplyRetrofall(itemData[1])) then
            local currentCharge = pl:GetTotalActiveCharge(itemData[2])
            if(currentCharge<itemData[4]) then
                doRetrofallReroll()
            end
        end
    end

    data.QUEUED_ITEM_USES = nil
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, nonThrowableReroll)


--- VANILLA THROWABLE ITEMS
--- BIT JANKY (DELAYED REROLL)

local vanillaThrowables = {
    [CollectibleType.COLLECTIBLE_DECAP_ATTACK] = 1,
    [CollectibleType.COLLECTIBLE_ERASER] = 1,
    [CollectibleType.COLLECTIBLE_SHARP_KEY] = 1,
    [CollectibleType.COLLECTIBLE_GLASS_CANNON] = 1,
    [CollectibleType.COLLECTIBLE_BOOMERANG] = 1,
    [CollectibleType.COLLECTIBLE_RED_CANDLE] = 1,
    [CollectibleType.COLLECTIBLE_CANDLE] = 1,
    [CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD] = 1,
}

---@param pl EntityPlayer
local function vanillaThrowableItemReroll(_, pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    local state = pl:GetItemState()
    data.RETRO_LAST_ITEM_STATE = data.RETRO_LAST_ITEM_STATE or state

    if(state==0 and data.RETRO_LAST_ITEM_STATE~=0 and pl:HasCollectible(ToyboxMod.COLLECTIBLE_RETROFALL)) then
        local isntPickupAnim = (string.find(pl:GetSprite():GetAnimation(), "PickupWalk")==nil)
        if(isntPickupAnim and vanillaThrowables[data.RETRO_LAST_ITEM_STATE] and ToyboxMod:canApplyRetrofall(data.RETRO_LAST_ITEM_STATE)) then
            doRetrofallReroll()
        end
    end

    data.RETRO_LAST_ITEM_STATE = state
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, vanillaThrowableItemReroll)


--- MODDED THROWABLE ITEMS
--- MODIFIES METATABLE TO TRY AND REROLL WHEN player:DischargeActiveItem(slot) IS CALLED

local ogMetaTable = getmetatable(EntityPlayer).__class
local newMetaTable = {}
local ogIndex = ogMetaTable.__index

function newMetaTable:DischargeActiveItem(slot)
    if(self:HasCollectible(ToyboxMod.COLLECTIBLE_RETROFALL) and ToyboxMod:canApplyRetrofall(ogMetaTable.GetActiveItem(self, slot))) then
        doRetrofallReroll()
    end

    ogMetaTable.DischargeActiveItem(self, slot)
end

rawset(ogMetaTable, "__index",
    function(self, key)
        if(newMetaTable[key]) then
            return newMetaTable[key]
        else
            return ogIndex(self, key)
        end
    end
)
--]]


--- SUPER RETRO MODE

local RENDER_RETROFALL = -1
local BOX_WIDTH = 10000
local LINE_HEIGHT = 10

local font = Font()
font:Load("font/pftempestasevencondensed.fnt")

local retrofallDescStrings = {
    "Bad news, tomorrow is retrofall, which is an 8-bit",
    "attack event on all classic gaming consoles",
    "including the Nintendo Entertainment System. There",
    "will be people trying to send you ray tracing,",
    "extreme graphics, 4K, Call of Duty, and there will",
    "also be pixel grabbers, moderners, and Unreal Engine",
    "4K Remasterers. I advise NO ONE to play video games",
    "from retro gamers you don't know, please stay safe.",
    "Please pass this on to any gaming console you own or",
    "have 1UP Mushroom and can level up to spread",
    "awareness. I wish you all safety. Also, make sure to",
    "be game over tomorrow, which gives you less chance",
    "for this to happen to you. It's also specifically",
    "against retro video gamers.",
}

local function renderRetrofallDesc(_)
    if(not ToyboxMod.CONFIG.SUPER_RETROFALL_BROS) then return end

    if(RENDER_RETROFALL>=0) then
        local streakSprite = Game():GetHUD():GetStreakSprite()
        local baseCenterPos = Vector(Isaac.GetScreenWidth()/2, 40)

        local frameData = streakSprite:GetNullFrame("Center")
        local frameScale = frameData:GetScale()
        baseCenterPos = baseCenterPos+frameData:GetPos()+Vector(0,17)*frameScale

        for key, str in ipairs(retrofallDescStrings) do
            font:DrawStringScaled(str, baseCenterPos.X-BOX_WIDTH/2, baseCenterPos.Y, frameScale.X, frameScale.Y, KColor(1,1,1,1), BOX_WIDTH, true)

            baseCenterPos.Y = baseCenterPos.Y+LINE_HEIGHT*frameScale.Y
        end

        if(streakSprite:IsFinished("Text")) then RENDER_RETROFALL = -1 end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, renderRetrofallDesc)

local function replaceRetrofallDesc(_, title, subtitle, sticky, curse)
    if(not ToyboxMod.CONFIG.SUPER_RETROFALL_BROS) then return end

    if(title=="RETROFALL") then
        RENDER_RETROFALL = 0

        if(subtitle~="") then
            Game():GetHUD():ShowItemText("RETROFALL", "", curse)
            return false
        end
    else
        RENDER_RETROFALL = -1
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ITEM_TEXT_DISPLAY, replaceRetrofallDesc)
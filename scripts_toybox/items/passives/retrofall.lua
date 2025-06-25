local REPLACED_CHARGE = 6

ToyboxMod.SUPER_RETROFALL_DICE = {
    {ID=CollectibleType.COLLECTIBLE_D1, Charges=4, Suffix="d1", Name="D1"},
    {ID=CollectibleType.COLLECTIBLE_D4, Charges=6, Suffix="d4", Name="D4"},
    {ID=CollectibleType.COLLECTIBLE_D6, Charges=6, Suffix="d6", Name="The D6"},
    {ID=CollectibleType.COLLECTIBLE_ETERNAL_D6, Charges=2, Suffix="ed6", Name="Eternal D6"},
    {ID=CollectibleType.COLLECTIBLE_D7, Charges=3, Suffix="d7", Name="D7"},
    {ID=CollectibleType.COLLECTIBLE_D8, Charges=4, Suffix="d8", Name="D8"},
    {ID=CollectibleType.COLLECTIBLE_D10, Charges=2, Suffix="d10", Name="D10"},
    {ID=CollectibleType.COLLECTIBLE_D12, Charges=3, Suffix="d12", Name="D12"},
    {ID=CollectibleType.COLLECTIBLE_D20, Charges=6, Suffix="d20", Name="D20"},
    {ID=CollectibleType.COLLECTIBLE_D100, Charges=6, Suffix="d100", Name="D100"},
    {ID=CollectibleType.COLLECTIBLE_SPINDOWN_DICE, Charges=6, Suffix="spindown", Name="Spindown Dice"},
    {ID=ToyboxMod.COLLECTIBLE_D, Charges=1, Suffix="d0", Name="D0"},
}

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
    if(ToyboxMod.CONFIG.SUPER_RETROFALL_BROS) then
        local selId = ToyboxMod:getExtraData("SUPER_RETROFALL_ID") or 3
        Isaac.GetPlayer():UseActiveItem(ToyboxMod.SUPER_RETROFALL_DICE[selId].ID, UseFlag.USE_NOANIM, -1)
    else
        Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_D6, UseFlag.USE_NOANIM, -1)
    end
end

---@param id CollectibleType
---@param pl EntityPlayer
local function replaceRetroCharge(_, id, pl, vardata, current)
    if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_RETROFALL) and ToyboxMod:canApplyRetrofall(id)) then
        if(ToyboxMod.CONFIG.SUPER_RETROFALL_BROS) then
            local selId = ToyboxMod:getExtraData("SUPER_RETROFALL_ID") or 3
            return ToyboxMod.SUPER_RETROFALL_DICE[selId].Charges
        else
            return REPLACED_CHARGE
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, replaceRetroCharge)

local function giveExtraInitialCharge(_, id, charge, firstTime, slot, var, pl)
    if(not (firstTime and pl:HasCollectible(ToyboxMod.COLLECTIBLE_RETROFALL) and ToyboxMod:canApplyRetrofall(id))) then return end

    if(charge==Isaac.GetItemConfig():GetCollectible(id).MaxCharges) then
        if(ToyboxMod.CONFIG.SUPER_RETROFALL_BROS) then
            local selId = ToyboxMod:getExtraData("SUPER_RETROFALL_ID") or 3
            return {id, ToyboxMod.SUPER_RETROFALL_DICE[selId].Charges, firstTime, slot, var}
        else
            return {id, REPLACED_CHARGE, firstTime, slot, var}
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, giveExtraInitialCharge)

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

local function superRetrofallStart(_, isContinued)
    if(not ToyboxMod.CONFIG.SUPER_RETROFALL_BROS) then return end

    if(not isContinued) then
        local rng = ToyboxMod:generateRng()
        ToyboxMod:setExtraData("SUPER_RETROFALL_ID", rng:RandomInt(#ToyboxMod.SUPER_RETROFALL_DICE)+1)
    end

    local selId = ToyboxMod:getExtraData("SUPER_RETROFALL_ID") or 3
    Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_RETROFALL).GfxFileName = "gfx_tb/items/collectibles/retrofall/retrofall_"..ToyboxMod.SUPER_RETROFALL_DICE[selId].Suffix..".png"
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, superRetrofallStart)
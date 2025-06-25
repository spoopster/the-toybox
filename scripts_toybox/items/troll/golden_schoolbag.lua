

local itemAnm2 = "gfx_tb/ui/ui_goldenschoolbag_item.anm2"

local ITEMS_PER_ROW = 6

local selectSprite = Sprite("gfx_tb/ui/ui_pezdispenser_inventory.anm2", true)
selectSprite:Play("Idle", true)

local barSprite = Sprite("gfx_tb/ui/ui_minicharge.anm2", true)
barSprite.Scale = Vector(1,1)*0.5

local function getNewItemSprite(id)
    local gfx = Isaac.GetItemConfig():GetCollectible(id).GfxFileName

    local newSprite = Sprite(itemAnm2, false)
    newSprite:ReplaceSpritesheet(0, gfx, true)
    newSprite:Play("Idle", true)
    newSprite.Scale = Vector(1,1)*0.5

    return newSprite
end

local function addGoldenSchoolbagItem(pl, item, charge)
    local data = ToyboxMod:getEntityDataTable(pl)
    data.GOLDEN_SCHOOLBAG_DATA = data.GOLDEN_SCHOOLBAG_DATA or {}

    table.insert(data.GOLDEN_SCHOOLBAG_DATA, {
        ID = item,
        Charge = charge,
        Sprite = getNewItemSprite(item)
    })
end

---@param item CollectibleType
---@param pl EntityPlayer
local function postAddCollectible(_, item, charge, _, _, _, pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    data.GOLDEN_SCHOOLBAG_DATA = data.GOLDEN_SCHOOLBAG_DATA or {}

    if(item==ToyboxMod.COLLECTIBLE_GOLDEN_SCHOOLBAG) then
        for _, slot in ipairs({ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY}) do
            local active = pl:GetActiveItem(slot)
            if(active~=0) then
                if(Isaac.GetItemConfig():GetCollectible(active).ChargeType~=ItemConfig.CHARGE_SPECIAL) then
                    addGoldenSchoolbagItem(pl, active, pl:GetActiveCharge(slot))
                end
                pl:RemoveCollectible(active)
            end
        end
    elseif(pl:HasCollectible(ToyboxMod.COLLECTIBLE_GOLDEN_SCHOOLBAG)) then
        local conf = Isaac.GetItemConfig():GetCollectible(item)
        if(conf and conf.Type==ItemType.ITEM_ACTIVE) then
            addGoldenSchoolbagItem(pl, item, conf.MaxCharges)
            return false
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, postAddCollectible)

---@param pl EntityPlayer
local function postplayerupdate(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_GOLDEN_SCHOOLBAG)) then return end
    local data = ToyboxMod:getEntityDataTable(pl)
    data.GOLDEN_SCHOOLBAG_DATA = data.GOLDEN_SCHOOLBAG_DATA or {}
    local size = #data.GOLDEN_SCHOOLBAG_DATA

    if(size<=0) then return end

    if(Input.IsActionTriggered(ButtonAction.ACTION_DROP, pl.ControllerIndex)) then
        local seven = 7
        data.GOLDEN_SCHOOLBAG_IDX = (data.GOLDEN_SCHOOLBAG_IDX or 0)%size+1
    end

    local idx = data.GOLDEN_SCHOOLBAG_IDX or 1
    local isMaxcharge = (data.GOLDEN_SCHOOLBAG_DATA[idx].Charge == Isaac.GetItemConfig():GetCollectible(data.GOLDEN_SCHOOLBAG_DATA[idx].ID).MaxCharges)
    if(isMaxcharge and Input.IsActionTriggered(ButtonAction.ACTION_ITEM, pl.ControllerIndex)) then
        
        pl:UseActiveItem(data.GOLDEN_SCHOOLBAG_DATA[idx].ID, UseFlag.USE_OWNED | UseFlag.USE_ALLOWNONMAIN, -1)

        if(Game():GetDebugFlags() & DebugFlag.INFINITE_ITEM_CHARGES == 0) then
            data.GOLDEN_SCHOOLBAG_DATA[idx].Charge = 0
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postplayerupdate)

local function postrererrrrrrrrrreeerrrrrrwerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrwererfftrerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr(_)
    local pl = Isaac.GetPlayer()
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_GOLDEN_SCHOOLBAG)) then return end
    local schoolbagData = ToyboxMod:getEntityDataTable(Isaac.GetPlayer()).GOLDEN_SCHOOLBAG_DATA or {}
    local chosenIdx = ToyboxMod:getEntityDataTable(Isaac.GetPlayer()).GOLDEN_SCHOOLBAG_IDX or 1

    local conf = Isaac.GetItemConfig()

    selectSprite:SetFrame("Idle", 1)

    local renderPos = Vector(20,12)*Options.HUDOffset+Vector(40,40)
    for i, data in ipairs(schoolbagData) do
        data.ID = data.ID or 1
        data.Sprite = data.Sprite or getNewItemSprite(data.ID)

        local newPos = renderPos+((i-1)%ITEMS_PER_ROW)*Vector(18,0)+((i-1)//ITEMS_PER_ROW)*Vector(0,16)
        local chargePos = newPos+Vector(8,0)

        local itemConf = conf:GetCollectible(data.ID)

        local charge = data.Charge
        local maxCharge = itemConf.MaxCharges

        data.Sprite:Render(newPos)

        if(maxCharge>0) then
            barSprite:Play("Back", true); barSprite:Render(chargePos)
            barSprite:Play("Full", true); barSprite:Render(chargePos, Vector(0,math.ceil(29*(1-charge/maxCharge))))

            local chargeFrame = 0
            if(itemConf.ChargeType~=ItemConfig.CHARGE_TIMED and maxCharge<=12) then
                chargeFrame = maxCharge
            end
            barSprite:SetFrame("Overlay", chargeFrame-1); barSprite:Render(chargePos)
        end

        if(i==chosenIdx) then
            selectSprite:Render(newPos)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, postrererrrrrrrrrreeerrrrrrwerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrwererfftrerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr)


local function precleanaward(_)
    local pl = Isaac.GetPlayer()
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_GOLDEN_SCHOOLBAG)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.GOLDEN_SCHOOLBAG_DATA = data.GOLDEN_SCHOOLBAG_DATA or {}

    local conf = Isaac.GetItemConfig()

    for _, iData in ipairs(data.GOLDEN_SCHOOLBAG_DATA) do
        iData.ID = iData.ID or 1
        iData.Charge = iData.Charge or 0
        local iconf = conf:GetCollectible(iData.ID)

        local wasMaxCharges = (iData.Charge==iconf.MaxCharges)
        
        if(iconf.ChargeType==ItemConfig.CHARGE_NORMAL) then
            iData.Charge = iData.Charge+1
        elseif(iconf.ChargeType==ItemConfig.CHARGE_TIMED) then
            iData.Charge = iconf.MaxCharges
        end

        if(iData.Charge==iconf.MaxCharges and not wasMaxCharges) then
            SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, precleanaward)

local function postplayerupdate33(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_GOLDEN_SCHOOLBAG)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.GOLDEN_SCHOOLBAG_DATA = data.GOLDEN_SCHOOLBAG_DATA or {}

    local conf = Isaac.GetItemConfig()

    for _, iData in ipairs(data.GOLDEN_SCHOOLBAG_DATA) do
        iData.ID = iData.ID or 1
        iData.Charge = iData.Charge or 0

        local iconf = conf:GetCollectible(iData.ID)
        local wasMaxCharges = (iData.Charge==iconf.MaxCharges)

        
        if(iconf.ChargeType==ItemConfig.CHARGE_TIMED) then
            iData.Charge = math.min(iData.Charge+1, iconf.MaxCharges)
        end

        if(iData.Charge==iconf.MaxCharges and not wasMaxCharges) then
            SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postplayerupdate33)
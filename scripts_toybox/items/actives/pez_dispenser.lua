
local sfx = SFXManager()

--TODO: coop compat, maybe? against it because its an inventory thing so it should have coop support (awesome)

local DROP_REQ_FRAMES = 60*2

local MAXSLOTS = 4
local MAXSLOTS_PLUSBATTERY = 1
local MAXSLOTS_PLUSCARBATTERY = 1

local INVENTORY_EMPTYSPRITE = Sprite("gfx_tb/ui/ui_pezdispenser_inventory.anm2", true)
INVENTORY_EMPTYSPRITE:SetFrame("Idle", 0)
INVENTORY_EMPTYSPRITE.Color = Color(1,1,1,0.5)

local INVENTORY_CROSSSPRITE = Sprite("gfx_tb/ui/ui_pezdispenser_inventory.anm2", true)
INVENTORY_CROSSSPRITE:SetFrame("Idle", 1)
INVENTORY_CROSSSPRITE.Scale = Vector(1,1)

local NAME_FONT = Font()
NAME_FONT:Load("font/pftempestasevencondensed.fnt")

local EID_OFFSET = "CandyDispenser"
local EID_POS_OFFSET = Vector(0,30)

local function getSpriteDataForConsumable(id, isPill, isSmall)
    if(isSmall) then
        if(isPill) then
            local pillConfig = EntityConfig.GetEntity(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,id)

            return {
                Sprite = Sprite(pillConfig:GetAnm2Path(), true),
                Animation = "HUDSmall",
                Frame = 0,
            }
        else
            local pickupId = Isaac.GetItemConfig():GetCard(id).PickupSubtype
            local cardConfig = EntityConfig.GetEntity(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,pickupId)

            return {
                Sprite = Sprite(cardConfig:GetAnm2Path(), true),
                Animation = "HUDSmall",
                Frame = 0,
            }
        end
    else
        if(isPill) then
            local pillConfig = EntityConfig.GetEntity(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,id)

            return {
                Sprite = Sprite(pillConfig:GetAnm2Path(), true),
                Animation = "HUD",
                Frame = 0,
            }
        else
            local cardPillSprite = Game():GetHUD():GetCardsPillsSprite()

            local pickupConfig = Isaac.GetItemConfig():GetCard(id)
            local pickupId = pickupConfig.PickupSubtype
            local cardConfig = EntityConfig.GetEntity(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,pickupId)

            if(pickupConfig.HudAnim=="") then -- vanilla card
                local frameToCheck = cardPillSprite:GetAnimationData("CardFronts"):GetLayer(0):GetFrame(id)
                if(frameToCheck:IsVisible()) then -- this is false for certain cards (ex. runes, soul stones ect)
                    return {
                        Sprite = cardPillSprite,
                        Animation = "CardFronts",
                        Frame = id,
                    }
                else
                    return {
                        Sprite = Sprite(cardConfig:GetAnm2Path(), true),
                        Animation = "HUD",
                        Frame = 0,
                    }
                end
            else -- modded card
                return {
                    Sprite = pickupConfig.ModdedCardFront,
                    Animation = pickupConfig.HudAnim,
                    Frame = 0,
                }
            end
        end
    end
end

local function getMaxInventorySlots(player)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_PEZ_DISPENSER)) then return 0 end

    local numSlots = MAXSLOTS
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY)) then
        numSlots = numSlots+MAXSLOTS_PLUSBATTERY
    end
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)) then
        numSlots = numSlots+MAXSLOTS_PLUSCARBATTERY
    end

    return numSlots
end

local function getDispenserDataForPickup(id, isPill)
    --if(not (pickup and pickup:ToPickup())) then return end
    --pickup = pickup:ToPickup()
    --if(not (pickup.Variant==PickupVariant.PICKUP_PILL or pickup.Variant==PickupVariant.PICKUP_TAROTCARD)) then return end

    --local isPill = (pickup.Variant==PickupVariant.PICKUP_PILL)
    local spriteDataBig = getSpriteDataForConsumable(id, isPill, false)
    local spriteDataSmall = getSpriteDataForConsumable(id, isPill, true)

    return {
        ID = id,
        IsPill = isPill,
        HUD = spriteDataBig,
        SmallHUD = spriteDataSmall
    }
end

local function validateDispenserInventory(inventory)
    if(not inventory) then return {} end

    local nextSpot = 1
    local maxConsId = 0
    for id, _ in pairs(inventory) do
        maxConsId = math.max(maxConsId, id)
    end
    
    for i=1, maxConsId do
        if(inventory[i]) then
            if(i~=nextSpot) then
                inventory[nextSpot] = ToyboxMod:cloneTable(inventory[i])
                inventory[i] = nil
            end

            nextSpot = nextSpot+1
        end
    end

    return inventory
end

local function dropDispenserConsumable(player, index, shouldSpawnPickup)
    local dispenserInventory = ToyboxMod:getEntityData(player, "PILLCRUSHER_INVENTORY")
    local toRemove = dispenserInventory[index or 1]
    if(not toRemove) then return end

    local spawnedPickup
    if(shouldSpawnPickup) then
        local spawnPos = player.Position
        spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(spawnPos, 40)

        if(toRemove.IsPill) then
            spawnedPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,toRemove.ID,spawnPos,Vector.Zero,player):ToPickup()
        else
            spawnedPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,toRemove.ID,spawnPos,Vector.Zero,player):ToPickup()
        end
    end

    dispenserInventory[index or 1] = nil
    ToyboxMod:setEntityData(player, "PILLCRUSHER_INVENTORY", validateDispenserInventory(dispenserInventory))

    return spawnedPickup
end
local function addDispenserConsumable(player, id, isPill)
    local dispenserInventory = validateDispenserInventory(ToyboxMod:getEntityData(player, "PILLCRUSHER_INVENTORY") or {})
    local maxSlots = getMaxInventorySlots(player)

    if(#dispenserInventory==maxSlots) then
        dropDispenserConsumable(player, maxSlots, true)
        dispenserInventory[maxSlots] = nil
        
        local newInv = {}
        newInv[1] = getDispenserDataForPickup(id,isPill)
        for i, consData in ipairs(dispenserInventory) do
            newInv[i+1] = ToyboxMod:cloneTable(consData)
        end
        dispenserInventory = newInv
    else
        dispenserInventory[#dispenserInventory+1] = getDispenserDataForPickup(id,isPill)
    end

    ToyboxMod:setEntityData(player, "PILLCRUSHER_INVENTORY", validateDispenserInventory(dispenserInventory))
end

---@param player EntityPlayer
local function takeDispenserConsumable(_, _, rng, player, flags)
    local dispenserInventory = validateDispenserInventory((ToyboxMod:getEntityData(player, "PILLCRUSHER_INVENTORY") or {}))
    if(#dispenserInventory==0) then return end
    local selIndex = (ToyboxMod:getEntityData(player, "PILLCRUSHER_SELECTED") or 1)
    local toRemove = ToyboxMod:cloneTable(dispenserInventory[selIndex])
    dropDispenserConsumable(player, selIndex, false)

    if(toRemove.IsPill) then
        player:UsePill(Game():GetItemPool():GetPillEffect(toRemove.ID, player), toRemove.ID)
    else
        player:UseCard(toRemove.ID)
    end
    sfx:Play(SoundEffect.SOUND_PLOP)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, takeDispenserConsumable, ToyboxMod.COLLECTIBLE_PEZ_DISPENSER)

local function collectConsumable(_, player, pickup)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_PEZ_DISPENSER)) then return end

    if(pickup.Variant==PickupVariant.PICKUP_TAROTCARD) then
        addDispenserConsumable(player, pickup.SubType, false)
    elseif(pickup.Variant==PickupVariant.PICKUP_PILL) then
        addDispenserConsumable(player, pickup.SubType, true)
    else
        return
    end

    -- visuals
    sfx:Play(SoundEffect.SOUND_PLOP)
    pickup:GetSprite():Play("Collect", true)
    pickup.Velocity = Vector.Zero
    pickup:PlayPickupSound()
    pickup:Die()
    if(pickup.Variant==PickupVariant.PICKUP_PILL) then
        player:AnimatePill(pickup.SubType, "UseItem")
    else
        player:AnimateCard(pickup.SubType, "UseItem")
    end

    return false
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLECT_CARD, collectConsumable)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLECT_PILL, collectConsumable)

---@param player EntityPlayer
local function removeExcessPickups(_, player)
    local dispenserInventory = (ToyboxMod:getEntityData(player, "PILLCRUSHER_INVENTORY") or {})
    local numToRemove = (#dispenserInventory)-getMaxInventorySlots(player)

    if(numToRemove>0) then
        for _=1, numToRemove do
            dropDispenserConsumable(player, 1, true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, removeExcessPickups)

---@param player EntityPlayer
local function checkDropButton(_, player)
    if(EID) then
        if(player:HasCollectible(ToyboxMod.COLLECTIBLE_PEZ_DISPENSER)) then
            EID:addTextPosModifier(EID_OFFSET, EID_POS_OFFSET)
        else
            EID:removeTextPosModifier(EID_OFFSET)
        end
    end

    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_PEZ_DISPENSER)) then return end

    local dispenserInventory = validateDispenserInventory((ToyboxMod:getEntityData(player, "PILLCRUSHER_INVENTORY") or {}))
    for _, idx in pairs(PillCardSlot) do
        local pocketItem = player:GetPocketItem(idx)
        if(pocketItem:GetSlot()~=0 and pocketItem:GetType()~=PocketItemType.ACTIVE_ITEM) then

            local id = pocketItem:GetSlot()
            local isPill = (pocketItem:GetType()==PocketItemType.PILL)

            addDispenserConsumable(player, id, isPill)
            player:RemovePocketItem(idx)
        end
    end

    if(Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
        local selIndex = (ToyboxMod:getEntityData(player, "PILLCRUSHER_SELECTED") or 1)
        selIndex = selIndex%(math.max(1, #dispenserInventory))+1
        ToyboxMod:setEntityData(player, "PILLCRUSHER_SELECTED", selIndex)
    end

    local data = ToyboxMod:getEntityDataTable(player)
    data.PILLCRUSHER_DROP_FRAMES = (data.PILLCRUSHER_DROP_FRAMES or 0)
    if(Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
        data.PILLCRUSHER_DROP_FRAMES = data.PILLCRUSHER_DROP_FRAMES+1
    else
        data.PILLCRUSHER_DROP_FRAMES = 0
    end

    if(data.PILLCRUSHER_DROP_FRAMES==DROP_REQ_FRAMES) then
        local numInInventory = #dispenserInventory

        for _=1, numInInventory do
            dropDispenserConsumable(player, 1, true)
        end

        data.PILLCRUSHER_INVENTORY = {}
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_UPDATE, checkDropButton)

local function renderInventory()
    local player = Isaac.GetPlayer()
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_PEZ_DISPENSER)) then return end
    local dispenserInventory = (ToyboxMod:getEntityData(player, "PILLCRUSHER_INVENTORY") or {})
    local selectedIndex = ToyboxMod:clamp(ToyboxMod:getEntityData(player, "PILLCRUSHER_SELECTED") or 1, 1, math.max(1, #dispenserInventory))
    ToyboxMod:setEntityData(player, "PILLCRUSHER_SELECTED", selectedIndex)

    local renderPos = Vector(47,41)+Vector(20,12)*Options.HUDOffset
    local renderOffset = Vector(12,0)
    local smallRenderOffset = Vector(0,0)
    local currentPos = renderPos

    for i=1, getMaxInventorySlots(player) do
        INVENTORY_EMPTYSPRITE:Render(currentPos)

        currentPos = currentPos+renderOffset
        if(i==selectedIndex) then
            currentPos = currentPos+smallRenderOffset
        end
    end

    currentPos = renderPos
    for i, consData in ipairs(dispenserInventory) do
        local isSmall = true
        local spKey = "SmallHUD"
        if(i==selectedIndex) then
            spKey = "HUD"
            isSmall = false
        end

        if(not (consData[spKey] and consData[spKey].Sprite)) then
            consData[spKey] = getSpriteDataForConsumable(consData.ID, consData.IsPill, isSmall)
        end

        local scaleSize = 0.5
        consData[spKey].Sprite.Scale = consData[spKey].Sprite.Scale*scaleSize
        consData[spKey].Sprite:SetFrame(consData[spKey].Animation, consData[spKey].Frame)
        consData[spKey].Sprite:Render(currentPos+Vector(0, (i==selectedIndex) and 1 or 0))
        consData[spKey].Sprite.Scale = consData[spKey].Sprite.Scale/scaleSize

        if(i==selectedIndex) then
            local name
            local itemPool = Game():GetItemPool()
            if(consData.IsPill) then
                if(itemPool:IsPillIdentified(consData.ID)) then
                    name = Isaac.GetItemConfig():GetPillEffect(itemPool:GetPillEffect(consData.ID, player)).Name
                else
                    name = "???"
                end
            else
                name = Isaac.GetItemConfig():GetCard(consData.ID).Name
            end
            local localizedName = Isaac.GetString("PocketItems", name)
            if(localizedName~="StringTable::InvalidKey") then
                name = localizedName
            end

            local namePos = currentPos-renderOffset/2+Vector(0,12)*scaleSize
            NAME_FONT:DrawStringScaled(name, namePos.X, namePos.Y, scaleSize, scaleSize, KColor(1,1,1,1))

            currentPos = currentPos+smallRenderOffset
        end
        currentPos = currentPos+renderOffset
    end
    INVENTORY_CROSSSPRITE:Render(renderPos+(selectedIndex-1)*renderOffset)

    Game():GetHUD():GetCardsPillsSprite().Scale = Vector(1,1)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, renderInventory)
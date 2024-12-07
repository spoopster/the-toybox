local mod = MilcomMOD
local sfx = SFXManager()

local MAX_SLOTS = 2
local MAX_SLOTS_BATTERY_ADD = 1
local DROP_DURATION = math.floor(60*2)

local CONS_OFFSET = Vector(5,0)
local ITEM_SPRITE = Sprite("gfx/ui/tb_custom_active_renders.anm2", true)
ITEM_SPRITE:Play("PEZ Dispenser", true)
local BAR_SPRITE = Sprite("gfx/ui/tb_ui_pezdispenser_bar.anm2", true)
BAR_SPRITE:Play("Bar", true)

local BAR_MINXPOS = -25
local BAR_PADDING = 5
local BAR_SLIDE_DUR = 20

local CONS_OFFSETS = {
    [1] = Vector(0,0),
    [2] = Vector(2,-14),
    [3] = Vector(10,-3),
    [4] = Vector(10,1),
    [5] = Vector(4,10),
    [6] = Vector(1,8),
}

local NAME_FONT = Font()
NAME_FONT:Load("font/pftempestasevencondensed.fnt")

local function getConsumableSpriteFromData(data, isSmall)
    if(isSmall) then
        if(data[4] and data[4][1]) then return data[4] end

        if(data[2]) then
            local entityConf = EntityConfig.GetEntity(5,(data[2] and 70 or 300), data[1])
            return {Sprite(entityConf:GetAnm2Path(), true), "HUDSmall", 0} -- The pickup anm2's small HUD animation, for runes and pills and other objects
        else
            local conf = Isaac.GetItemConfig()
            local consConf = conf:GetCard(data[1])
            local entityConf = EntityConfig.GetEntity(5,(data[2] and 70 or 300), consConf.PickupSubtype)

            return {Sprite(entityConf:GetAnm2Path(), true), "HUDSmall", 0} -- The pickup anm2's small HUD animation, for runes and pills and other objects
        end
    else
        if(data[3] and data[3][1]) then return data[3] end

        if(data[2]) then
            local entityConf = EntityConfig.GetEntity(5,(data[2] and 70 or 300), data[1])
            return {Sprite(entityConf:GetAnm2Path(), true), "HUD", 0} -- The pickup anm2's HUD animation, for runes and pills and other objects
        else
            local conf = Isaac.GetItemConfig()
            local consConf = conf:GetCard(data[1])
            local HUDConsSprite = Game():GetHUD():GetCardsPillsSprite()
            local entityConf = EntityConfig.GetEntity(5,(data[2] and 70 or 300), consConf.PickupSubtype)

            if(consConf.HudAnim=="") then -- For vanilla cards
                local desiredFrame = HUDConsSprite:GetAnimationData("CardFronts"):GetLayer(0):GetFrame(data[1])
                if(desiredFrame:IsVisible()) then -- This is false for certain cards like runes and soul stones
                    return {HUDConsSprite, "CardFronts", data[1]} -- The respective frame from the vanilla card anm2
                else
                    return {Sprite(entityConf:GetAnm2Path(), true), "HUD", 0} -- The pickup anm2's HUD animation, for runes and other objects
                end
            else -- For modded cards
                return {consConf.ModdedCardFront, consConf.HudAnim, 0}
            end
        end
    end
end
local function getMaxDispenserSlots(player)
    if(not player:HasCollectible(mod.COLLECTIBLE_PEZ_DISPENSER)) then return 0 end
    local slots = MAX_SLOTS+(player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and MAX_SLOTS_BATTERY_ADD or 0)+(player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and MAX_SLOTS_BATTERY_ADD or 0)
    return math.min(slots, #CONS_OFFSETS)
end
local function countConsumablesInDispenser(player)
    local data = mod:getEntityDataTable(player)
    data.PILLCRUSHER_HELD_CONS = data.PILLCRUSHER_HELD_CONS or {}
    if(#data.PILLCRUSHER_HELD_CONS==0) then return 0 end

    local numConsHeld = 0
    for _, consData in ipairs(data.PILLCRUSHER_HELD_CONS) do
        if(consData and consData[1]~=-1) then numConsHeld = numConsHeld+1 end
    end
    return numConsHeld
end
local function dropDispenserConsumables(player, posSt, posEnd)
    local data = mod:getEntityDataTable(player)
    data.PILLCRUSHER_HELD_CONS = data.PILLCRUSHER_HELD_CONS or {}

    local counter = 0
    local room = Game():GetRoom()
    for i, consData in ipairs(data.PILLCRUSHER_HELD_CONS) do
        if(consData[1]~=-1) then
            counter = counter+1
            if(counter>=posSt and counter<=posEnd) then
                local pickup = Isaac.Spawn(5, (consData[2] and 70 or 300), consData[1], room:FindFreePickupSpawnPosition(player.Position,40), Vector.Zero, player):ToPickup()
                data.PILLCRUSHER_HELD_CONS[i] = {-1,false,nil,nil}
            end
        end
    end
end

---@param player EntityPlayer
local function usePillCrusher(_, _, rng, player, flags)
    local data = mod:getEntityDataTable(player)
    data.PILLCRUSHER_HELD_CONS = data.PILLCRUSHER_HELD_CONS or {}

    local numConsHeld = countConsumablesInDispenser(player)
    if(numConsHeld>0) then
        local pickupToUse = mod:cloneTable(data.PILLCRUSHER_HELD_CONS[1])

        for i=2, numConsHeld do
            data.PILLCRUSHER_HELD_CONS[i-1] = mod:cloneTable(data.PILLCRUSHER_HELD_CONS[i])
        end
        data.PILLCRUSHER_HELD_CONS[numConsHeld] = {-1,false,nil,nil}

        if(pickupToUse[2]) then
            --player:UsePill(Game():GetItemPool():GetPillEffect(pickupToUse[1], player), pickupToUse[1])
            player:AddPill(pickupToUse[1])
        else
            --player:UseCard(pickupToUse[1])
            player:AddCard(pickupToUse[1])
        end
        sfx:Play(SoundEffect.SOUND_PLOP)
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, usePillCrusher, mod.COLLECTIBLE_PEZ_DISPENSER)

--! ADD CONSUMABLES TO SLOTS
---@param pl EntityPlayer
---@param pickup EntityPickup
local function preAddCard(_, pl, pickup)
    if(not pl:HasCollectible(mod.COLLECTIBLE_PEZ_DISPENSER)) then return end
    local data = mod:getEntityDataTable(pl)
    data.PILLCRUSHER_HELD_CONS = data.PILLCRUSHER_HELD_CONS or {}

    local numConsHeld = countConsumablesInDispenser(pl)
    if(numConsHeld>=getMaxDispenserSlots(pl)) then return end

    for i=numConsHeld, 1, -1 do
        data.PILLCRUSHER_HELD_CONS[i+1] = mod:cloneTable(data.PILLCRUSHER_HELD_CONS[i])
    end
    data.PILLCRUSHER_HELD_CONS[1] = {pickup.SubType, false, getConsumableSpriteFromData({pickup.SubType, false}, false), getConsumableSpriteFromData({pickup.SubType, false}, true)}

    sfx:Play(SoundEffect.SOUND_PLOP)
    pickup:GetSprite():Play("Collect", true)
    pickup.Velocity = Vector.Zero
    pickup:PlayPickupSound()
    pickup:Die()

    pl:AnimateCard(pickup.SubType, "UseItem")

    return false
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLECT_CARD, preAddCard)
---@param pl EntityPlayer
---@param pickup EntityPickup
local function preAddPill(_, pl, pickup)
    if(not pl:HasCollectible(mod.COLLECTIBLE_PEZ_DISPENSER)) then return end
    local data = mod:getEntityDataTable(pl)
    data.PILLCRUSHER_HELD_CONS = data.PILLCRUSHER_HELD_CONS or {}

    local numConsHeld = countConsumablesInDispenser(pl)
    if(numConsHeld>=getMaxDispenserSlots(pl)) then return end

    for i=numConsHeld, 1, -1 do
        data.PILLCRUSHER_HELD_CONS[i+1] = mod:cloneTable(data.PILLCRUSHER_HELD_CONS[i])
    end
    data.PILLCRUSHER_HELD_CONS[1] = {pickup.SubType, true, getConsumableSpriteFromData({pickup.SubType, true}, false), getConsumableSpriteFromData({pickup.SubType, true}, true)}

    sfx:Play(SoundEffect.SOUND_PLOP)
    pickup:GetSprite():Play("Collect", true)
    pickup.Velocity = Vector.Zero
    pickup:PlayPickupSound()
    pickup:Die()

    pl:AnimatePill(pickup.SubType, "UseItem")

    return false
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLECT_PILL, preAddPill)

--! ITEM RENDERING
---@param player EntityPlayer
local function renderItem(_, player, slot, offset, a, scale)
    if(not ((slot==ActiveSlot.SLOT_PRIMARY or slot==ActiveSlot.SLOT_POCKET) and player:GetActiveItem(slot)==mod.COLLECTIBLE_PEZ_DISPENSER)) then return end
    local data = mod:getEntityDataTable(player)
    data.PILLCRUSHER_HELD_CONS = data.PILLCRUSHER_HELD_CONS or {}
    local numConsHeld = countConsumablesInDispenser(player)

    --! RENDER SECONDARY CONSUMABLES
    local vanillaConsSprite = Game():GetHUD():GetCardsPillsSprite()
    local ogAlpha = vanillaConsSprite.Color.A
    
    local renderPos = offset+Vector(16,16)+Vector(-8,4)
    local ioffset = 0
    for i=1, numConsHeld do
        if(data.PILLCRUSHER_HELD_CONS[i][1]~=-1) then
            renderPos = renderPos+(CONS_OFFSETS[i+ioffset] or Vector.Zero)*scale
            if(not (data.PILLCRUSHER_HELD_CONS[i][3] and data.PILLCRUSHER_HELD_CONS[i][3][1])) then
                data.PILLCRUSHER_HELD_CONS[i][3] = mod:cloneTable(getConsumableSpriteFromData(data.PILLCRUSHER_HELD_CONS[i], false))
            end
            if(not (data.PILLCRUSHER_HELD_CONS[i][4] and data.PILLCRUSHER_HELD_CONS[i][4][1])) then
                data.PILLCRUSHER_HELD_CONS[i][4] = mod:cloneTable(getConsumableSpriteFromData(data.PILLCRUSHER_HELD_CONS[i], true))
            end
        else
            ioffset = ioffset-1
        end
    end

    ioffset = 0
    for i=numConsHeld, 2, -1 do
        if(data.PILLCRUSHER_HELD_CONS[i][1]~=-1) then
            local dt = data.PILLCRUSHER_HELD_CONS[i][4]
            dt[1].Color = Color(1,1,1,a)
            dt[1].Scale = Vector(scale,scale)
            dt[1]:SetFrame(dt[2], dt[3])
            dt[1]:Render(renderPos)
            renderPos = renderPos-(CONS_OFFSETS[i+ioffset] or Vector.Zero)*scale
        else
            ioffset = ioffset+1
        end
    end
    
    --! RENDER ITEM
    local toLerp = Vector.Zero
    if(numConsHeld>0) then toLerp = CONS_OFFSET end
    data.PILLCRUSHER_OFFSET = mod:lerp((data.PILLCRUSHER_OFFSET or Vector.Zero), toLerp, 0.5)
    ITEM_SPRITE.Scale = Vector(scale,scale)
    ITEM_SPRITE.Color = Color(1,1,1,a)
    ITEM_SPRITE:Render(offset+data.PILLCRUSHER_OFFSET+Vector(16,16))

    --! RENDER MAIN CONSUMABLE
    if(numConsHeld>=1 and data.PILLCRUSHER_HELD_CONS[1] and data.PILLCRUSHER_HELD_CONS[1][1]~=-1) then
        local consData = data.PILLCRUSHER_HELD_CONS[1]
        local renderData = consData[3]
        renderData[1].Color = Color(1,1,1,a)
        renderData[1].Scale = Vector(scale,scale)
        renderData[1]:SetFrame(renderData[2], renderData[3])
        renderData[1]:Render(renderPos)

        if(mod.CONFIG.PEZDISPENSER_DISPLAY_NAME~=2) then
            local text
            local conf = Isaac.GetItemConfig()
            local pool = Game():GetItemPool()
            if(consData[2]) then
                text = conf:GetPillEffect(pool:GetPillEffect(consData[1], player)).Name
            else
                text = conf:GetCard(consData[1]).Name
            end
            local localizedText = Isaac.GetString("PocketItems", text)
            if(localizedText~="StringTable::InvalidKey") then text = localizedText end
            data.PILLCRUSHER_STORED_NAME = text
        end
    end

    --[[
    if(mod.CONFIG.PEZDISPENSER_DISPLAY_NAME~=2 and data.PILLCRUSHER_MAP_FRAMES and data.PILLCRUSHER_MAP_FRAMES>0) then
        local text = data.PILLCRUSHER_STORED_NAME or ""
        local screenSizes = {Isaac.GetScreenWidth(), Isaac.GetScreenHeight()}
        local isPastMiddle = {offset.X*2>=screenSizes[1], offset.Y*2>=screenSizes[2]}

        local textScale = 1*scale
        local width = NAME_FONT:GetStringWidth(text)*textScale
        local barXPos = width+BAR_PADDING*2
        local barMinPos = BAR_MINXPOS
        local posOffset = Vector(0,0)
        local textOffset = Vector(-width-BAR_PADDING, 0)
        if(isPastMiddle[1]) then
            barXPos = screenSizes[1]-barXPos-BAR_PADDING
            barMinPos = screenSizes[1]-barMinPos
            textOffset.X = BAR_PADDING
        end
        if(isPastMiddle[2]) then
            posOffset.Y = -30
        end

        local frames = (data.PILLCRUSHER_MAP_FRAMES/BAR_SLIDE_DUR)^(0.2)
        frames = math.min(1, frames)

        if(not Game():IsPaused()) then print(frames) end

        local finalBarPos = Vector(0,24+offset.Y)+posOffset+Vector(mod:lerp(barMinPos, barXPos, frames),0)

        BAR_SPRITE.FlipX = isPastMiddle[1]
        BAR_SPRITE:Render(finalBarPos+Vector(0,7))
        NAME_FONT:DrawStringScaled(text, finalBarPos.X+textOffset.X, finalBarPos.Y+textOffset.Y, textScale, textScale, KColor(1,1,1,1))
    end
    --]]

    vanillaConsSprite.Color = Color(1,1,1,ogAlpha)

    return true
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, math.huge, renderItem)

---@param pl EntityPlayer
local function playerUpdate(_, pl)
    local data = mod:getEntityDataTable(pl)
    data.PILLCRUSHER_HELD_CONS = data.PILLCRUSHER_HELD_CONS or {}
    local numConsHeld = countConsumablesInDispenser(pl)

    if(not pl:HasCollectible(mod.COLLECTIBLE_PEZ_DISPENSER)) then
        if(numConsHeld>0) then dropDispenserConsumables(pl, 1, numConsHeld) end
        return
    end

    local maxSlots = getMaxDispenserSlots(pl)
    if(numConsHeld>maxSlots) then
        dropDispenserConsumables(pl, maxSlots+1, numConsHeld)
    end

    local pType = pl:GetPlayerType()
    local isJnE = (pType==PlayerType.PLAYER_JACOB or pType==PlayerType.PLAYER_ESAU)

    if(Input.IsActionPressed(ButtonAction.ACTION_DROP, pl.ControllerIndex) and ((not isJnE) or (isJnE and pl:GetMovementInput():Length()<0.01))) then
        data.PILLCRUSHER_DROP_FRAMES = (data.PILLCRUSHER_DROP_FRAMES or 0)+1
    else
        data.PILLCRUSHER_DROP_FRAMES = 0
    end

    data.PILLCRUSHER_MAP_FRAMES = data.PILLCRUSHER_MAP_FRAMES or 0
    if(mod.CONFIG.PEZDISPENSER_DISPLAY_NAME==0) then
        if(numConsHeld>0 and Input.IsActionPressed(ButtonAction.ACTION_MAP, pl.ControllerIndex) and data.PILLCRUSHER_MAP_FRAMES<=BAR_SLIDE_DUR+3) then
            data.PILLCRUSHER_MAP_FRAMES = math.min(data.PILLCRUSHER_MAP_FRAMES+1, BAR_SLIDE_DUR+3)
        elseif(data.PILLCRUSHER_MAP_FRAMES>0) then
            data.PILLCRUSHER_MAP_FRAMES = math.max(data.PILLCRUSHER_MAP_FRAMES-2, 0)
        end
    elseif(mod.CONFIG.PEZDISPENSER_DISPLAY_NAME==1) then
        if(numConsHeld>0 and data.PILLCRUSHER_MAP_FRAMES<=BAR_SLIDE_DUR+3) then
            data.PILLCRUSHER_MAP_FRAMES = math.min(data.PILLCRUSHER_MAP_FRAMES+1, BAR_SLIDE_DUR+3)
        elseif(data.PILLCRUSHER_MAP_FRAMES>0) then
            data.PILLCRUSHER_MAP_FRAMES = math.max(data.PILLCRUSHER_MAP_FRAMES-2, 0)
        end
    end

    if(numConsHeld>1 and data.PILLCRUSHER_DROP_FRAMES==1) then
        local pickupToUse = mod:cloneTable(data.PILLCRUSHER_HELD_CONS[1])
        for i=2, numConsHeld do
            data.PILLCRUSHER_HELD_CONS[i-1] = mod:cloneTable(data.PILLCRUSHER_HELD_CONS[i])
        end
        data.PILLCRUSHER_HELD_CONS[numConsHeld] = mod:cloneTable(pickupToUse)
    end
    if(numConsHeld>0 and data.PILLCRUSHER_DROP_FRAMES>=DROP_DURATION) then
        dropDispenserConsumables(pl, 1, numConsHeld)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, playerUpdate, 0)

local function postUpdate(_)
    local conf = Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE_PEZ_DISPENSER)
    if(mod.CONFIG.PEZDISPENSER_ANTIBIRTH_KILLER and conf.Name=="Candy Dispenser") then
        conf.Name = "Legally Distinct Pill Crusher"
        conf.GfxFileName = "gfx/items/collectibles/tb_pill_crusher.png"
        ITEM_SPRITE:ReplaceSpritesheet(0, conf.GfxFileName)
        ITEM_SPRITE:ReplaceSpritesheet(1, conf.GfxFileName, true)
        BAR_SPRITE:Play("Bar2", true)

        for _, pickup in ipairs(Isaac.FindByType(5,100,mod.COLLECTIBLE_PEZ_DISPENSER)) do
            local sp = pickup:GetSprite()
            sp:ReplaceSpritesheet(1, "gfx/items/collectibles/tb_pill_crusher.png", true)
        end
    elseif((not mod.CONFIG.PEZDISPENSER_ANTIBIRTH_KILLER) and conf.Name~="Candy Dispenser") then
        conf.Name = "Candy Dispenser"
        conf.GfxFileName = "gfx/items/collectibles/tb_pez_dispenser.png"
        ITEM_SPRITE:ReplaceSpritesheet(0, conf.GfxFileName)
        ITEM_SPRITE:ReplaceSpritesheet(1, conf.GfxFileName, true)
        BAR_SPRITE:Play("Bar", true)
        
        for _, pickup in ipairs(Isaac.FindByType(5,100,mod.COLLECTIBLE_PEZ_DISPENSER)) do
            local sp = pickup:GetSprite()
            sp:ReplaceSpritesheet(1, "gfx/items/collectibles/tb_pez_dispenser.png", true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)
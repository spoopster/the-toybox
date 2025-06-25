

local registry = require("scripts.tcainrework.stored.id_to_iteminfo")

local sp = Sprite("gfx_tb/suck my dick.anm2", true)
sp:Play("Idle", true)
sp.PlaybackSpeed = 0.25
sp:GetLayer(0):SetCustomShader("spriteshaders/mengershader")

---@param pl EntityPlayer
---@param slot ActiveSlot
---@param offset Vector
local function renderActiveItem(_, pl, slot, offset, alpha, scale, chargebaroffset)
    if(pl:GetActiveItem(slot)~=ToyboxMod.COLLECTIBLE_COMPRESSED_DICE) then return end
    if(slot~=ActiveSlot.SLOT_PRIMARY) then return end

    sp.Scale = Vector(1,1)
    sp:Render(offset+Vector(16,16))
    sp:Update()

    local layer = sp:GetLayer(0)
    layer:SetColor(Color(1,1,1,1,0,0,0,(Game():GetFrameCount()/30),0,0,0))

    return true
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, renderActiveItem)

---@param rng RNG
---@param pl EntityPlayer
local function useCompressedDice(_, _, rng, pl)
    pl:ChangePlayerType(rng:RandomInt(2)==0 and PlayerType.PLAYER_ISAAC_B or PlayerType.PLAYER_ISAAC)
    pl:UseActiveItem(CollectibleType.COLLECTIBLE_CLICKER)
    Isaac.StartNewGame(pl:GetPlayerType(), Challenge.CHALLENGE_NULL, rng:RandomInt(4))
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useCompressedDice, ToyboxMod.COLLECTIBLE_COMPRESSED_DICE)

---@param pickup EntityPickup
local function pickupRender(_, pickup, offset)
    if(pickup.SubType~=ToyboxMod.COLLECTIBLE_COMPRESSED_DICE) then return end

    local pSp = pickup:GetSprite()
    local frameData = pSp:GetLayerFrameData(1)

    local renderPos = Isaac.WorldToRenderPosition(pickup.Position)+offset

    sp.Scale = frameData:GetScale()
    renderPos = renderPos+frameData:GetPos()-frameData:GetPivot()+Vector(16,16)

    sp:Render(renderPos)
    sp:Update()

    local layer = sp:GetLayer(0)
    layer:SetColor(Color(1,1,1,1,0,0,0,(Game():GetFrameCount()/30),0,0,0))
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, pickupRender, PickupVariant.PICKUP_COLLECTIBLE)

---@param pl EntityPlayer
local function playerRender(_, pl, offset)
    local queuedItem = pl.QueuedItem
    if(not (queuedItem.Item and queuedItem.Item.ID==ToyboxMod.COLLECTIBLE_COMPRESSED_DICE)) then return end

    if(not Game():IsPaused()) then
        local heldsp = pl:GetHeldSprite()
        --print(heldsp.Offset, heldsp:GetFilename())
    end

    local renderPos = Isaac.WorldToRenderPosition(pl.Position)+offset

    sp.Scale = Vector(1,1)
    renderPos = renderPos+Vector(0,-40)

    sp:Render(renderPos)
    sp:Update()

    local layer = sp:GetLayer(0)
    layer:SetColor(Color(1,1,1,1,0,0,0,(Game():GetFrameCount()/30),0,0,0))
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, playerRender)
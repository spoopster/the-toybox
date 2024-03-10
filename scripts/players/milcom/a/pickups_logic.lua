local mod = MilcomMOD

--#region MENU_STUFF
local menuSprite = Sprite()
menuSprite:Load("gfx/ui/milcom_a/pickups/milcom_a_hudpickups.anm2", true)

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")

local MENU_RENDER_POS = Vector(0,32)
local pickupsRenderData = {
    CARDBOARD = {OFFSET=Vector(1, -3), TEXTOFFSET=Vector(20, -2), FRAME=0},
    DUCT_TAPE = {OFFSET=Vector(1, 9), TEXTOFFSET=Vector(20, 11),  FRAME=1},
    NAILS = {OFFSET=Vector(1, 23), TEXTOFFSET=Vector(20, 24), FRAME=2},
}

local function postRender(_, player)
    if(not mod:isAnyPlayerMilcomA()) then return end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, postRender)

local function renderPickupHUD(_, player, slot)
    --if(not (mod:getPlayerNumFromPlayerEnt(player)==0 and slot==0)) then return end
    if(not mod:isAnyPlayerMilcomA()) then return end

    local offset = Vector(Options.HUDOffset*20, Options.HUDOffset*12)
    local renderPos = offset+MENU_RENDER_POS

    menuSprite:Play("Menu", true)
    menuSprite:Render(renderPos)

    menuSprite:Play("Pickups", true)
    for pickup, rData in pairs(pickupsRenderData) do
        local num = mod.MILCOM_A_PICKUPS[pickup]

        menuSprite:SetFrame(rData.FRAME)
        menuSprite:Render(renderPos+rData.OFFSET)

        f:DrawString(tostring(math.floor((num%100-num%10)/10))..tostring(num%10), (renderPos+rData.TEXTOFFSET).X, (renderPos+rData.TEXTOFFSET).Y, KColor(1,1,1,1))
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_HUD_RENDER, 1e6, renderPickupHUD)
--#endregion

local function replacePickupsWithMaterials(_)
    if(not mod:isAnyPlayerMilcomA()) then return end
    local player = mod:getFirstMilcomA()
    if(not player) then return end
    ---@type EntityPlayer
    player = player:ToPlayer()

    if(not mod:canMilcomUseCoins()) then
        if(player:GetNumCoins()>0) then
            mod.MILCOM_A_PICKUPS.CARDBOARD = mod:clamp(mod.MILCOM_A_PICKUPS.CARDBOARD+player:GetNumCoins(), 99, 0)
            player:AddCoins(-player:GetNumCoins())
        end

        mod.MILCOM_A_PICKUPS.CARDBOARD_NOUPGRADE = mod.MILCOM_A_PICKUPS.CARDBOARD
    else
        if(mod.MILCOM_A_PICKUPS.CARDBOARD_NOUPGRADE~=-1) then
            player:AddCoins(mod.MILCOM_A_PICKUPS.CARDBOARD_NOUPGRADE or 0)
            mod.MILCOM_A_PICKUPS.CARDBOARD_NOUPGRADE = -1
        end

        mod.MILCOM_A_PICKUPS.CARDBOARD = player:GetNumCoins()
    end

    if(player:HasGoldenBomb()) then
        player:AddBombs(5)
        player:RemoveGoldenBomb()
    end
    if(not mod:canMilcomUseBombs()) then
        if(player:GetNumBombs()>0) then
            mod.MILCOM_A_PICKUPS.DUCT_TAPE = mod:clamp(mod.MILCOM_A_PICKUPS.DUCT_TAPE+player:GetNumBombs(), 99, 0)
            player:AddBombs(-player:GetNumBombs())
        end

        mod.MILCOM_A_PICKUPS.DUCT_TAPE_NOUPGRADE = mod.MILCOM_A_PICKUPS.DUCT_TAPE
    else
        if(mod.MILCOM_A_PICKUPS.DUCT_TAPE_NOUPGRADE~=-1) then
            player:AddBombs(mod.MILCOM_A_PICKUPS.DUCT_TAPE_NOUPGRADE or 0)
            mod.MILCOM_A_PICKUPS.DUCT_TAPE_NOUPGRADE = -1
        end

        mod.MILCOM_A_PICKUPS.DUCT_TAPE = player:GetNumBombs()
    end

    if(player:HasGoldenKey()) then
        player:AddKeys(5)
        player:RemoveGoldenKey()
    end
    if(not mod:canMilcomUseKeys()) then
        if(player:GetNumKeys()>0) then
            mod.MILCOM_A_PICKUPS.NAILS = mod:clamp(mod.MILCOM_A_PICKUPS.NAILS+player:GetNumKeys(), 99, 0)
            player:AddKeys(-player:GetNumKeys())
        end

        mod.MILCOM_A_PICKUPS.NAILS_NOUPGRADE = mod.MILCOM_A_PICKUPS.NAILS
    else
        if(mod.MILCOM_A_PICKUPS.NAILS_NOUPGRADE~=-1) then
            player:AddKeys(mod.MILCOM_A_PICKUPS.NAILS_NOUPGRADE or 0)
            mod.MILCOM_A_PICKUPS.NAILS_NOUPGRADE = -1
        end

        mod.MILCOM_A_PICKUPS.NAILS = player:GetNumKeys()
    end

    --[[if(mod:getData(player, "MILCOMA_JUST_GOT_COCKLOCKED")==true) then
        mod.MILCOM_A_PICKUPS.NAILS = mod.MILCOM_A_PICKUPS.NAILS+1

        mod:setData(player, "MILCOMA_JUST_GOT_COCKLOCKED", false)
    end]]

    --[[if(player:GetNumCoins()>0) then
        mod:addCardboard(player:GetNumCoins())
        player:AddCoins(-player:GetNumCoins())
    end

    if(player:GetNumBombs()>0) then
        mod:addDuctTape(player:GetNumBombs())
        player:AddBombs(-player:GetNumBombs())
    end
    if(player:HasGoldenBomb()) then
        mod:addDuctTape(5)
        player:RemoveGoldenBomb()
    end

    if(player:GetNumKeys()>0) then
        mod:addNails(player:GetNumKeys())
        player:AddKeys(-player:GetNumKeys())
    end
    if(player:HasGoldenKey()) then
        mod:addNails(5)
        player:RemoveGoldenKey()
    end]]
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, -(1e6), replacePickupsWithMaterials)

--#region PICKUP_ENTITIES

-- [[

---@param pickup EntityPickup
local function postMaterialInit(_, pickup)
    pickup:GetSprite():Play("Appear", true)
    pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postMaterialInit, mod.MATERIAL_A_VARIANT)

---@param pickup EntityPickup
---@param collider Entity
local function preMaterialCollision(_, pickup, collider)
    if(pickup.Wait>0) then return true end
    if(collider.Type==5) then return false end
    if(collider.Type~=1) then return true end
    if(pickup:GetSprite():GetAnimation()~="Idle") then return true end

    if(pickup.SubType==mod.MATERIAL_A_SUBTYPE.CARDBOARD) then
        collider:ToPlayer():AddCoins(1)
    elseif(pickup.SubType==mod.MATERIAL_A_SUBTYPE.DUCT_TAPE) then
        collider:ToPlayer():AddBombs(1)
    elseif(pickup.SubType==mod.MATERIAL_A_SUBTYPE.NAILS) then
        collider:ToPlayer():AddKeys(1)
    end

    pickup:GetSprite():Play("Collect", true)
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, preMaterialCollision, mod.MATERIAL_A_VARIANT)

---@param pickup EntityPickup
local function postMaterialUpdate(_, pickup)
    local sprite = pickup:GetSprite()
    if(sprite:IsFinished("Appear")) then
        sprite:Play("Idle", true)
    end
    if(sprite:IsFinished("Collect")) then
        pickup:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postMaterialUpdate, mod.MATERIAL_A_VARIANT)

--]]

--#endregion
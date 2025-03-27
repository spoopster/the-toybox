local mod = ToyboxMod
--* You can pick up and throw poops by using this item
--? maybe make custom rainbow, giant and charming poop variants for the entity
--? if possible make it hold up poop enemies bc funny

local function justUsedPoop(_, item, rng, player)
    if(not mod:playerHasLimitBreak(player)) then return end
    mod:setEntityData(player, "JUST_USED_POOP", true)
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, justUsedPoop, CollectibleType.COLLECTIBLE_POOP)

---@param pl EntityPlayer
local function postPlayerUpdate(_, pl)
    if(not mod:playerHasLimitBreak(pl)) then return end
    if(mod:getEntityData(pl, "JUST_USED_POOP")) then
        mod:setEntityData(pl, "JUST_USED_POOP", nil)
        return
    end

    local isUsingPrimaryPoop = (Input.IsActionTriggered(ButtonAction.ACTION_ITEM, pl.ControllerIndex) and pl:GetActiveItem(ActiveSlot.SLOT_PRIMARY)==CollectibleType.COLLECTIBLE_POOP)
    local isUsingPocketPoop = (Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, pl.ControllerIndex) and pl:GetActiveItem(ActiveSlot.SLOT_POCKET)==CollectibleType.COLLECTIBLE_POOP)

    if(isUsingPrimaryPoop or isUsingPocketPoop) then
        local room = Game():GetRoom()
        local gridAlignedPos = room:GetGridPosition(room:GetGridIndex(pl.Position))

        ---@type GridEntityPoop|EntityNPC
        local closestPoop
        local closestDistSq, closestIdx
        for i=-1, 1 do
            for j=-1, 1 do
                local gridPos = gridAlignedPos+Vector(i,j)*40
                local gridIdx = room:GetGridIndex(gridPos)

                local grid = room:GetGridEntity(gridIdx)
                if(grid and grid:ToPoop()) then
                    grid = grid:ToPoop()
                    local dist = gridPos:DistanceSquared(pl.Position)
                    if(closestPoop==nil or (closestPoop and closestDistSq and closestDistSq>dist)) then
                        closestPoop = grid
                        closestDistSq = dist
                        closestIdx = gridIdx
                    end
                end
            end
        end

        for _, ent in ipairs(Isaac.FindInRadius(pl.Position, 30)) do
            --local conf = EntityConfig.GetEntity(ent.Type,ent.Variant,ent.SubType)
            if(ent.Type==EntityType.ENTITY_POOP--[[or conf:GetGibFlags() & GibFlag.POOP ~= 0]]) then
                local dist = ent.Position:DistanceSquared(pl.Position)
                if(closestPoop==nil or (closestPoop and closestDistSq and closestDistSq>dist)) then
                    closestPoop = ent
                    closestDistSq = dist
                end
            end
        end

        if(not closestPoop) then return end

        if(closestPoop.IsEnemy) then
            pl:TryHoldEntity(closestPoop)
        else
            local poopVarToHeldVar = {
                [GridPoopVariant.NORMAL] = EntityPoopVariant.NORMAL,
                [GridPoopVariant.RED] = EntityPoopVariant.FLAMING,
                [GridPoopVariant.CHUNKY] = EntityPoopVariant.CHUNKY,
                [GridPoopVariant.CORN] = EntityPoopVariant.CORN,
                [GridPoopVariant.GOLDEN] = EntityPoopVariant.GOLDEN,
                --[GridPoopVariant.RAINBOW] = EntityPoopVariant.NORMAL,
                [GridPoopVariant.BLACK] = EntityPoopVariant.BLACK,
                [GridPoopVariant.HOLY] = EntityPoopVariant.HOLY,
                [GridPoopVariant.WHITE] = EntityPoopVariant.WHITE,
                --[GridPoopVariant.CHARMING] = EntityPoopVariant.NORMAL,
            }

            local newPoop = Isaac.Spawn(EntityType.ENTITY_POOP, poopVarToHeldVar[closestPoop:GetVariant()] or EntityPoopVariant.NORMAL, 0, pl.Position,Vector.Zero,pl)
            newPoop:Update()
            newPoop:GetSprite():SetFrame("State1", newPoop:GetSprite():GetAnimationData("State1"):GetLength()-1)
            pl:TryHoldEntity(newPoop)

            room:RemoveGridEntityImmediate(closestIdx, 0, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate, 0)
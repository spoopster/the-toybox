local mod = MilcomMOD

local statusSprite = Sprite("gfx/ui/tb_custom_statuses.anm2", true)

mod.CUSTOM_STATUS_EFFECTS = {}

function mod:addCustomStatusEffect(animName, overlayColor, applyCondition)
    table.insert(mod.CUSTOM_STATUS_EFFECTS,
        {
            ANIMATION = animName,
            COLOR = overlayColor,
            CONDITION = applyCondition,
        }
    )
end

--mod:addCustomStatusEffect("Test1", function(npc) return true end)
--mod:addCustomStatusEffect("Test2", function(npc) return true end)

local function npcRender(_, npc, offset)
    local toRender = {}
    for _, data in ipairs(mod.CUSTOM_STATUS_EFFECTS) do
        if(data.CONDITION(npc)) then
            table.insert(toRender, data.ANIMATION)
        end
    end

    local statusOverlayPos = Vector(0,0)
    local overlayFrame = npc:GetSprite():GetNullFrame("OverlayEffect")
    if(overlayFrame) then
        statusOverlayPos = overlayFrame:GetPos()
    end

    for i=1, #toRender do
        statusSprite:Play(toRender[i],true)
        statusSprite:SetFrame(npc.FrameCount%statusSprite:GetCurrentAnimationData():GetLength())

        local rPos = statusOverlayPos+Vector((i-#toRender/2-1/2)*17, -24)+Isaac.WorldToScreen(npc.Position)+offset
        statusSprite:Render(rPos)
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NPC_RENDER, math.huge, npcRender)

local function npcUpdate(_, npc)
    local selIdx = -1
    for i, data in ipairs(mod.CUSTOM_STATUS_EFFECTS) do
        if(data.CONDITION(npc)) then
            selIdx=i
        end
    end

    if(selIdx~=-1) then
        npc:SetColor(mod.CUSTOM_STATUS_EFFECTS[selIdx].COLOR, 2, 1, false, false)
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NPC_RENDER, math.huge, npcUpdate)

--
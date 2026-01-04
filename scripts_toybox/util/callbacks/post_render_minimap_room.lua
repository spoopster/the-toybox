
-- TODO: MinimAPI bands rendering support?? one day

local MINIMAP_SPRITE = Sprite("gfx_tb/ui/ui_tinted_room.anm2", true)

local TINT_ALPHA = 0.2
local TINT_INTENSITY = 1
local TINT_CENTER_INTENSITY = 1--2

local SMALL_MINIMAP_ROOMS_DISTANCE = 5
local SMALL_MINIMAP_SIZE = Vector(49,43)

local ROOM_GRID_SIZE = Vector(9,8)
local ROOM_GRID_SIZE_BIG = Vector(18,16)

local normalMapOpacity = 1
local expandedMapOpacity = 0
local mapHeldTime = 0
local keepMapExpanded = 0

local colorInverse = Color(255,255,255, 1)

local function isAnyoneHoldingMap()
    local players = PlayerManager.GetPlayers()
    for _, pl in ipairs(players) do
        if(pl:IsLocalPlayer() and Input.IsActionPressed(ButtonAction.ACTION_MAP, pl.ControllerIndex)) then
            return true
        end
    end
    return false
end

local function updateMapOpacity(_, g)
    local state = Minimap:GetState()
    local heldTime = Minimap:GetHoldTime()

    if(state==MinimapState.NORMAL) then
        normalMapOpacity = math.min(normalMapOpacity+0.1, 1)
        expandedMapOpacity = math.max(expandedMapOpacity-0.2, 0)
    elseif(state==MinimapState.EXPANDED) then
        local oldst, newst

        if(not keepMapExpanded) then
            normalMapOpacity = 0
        else
            normalMapOpacity = math.max(normalMapOpacity-0.2, 0)
        end

        if(heldTime<9) then
            if(isAnyoneHoldingMap()) then
                expandedMapOpacity = math.min(expandedMapOpacity+0.1, 1)
            end
        else
            expandedMapOpacity = 1
        end
    elseif(state==MinimapState.EXPANDED_OPAQUE) then
        normalMapOpacity = math.max(normalMapOpacity-0.2, 0)
        expandedMapOpacity = math.min(expandedMapOpacity+0.1, Options.MapOpacity)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_MINIMAP_UPDATE, updateMapOpacity)


local function floorVector(vec)
    return Vector(math.floor(vec.X), math.floor(vec.Y))
end
local function maxVectorComponents(vec, num)
    return Vector(math.max(vec.X, num), math.max(vec.Y, num))
end

local function runcallback(isBig, roomIdx, roomPos, roomSize, mapAlpha, TLclamp, BRclamp, brclamp2)
    Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_RENDER_MINIMAP_ROOM,
        isBig, -- is it rendered on the big map?
        roomIdx, -- room grid index
        roomPos, -- room render position
        roomSize, -- room render size
        mapAlpha, -- alpha
        TLclamp, -- top left map clamp?
        BRclamp, -- bottom left map clamp?
        brclamp2
    )
end

local function tryRenderAuraAtLevelIdxSmall(renderRoom, centerPos, centerSize, colormod)
    if(renderRoom.DisplayFlags == RoomDescriptor.DISPLAY_NONE) then return end

    local topLeftPos = ToyboxMod:gridIndexToPositionVector(renderRoom.GridIndex)
    local isInBoundsX = (centerPos.X+centerSize.X-4<=topLeftPos.X) and (centerPos.X+3>=topLeftPos.X)
    local isInBoundsY = (centerPos.Y+centerSize.X-4<=topLeftPos.Y) and (centerPos.Y+3>=topLeftPos.Y)
    if(not (isInBoundsX and isInBoundsY)) then return end

    local mapCornerPos = Vector(Isaac.GetScreenWidth(), 0)+Vector(-24,12)*Options.HUDOffset+Vector(-7,6)+Vector(-47,0)+Vector(-2,-2)

    local shape = RoomShape.ROOMSHAPE_1x1
    if(renderRoom.Data and renderRoom.Data.Subtype~=BossType.DELIRIUM) then
        shape = renderRoom.Data.Shape
    end
    local roomSize = ROOM_GRID_SIZE*ToyboxMod.ROOM_DIMENSIONS[shape]

    local relativePos = floorVector((ROOM_GRID_SIZE-Vector(1,1))*(Vector(3,3)-centerSize/2+topLeftPos-centerPos))

    local topLeftClamp = maxVectorComponents(-relativePos, 0)
    local bottomRightClamp = maxVectorComponents(relativePos+roomSize-SMALL_MINIMAP_SIZE, 0)
    local bottomRightClamp2 = maxVectorComponents(relativePos+ROOM_GRID_SIZE-SMALL_MINIMAP_SIZE, 0)

    runcallback(false, renderRoom.SafeGridIndex, mapCornerPos+relativePos, roomSize, colormod, topLeftClamp, bottomRightClamp, bottomRightClamp2)
end

local function tryRenderAuraAtLevelIdxBig(renderRoom, bounds, colormod)
    if(renderRoom.DisplayFlags == RoomDescriptor.DISPLAY_NONE) then return end

    local mapCornerPos = Vector(Isaac.GetScreenWidth(), 0)+Vector(-24,12)*Options.HUDOffset+Vector(-1,0)*Minimap.GetDisplayedSize()+Vector(0,2)

    local topLeftPos = ToyboxMod:gridIndexToPositionVector(renderRoom.GridIndex)
    local relativePos = floorVector((ROOM_GRID_SIZE_BIG-Vector(1,1))*(topLeftPos-Vector(bounds.Left, bounds.Up)))

    local shape = RoomShape.ROOMSHAPE_1x1
    if(renderRoom.Data and renderRoom.Data.Subtype~=BossType.DELIRIUM) then
        shape = renderRoom.Data.Shape
    end

    runcallback(true, renderRoom.SafeGridIndex, mapCornerPos+relativePos, ROOM_GRID_SIZE_BIG*ToyboxMod.ROOM_DIMENSIONS[shape], colormod, nil, nil, nil)
end

local function mapRenderAuras()
    local level = Game():GetLevel()
    if(level:GetCurses() & LevelCurse.CURSE_OF_THE_LOST == LevelCurse.CURSE_OF_THE_LOST) then return end

    if(MinimapAPI) then
        
    else
        local curRoom = level:GetCurrentRoomDesc()
        local currentIdx = curRoom.GridIndex
        if(curRoom.GridIndex<0) then return end

        local roomPos = Vector(currentIdx%13, currentIdx//13)
        local roomSize = ToyboxMod.ROOM_DIMENSIONS[(curRoom.Data and curRoom.Data.Shape or 1)]
        if(curRoom.Data and curRoom.Data.Subtype==BossType.DELIRIUM) then roomSize = ToyboxMod.ROOM_DIMENSIONS[RoomShape.ROOMSHAPE_1x1] end

        if(normalMapOpacity>0) then
            for x=math.max(roomPos.X-4, 0), math.min(roomPos.X+4, 12) do
                for y=math.max(roomPos.Y-4, 0), math.min(roomPos.Y+4, 12) do
                    local idx = x+y*13
                    local roomToRender = level:GetRoomByIdx(idx)
                    if(roomToRender.SafeGridIndex==idx) then
                        tryRenderAuraAtLevelIdxSmall(roomToRender, roomPos, roomSize, normalMapOpacity)
                    end
                end
            end
        end
        if(expandedMapOpacity>0) then
            local mapbounds = {Left=12, Right=0, Up=12, Down=0}
            for x=0,12 do
                for y=0,12 do
                    local room = level:GetRoomByIdx(x+y*13)
                    if(room.Data and room.DisplayFlags~=RoomDescriptor.DISPLAY_NONE) then
                        mapbounds.Left = math.min(x, mapbounds.Left)
                        mapbounds.Right = math.max(x, mapbounds.Right)

                        mapbounds.Up = math.min(y, mapbounds.Up)
                        mapbounds.Down = math.max(y, mapbounds.Down)
                    end
                end
            end

            for x=mapbounds.Left, mapbounds.Right do
                for y=mapbounds.Up, mapbounds.Down do
                    local idx = x+y*13
                    local roomToRender = level:GetRoomByIdx(idx)
                    if(roomToRender.SafeGridIndex==idx) then
                        tryRenderAuraAtLevelIdxBig(roomToRender, mapbounds, expandedMapOpacity)
                    end
                end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_MINIMAP_RENDER, mapRenderAuras)
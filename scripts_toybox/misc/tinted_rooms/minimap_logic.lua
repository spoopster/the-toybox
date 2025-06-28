
-- TODO: MinimAPI bands rendering support?? one day

local MINIMAP_SPRITE = Sprite("gfx_tb/ui/ui_tinted_room.anm2", true)

local TINT_ALPHA = 0.2
local TINT_INTENSITY = 1
local TINT_CENTER_INTENSITY = 1--2

local SMALL_MINIMAP_SIZE = Vector(49,43)

local ROOM_GRID_SIZE = Vector(9,8)
local ROOM_GRID_SIZE_BIG = Vector(18,16)

local function floorVector(vec)
    return Vector(math.floor(vec.X), math.floor(vec.Y))
end
local function maxVectorComponents(vec, num)
    return Vector(math.max(vec.X, num), math.max(vec.Y, num))
end

local function getCompositeResult(tintBuffer, tintData)
    local finalColor = Color(0,0,0,TINT_ALPHA)
    for i, flag in ipairs(tintBuffer) do
        local tempColor = ToyboxMod.TINTED_ROOM_COLOR_BITWISE[flag]

        local int = (tintData.Centers & flag ~= 0) and TINT_CENTER_INTENSITY or TINT_INTENSITY
        local col = Color(tempColor.Red*int, tempColor.Green*int, tempColor.Blue*int, tempColor.Alpha*TINT_ALPHA)

        finalColor = Color(
            (col.R*col.A+finalColor.R*finalColor.A*(1-col.A))/(col.A+finalColor.A*(1-col.A)),
            (col.G*col.A+finalColor.G*finalColor.A*(1-col.A))/(col.A+finalColor.A*(1-col.A)),
            (col.B*col.A+finalColor.B*finalColor.A*(1-col.A))/(col.A+finalColor.A*(1-col.A)),
            TINT_ALPHA
        )
    end
    return finalColor
end

local function tryRenderAuraAtLevelIdxSmall(renderRoom, tintData, centerPos, centerSize)
    if(renderRoom.DisplayFlags & (RoomDescriptor.DISPLAY_BOX | RoomDescriptor.DISPLAY_ICON) == RoomDescriptor.DISPLAY_NONE) then return end

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

    local anim = (ToyboxMod.CONFIG.TINTED_ROOM_DISPLAY_TYPE & ToyboxMod.TINTED_ROOM_DISPLAY.GRADIENT_FLAG ~= 0) and "RoomsSmallGradient" or "RoomsSmall"
    MINIMAP_SPRITE:SetFrame(anim, shape-1)

    local numTints = 0
    local tintsToRender = {}

    for flag, _ in pairs(ToyboxMod.TINTED_ROOM_COLOR_BITWISE) do
        if(tintData.Tints & flag ~= 0) then
            numTints = numTints+1
            table.insert(tintsToRender, flag)
        end
    end

    if(ToyboxMod.CONFIG.TINTED_ROOM_DISPLAY_TYPE & ToyboxMod.TINTED_ROOM_DISPLAY.COMPOSITE_FLAG ~= 0) then
        MINIMAP_SPRITE.Color = getCompositeResult(tintsToRender, tintData)
        MINIMAP_SPRITE:Render(mapCornerPos+relativePos, topLeftClamp, bottomRightClamp)
    else
        for i, flag in ipairs(tintsToRender) do
            local colorInt = (tintData.Centers & flag ~= 0) and TINT_CENTER_INTENSITY or TINT_INTENSITY

            local baseColor = ToyboxMod.TINTED_ROOM_COLOR_BITWISE[flag]
            local finalColor = Color(baseColor.Red*colorInt, baseColor.Green*colorInt, baseColor.Blue*colorInt, baseColor.Alpha*TINT_ALPHA)

            local leftColorClamp = Vector(math.ceil(roomSize.X*(i-1)/numTints),0)
            local rightColorClamp = Vector(math.floor(roomSize.X*(numTints-i)/numTints),0)

            local finalTopLeftClamp = Vector(math.max(leftColorClamp.X, topLeftClamp.X), topLeftClamp.Y)
            local finalBottomRightClamp = Vector(math.max(rightColorClamp.X, bottomRightClamp.X), bottomRightClamp.Y)

            MINIMAP_SPRITE.Color = finalColor
            MINIMAP_SPRITE:Render(mapCornerPos+relativePos, finalTopLeftClamp, finalBottomRightClamp)
        end
    end
end

local function tryRenderAuraAtLevelIdxBig(renderRoom, tintData, bounds)
    if(renderRoom.DisplayFlags & (RoomDescriptor.DISPLAY_BOX | RoomDescriptor.DISPLAY_ICON) == RoomDescriptor.DISPLAY_NONE) then return end

    local mapCornerPos = Vector(Isaac.GetScreenWidth(), 0)+Vector(-24,12)*Options.HUDOffset+Vector(-1,0)*Minimap.GetDisplayedSize()+Vector(0,2)

    local topLeftPos = ToyboxMod:gridIndexToPositionVector(renderRoom.GridIndex)
    local relativePos = floorVector((ROOM_GRID_SIZE_BIG-Vector(1,1))*(topLeftPos-Vector(bounds.Left, bounds.Up)))

    local shape = RoomShape.ROOMSHAPE_1x1
    if(renderRoom.Data and renderRoom.Data.Subtype~=BossType.DELIRIUM) then
        shape = renderRoom.Data.Shape
    end

    local anim = (ToyboxMod.CONFIG.TINTED_ROOM_DISPLAY_TYPE & ToyboxMod.TINTED_ROOM_DISPLAY.GRADIENT_FLAG ~= 0) and "RoomsBigGradient" or "RoomsBig"
    MINIMAP_SPRITE:SetFrame(anim, shape-1)

    local roomWidth = ROOM_GRID_SIZE_BIG.X*ToyboxMod.ROOM_DIMENSIONS[shape].X

    local numTints = 0
    local tintsToRender = {}

    for flag, _ in pairs(ToyboxMod.TINTED_ROOM_COLOR_BITWISE) do
        if(tintData.Tints & flag ~= 0) then
            numTints = numTints+1
            table.insert(tintsToRender, flag)
        end
    end

    if(ToyboxMod.CONFIG.TINTED_ROOM_DISPLAY_TYPE & ToyboxMod.TINTED_ROOM_DISPLAY.COMPOSITE_FLAG ~= 0) then
        MINIMAP_SPRITE.Color = getCompositeResult(tintsToRender, tintData)
        MINIMAP_SPRITE:Render(mapCornerPos+relativePos, topLeftClamp, bottomRightClamp)
    else
        for i, flag in ipairs(tintsToRender) do
            local colorInt = (tintData.Centers & flag ~= 0) and TINT_CENTER_INTENSITY or TINT_INTENSITY

            local baseColor = ToyboxMod.TINTED_ROOM_COLOR_BITWISE[flag]
            local finalColor = Color(baseColor.Red*colorInt, baseColor.Green*colorInt, baseColor.Blue*colorInt, baseColor.Alpha*TINT_ALPHA)

            local leftColorClamp = Vector(math.ceil(roomWidth*(i-1)/numTints),0)
            local rightColorClamp = Vector(math.floor(roomWidth*(numTints-i)/numTints),0)

            MINIMAP_SPRITE.Color = finalColor
            MINIMAP_SPRITE:Render(mapCornerPos+relativePos, leftColorClamp, rightColorClamp)
        end
    end
end

local function mapRenderAuras()
    local level = Game():GetLevel()
    if(level:GetCurses() & LevelCurse.CURSE_OF_THE_LOST == LevelCurse.CURSE_OF_THE_LOST) then return end

    if(MinimapAPI) then
        local data = ToyboxMod:getExtraDataTable()
        data.TINTED_ROOM_POSITIONS = data.TINTED_ROOM_POSITIONS or {}

        for x=0, 12 do
            for y=0, 12 do
                local idx = x+y*13
                if(data.TINTED_ROOM_POSITIONS[idx]) then
                    local tintData = data.TINTED_ROOM_POSITIONS[idx]
                    
                    local numTints = 0
                    local tintsToRender = {}

                    for flag, _ in pairs(ToyboxMod.TINTED_ROOM_COLOR_BITWISE) do
                        if(tintData.Tints & flag ~= 0) then
                            numTints = numTints+1
                            table.insert(tintsToRender, flag)
                        end
                    end

                    --if(ToyboxMod.CONFIG.TINTED_ROOM_DISPLAY_TYPE & ToyboxMod.TINTED_ROOM_DISPLAY.COMPOSITE_FLAG ~= 0) then
                        MinimapAPI:GetRoomByIdx(idx).Color = getCompositeResult(tintsToRender, tintData)
                    --else
                        -- TODO!
                    --end
                end
            end
        end
    else
        local curRoom = level:GetCurrentRoomDesc()
        local currentIdx = curRoom.GridIndex
        if(curRoom.GridIndex<0) then return end

        local roomPos = Vector(currentIdx%13, currentIdx//13)
        local roomSize = ToyboxMod.ROOM_DIMENSIONS[(curRoom.Data and curRoom.Data.Shape or 1)]
        if(curRoom.Data and curRoom.Data.Subtype==BossType.DELIRIUM) then roomSize = ToyboxMod.ROOM_DIMENSIONS[RoomShape.ROOMSHAPE_1x1] end

        local data = ToyboxMod:getExtraDataTable()
        data.TINTED_ROOM_POSITIONS = data.TINTED_ROOM_POSITIONS or {}
        
        if(Minimap.GetState()==MinimapState.NORMAL) then
            for x=math.max(roomPos.X-4, 0), math.min(roomPos.X+4, 12) do
                for y=math.max(roomPos.Y-4, 0), math.min(roomPos.Y+4, 12) do
                    local idx = x+y*13
                    local roomToRender = level:GetRoomByIdx(idx)
                    if(data.TINTED_ROOM_POSITIONS[idx]) then
                        tryRenderAuraAtLevelIdxSmall(roomToRender, data.TINTED_ROOM_POSITIONS[idx], roomPos, roomSize)
                    end
                end
            end
        elseif(Minimap.GetState()==MinimapState.EXPANDED) then
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
                    if(data.TINTED_ROOM_POSITIONS[idx]) then
                        tryRenderAuraAtLevelIdxBig(roomToRender, data.TINTED_ROOM_POSITIONS[idx], mapbounds)
                    end
                end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_MINIMAP_RENDER, mapRenderAuras)
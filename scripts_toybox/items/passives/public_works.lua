local mod = ToyboxMod

--local AURA_SPRITE = Sprite("gfx/ui/tb_ui_public_works.anm2", true)
local AURA_SPRITE_SMALL = Sprite("gfx/ui/minimap1.anm2", true)
local AURA_SPRITE_BIG = Sprite("gfx/ui/minimap2.anm2", true)

local auraalpha = 0.25

local auraEffects = {
    RED = 1<<0,
    BLUE = 1<<1,
    GREEN = 1<<2,
    YELLOW = 1<<3,
    PURPLE = 1<<4,
}

local auraColors = {
    [auraEffects.RED] = KColor(1,0,0,1),
    [auraEffects.BLUE] = KColor(0,0,1,1),
    [auraEffects.GREEN] = KColor(0,1,0,1),
    [auraEffects.YELLOW] = KColor(1,1,0,1),
    [auraEffects.PURPLE] = KColor(1,0,1,1),
}

local auraPositions = {
    {Vector(6,8), auraEffects.BLUE},
    {Vector(6,6), auraEffects.GREEN},
    {Vector(9,6), auraEffects.YELLOW},
    {Vector(2,10), auraEffects.PURPLE},
}

local aurasize = 1

local aurabuffer = {}

local roomGridSize = Vector(9,8)
local roomGridSizeBig = Vector(18,16)

local minimapSize = Vector(49,43)

local roomSizes = {
    [RoomShape.ROOMSHAPE_1x1] = Vector(1,1),
    [RoomShape.ROOMSHAPE_IH] = Vector(1,1),
    [RoomShape.ROOMSHAPE_IV] = Vector(1,1),
    [RoomShape.ROOMSHAPE_1x2] = Vector(1,2),
    [RoomShape.ROOMSHAPE_IIV] = Vector(1,2),
    [RoomShape.ROOMSHAPE_2x1] = Vector(2,1),
    [RoomShape.ROOMSHAPE_IIH] = Vector(2,1),
    [RoomShape.ROOMSHAPE_2x2] = Vector(2,2),
    [RoomShape.ROOMSHAPE_LTL] = Vector(2,2),
    [RoomShape.ROOMSHAPE_LTR] = Vector(2,2),
    [RoomShape.ROOMSHAPE_LBL] = Vector(2,2),
    [RoomShape.ROOMSHAPE_LBR] = Vector(2,2),
}

local function mapUpdateBuffer()
    aurabuffer = {}

    local level = Game():GetLevel()

    for _, data in ipairs(auraPositions) do
        local x,y = data[1].X, data[1].Y

        local idx = x+y*13
        local room = level:GetRoomByIdx(idx)
        if(room.Data and room.SafeGridIndex>=0) then
            local roomPos = Vector(room.SafeGridIndex%13, room.SafeGridIndex//13)
            local roomSize = roomSizes[(room.Data and room.Data.Shape or 1)]

            local alreadyPartOfAura = {}
            for rx=roomPos.X, roomPos.X+roomSize.X-1 do
                for ry=roomPos.Y, roomPos.Y+roomSize.Y-1 do
                    if(level:GetRoomByIdx(rx+ry*13).SafeGridIndex==room.SafeGridIndex) then
                        for ax=-aurasize, aurasize do
                            for ay=-aurasize, aurasize do
                                local dx = rx+ax
                                local dy = ry+ay
                                local newidx = level:GetRoomByIdx(dx+dy*13).SafeGridIndex
                                if(not alreadyPartOfAura[newidx]) then
                                    alreadyPartOfAura[newidx] = true
                                    
                                    aurabuffer[newidx] = aurabuffer[newidx] or {}
                                    table.insert(aurabuffer[newidx], {data[2], (ax==0 and ay==0) and true or false})
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_MINIMAP_UPDATE, mapUpdateBuffer)

local function tryRenderAuraAtLevelIdxSmall(idx, centerPos, centerSize)
    if(not aurabuffer[idx]) then return end

    local renderedRoom = Game():GetLevel():GetRoomByIdx(idx)
    if(renderedRoom.DisplayFlags & (RoomDescriptor.DISPLAY_BOX | RoomDescriptor.DISPLAY_ICON) == RoomDescriptor.DISPLAY_NONE) then return end

    local safeIdxToPos = Vector(renderedRoom.SafeGridIndex%13, renderedRoom.SafeGridIndex//13)
    local idxToPos = Vector(renderedRoom.GridIndex%13, renderedRoom.GridIndex//13)
    local roomShape = (renderedRoom.Data and renderedRoom.Data.Shape or RoomShape.ROOMSHAPE_1x1)
    local roomSize = roomSizes[roomShape]

    

    local maxDist = Vector(4,4)-centerSize
    local reducedSize = centerSize-Vector(1,1)

    local isInBoundsX = (centerPos.X-maxDist.X<=idxToPos.X) and (centerPos.X+reducedSize.X+maxDist.X>=idxToPos.X)
    local isInBoundsY = (centerPos.Y-maxDist.Y<=idxToPos.Y) and (centerPos.Y+reducedSize.Y+maxDist.Y>=idxToPos.Y)

    if(not (isInBoundsX and isInBoundsY)) then return end

    local topLeftMapCorner = Vector(Isaac.GetScreenWidth(), 0)+Vector(-24,12)*Options.HUDOffset+Vector(-7,6)+Vector(-47,0)

    local render
    local clamp1, clamp2

    local relCenterPos = Vector(3,3)-centerSize*0.5
    local relativePos = (roomGridSize-Vector(1,1))*(relCenterPos+idxToPos-centerPos)
    relativePos.X = math.floor(relativePos.X)
    relativePos.Y = math.floor(relativePos.Y)

    if(relativePos.X<0 or relativePos.Y<0) then
        clamp1 = Vector(math.max(0, -relativePos.X), math.max(0, -relativePos.Y))
    end
    if(relativePos.X+roomGridSize.X*roomSize.X>minimapSize.X or relativePos.Y+roomGridSize.Y*roomSize.Y>minimapSize.Y) then
        local overflow = relativePos+roomGridSize*roomSize-minimapSize

        clamp2 = Vector(math.max(0, overflow.X), math.max(0, overflow.Y))
    end

    render = relativePos+topLeftMapCorner+Vector(-2,-2)

    local anim = (safeIdxToPos.X==centerPos.X and safeIdxToPos.Y==centerPos.Y) and "RoomCurrent" or "RoomVisited"
    AURA_SPRITE_SMALL:SetFrame(anim, roomShape-1)

    for _, auraIdx in ipairs(aurabuffer[idx]) do
        local auraColor = auraColors[auraIdx[1]]

        local finalColor = Color(auraColor.Red, auraColor.Green, auraColor.Blue,auraColor.Alpha*auraalpha)
        if(auraIdx[2]) then
            finalColor.R = finalColor.R*2
            finalColor.G = finalColor.G*2
            finalColor.B = finalColor.B*2
        end

        AURA_SPRITE_SMALL.Color = finalColor
        AURA_SPRITE_SMALL:Render(render, clamp1, clamp2)
    end
end

local function tryRenderAuraAtLevelIdxBig(idx, centerPos, bounds)
    if(not aurabuffer[idx]) then return end

    local renderedRoom = Game():GetLevel():GetRoomByIdx(idx)
    if(renderedRoom.DisplayFlags & (RoomDescriptor.DISPLAY_BOX | RoomDescriptor.DISPLAY_ICON) == RoomDescriptor.DISPLAY_NONE) then return end

    local safeIdxToPos = Vector(renderedRoom.SafeGridIndex%13, renderedRoom.SafeGridIndex//13)
    local idxToPos = Vector(renderedRoom.GridIndex%13, renderedRoom.GridIndex//13)
    local roomShape = (renderedRoom.Data and renderedRoom.Data.Shape or RoomShape.ROOMSHAPE_1x1)

    local topLeftMapCorner = Vector(Isaac.GetScreenWidth(), 0)+Vector(-24,12)*Options.HUDOffset+Vector(-1,0)*Minimap.GetDisplayedSize()

    local render
    local relativePos = (roomGridSizeBig-Vector(1,1))*(idxToPos-Vector(bounds.Left, bounds.Up))
    relativePos.X = math.floor(relativePos.X)
    relativePos.Y = math.floor(relativePos.Y)

    render = relativePos+topLeftMapCorner+Vector(0,2)

    local anim = (safeIdxToPos.X==centerPos.X and safeIdxToPos.Y==centerPos.Y) and "RoomCurrent" or "RoomVisited"
    AURA_SPRITE_BIG:SetFrame(anim, roomShape-1)

    for _, auraIdx in ipairs(aurabuffer[idx]) do
        local auraColor = auraColors[auraIdx[1]]

        local finalColor = Color(auraColor.Red, auraColor.Green, auraColor.Blue,auraColor.Alpha*auraalpha)
        if(auraIdx[2]) then
            finalColor.R = finalColor.R*2
            finalColor.G = finalColor.G*2
            finalColor.B = finalColor.B*2
        end

        AURA_SPRITE_BIG.Color = finalColor
        AURA_SPRITE_BIG:Render(render)
    end
end

local function mapRenderAuras()
    local level = Game():GetLevel()
    if(level:GetCurses() & LevelCurse.CURSE_OF_THE_LOST == LevelCurse.CURSE_OF_THE_LOST) then return end

    

    if(MinimapAPI) then
        for x=0, 12 do
            for y=0, 12 do
                local idx = x+y*13

                if(aurabuffer[idx]) then
                    local finalColor = Color(1,1,1, 1)

                    for i=1, #aurabuffer[idx] do
                        local otherkCol = auraColors[aurabuffer[idx][i][1]]
                        local otherColor = Color(otherkCol.Red,otherkCol.Green,otherkCol.Blue,1)
                        local alpha = otherkCol.Alpha*auraalpha ---@type number

                        local colorMult = 1
                        if(aurabuffer[idx][i][2]) then
                            colorMult = 2
                        end

                        finalColor = Color(
                                        otherColor.R*alpha*colorMult+finalColor.R*(1-alpha),
                                        otherColor.G*alpha*colorMult+finalColor.G*(1-alpha),
                                        otherColor.B*alpha*colorMult+finalColor.B*(1-alpha)
                                    )
                    end

                    MinimapAPI:GetRoomByIdx(idx).Color = finalColor
                end
            end
        end
    else
        local curRoom = level:GetCurrentRoomDesc()
        local currentIdx = curRoom.GridIndex
        if(curRoom.GridIndex<0) then return end

        local roomPos = Vector(currentIdx%13, currentIdx//13)
        local roomSize = roomSizes[(curRoom.Data and curRoom.Data.Shape or 1)]
        
        if(Minimap.GetState()==MinimapState.NORMAL) then
            for x=-4, 4 do
                for y=-4, 4 do
                    local dx = roomPos.X+x
                    local dy = roomPos.Y+y

                    if(dx>=0 and dx<13 and dy>=0 and dy<13) then
                        local idx = dx+dy*13
                        tryRenderAuraAtLevelIdxSmall(idx, roomPos, roomSize)
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
                        mapbounds.Up = math.min(y, mapbounds.Up)
                    end
                end
            end

            for x=0, 12 do
                for y=0, 12 do
                    local idx = x+y*13
                    tryRenderAuraAtLevelIdxBig(idx, roomPos, mapbounds)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_MINIMAP_RENDER, mapRenderAuras)
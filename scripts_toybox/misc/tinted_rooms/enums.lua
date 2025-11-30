

ToyboxMod.TINTED_ROOM = {
    RED = 1<<0,
    BLUE = 1<<1,
    GREEN = 1<<2,
    YELLOW = 1<<3,
    PURPLE = 1<<4,
    CYAN = 1<<5,
    WHITE = 1<<6,
    BLACK = 1<<7,
    
    BROWN = 1<<8,
    PINK = 1<<9,
}

ToyboxMod.TINTED_ROOM_COLOR = {
    RED = KColor(1,0,0,1),
    BLUE = KColor(0,0,1,1),
    GREEN = KColor(0,1,0,1),
    YELLOW = KColor(1,1,0,1),
    PURPLE = KColor(1,0,1,1),
    CYAN = KColor(0,1,1,1),
    WHITE = KColor(1,1,1,1),
    BLACK = KColor(0,0,0,1),
    
    BROWN = KColor(150/255,75/255,0,1),
    PINK = KColor(1,0.5,0.5,1),
}
ToyboxMod.TINTED_ROOM_COLOR_BITWISE = {}
for key, val in pairs(ToyboxMod.TINTED_ROOM_COLOR) do
    ToyboxMod.TINTED_ROOM_COLOR_BITWISE[ToyboxMod.TINTED_ROOM[key]] = val
end

ToyboxMod.ROOM_DIMENSIONS = {
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

ToyboxMod.TINTED_ROOM_DISPLAY = {
    BANDS = 0,
    COMPOSITE = 1,
    BANDS_GRADIENT = 2,
    COMPOSITE_GRADIENT = 3,

    COMPOSITE_FLAG = 1<<0,
    GRADIENT_FLAG = 1<<1,
}

---@param pos Vector
---@return integer
function ToyboxMod:positionVectorToGridIndex(pos)
    if(pos.X<0 or pos.X>=13 or pos.Y<0 or pos.Y>=13) then return -1 end
    return pos.X+pos.Y*13
end
---@param idx integer
---@return Vector
function ToyboxMod:gridIndexToPositionVector(idx)
    return Vector(idx%13, idx//13)
end
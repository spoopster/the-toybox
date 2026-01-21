if(not MinimapAPI) then return end

local TINT_ALPHA = 0.2
local TINT_INTENSITY = 1
local TINT_CENTER_INTENSITY = 1--2

local normalMapOpacity = 1
local expandedMapOpacity = 0
local mapHeldTime = 0
local keepMapExpanded = 0

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

        if(keepMapExpanded) then
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

local function renderTint(sprite, width, pos, TLclamp, BRclamp, tintData, colormod)
    local numTints = 0
    local tintsToRender = {}

    for flag, _ in pairs(ToyboxMod.TINTED_ROOM_COLOR_BITWISE) do
        if(tintData.Tints & flag ~= 0) then
            numTints = numTints+1
            table.insert(tintsToRender, flag)
        end
    end

    local lv = Game():GetLevel()
    local ismirror = (lv:GetDimension()==Dimension.MIRROR and lv:HasMirrorDimension())

    if(ToyboxMod.CONFIG.TINTED_ROOM_DISPLAY_TYPE & ToyboxMod.TINTED_ROOM_DISPLAY.COMPOSITE_FLAG ~= 0) then
        sprite.Color = ToyboxMod:getTintedRoomCompositeColor(tintsToRender, tintData)
        sprite:Render(pos, topLeftClamp, bottomRightClamp)
    else
        for i, flag in ipairs(tintsToRender) do
            local colorInt = (tintData.Centers & flag ~= 0) and TINT_CENTER_INTENSITY or TINT_INTENSITY

            local rpos = pos

            local baseColor = ToyboxMod.TINTED_ROOM_COLOR_BITWISE[flag]
            local finalColor = Color(baseColor.Red*colorInt, baseColor.Green*colorInt, baseColor.Blue*colorInt, baseColor.Alpha*TINT_ALPHA)
            
            local leftColorClamp = Vector(width*(i-1)/numTints,0)
            local rightColorClamp = Vector(width*(numTints-i)/numTints,0)

            leftColorClamp.X = math.ceil(leftColorClamp.X)
            rightColorClamp.X = math.floor(rightColorClamp.X)

            if(ismirror) then
                local dif = math.ceil(  (i-1-(numTints-i))/numTints*width )
                leftColorClamp.X = leftColorClamp.X-dif
                rightColorClamp.X = rightColorClamp.X+dif

                rpos = rpos+Vector(dif,0)
            end

            if(TLclamp) then
                leftColorClamp = Vector(math.max(leftColorClamp.X, TLclamp.X), TLclamp.Y)
            end
            if(BRclamp) then
                rightColorClamp = Vector(math.max(rightColorClamp.X, BRclamp.X), BRclamp.Y)
            end


            sprite.Color = finalColor*(colormod or Color.Default)
            sprite:Render(rpos, leftColorClamp, rightColorClamp)
        end
    end
end

local ogfunc = MinimapAPI.GetConfig
MinimapAPI.GetConfig = function(self, option)
    if(option=="ShowIcons") then
        local roomAnimPivot = Vector(-2, -2)
        local roomPixelSize = Vector(9, 8)
        local outlinePixelSize = Vector(16, 16)
        local largeRoomSize = Vector(17, 15)

        local data = ToyboxMod:getExtraDataTable()
        data.TINTED_ROOM_POSITIONS = data.TINTED_ROOM_POSITIONS or {}

        local size
        MinimapAPI.SpriteMinimapSmall.Scale = Vector(1, 1)
        if MinimapAPI:IsLarge() then -- big unbound map
            size = "huge"
        elseif ogfunc(self, "DisplayMode") == 1 then -- small unbound map
            size = "small"
        elseif ogfunc(self, "DisplayMode") == 2 then -- Bounded map
            if MinimapAPI.GlobalScaleX < 1 then
                size = "small"
            else
                size = "bounded"
            end
        elseif ogfunc(self, "DisplayMode") == 4 then -- hidden map
            size = "hide"
        end

        if(size=="hide") then return ogfunc(self, option)
        elseif(size=="bounded") then
            local screen_size = MinimapAPI:GetScreenTopRight()
            local offsetVec = Vector( screen_size.X - ogfunc(self, "MapFrameWidth") - ogfunc(self, "PositionX") + outlinePixelSize.X, screen_size.Y + ogfunc(self, "PositionY") - outlinePixelSize.Y/2 - 2)

            for _, room in pairs(MinimapAPI:GetLevel()) do
                if(room.Descriptor and data.TINTED_ROOM_POSITIONS[tostring(room.Descriptor.SafeGridIndex)]) then
                    local iscurrent = MinimapAPI:PlayerInRoom(room)
                    local spr = MinimapAPI.SpriteMinimapSmall
                    if room:IsVisible() then
                        local frame = MinimapAPI:GetRoomShapeFrame(room.Shape)
                        local anim
                        if iscurrent then
                            anim = "RoomCurrent"
                        elseif room:IsClear() then
                            anim = "RoomVisited"
                        elseif ogfunc(self, "DisplayExploredRooms") and room:IsVisited() then
                            spr = MinimapAPI.SpriteMinimapCustomSmall
                            anim = "RoomSemivisited"
                        else
                            anim = "RoomUnvisited"
                        end
                        if type(frame) == "table" then
                            local fr0 = frame.small
                            local fr1 = fr0[anim] or fr0["RoomUnvisited"]
                            spr = fr1.sprite or spr
                            updateMinimapIcon(spr, fr1)
                        else
                            spr:SetFrame(anim, frame)
                        end
                        local rms = MinimapAPI:GetRoomShapeGridSize(room.Shape)
                        local rsgp = MinimapAPI.RoomShapeGridPivots[room.Shape]
                        local roomPivotOffset = Vector((roomPixelSize.X - 1) * rsgp.X, (roomPixelSize.Y - 1) * rsgp.Y)
                        local roomPixelBR = Vector(roomPixelSize.X * rms.X, roomPixelSize.Y * rms.Y) - roomAnimPivot
                        local brcutoff = room.RenderOffset - offsetVec + roomPixelBR - MinimapAPI:GetFrameBR() - roomPivotOffset
                        local tlcutoff = -(room.RenderOffset - offsetVec - roomPivotOffset)
                        if brcutoff.X < roomPixelBR.X and brcutoff.Y < roomPixelBR.Y and
                            tlcutoff.X - roomPivotOffset.X < roomPixelBR.X and tlcutoff.Y - roomPivotOffset.Y < roomPixelBR.Y then
                            brcutoff:Clamp(0, 0, roomPixelBR.X, roomPixelBR.Y)
                            tlcutoff:Clamp(0, 0, roomPixelBR.X, roomPixelBR.Y)
                            spr.Scale = Vector(MinimapAPI.GlobalScaleX, 1)
                            
                            local tintdata = data.TINTED_ROOM_POSITIONS[tostring(room.Descriptor.SafeGridIndex)]

                            local ogcol = spr.Color
                            spr.Color = Color.Default
                            renderTint(spr, roomPixelSize.X * rms.X, room.RenderOffset, tlcutoff, brcutoff, tintdata, Color(255,255,255,0.012))
                            spr.Color = ogcol
                        end
                    end
                end
            end
            MinimapAPI.SpriteMinimapSmall.Color = Color(1, 1, 1, ogfunc(self, "MinimapTransparency"), 0, 0, 0)
        else
            local sprite = size == "small" and MinimapAPI.SpriteMinimapSmall or MinimapAPI.SpriteMinimapLarge
            sprite.Scale = Vector(MinimapAPI.GlobalScaleX, 1)

            for _, room in pairs(MinimapAPI:GetLevel()) do
                if(room.Descriptor and data.TINTED_ROOM_POSITIONS[tostring(room.Descriptor.SafeGridIndex)]) then
                    local iscurrent = MinimapAPI:PlayerInRoom(room)
                    if room:IsVisible() then
                        local frame = MinimapAPI:GetRoomShapeFrame(room.Shape)
                        local anim
                        local spr = sprite
                        if iscurrent then
                            anim = "RoomCurrent"
                        elseif room:IsClear() then
                            anim = "RoomVisited"
                        elseif ogfunc(self, "DisplayExploredRooms") and room:IsVisited() then
                            spr = size == "small" and MinimapAPI.SpriteMinimapCustomSmall or MinimapAPI.SpriteMinimapCustomLarge
                            anim = "RoomSemivisited"
                        else
                            anim = "RoomUnvisited"
                        end
                        spr.Scale = Vector(MinimapAPI.GlobalScaleX, 1)
                        if ogfunc(self, "VanillaSecretRoomDisplay") and (room.PermanentIcons[1] == "SecretRoom" or room.PermanentIcons[1] == "SuperSecretRoom") and anim == "RoomUnvisited" then
                            -- whatever
                        elseif type(frame) == "table" then
                            local fr0 = frame[size == "small" and "small" or "large"]
                            local fr1 = fr0[anim] or fr0["RoomUnvisited"]
                            spr = fr1.sprite or sprite
                            updateMinimapIcon(spr, fr1)
                        else
                            spr:SetFrame(anim, frame)
                        end

                        local width = (largeRoomSize.X+1) * MinimapAPI:GetRoomShapeGridSize(room.Shape).X
                        if(size=="small") then
                            width = roomPixelSize.X * MinimapAPI:GetRoomShapeGridSize(room.Shape).X
                        end

                        local tintdata = data.TINTED_ROOM_POSITIONS[tostring(room.Descriptor.SafeGridIndex)]

                        local ogcol = spr.Color
                        spr.Color = Color.Default
                        renderTint(spr, width, room.RenderOffset, nil, nil, tintdata, Color(255,255,255,0.012))
                        spr.Color = ogcol
                    end
                end
            end
        end
    end
    return ogfunc(self, option)
end
ToyboxMod.CUSTOM_ICONS = {}

function ToyboxMod:addCustomRoomIcon(icon, condition, additive)
    table.insert(ToyboxMod.CUSTOM_ICONS, {Icon=icon,Condition=condition, Additive=additive})
end

if(MinimapAPI) then
    local function replaceIcon(_)
        for _, v in ipairs(MinimapAPI:GetLevel()) do
            if(not v.ToyboxCustomIconsDone) then
                v.ToyboxCustomIconsDone = true

                local ogFunc = v.UpdateType
                function v:UpdateType()
                    ogFunc(self)

                    for _, data in ipairs(ToyboxMod.CUSTOM_ICONS) do
                        if(data.Condition(self)) then
                            if(data.Additive) then
                                table.insert(self.PermanentIcons, data.Icon)
                            else
                                self.PermanentIcons = { data.Icon }
                            end
                        end
                    end
                end
            end

            for _, data in ipairs(ToyboxMod.CUSTOM_ICONS) do
                if(data.Condition(v)) then
                    if(data.Additive) then
                        local shouldadd = true
                        for _, val in ipairs(v.PermanentIcons) do
                            if(val==data.Icon) then
                                shouldadd = false
                                break
                            end
                        end
                        if(shouldadd) then
                            table.insert(v.PermanentIcons, data.Icon)
                        end
                    else
                        v.PermanentIcons = { data.Icon }
                    end
                elseif(data.Additive) then
                    for i, val in ipairs(v.PermanentIcons) do
                        if(val==data.Icon) then
                            table.remove(v.PermanentIcons, i)
                            break
                        end
                    end
                end
            end
        end
    end
    ToyboxMod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, replaceIcon)
end
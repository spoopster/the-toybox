ToyboxMod.CUSTOM_ICONS = {}

function ToyboxMod:addCustomRoomIcon(icon, condition)
    table.insert(ToyboxMod.CUSTOM_ICONS, {Icon=icon,Condition=condition})
end

if(MinimapAPI) then
    local function replaceIcon(_)
        for _,v in ipairs(MinimapAPI:GetLevel()) do
            if(not v.ToyboxCustomIconsDone) then
                v.ToyboxCustomIconsDone = true

                local ogFunc = v.UpdateType
                function v:UpdateType()
                    ogFunc(self)

                    for _, data in ipairs(ToyboxMod.CUSTOM_ICONS) do
                        if(data.Condition(self)) then
                            self.PermanentIcons = { data.Icon }
                        end
                    end
                end

                for _, data in ipairs(ToyboxMod.CUSTOM_ICONS) do
                    if(data.Condition(v)) then
                        v.PermanentIcons = { data.Icon }
                    end
                end
            end
        end
    end
    ToyboxMod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, replaceIcon)
end
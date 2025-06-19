

-- i hate it here

ToyboxMod.CHAPI_DAMAGE_CALLBACKS = {}

function ToyboxMod:addChapiDamageCallback(func, priority)
    table.insert(ToyboxMod.CHAPI_DAMAGE_CALLBACKS, {Function=func, Priority=(priority or 0)})

    table.sort(ToyboxMod.CHAPI_DAMAGE_CALLBACKS, function(a,b) return a.Priority<=b.Priority end)
end

if(CustomHealthAPI) then
    local function applyCHAPIDamage(_, player, dmg, flags, source, frames)
        player = player:ToPlayer()
        local data = ToyboxMod:getEntityDataTable(player)

        if(data.CANCEL_CHAPI_DMG==nil) then return end

        local dmg1 = dmg
        local flags1 = flags
        local frames1 = frames

        if(data.CANCEL_CHAPI_DMG==true) then
            data.CANCEL_CHAPI_DMG = false

            for _, d in ipairs(ToyboxMod.CHAPI_DAMAGE_CALLBACKS) do
                local r = d.Function(ToyboxMod, player, dmg1, flags1, source, frames1)
                if(r~=nil) then
                    if(type(r)=="table") then

                        dmg1=r.Damage
                        flags1=r.DamageFlags
                        frames1=r.DamageCountdown
                    elseif(r==false) then
                        return r
                    end
                end
            end
        end
        

        if(not (dmg==dmg1 and flags==flags1 and frames==frames1)) then
            return {
                Damage=dmg1,
                DamageFlags=flags1,
                DamageCountdown=frames1,
            }
        end
    end
    --ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -1e6, applyCHAPIDamage, EntityType.ENTITY_PLAYER)
    
    ---@param player Entity
    local function cancelCHAPIDmg(player, dmg, flags, source, frames)
        player = player:ToPlayer()
        local data = ToyboxMod:getEntityDataTable(player)
        if(data.CANCEL_CHAPI_DMG~=nil) then return end

        data.CANCEL_CHAPI_DMG=true
        player:TakeDamage(dmg,flags,source,frames)
        data.CANCEL_CHAPI_DMG=nil

        --return true
    end
    --CustomHealthAPI.Library.AddCallback(ToyboxMod, CustomHealthAPI.Enums.Callbacks.PRE_PLAYER_DAMAGE, 1e12, cancelCHAPIDmg)
end
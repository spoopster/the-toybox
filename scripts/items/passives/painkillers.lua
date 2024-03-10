local mod = MilcomMOD

local DAMAGE_COUNTER_ROOT_POWER = 3.5
local DAMAGE_TIMER = 60*1

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")

local function calcPainkillerDamage(player)
    local dmg = mod:getData(player, "PAINKILLERS_DAMAGE_COUNTER") or 0

    return math.floor(dmg^(1/DAMAGE_COUNTER_ROOT_POWER))
end
local function calcPainkillerTimer(player)
    return math.floor( DAMAGE_TIMER*(1+(player:GetCollectibleNum(mod.COLLECTIBLE_PAINKILLERS)-1)*0.5) )
end

---@param player EntityPlayer
local function painkillersTimerUpdate(_, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_PAINKILLERS)) then return end

    local data = mod:getDataTable(player)
    data.PAINKILLERS_DAMAGE_TIMER = data.PAINKILLERS_DAMAGE_TIMER or 0

    if(data.PAINKILLERS_DAMAGE_TIMER>0) then
        data.PAINKILLERS_DAMAGE_TIMER = data.PAINKILLERS_DAMAGE_TIMER-1

        if(data.PAINKILLERS_DAMAGE_TIMER==0) then
            data.PAINKILLERS_CANCELLING_DAMAGE = false
            player:TakeDamage(1,0,EntityRef(player),0)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, painkillersTimerUpdate)

---@param player EntityPlayer
local function painkillersCancelDamage(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    if(not player:HasCollectible(mod.COLLECTIBLE_PAINKILLERS)) then return end
    local data = mod:getDataTable(player)

    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    if(data.PAINKILLERS_CANCELLING_DAMAGE==nil) then data.PAINKILLERS_CANCELLING_DAMAGE=true end

    if(data.PAINKILLERS_CANCELLING_DAMAGE==true) then
        data.PAINKILLERS_DAMAGE_TIMER = calcPainkillerTimer(player)+5

        local oldDmg = calcPainkillerDamage(player)
        data.PAINKILLERS_DAMAGE_COUNTER = (data.PAINKILLERS_DAMAGE_COUNTER or 0)+dmg*2

        if(oldDmg~=calcPainkillerDamage(player)) then
            local bloodSplat = Isaac.Spawn(1000,2,0,player.Position,Vector.Zero,nil):ToEffect()
            bloodSplat.DepthOffset = 5
        end

        return false
    end
    if(data.PAINKILLERS_CANCELLING_DAMAGE==false) then
        local dmgToTake = calcPainkillerDamage(player)
        data.PAINKILLERS_DAMAGE_COUNTER=0
        data.PAINKILLERS_CANCELLING_DAMAGE=nil

        return {
            Damage=dmgToTake,
            DamageFlags=flags,
            DamageCountdown=60*dmgToTake,
        }
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -math.huge, painkillersCancelDamage, EntityType.ENTITY_PLAYER)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER,
function(_,p,offset)
    if(not p:HasCollectible(mod.COLLECTIBLE_PAINKILLERS)) then return end
    local dmg = mod:getData(p, "PAINKILLERS_DAMAGE_COUNTER") or 0
    if(dmg<1) then return end

    local counter = calcPainkillerDamage(p)*0.5
    local st = ""

    local iMax = counter//1
    local shouldMakeHalfHeart = math.abs(counter%1-0.5)<0.01
    for i=1, iMax do
        st = st.."<3"
        if(i~=iMax or shouldMakeHalfHeart) then st=st.." " end
    end
    if(shouldMakeHalfHeart) then st=st.."<" end

    local rPos = Isaac.WorldToScreen(p.Position)+Vector(0,10)
    f:DrawString(st, rPos.X-200, rPos.Y, KColor(1,1,1,1), 400, true)

    local timeLeft = mod:getData(p, "PAINKILLERS_DAMAGE_TIMER")/calcPainkillerTimer(p)
    local timeSt = ""
    for i=0,1,0.1 do
        if(i<=timeLeft) then timeSt=timeSt.."|"
        else timeSt=timeSt.."-" end
    end
    f:DrawString(timeSt, rPos.X-200, rPos.Y+10, KColor(1,1,1,1), 400, true)
end
)
local MAX_EXTRA_HEAD_NUM = 4
local NEGATIVE_TEARS_MULT = 0.1

local MAX_HEAD_DISTANCE = 50
local HEAD_BASE_POS_OFFS = Vector(0,-10)
local BASE_HEAD_MASS = 50
local REG_HEAD_MASS = 3

---@param pl EntityPlayer
local function initHydraHeadData(pl, mass)
    return {
        Pos = pl.Position,
        PosOffset = Vector.Zero,
        Vel = Vector.Zero,
        Mass = mass,
    }
end

---@param pl EntityPlayer
local function addHydraHead(pl)
    local data = ToyboxMod:getEntityDataTable(pl)

    if((data.HYDRA_HEADS or 0)>=MAX_EXTRA_HEAD_NUM) then return false end

    data.HYDRA_HEADS = (data.HYDRA_HEADS or 0)+1
    data.HYDRA_HEAD_DATA = data.HYDRA_HEAD_DATA or {}

    data.HYDRA_HEAD_DATA[data.HYDRA_HEADS] = initHydraHeadData(pl, REG_HEAD_MASS)

    pl:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)

    return true
end
---@param pl EntityPlayer
local function resetHydraHeads(pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    data.HYDRA_HEADS = 0
    data.HYDRA_HEAD_DATA = {[0]=initHydraHeadData(pl, BASE_HEAD_MASS)}

    pl:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
end

---@param player Entity
local function tryAddHead(_, player, _, flags, source)
    player = player:ToPlayer()
    if(not ToyboxMod:hasCustomTransformation(player, "HYDRA")) then return end

    if(addHydraHead(player)) then
        local poof = Isaac.Spawn(1000,15,0,player.Position,Vector.Zero,nil):ToEffect()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, tryAddHead, EntityType.ENTITY_PLAYER)

---@param pl EntityPlayer
local function removeHeads(_, pl)
    if(pl.FrameCount==0) then return end

    resetHydraHeads(pl)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_LOSE_CUSTOM_TRANSFORMATION, removeHeads, "HYDRA")
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, removeHeads)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    if(not ToyboxMod:hasCustomTransformation(pl, "HYDRA")) then return end

    local numHeads = ToyboxMod:getEntityData(pl, "HYDRA_HEADS") or 0
    return val*(1-NEGATIVE_TEARS_MULT*numHeads)
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat, EvaluateStatStage.FLAT_TEARS)

---@param pl EntityPlayer
---@param params MultiShotParams
local function evalMultishotParams(_, pl, params)
    if(not ToyboxMod:hasCustomTransformation(pl, "HYDRA")) then return end
    local data = ToyboxMod:getEntityDataTable(pl)

    if((data.HYDRA_HEADS or 0)>0) then
        params:SetNumLanesPerEye(params:GetNumLanesPerEye()+data.HYDRA_HEADS)
        params:SetNumTears(params:GetNumTears()+params:GetNumEyesActive()*data.HYDRA_HEADS)

        local invalidWeaps = {[15]=true, [6]=true, [13]=true, [12]=true, [8]=true, [7]=true, [WeaponType.WEAPON_TEARS]=true}
        local weap = pl:GetWeapon(1):GetWeaponType()
        if(not invalidWeaps[weap]) then
            local tearspereye = params:GetNumTears()/params:GetNumEyesActive()
            local oldAngle = params:GetSpreadAngle(weap)*(tearspereye-data.HYDRA_HEADS)
            if(oldAngle<5) then oldAngle = 120 end
            params:SetSpreadAngle(weap, oldAngle/tearspereye)
        end

        return params
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, evalMultishotParams)


---@param pl EntityPlayer
local function updateHeads(_, pl)
    if(not ToyboxMod:hasCustomTransformation(pl, "HYDRA")) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.HYDRA_HEADS = data.HYDRA_HEADS or 0
    data.HYDRA_HEAD_DATA = data.HYDRA_HEAD_DATA or {[0]=initHydraHeadData(pl, BASE_HEAD_MASS)}

    for i, hData in pairs(data.HYDRA_HEAD_DATA) do
        hData = hData or initHydraHeadData(pl)

        if(Game():GetRoom():GetFrameCount()==0) then
            hData.Pos = pl.Position+hData.PosOffset
        end

        hData.Pos = hData.Pos+hData.Vel*1
        hData.PosOffset = hData.Pos-pl.Position

        local posDif = (pl.Position+HEAD_BASE_POS_OFFS*pl.SpriteScale+pl.TearsOffset+pl:GetFlyingOffset()-hData.Pos)
        local len = posDif:Length()
        if(len>10) then
            posDif = posDif:Resized(len)
        end

        hData.Vel = ToyboxMod:lerp(hData.Vel, posDif*0.1+Vector.FromAngle(math.random()*360)*0.7, 0.5)

        local dist = hData.Pos:Distance(pl.Position+pl.TearsOffset+pl:GetFlyingOffset())
        local dEps = (dist-MAX_HEAD_DISTANCE)
        if(dEps>0) then
            hData.Vel = hData.Vel+(pl.Position+pl.TearsOffset+pl:GetFlyingOffset()-hData.Pos):Normalized()*dEps*0.3
        end
    end

    local headRadius = 7
    for i, hData in pairs(data.HYDRA_HEAD_DATA) do
        for i2, hData2 in pairs(data.HYDRA_HEAD_DATA) do
            if(i>i2) then
                local dif = hData.Pos-hData2.Pos
                local errorDist = dif:Length()
                if(errorDist<=headRadius*2+3) then
                    local resizeDif = dif:Resized(math.max(1, 2*headRadius-errorDist))
                    local mSum = hData.Mass+hData2.Mass

                    hData.Pos = hData.Pos+resizeDif*hData2.Mass/mSum
                    hData.PosOffset = hData.Pos-pl.Position
                    hData2.Pos = hData2.Pos-resizeDif*hData.Mass/mSum
                    hData2.PosOffset = hData2.Pos-pl.Position
                    hData.Vel = hData.Vel+(resizeDif*hData2.Mass/mSum)*1.1
                    hData2.Vel = hData2.Vel-(resizeDif*hData.Mass/mSum)*1.1
                end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateHeads)

local beamSprite = Sprite()
beamSprite:Load("gfx_tb/effects/effect_poison_beam.anm2", true)
beamSprite:Play("Idle", true)

---@param pl EntityPlayer
local function renderHeads(_, pl)
    if(not ToyboxMod:hasCustomTransformation(pl, "HYDRA")) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.HYDRA_HEADS = data.HYDRA_HEADS or 0
    data.HYDRA_HEAD_DATA = data.HYDRA_HEAD_DATA or {[0]=initHydraHeadData(pl, BASE_HEAD_MASS)}

    local headY = {}
    for i=0, data.HYDRA_HEADS do
        local headData = data.HYDRA_HEAD_DATA[i] or {initHydraHeadData(pl, (i==0 and BASE_HEAD_MASS or REG_HEAD_MASS))}

        table.insert(headY, {i, headData.Pos})
    end
    table.sort(headY, function(a,b)
        return (a[2].Y<b[2].Y)
    end)

    data.ALLOW_RENDER_HYDRA_HEADS = true
    for _, headYDat in ipairs(headY) do
        local headData = data.HYDRA_HEAD_DATA[headYDat[1]] or {initHydraHeadData(pl, (i==0 and BASE_HEAD_MASS or REG_HEAD_MASS))}

        local bpos1 = Isaac.WorldToRenderPosition(pl.Position+pl.TearsOffset+pl:GetFlyingOffset()+Vector(0,-15)*pl.SpriteScale)
        local bpos2 = Isaac.WorldToRenderPosition(headData.Pos+Vector(0,-20)*pl.SpriteScale)
        local bdir = (bpos2-bpos1):Normalized()
        local bdist = bpos1:Distance(bpos2)
        local step = 7

        while(bdist>=0) do
            beamSprite:Render(bpos1+Game():GetRoom():GetRenderScrollOffset())
            bpos1 = bpos1+bdir*step
            bdist = bdist-step
        end
    end
    
    for _, headYDat in ipairs(headY) do
        local headData = data.HYDRA_HEAD_DATA[headYDat[1]] or {initHydraHeadData(pl, (i==0 and BASE_HEAD_MASS or REG_HEAD_MASS))}

        pl:RenderHead(Isaac.WorldToRenderPosition(headData.Pos)+Game():GetRoom():GetRenderScrollOffset())
    end
    data.ALLOW_RENDER_HYDRA_HEADS = false
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, renderHeads)

---@param pl EntityPlayer
local function cancelHeadRender(_, pl)
    if(not ToyboxMod:hasCustomTransformation(pl, "HYDRA")) then return end

    if(not ToyboxMod:getEntityData(pl, "ALLOW_RENDER_HYDRA_HEADS")) then
        return false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_RENDER_PLAYER_HEAD, cancelHeadRender)
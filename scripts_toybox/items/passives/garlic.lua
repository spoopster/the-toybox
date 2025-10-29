local beamSprite = Sprite()
beamSprite:Load("gfx_tb/effects/effect_poison_beam.anm2", true)
beamSprite:Play("Idle", true)
beamSprite.PlaybackSpeed = 0.2

local size = 32

local beam = Beam(beamSprite, "body", false, false)
beam:GetSprite():GetLayer("body"):SetWrapTMode(0)
beamSprite:GetLayer("body"):SetWrapSMode(1)

---@param laser EntityLaser
---@param offset Vector
local function renderPoisonBeam(_, laser, offset)
    if(not laser:IsSampleLaser()) then return end

    local samples = laser:GetSamples()

    --[[ ]]
    for i=1, #samples do
        local s = samples:Get(i-1)+laser.PositionOffset
        
        local c = Capsule(s, Vector(1,1), 0, 5)
        local sh = DebugRenderer.Get(2000+i, true)
        sh:Capsule(c)
        sh:SetTimeout(1)
    end
    for i=2, #samples do
        local s = samples:Get(i-1)+laser.PositionOffset
        local s1 = samples:Get(i-2)+laser.PositionOffset
        
        local c = Capsule((s+s1)/2, Vector(s:Distance(s1)/2,1), (s-s1):GetAngleDegrees(), 1)
        local sh = DebugRenderer.Get(3000+i, true)
        sh:Capsule(c)
        sh:SetTimeout(1)
    end
    --]]

    --[[]]
    local distTravelled = 0
    
    local nextTarget = size

    local width = 1*laser:GetScale()

    local dist = 0
    local offs = Vector(0,100)
    for i=1, #samples do
        local s1 = samples:Get(i-1)+offs
        local s0 = (i==1 and s1 or (samples:Get(i-2)+offs))

        dist = dist+Isaac.WorldToScreen(s1):Distance(Isaac.WorldToScreen(s0))

        beam:Add(Isaac.WorldToScreen(s1), dist, width)
    end

    --[[]]
    local points = beam:GetPoints()
    Isaac.RenderText(#points, 100, 100, 1,1,1,1)
    for i=1, #points do
        local p = points[i]
        local s = (p:GetPosition()-offs)
        s = s--+Vector(0, Isaac.GetScreenHeight()/2)
        
        local c = Capsule(s, Vector(1,1), 0, 5)
        local sh = DebugRenderer.Get(4000+i, true)
        sh:Capsule(c)
        sh:SetTimeout(1)
    end
    for i=2, #samples do
        local p = points[i]
        local p1 = points[i-1]

        local s = (p:GetPosition()-offs)
        local s1 = (p1:GetPosition()-offs)

        local c = Capsule((s+s1)/2, Vector(s:Distance(s1)/2,1)/2, (s-s1):GetAngleDegrees(), 2)
        local sh = DebugRenderer.Get(4500+i, true)
        sh:Capsule(c)
        sh:SetTimeout(1)
    end
    --] ]


    beam:GetSprite():Update()
    beam:Render()
    --]]
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, renderPoisonBeam)
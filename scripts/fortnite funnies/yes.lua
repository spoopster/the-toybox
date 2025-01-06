local mod = MilcomMOD
local sfx = SFXManager()

local SEL_PLAYERS = {}

local function rendersYes()
    if(Game():IsPaused()) then return end
    if(not Input.IsMouseBtnPressed(MouseButton.LEFT)) then
        SEL_PLAYERS = {}

        return
    end

    local mousePos = Input.GetMousePosition(true)--/(Isaac.GetScreenPointScale())--*Isaac.GetScreenWidth()/Isaac.GetScreenHeight()
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local dist = pl.Position:Distance(mousePos)

        if(dist<10 and not SEL_PLAYERS[i]) then
            SEL_PLAYERS[i] = 0
        end
    end

    for i, frames in pairs(SEL_PLAYERS) do
        local pl = Isaac.GetPlayer(i)

        local dir = (mousePos-pl.Position)

        local lerpDist = 20
        local dist = math.min(1, pl.Position:Distance(mousePos)/lerpDist)^0.5

        pl.Velocity = mod:lerp(pl.Velocity, dir, 0.2+0.8*(1-dist))
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, rendersYes)
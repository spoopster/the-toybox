local mod = MilcomMOD

local font = Font("font/pftempestasevencondensed.fnt")

local function renderWarning(_)
    if(CustomHealthAPI and PlayerManager.AnyoneIsPlayerType(mod.PLAYER_ATLAS_A)) then
        local rPos = Vector(160,140)

        local f = (math.sin(math.rad(Game():GetFrameCount()*15))/2+0.5)*0.2
        local c = KColor(1,0.1+f,0.1+f,1)

        font:DrawString("Custom Health API mod detected!", rPos.X, rPos.Y, c)
        font:DrawString("Atlas is VERY unstable with CHAPI due to the various reimplementations", rPos.X, rPos.Y+10, c)
        font:DrawString("the API has that break Atlas' unique health system!", rPos.X, rPos.Y+20, c)
        font:DrawString("Please disable any mod that uses CHAPI to be able to properly play Atlas", rPos.X, rPos.Y+40, c)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, renderWarning)
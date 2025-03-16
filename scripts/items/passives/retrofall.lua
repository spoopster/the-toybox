local mod = ToyboxMod

local itemTextOnScreen = -1
local BOX_WIDTH = 10000

local lineHeight = 10

local font = Font()
font:Load("font/pftempestasevencondensed.fnt")

local stringsss = {
    "Bad news, tomorrow is retrofall, which is an 8-bit",
    "attack event on all classic gaming consoles",
    "including the Nintendo Entertainment System. There",
    "will be people trying to send you ray tracing,",
    "extreme graphics, 4K, Call of Duty, and there will",
    "also be pixel grabbers, moderners, and Unreal Engine",
    "4K Remasterers. I advise NO ONE to play video games",
    "from retro gamers you don't know, please stay safe.",
    "Please pass this on to any gaming console you own or",
    "have 1UP Mushroom and can level up to spread",
    "awareness. I wish you all safety. Also, make sure to",
    "be game over tomorrow, which gives you less chance",
    "for this to happen to you. It's also specifically",
    "against retro video gamers.",
}

local function postHudRender(_)
    if(itemTextOnScreen>=0) then
        local streakSprite = Game():GetHUD():GetStreakSprite()
        local baseCenterPos = Vector(Isaac.GetScreenWidth()/2, 40)

        local frameData = streakSprite:GetNullFrame("Center")
        local frameScale = frameData:GetScale()
        baseCenterPos = baseCenterPos+frameData:GetPos()+Vector(0,17)*frameScale

        for key, str in ipairs(stringsss) do
            font:DrawStringScaled(str, baseCenterPos.X-BOX_WIDTH/2, baseCenterPos.Y, frameScale.X, frameScale.Y, KColor(1,1,1,1), BOX_WIDTH, true)

            baseCenterPos.Y = baseCenterPos.Y+lineHeight*frameScale.Y
        end

        if(streakSprite:IsFinished("Text")) then itemTextOnScreen = -1 end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, postHudRender)

local function asdasdad(_, title, subtitle, sticky, curse)
    if(title=="RETROFALL") then
        itemTextOnScreen = 0
    else
        itemTextOnScreen = -1
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_ITEM_TEXT_DISPLAY, asdasdad)
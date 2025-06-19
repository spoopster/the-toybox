

local KILLSCREEN_DMG = 1
local KILLSCREEN_FREQ = 15

local function dealKillscreenDMG(_)
    local totalMult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_KILLSCREEN)
    if(totalMult<=0) then return end

    local dv = 1+(totalMult-1)/2
    local freq = math.max(1, KILLSCREEN_FREQ//dv)
    if(Game():GetFrameCount()%freq~=0) then return end

    local centerX = Game():GetRoom():GetCenterPos().X

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        local npc = ent:ToNPC()
        if(npc and ToyboxMod:isValidEnemy(npc)) then
            if(npc.Position.X>=centerX) then
                npc:TakeDamage(KILLSCREEN_DMG, 0, EntityRef(PlayerManager.FirstTrinketOwner(ToyboxMod.TRINKET_KILLSCREEN)), 0)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, dealKillscreenDMG)
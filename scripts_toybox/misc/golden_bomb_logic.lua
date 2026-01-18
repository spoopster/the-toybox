---@param shouldHave boolean
local function updateGoldenBombState(shouldHave)
    if(not ToyboxMod:getExtraData("GOLDEN_BOMB_OVERRIDE")) then
        ToyboxMod:setExtraData("GOLDEN_BOMB_STATE", shouldHave)
    end
end

---@param pickup EntityPickup
---@param coll Entity
local function goldenBombColl(_, pickup, coll)
    if(pickup.SubType~=BombSubType.BOMB_GOLDEN) then return end

    local sp = pickup:GetSprite()
    if(not (sp:GetAnimation()=="Collect")) then return end

    local pl = (coll and coll:ToPlayer() or nil)
    if(pl) then
        updateGoldenBombState(true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, goldenBombColl, PickupVariant.PICKUP_BOMB)

local function resetGoldenKey(_)
    if(not Game():GetRoom():IsFirstVisit()) then return end

    updateGoldenBombState(false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetGoldenKey)


--- metatable stuff for mod compat

local ogMetaTable = getmetatable(EntityPlayer).__class
local newMetaTable = {}
local ogIndex = ogMetaTable.__index

function newMetaTable:AddGoldenBomb()
    updateGoldenBombState(true)

    ogMetaTable.AddGoldenBomb(self)
end

function newMetaTable:RemoveGoldenBomb()
    updateGoldenBombState(false)

    ogMetaTable.RemoveGoldenBomb(self)
end

rawset(ogMetaTable, "__index",
    function(self, key)
        if(newMetaTable[key]) then
            return newMetaTable[key]
        else
            return ogIndex(self, key)
        end
    end
)
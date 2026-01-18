---@param shouldHave boolean
local function updateGoldenKeyState(shouldHave)
    if(not ToyboxMod:getExtraData("GOLDEN_KEY_OVERRIDE")) then
        ToyboxMod:setExtraData("GOLDEN_KEY_STATE", shouldHave)
    end
end

---@param pickup EntityPickup
---@param coll Entity
local function goldenKeyColl(_, pickup, coll)
    if(pickup.SubType~=KeySubType.KEY_GOLDEN) then return end

    local sp = pickup:GetSprite()
    if(not (sp:GetAnimation()=="Collect")) then return end

    local pl = (coll and coll:ToPlayer() or nil)
    if(pl) then
        updateGoldenKeyState(true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, goldenKeyColl, PickupVariant.PICKUP_KEY)

local function resetGoldenKey(_)
    if(not Game():GetRoom():IsFirstVisit()) then return end

    updateGoldenKeyState(false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetGoldenKey)


--- metatable stuff for mod compat

local ogMetaTable = getmetatable(EntityPlayer).__class
local newMetaTable = {}
local ogIndex = ogMetaTable.__index

function newMetaTable:AddGoldenKey()
    updateGoldenKeyState(true)

    ogMetaTable.AddGoldenKey(self)
end

function newMetaTable:RemoveGoldenKey()
    updateGoldenKeyState(false)

    ogMetaTable.RemoveGoldenKey(self)
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


local COSTUME_PATH = "gfx_tb/characters/costume_atlas_rock.anm2"
local COSTUME_DEFAULT = "gfx_tb/characters/costumes/character_atlas_horn.png"
ToyboxMod.HORN_COSTUMES = {}

local function compareSort(tableA, tableB)
    return (tableA.Priority<tableB.Priority)
end

---@param costumePath string Path of the costume spritesheet
---@param condition function Condition for the costume; args = player (EntityPlayer); return = bool
---@param priority number? Priority of the costume, default = 0
function ToyboxMod:addHornCostume(costumePath, condition, priority)
    priority = priority or 0

    table.insert(ToyboxMod.HORN_COSTUMES,
        {
            CostumePath = costumePath,
            ActiveCondition = condition,
            Priority = priority,
        }
    )

    table.sort(ToyboxMod.HORN_COSTUMES, compareSort)
end

ToyboxMod:addHornCostume("gfx_tb/characters/costumes_atlas_a_horn/costume_sad_onion.png", function(pl) return pl:HasCollectible(1) end, 0)
ToyboxMod:addHornCostume(
    "gfx_tb/characters/costumes_atlas_a_horn/costume_salt_mantle.png",
    function(pl) return pl:IsNullItemCostumeVisible(ToyboxMod.MANTLE_DATA.SALT.CHARIOT_COSTUME, "head") end,
    99
)


---@param pl EntityPlayer
local function updateCostume(_, _, pl, _)
    if(pl:GetPlayerType()~=ToyboxMod.PLAYER_TYPE.ATLAS_A) then return end

    ToyboxMod:setEntityData(pl, "UPDATE_COSTUMES", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_COSTUME, updateCostume)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_REMOVE_COSTUME, updateCostume)

---@param player EntityPlayer
local function evaluateHorn(_, player)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_TYPE.ATLAS_A) then return end
    if(not ToyboxMod:getEntityData(player, "UPDATE_COSTUMES")) then return end
    ToyboxMod:setEntityData(player, "UPDATE_COSTUMES", nil)

    local costumeSprite = COSTUME_DEFAULT

    if(not player:HasCurseMistEffect()) then
        for i=#ToyboxMod.HORN_COSTUMES, 1, -1 do
            local cData = ToyboxMod.HORN_COSTUMES[i]

            if((not cData.ActiveCondition) or (cData.ActiveCondition and cData.ActiveCondition(player))) then
                costumeSprite = cData.CostumePath

                break
            end
        end
    end

    local sp
    for _, cDesc in ipairs(player:GetCostumeSpriteDescs()) do
        if(cDesc:GetSprite():GetFilename()==COSTUME_PATH) then
            sp = cDesc:GetSprite()
            break
        end
    end

    sp:ReplaceSpritesheet(1, costumeSprite)
    sp:LoadGraphics()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, evaluateHorn, 0)
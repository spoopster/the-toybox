local mod = MilcomMOD

local COSTUME_PATH = "gfx/characters/tb_costume_atlas_rock.anm2"
local COSTUME_DEFAULT = "gfx/characters/costumes/tb_character_atlas_horn.png"
mod.HORN_COSTUMES = {}

local function compareSort(tableA, tableB)
    return (tableA.Priority<tableB.Priority)
end

---@param costumePath string Path of the costume spritesheet
---@param condition function Condition for the costume; args = player (EntityPlayer); return = bool
---@param priority number? Priority of the costume, default = 0
function mod:addHornCostume(costumePath, condition, priority)
    priority = priority or 0

    table.insert(mod.HORN_COSTUMES,
        {
            CostumePath = costumePath,
            ActiveCondition = condition,
            Priority = priority,
        }
    )

    table.sort(mod.HORN_COSTUMES, compareSort)
end

mod:addHornCostume("gfx/characters/costumes_atlas_a_horn/tb_costume_sad_onion.png", function(pl) return pl:HasCollectible(1) end, 0)
mod:addHornCostume(
    "gfx/characters/costumes_atlas_a_horn/tb_costume_salt_mantle.png",
    function(pl) return pl:IsNullItemCostumeVisible(mod.MANTLE_DATA.SALT.CHARIOT_COSTUME, "head") end,
    99
)


---@param pl EntityPlayer
local function updateCostume(_, _, pl, _)
    if(pl:GetPlayerType()~=mod.PLAYER_TYPE.ATLAS_A) then return end

    mod:setEntityData(pl, "UPDATE_COSTUMES", true)
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_COSTUME, updateCostume)
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_REMOVE_COSTUME, updateCostume)

---@param player EntityPlayer
local function evaluateHorn(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_TYPE.ATLAS_A) then return end
    if(not mod:getEntityData(player, "UPDATE_COSTUMES")) then return end
    mod:setEntityData(player, "UPDATE_COSTUMES", nil)

    local costumeSprite = COSTUME_DEFAULT

    if(not player:HasCurseMistEffect()) then
        for i=#mod.HORN_COSTUMES, 1, -1 do
            local cData = mod.HORN_COSTUMES[i]

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
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, evaluateHorn, 0)
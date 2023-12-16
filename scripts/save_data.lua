local mod = MilcomMOD
local json = require("json")

local function cloneTable(t)
    local tClone = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            tClone[key]={}
            for key2, val2 in pairs(cloneTable(val)) do
                tClone[key][key2]=val2
            end
        else
            tClone[key]=val
        end
    end
    return tClone
end

local function cloneSaveTableWithoutDeleting(table1, table2)
    for key, val in pairs(table2) do
        if(type(val)=="table") then
            table1[key] = {}
            cloneSaveTableWithoutDeleting(table1[key], table2[key])
        else
            table1[key]=val
        end
    end
end

---@param t table
local function convertTableToSaveData(t)
    local data = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            data[key] = {}
            for key1, val1 in pairs(convertTableToSaveData(val)) do
                data[key][key1] = val1
            end
        elseif(type(val)=="userdata" and type(val.LengthSquared)=="function") then
            data[key] = {}
            for key1, val1 in pairs(mod:vectorToVectorTable(val)) do
                data[key][key1] = val1
            end
        elseif(type(val)=="userdata" and type(val.SetColorize)=="function") then
            data[key] = {}
            for key1, val1 in pairs(mod:colorToColorTable(val)) do
                data[key][key1] = val1
            end
        else
            data[key]=val
        end
    end

    return data
end

---@param t table
local function convertSaveDataToTable(t)
    local data = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            data[key] = {}

            if(val.IsVectorTable) then
                data[key] = mod:vectorTableToVector(val)
            elseif(val.IsColorTable) then
                data[key] = mod:colorToColorTable(val)
            else
                for key1, val1 in pairs(convertSaveDataToTable(val)) do
                    data[key][key1] = val1
                end
            end
        else
            data[key] = val
        end
    end

    return data
end

local isDataLoaded = false
local defaultMarks = {
    ["Isaac"] = 0,
    ["BlueBaby"] = 0,
    ["Satan"] = 0,
    ["Lamb"] = 0,
    ["BossRush"] = 0,
    ["Hush"] = 0,
    ["MegaSatan"] = 0,
    ["Delirium"] = 0,
    ["Mother"] = 0,
    ["Beast"] = 0,
    ["UltraGreed"] = 0,
    ["UltraGreedier"] = 0,
    ["MomsHeart"] = 0,
}
mod.BASEMARKS = {
    CHARACTERS = {
        MILCOM_A = cloneTable(defaultMarks),
        MILCOM_B = cloneTable(defaultMarks),
    },
}

mod.MARKS = cloneTable(mod.BASEMARKS)
mod.UNLOCKS = {
    CHARACTERS = {
        MILCOM_A = {
            ["Isaac"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["BlueBaby"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Satan"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Lamb"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["BossRush"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Hush"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["MegaSatan"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Delirium"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Mother"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Beast"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["UltraGreed"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["UltraGreedier"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
        },
        MILCOM_B = {
            ["Isaac"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["BlueBaby"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Satan"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Lamb"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["BossRush"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Hush"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["MegaSatan"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Delirium"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Mother"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["Beast"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["UltraGreed"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
            ["UltraGreedier"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"none"}},
        },
    },
}

function mod:saveProgress()
    local save = {}
    save.milcomData = {}
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        if(player:GetPlayerType()==mod.MILCOM_A_ID) then
            local seed = ""..player:GetCollectibleRNG(198):GetSeed() --* milcom uses box's rng just in case !

            save.milcomData[seed] = convertTableToSaveData(mod:getMilcomATable(player))
        end
    end
    save.unlockData = cloneTable(mod.BASEMARKS)
    cloneSaveTableWithoutDeleting(save.unlockData, mod.MARKS)

	mod:SaveData(json.encode(save))
end

function mod:saveNewFloor()
    if(isDataLoaded) then mod:saveProgress() end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.saveNewFloor)
function mod:saveGameExit(save)
    mod:saveProgress()
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveGameExit)

--#region ACHIEVEMENT_LOGIC
--[[
local function getScreenCenter()
    local game = Game()
	local room = game:GetRoom()

	local pos = room:WorldToScreenPosition(Vector(0,0)) - room:GetRenderScrollOffset() - game.ScreenShakeOffset
	local rx = pos.X + 60 * 26 / 40
	local ry = pos.Y + 140 * (26 / 40)

	return Vector(rx + 13*13, ry + 7*13)
end

local achievement_paper_queue={["HEAD"]=1,["TAIL"]=1}
local achievement_frame_count=0
local achievement_frame_state=0
local achievement_paper_in_sound=true
local achievement_paper_out_sound=true

function mod:RenderAchievements()
	if Game():IsPaused() then
		return
	end
	if achievement_paper_queue["TAIL"]<achievement_paper_queue["HEAD"] then
		local tmp_sprite=achievement_paper_queue[achievement_paper_queue["TAIL"] ]
		if achievement_frame_count<8 then
			if achievement_paper_in_sound then
				SFXManager():Play(17,1.0)
				achievement_paper_in_sound=false
			end
			tmp_sprite:SetFrame("Appear",achievement_frame_count)
		elseif achievement_frame_count<32 then
			tmp_sprite:SetFrame("Idle",(achievement_frame_count-8)%8)
		else
			if achievement_paper_out_sound then
				SFXManager():Play(18,1.0)
				achievement_paper_out_sound=false
			end
			tmp_sprite:SetFrame("Disappear",achievement_frame_count-32)
		end
		tmp_sprite:Render(getScreenCenter(),Vector(0,0),Vector(0,0))
		achievement_frame_state=(achievement_frame_state+1)%2
		if achievement_frame_state==0 then
			achievement_frame_count=achievement_frame_count+1
			if achievement_frame_count==40 then
				achievement_paper_queue[achievement_paper_queue["TAIL"] ]=nil
				achievement_paper_queue["TAIL"]=achievement_paper_queue["TAIL"]+1
				achievement_frame_count=0
				achievement_paper_in_sound=true
				achievement_paper_out_sound=true
			end
		end
	else
		achievement_paper_in_sound=true
		achievement_paper_out_sound=true
	end
end

mod:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.LATE, mod.RenderAchievements)

---@param achname string
function mod:showAchievement(achname)
	local tmp_sprite=Sprite()
	local achstring=tostring(achname)
	tmp_sprite:Load("gfx/green_achievement.anm2",false)
	tmp_sprite:ReplaceSpritesheet(3,"gfx/achievements/"..achstring..".png")
	tmp_sprite:LoadGraphics()
	achievement_paper_queue[achievement_paper_queue["HEAD"] ]=tmp_sprite
	achievement_paper_queue["HEAD"]=achievement_paper_queue["HEAD"]+1
end
]]
--#endregion

local playerTypeToTable = {
    [mod.MILCOM_A_ID] = "MILCOM_A",
    [mod.MILCOM_B_ID] = "MILCOM_B",
}

--#region UNLOCK_LOGIC

local lambDead = false
local blueBabyDead = false

function mod:beastUnlock(entity)
    if(not (Game():GetVictoryLap()==0 and entity.Variant==0)) then return end
	for i = 0, Game():GetNumPlayers()-1 do
        local unlock = "Beast"
        local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
        if(playerTable==nil) then goto invalid end
        if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
        mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1

        --[[
        local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
        for _, achievement in ipairs(achTable) do
            mod:showAchievement(achievement)
        end
        ]]
        ::invalid::
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.beastUnlock, EntityType.ENTITY_BEAST)

function mod:unlocks1(npc)
    if(Game():GetVictoryLap()~=0) then return end
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local stage = Game():GetLevel()

		if(Game():GetVictoryLap()==0) then
			if(stage:GetStage()==LevelStage.STAGE5) then --Isaac and Satan unlocks
				if(npc.Type==EntityType.ENTITY_ISAAC) then
                    local unlock = "Isaac"
                    local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
                    if(playerTable==nil) then goto invalid end
                    if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1
            
                    --[[
                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ]]
                    ::invalid::
				elseif(npc.Type==EntityType.ENTITY_SATAN) then
                    local unlock = "Satan"
                    local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
                    if(playerTable==nil) then goto invalid end
                    if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1
            
                    --[[
                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ]]
                    ::invalid::
				end
			elseif(stage:GetStage()==LevelStage.STAGE6) then --Blue Baby, the Lamb, and Mega Satan unlocks
				if(npc.Type==EntityType.ENTITY_ISAAC and npc.Variant==1) then
					blueBabyDead = true
				elseif(npc.Type==EntityType.ENTITY_THE_LAMB) then
					lambDead = true
				elseif(npc.Type==EntityType.ENTITY_MEGA_SATAN_2) then
                    local unlock = "MegaSatan"
                    local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
                    if(playerTable==nil) then goto invalid end
                    if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1
            
                    --[[
                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ]]
                    ::invalid::
				end
			elseif(stage:GetStage()==LevelStage.STAGE7 and npc.Type==EntityType.ENTITY_DELIRIUM) then --Delirium unlocks
                local unlock = "Delirium"
                local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
                if(playerTable==nil) then goto invalid end
                if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
                mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1
        
                --[[
                local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
                for _, achievement in ipairs(achTable) do
                    mod:showAchievement(achievement)
                end
                ]]
                ::invalid::
			elseif((stage:GetStage()==LevelStage.STAGE4_1 or stage:GetStage()==LevelStage.STAGE4_2) and npc.Type==EntityType.ENTITY_MOTHER and npc.Variant==10) then --Mother unlocks
                local unlock = "Mother"
                local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
                if(playerTable==nil) then goto invalid end
                if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
                mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1
        
                --[[
                local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
                for _, achievement in ipairs(achTable) do
                    mod:showAchievement(achievement)
                end
                ]]
                ::invalid::
            end
        elseif((stage:GetStage()==LevelStage.STAGE4_1 or stage:GetStage()==LevelStage.STAGE4_2) and (not Game().Difficulty>=Difficulty.DIFFICULTY_GREED) and npc.Type==EntityType.ENTITY_MOMS_HEART and (npc.Variant==0 or npc.Variant==1)) then --Mother unlocks
            local unlock = "MomsHeart"
            local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
            if(playerTable==nil) then goto invalid end
            if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
            mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1
    
            --[[
            local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
            for _, achievement in ipairs(achTable) do
                mod:showAchievement(achievement)
            end
            ]]
            ::invalid::
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.unlocks1)

function mod:unlocks2()
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local room = Game():GetRoom()
		local stage = Game():GetLevel()
        if(Game():GetVictoryLap()==0) then
            if(stage:GetStage() == LevelStage.STAGE6 and room:GetType() == RoomType.ROOM_BOSS and room:IsClear()) then
                if blueBabyDead then
                    local unlock = "BlueBaby"
                    local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
                    if(playerTable==nil) then goto invalid end
                    if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1
            
                    --[[
                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ]]
                    ::invalid::

                    blueBabyDead = false
                elseif lambDead then
                    local unlock = "Lamb"
                    local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
                    if(playerTable==nil) then goto invalid end
                    if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1
            
                    --[[
                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ]]
                    ::invalid::

                    lambDead = false
                end
            end
            --Boss rush unlocks
            if(Game():GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DONE)
            and(stage:GetStage()==LevelStage.STAGE3_1 or stage:GetStage()==LevelStage.STAGE3_2)) then
                local unlock = "BossRush"
                local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
                if(playerTable==nil) then goto invalid end
                if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
                mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1
        
                --[[
                local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
                for _, achievement in ipairs(achTable) do
                    mod:showAchievement(achievement)
                end
                ]]
                ::invalid::
            end
            --Hush unlocks
            if(Game():GetStateFlag(GameStateFlag.STATE_BLUEWOMB_DONE)
            and stage:GetStage()==LevelStage.STAGE4_3) then
                local unlock = "Hush"
                local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
                if(playerTable==nil) then goto invalid end
                if(mod.MARKS.CHARACTERS[playerTable][unlock]==Game().Difficulty+1) then goto invalid end
                mod.MARKS.CHARACTERS[playerTable][unlock]=Game().Difficulty+1
        
                --[[
                local achTable = mod.UNLOCKS.CHARACTERS[playerTable][unlock].ACHIEVEMENT
                for _, achievement in ipairs(achTable) do
                    mod:showAchievement(achievement)
                end
                ]]
                ::invalid::
            end
        end
        --Greed and greedier unlocks
        if(Game():IsGreedMode() and stage:GetStage()==LevelStage.STAGE7_GREED) then
            if(room:GetRoomShape()==RoomShape.ROOMSHAPE_1x2 and room:IsClear()) then
                if(Game().Difficulty>=Difficulty.DIFFICULTY_GREED) then
                    local playerTable = playerTypeToTable[Isaac.GetPlayer(i):GetPlayerType()]
                    if(playerTable==nil) then goto invalid end

                    if(mod.MARKS.CHARACTERS[playerTable]["UltraGreed"]==0) then
                        mod.MARKS.CHARACTERS[playerTable]["UltraGreed"]=1

                        --[[
                        local achTable = mod.UNLOCKS.CHARACTERS[playerTable]["UltraGreed"].ACHIEVEMENT
                        for _, achievement in ipairs(achTable) do
                            mod:showAchievement(achievement)
                        end
                        ]]
                    end
                    if(Game().Difficulty==Difficulty.DIFFICULTY_GREED) then goto invalid end

                    if(mod.MARKS.CHARACTERS[playerTable]["UltraGreedier"]~=0) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable]["UltraGreedier"]=1
            
                    --[[
                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable]["UltraGreedier"].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ]]
                    ::invalid::
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.unlocks2)

--#endregion

function mod:dataSaveInit(player)
    if(Game():GetFrameCount()==0) then
        if(player:GetPlayerType()==mod.MILCOM_A_ID) then
            mod.MILCOM_A_DATA[player.InitSeed] = mod:cloneTable(mod.MILCOM_A_BASEDATA)
        end
    else
        if(mod:HasData()) then
            local save = json.decode(mod:LoadData())
            local iData = save.milcomData[""..player:GetCollectibleRNG(198):GetSeed()]
            if(iData) then
                if(player:GetPlayerType()==mod.MILCOM_A_ID and iData["CHARACTER_SIDE"]=="A") then
                    mod.MILCOM_A_DATA[player.InitSeed] = convertSaveDataToTable(iData)
                end
            else
                if(player:GetPlayerType()==mod.MILCOM_A_ID) then
                    mod.MILCOM_A_DATA[player.InitSeed] = mod:cloneTable(mod.MILCOM_A_BASEDATA)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.dataSaveInit, 0)

function mod:postGameStartedLoadData(isCont)
    if(mod:HasData()) then
        local save = json.decode(mod:LoadData())

        mod.MARKS = cloneTable(mod.BASEMARKS)
        if(save.unlockData) then
            cloneSaveTableWithoutDeleting(mod.MARKS, save.unlockData)
        end
    end
    isDataLoaded = true
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.postGameStartedLoadData)

--#region LOCKED_ITEM_LOGIC
local itemPool = Game():GetItemPool()
local itemConfig = Isaac.GetItemConfig()

--#region COLLECTIBLE_LOGIC
function mod:rerollLockedCollectiblePickup(pickup)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for mark, unlock in pairs(unlockTable) do
            if(mod.MARKS.CHARACTERS[character][mark]~=0) then goto unlocked end
            if(not (unlock.TYPE=="COLLECTIBLE" and unlock.ID>0 and pickup.SubType==unlock.ID)) then goto invalidItem end

            pickup:Morph(pickup.Type, pickup.Variant, 0, true, true)

            ::unlocked:: ::invalidItem::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.rerollLockedCollectiblePickup, PickupVariant.PICKUP_COLLECTIBLE)

local function getActiveSlotForItem(player, collectibleType)
    for _, activeSlot in pairs(ActiveSlot) do
        if player:GetActiveItem(activeSlot) == collectibleType then
            return activeSlot
        end
    end

    return nil
end
--help

local maxTries = 100
local function getItemConfigOfSameType(collectibleType)
    local itemType = itemConfig:GetCollectible(collectibleType).Type

    local tries = 0
    while tries < maxTries do
        local chosenCollectible = itemPool:GetCollectible(ItemPoolType.POOL_TREASURE, false, Random(), CollectibleType.COLLECTIBLE_BREAKFAST)
        local collectibleConfig = itemConfig:GetCollectible(chosenCollectible)

        if collectibleConfig.Type == itemType then
            return collectibleConfig
        else
            tries = tries + 1
        end
    end

    return itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_BREAKFAST)
end

local function replaceCollectible(player, collectibleType)
    for _ = 1, player:GetCollectibleNum(collectibleType) do
        local activeSlot = getActiveSlotForItem(player, collectibleType)
        player:RemoveCollectible(collectibleType)

        local collectibleConfig = getItemConfigOfSameType(collectibleType)
        player:AddCollectible(collectibleConfig.ID, collectibleConfig.MaxCharges, true, activeSlot)
    end
end

function mod:replaceLockedCollectibles(player)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for mark, unlock in pairs(unlockTable) do
            if(mod.MARKS.CHARACTERS[character][mark]~=0) then goto unlocked end
            if(not (unlock.TYPE=="COLLECTIBLE" and unlock.ID>0 and player:HasCollectible(unlock.ID))) then goto invalidItem end

            if(player:HasCollectible(unlock.ID)) then
                replaceCollectible(player, unlock.ID)
            end

            ::unlocked:: ::invalidItem::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.replaceLockedCollectibles, 0)
--#endregion

--#region TRINKET_LOGIC
function mod:rerollLockedTrinketPickup(pickup)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for mark, unlock in pairs(unlockTable) do
            if(mod.MARKS.CHARACTERS[character][mark]~=0) then goto unlocked end
            if(not (unlock.TYPE=="TRINKET" and unlock.ID>0 and pickup.SubType==unlock.ID)) then goto invalidItem end

            pickup:Morph(pickup.Type, pickup.Variant, 0, true, true)

            ::unlocked:: ::invalidItem::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.rerollLockedTrinketPickup, PickupVariant.PICKUP_TRINKET)

local function replaceTrinket(player, trinketType)
    if not player:TryRemoveTrinket(trinketType) then return end
    player:AddTrinket(itemPool:GetTrinket(false))
end

function mod:replaceLockedTrinkets(player)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for mark, unlock in pairs(unlockTable) do
            if(mod.MARKS.CHARACTERS[character][mark]~=0) then goto unlocked end
            if(not (unlock.TYPE=="TRINKET" and unlock.ID>0 and player:HasTrinket(unlock.ID))) then goto invalidItem end

            replaceTrinket(player, unlock.ID)

            ::unlocked:: ::invalidItem::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.replaceLockedTrinkets, 0)
--#endregion
--#endregion
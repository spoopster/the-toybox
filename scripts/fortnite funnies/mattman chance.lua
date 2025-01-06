local mod = MilcomMOD
local persistentData = Isaac.GetPersistentGameData()

local MAX_STATS_PER_LINE = 10
local STAT_IDX_OFFSET = Vector(48,12)

local statsSprite = Sprite("gfx/ui/tb_ui_stats.anm2", true)
statsSprite:SetFrame("Idle", 0)
statsSprite.Color = Color(1,1,1,0.5,0,0,0)
local f = Font()
f:Load("font/luaminioutlined.fnt")

local function tearFire(_, tear, pl)
    mod:setEntityData(tear, "ACCURACY_PL", pl)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, tearFire)
local function tearCollision(_, tear)
    mod:setEntityData(tear, "ACCURACY_HIT", 1)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, tearCollision)
local function tearDeath(_, tear)
    local pl = mod:getEntityData(tear, "ACCURACY_PL")

    if(pl) then
        local data = mod:getEntityDataTable(pl)

        data.MATTMAN_CHANCE_TEARS_DIED = (data.MATTMAN_CHANCE_TEARS_DIED or 0)+1
        if(mod:getEntityData(tear, "ACCURACY_HIT")) then
            data.MATTMAN_CHANCE_TEARS_HIT = (data.MATTMAN_CHANCE_TEARS_HIT or 0)+1
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, tearDeath)

local function postNewRun(_, isCont)
    if(isCont) then return end

    mod:setExtraData("MATTMAN_CHANCE_LAMB_KILLS", persistentData:GetEventCounter(EventCounter.LAMB_KILLS))
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postNewRun)

local function getNumTears(pl)
    local params = pl:GetMultiShotParams(pl:GetWeapon(1):GetWeaponType())

    return params:GetNumTears()+params:GetNumRandomDirTears()
end

local newStats = {
    function(pos) -- MATTMAN CHANCE
        local itemPool = Game():GetItemPool():GetCollectiblesFromPool(ItemPoolType.POOL_TREASURE)
        local itemConf = Isaac.GetItemConfig()

        local q4Weight = 0
        local maxWeight = 0

        for _, itemData in ipairs(itemPool) do
            if(itemData.weight>itemData.removeOn) then
                maxWeight = maxWeight+itemData.weight

                local item = itemConf:GetCollectible(itemData.itemID)
                if(item and item.Quality>=4) then
                    q4Weight = q4Weight+itemData.weight
                end
            end
        end

        local chance = math.floor((q4Weight/maxWeight)*1000)/10
        
        return 0, (tostring(chance).."%")
    end,
    function(pos) -- GOLD PILL CHANCE
        local chance = math.floor(mod:getGoldenChance()*1000)/10
        
        return 2, (tostring(chance).."%")
    end,
    function(pos) -- HORSE PILL CHANCE
        local chance = math.floor(mod:getHorseChance()*1000)/10
        
        return 11, (tostring(chance).."%")
    end,
    function(pos) -- TEAR NUM
        return 6, tostring(getNumTears(Isaac.GetPlayer())*1/1)
    end,
    function(pos) -- SPLIT NUM
        local pl = Isaac.GetPlayer()
        local numTears = getNumTears(pl)

        local numSplitTears = numTears
        if(pl:HasCollectible(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE)) then
            numSplitTears = numSplitTears*3
        end
        if(pl:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE)) then
            numSplitTears = numSplitTears*3
        end
        if(pl:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY)) then
            numSplitTears = numSplitTears*5
        end

        if(pl:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)) then
            numSplitTears = numSplitTears*9.5
        end
        
        return 5, tostring(math.floor((numSplitTears-numTears)*100)/100)
    end,
    function(pos) -- GOLD TRINKET CHANCE
        return 4, "2.0%"
    end,
    function(pos) -- CHAMPION CHANCE
        local pl = Isaac.GetPlayer()
    
        local baseChance = 0.05+(pl:HasCollectible(CollectibleType.COLLECTIBLE_CHAMPION_BELT) and 0.15 or 0)
        if(Game():GetLevel():GetStage()==LevelStage.STAGE7) then
            baseChance = 0.75
        end

        local purpleHeartNum = pl:GetTrinketMultiplier(TrinketType.TRINKET_PURPLE_HEART)
        if(purpleHeartNum>1) then
            purpleHeartNum = 1+(purpleHeartNum-1)*2
        end
    
        return 3, tostring(math.floor(math.min(1, baseChance*(1+purpleHeartNum))*1000)/10).."%"
    end,
    function(pos) -- AVERAGE QUALITY STAT
        local itemConf = Isaac.GetItemConfig()
        local itemPool = Game():GetItemPool()

        local qualities = {}

        for i=1, itemConf:GetCollectibles().Size-1 do
            local curItem = itemConf:GetCollectible(i)

            if(curItem and curItem.ID and itemPool:HasCollectible(curItem.ID)) then
                qualities[curItem.Quality] = (qualities[curItem.Quality] or 0)+1
            end
        end

        local numQualities = 0
        local sumQualities = 0

        for qual, num in pairs(qualities) do
            numQualities = numQualities+num
            sumQualities = sumQualities+qual*num
        end
    
        return 8, tostring(math.floor(sumQualities/numQualities*100)/100)
    end,
    function(pos) -- ACCURACY STAT
        local tearsHit = mod:getEntityData(Isaac.GetPlayer(), "MATTMAN_CHANCE_TEARS_HIT") or 0
        local tearsDead = mod:getEntityData(Isaac.GetPlayer(), "MATTMAN_CHANCE_TEARS_DIED") or 0
    
        return 1, tostring(math.floor(tearsHit/math.max(1,tearsDead)*1000)/10).."%"
    end,
    function(pos) -- DONATION STAT
    
        return 9, tostring(persistentData:GetEventCounter(EventCounter.DONATION_MACHINE_COUNTER)%1000*10/10)
    end,
    function(pos) -- TINTED SKULL CHANCE
        local chance = 0
        if(persistentData:Unlocked(Achievement.STRANGE_DOOR)) then
            local level = Game():GetLevel()
            if(level:GetStage()==LevelStage.STAGE3_2 and Game().Difficulty<Difficulty.DIFFICULTY_GREED) then
                if(level:GetStageType()<StageType.STAGETYPE_REPENTANCE) then
                    chance = 1
                end
            end
        end
    
        return 10, tostring(math.floor(chance*1000)/10).."%"
    end,
    function(pos) -- EDEB TIJEB  STAT
        local tokens = persistentData:GetEventCounter(EventCounter.EDEN_TOKENS)
        local numDiv = 0
        while(tokens>=1000) do
            tokens = tokens/1000
            numDiv = numDiv+1
        end

        tokens = math.floor(tokens*10/10)

        local suffixes = {
            [0]="", "K","M","B","T","Q"
        }
    
        return 21, tostring(tokens*1/1)..suffixes[mod:clamp(numDiv,0,#suffixes)]
    end,
    function(pos) -- BABY PLUM SPARE CHANCE
        return 20, tostring(100-math.floor(persistentData:GetBestiaryKillCount(EntityType.ENTITY_BABY_PLUM,0)/math.max(persistentData:GetBestiaryEncounterCount(EntityType.ENTITY_BABY_PLUM,0))*1000)/10).."%"
    end,
    function(pos) -- LAMB KILS STAT
        return 18, tostring((persistentData:GetEventCounter(EventCounter.LAMB_KILLS)-(mod:getExtraData("MATTMAN_CHANCE_LAMB_KILLS") or 0))*1/1)
    end,
    function(pos) -- VICTORY LAPS STAT
        return 19, tostring(Game():GetVictoryLap()*1/1)
    end,
    function(pos) -- HUSH TIMER STAT
        local timeDif = math.max(0, Game().BlueWombParTime-Game().TimeCounter)

        local frames = timeDif%30
        timeDif = timeDif//30
        local seconds = timeDif%60
        timeDif = timeDif//60

        if(seconds<10) then seconds = "0"..tostring(seconds) end
    
        return 17, tostring(timeDif)..":"..tostring(seconds).."."..math.floor(frames/30*10)
    end,
    function(pos) -- BASE DAMAGE STAT
        local pt = Isaac.GetPlayer():GetPlayerType()
        local plEntry = XMLData.GetEntryById(XMLNode.PLAYER, pt)

        local dmg = 3.5
        if(plEntry.damagemodifier) then
            dmg = dmg-plEntry.damagemodifier
        end

        local playerMults = {
            [PlayerType.PLAYER_MAGDALENE_B] = 0.75,
            [PlayerType.PLAYER_BLUEBABY] = 1.05,
            [PlayerType.PLAYER_KEEPER] = 1.2,
            [PlayerType.PLAYER_CAIN] = 1.2,
            [PlayerType.PLAYER_CAIN_B] = 1.2,
            [PlayerType.PLAYER_EVE_B] = 1.2,
            [PlayerType.PLAYER_JUDAS] = 1.35,
            [PlayerType.PLAYER_AZAZEL] = 1.5,
            [PlayerType.PLAYER_THEFORGOTTEN] = 1.5,
            [PlayerType.PLAYER_AZAZEL_B] = 1.5,
            [PlayerType.PLAYER_THEFORGOTTEN_B] = 1.5,
            [PlayerType.PLAYER_LAZARUS2_B] = 1.5,
            [PlayerType.PLAYER_LAZARUS2] = 1.4,
            [PlayerType.PLAYER_THELOST_B] = 1.3,
            [PlayerType.PLAYER_BLACKJUDAS] = 2,
        }
        if(playerMults[pt]) then
            dmg = dmg*playerMults[pt]
        end

        return 16, string.format("%.2f", dmg)
    end,
    function(pos) -- BLUE FLIES STAT
        local plHash = GetPtrHash(Isaac.GetPlayer())

        local num = 0
        for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY)) do
            if(ent:ToFamiliar().Player and GetPtrHash(ent:ToFamiliar().Player)==plHash) then
                num = num+1
            end
        end

        return 15, tostring(num*1/1)
    end,
    function(pos) -- ACTIVE PERCENTAGE STAT
        local pl = Isaac.GetPlayer()

        local numActives = 0
        local charge = 0

        for _, slot in pairs(ActiveSlot) do
            if(pl:GetActiveItem(slot)~=0) then
                numActives = numActives+1
                charge = charge+(pl:GetTotalActiveCharge(slot))/math.max(pl:GetActiveMaxCharge(slot), 1)
            end
        end

        return 14, tostring(math.floor(charge/math.max(numActives, 1)*1000)/10).."%"
    end,
    function(pos) -- NUMBER POLAROIDS STAT
        local pl = Isaac.GetPlayer()

        local num = pl:GetCollectibleNum(CollectibleType.COLLECTIBLE_POLAROID)
        num = num+pl:GetCollectibleNum(CollectibleType.COLLECTIBLE_NEGATIVE)*0.472

        return 13, string.format("%.2f", num)
    end,
    function(pos) -- PLANETARIUM CHANCE
        return 12, tostring(math.floor(Game():GetLevel():GetPlanetariumChance()*1000)/10).."%"
    end,
    function(pos) -- DELIRIUM CHANCE
        if(Game():GetLevel():GetStage()~=LevelStage.STAGE7) then return end

        local numUnvisitedBossRooms = 0
        local deliriumNotVisited = 1

        for i=0, 168 do
            local room = Game():GetLevel():GetRoomByIdx(i, -1)

            if(room and room.Data and room.Data.Type==RoomType.ROOM_BOSS) then
                if(room.VisitedCount<=0) then
                    if(room.DeliriumDistance~=1) then
                        numUnvisitedBossRooms = numUnvisitedBossRooms+1
                    end
                else
                    if(room.DeliriumDistance==1) then
                        deliriumNotVisited = 0
                        numUnvisitedBossRooms = 1
                        break
                    end
                end
            end
        end
    
        return 7, tostring(math.floor(deliriumNotVisited/numUnvisitedBossRooms*1000)/10).."%", Vector(0, MAX_STATS_PER_LINE)
    end,
}

local function postHudRender(_)
    if(not mod.CONFIG.MORE_STATS) then return end
    if(not Game():GetHUD():IsVisible()) then return end

    local pos = Vector(20,12)*Options.HUDOffset + Vector(0,88)
    if(Game():GetNumPlayers()>1) then
        pos = pos+Vector(0,12)

        if(Isaac.GetPlayer():GetPlayerType()==PlayerType.PLAYER_JACOB) then
            pos = pos+Vector(0,14)
        end
        if(PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BLUEBABY_B)) then
            pos = pos+Vector(0,8)
        end
    end
    if(PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BETHANY)) then
        pos = pos+Vector(0,8)
    end
    if(PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BETHANY_B)) then
        pos = pos+Vector(0,8)
    end
    if(Game().Difficulty==Difficulty.DIFFICULTY_NORMAL and not Game():AchievementUnlocksDisallowed()) then
        pos = pos-Vector(0,16)
    end
    local startPos = Vector(0,9)

    if(PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DUALITY)) then
        startPos.Y = startPos.Y-1
    end
    if(REPENTOGON and (not persistentData:Unlocked(Achievement.PLANETARIUMS) or not Options.StatHUDPlanetarium)) then
        startPos.Y = startPos.Y-1
    end

    for _, renderFunc in ipairs(newStats) do
        local currentPos = pos+startPos*STAT_IDX_OFFSET

        local frame, text, overridePos = renderFunc(currentPos)
        if(frame and frame>=0) then
            if(overridePos) then
                currentPos = pos+overridePos*STAT_IDX_OFFSET
            end

            statsSprite:SetFrame(frame)
            statsSprite:Render(currentPos)
            f:DrawString(text, currentPos.X+16, currentPos.Y, KColor(1,1,1,0.5))

            if(not overridePos) then
                startPos.X = startPos.X+(startPos.Y+1)//MAX_STATS_PER_LINE
                startPos.Y = (startPos.Y+1)%MAX_STATS_PER_LINE
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, postHudRender)
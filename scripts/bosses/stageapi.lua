local mod = MilcomMOD

if(not (StageAPI and StageAPI.Loaded)) then return end



local bosses = {
    StageAPI.AddBossData("Shygals", {
        Name = "Shygals",
        Portrait = "gfx/bosses/shygals/boss_shygals.png",
        Offset = Vector(0,0),
        Bossname = "gfx/bosses/shygals/boss_shygals_name.png",
        Rooms = StageAPI.RoomsList("ToyboxShygalsRooms", include("resources.luarooms.boss_shygals")),
        Entity = {Type = mod.NPC_MAIN, Variant = mod.BOSS_SHYGALS},
    }),
}

StageAPI.AddBossToBaseFloorPool({BossID = "Shygals", Weight = 1.1}, LevelStage.STAGE2_1, StageType.STAGETYPE_ORIGINAL)
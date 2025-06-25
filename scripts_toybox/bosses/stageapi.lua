

if(not (StageAPI and StageAPI.Loaded)) then return end

local bosses = {
    StageAPI.AddBossData("Shy Gal", {
        Name = "Shy Gal",
        Portrait = "gfx_tb/bosses/shygals/boss_shygals.png",
        Offset = Vector(0,0),
        Bossname = "gfx_tb/bosses/shygals/boss_shygals_name.png",
        Rooms = StageAPI.RoomsList("ToyboxShygalsRooms", include("resources.luarooms.boss_shygals")),
        Entity = {Type = ToyboxMod.NPC_BOSS, Variant = ToyboxMod.BOSS_SHYGAL},
    }),
}

--StageAPI.AddBossToBaseFloorPool({BossID = "Shy Gal", Weight = 1.1}, LevelStage.STAGE2_1, StageType.STAGETYPE_ORIGINAL)
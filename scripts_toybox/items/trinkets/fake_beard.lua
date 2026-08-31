local SWING_CHANGE = 0.2

local function giveAxeOnKill(_, npc)
    local pl = PlayerManager.GetRandomTrinketOwner(ToyboxMod.TRINKET_FAKE_BEARD, npc:GetDropRNG():Next())
    if(not pl) then return end

    local chance = pl:GetTrinketMultiplier(ToyboxMod.TRINKET_FAKE_BEARD)*SWING_CHANGE
    if(pl:GetTrinketRNG(ToyboxMod.TRINKET_FAKE_BEARD):RandomFloat()<chance) then
        pl:SetInnateCollectibleGroup("FakeBeard", { [CollectibleType.COLLECTIBLE_NOTCHED_AXE] = 1 })
        pl:AddControlsCooldown(2)
        pl:UseActiveItem(CollectibleType.COLLECTIBLE_NOTCHED_AXE, UseFlag.USE_MIMIC)

        Isaac.CreateTimer(function()
            local weap = pl and pl:GetWeapon(0)
            if(weap and weap:GetWeaponType()==WeaponType.WEAPON_NOTCHED_AXE) then
                weap:SetFireDelay(5)
            end
        end, 0, 1, false)
        
        ToyboxMod.SFX:Play(ToyboxMod.SFX_EQUIP, 1.2)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, giveAxeOnKill)

local function clearInnateAxe(_, player)
    if(player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_NOTCHED_AXE, "FakeBeard")>0) then
        if(not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_NOTCHED_AXE)) then
            player:ClearInnateItemGroup("FakeBeard")
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, clearInnateAxe)
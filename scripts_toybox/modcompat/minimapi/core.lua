if(not MinimapAPI) then return end

local iconf = Isaac.GetItemConfig()
local function isCanTripped()
	return MinimapAPI.isRepentance and Isaac.GetChallenge() == Challenge.CHALLENGE_CANTRIPPED
end

--- ICONS!
local ICONS_SPRITE = Sprite("gfx_tb/ui/ui_minimapi_icons.anm2")

MinimapAPI:AddIcon("ToyboxPokemonCard", ICONS_SPRITE, "IconCards", 0)
MinimapAPI:AddIcon("ToyboxYugiohCard", ICONS_SPRITE, "IconCards", 1)
MinimapAPI:AddIcon("ToyboxSpectralCard", ICONS_SPRITE, "IconCards", 2)
MinimapAPI:AddIcon("ToyboxAppleCard", ICONS_SPRITE, "IconCards", 3)
MinimapAPI:AddIcon("ToyboxAltCard", ICONS_SPRITE, "IconCards", 4)
MinimapAPI:AddIcon("ToyboxRockMantle", ICONS_SPRITE, "IconCards", 5)
MinimapAPI:AddIcon("ToyboxPoopMantle", ICONS_SPRITE, "IconCards", 6)
MinimapAPI:AddIcon("ToyboxDarkMantle", ICONS_SPRITE, "IconCards", 7)
MinimapAPI:AddIcon("ToyboxHolyMantle", ICONS_SPRITE, "IconCards", 8)
MinimapAPI:AddIcon("ToyboxSaltMantle", ICONS_SPRITE, "IconCards", 9)
MinimapAPI:AddIcon("ToyboxGlassMantle", ICONS_SPRITE, "IconCards", 10)
MinimapAPI:AddIcon("ToyboxMetalMantle", ICONS_SPRITE, "IconCards", 11)
MinimapAPI:AddIcon("ToyboxGoldMantle", ICONS_SPRITE, "IconCards", 12)
MinimapAPI:AddIcon("ToyboxBoneMantle", ICONS_SPRITE, "IconCards", 13)

MinimapAPI:AddIcon("ToyboxLonelyKey", ICONS_SPRITE, "IconPickups", 0)
MinimapAPI:AddIcon("ToyboxInk1", ICONS_SPRITE, "IconPickups", 1)
MinimapAPI:AddIcon("ToyboxInk2", ICONS_SPRITE, "IconPickups", 2)
MinimapAPI:AddIcon("ToyboxSmorgasbord", ICONS_SPRITE, "IconPickups", 3)

MinimapAPI:AddIcon("ToyboxPyramidSlot", ICONS_SPRITE, "IconSlots", 0)
MinimapAPI:AddIcon("ToyboxFountainSlot", ICONS_SPRITE, "IconSlots", 1)

MinimapAPI:AddIcon("ToyboxGraveyardRoom", ICONS_SPRITE, "IconRooms", 0)
MinimapAPI:AddIcon("ToyboxTempleRoom", ICONS_SPRITE, "IconRooms", 1)
MinimapAPI:AddIcon("ToyboxTreasureRoomLibrary", ICONS_SPRITE, "IconRooms", 2)
MinimapAPI:AddIcon("ToyboxTempleTrialRoom", ICONS_SPRITE, "IconRooms", 3)
MinimapAPI:AddIcon("ToyboxTempleTrialRoomInactive", ICONS_SPRITE, "IconRooms", 4)

--- PICKUPS!
MinimapAPI:AddPickup("ToyboxPokemonCard","ToyboxPokemonCard",5,300,-1,MinimapAPI.PickupNotCollected,"cards",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2801 end)
MinimapAPI:AddPickup("ToyboxYugiohCard","ToyboxYugiohCard",5,300,-1,MinimapAPI.PickupNotCollected,"cards",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2802 end)
MinimapAPI:AddPickup("ToyboxSpectralCard","ToyboxSpectralCard",5,300,-1,MinimapAPI.PickupNotCollected,"cards",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2803 end)
MinimapAPI:AddPickup("ToyboxAppleCard","ToyboxAppleCard",5,300,-1,MinimapAPI.PickupNotCollected,"cards",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2804 end)
MinimapAPI:AddPickup("ToyboxAltCard","ToyboxAltCard",5,300,-1,MinimapAPI.PickupNotCollected,"cards",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2805 end)
MinimapAPI:AddPickup("ToyboxRockMantle","ToyboxRockMantle",5,300,-1,MinimapAPI.PickupNotCollected,"mantles",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2837 end)
MinimapAPI:AddPickup("ToyboxPoopMantle","ToyboxPoopMantle",5,300,-1,MinimapAPI.PickupNotCollected,"mantles",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2838 end)
MinimapAPI:AddPickup("ToyboxBoneMantle","ToyboxBoneMantle",5,300,-1,MinimapAPI.PickupNotCollected,"mantles",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2839 end)
MinimapAPI:AddPickup("ToyboxDarkMantle","ToyboxDarkMantle",5,300,-1,MinimapAPI.PickupNotCollected,"mantles",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2840 end)
MinimapAPI:AddPickup("ToyboxHolyMantle","ToyboxHolyMantle",5,300,-1,MinimapAPI.PickupNotCollected,"mantles",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2841 end)
MinimapAPI:AddPickup("ToyboxSaltMantle","ToyboxSaltMantle",5,300,-1,MinimapAPI.PickupNotCollected,"mantles",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2842 end)
MinimapAPI:AddPickup("ToyboxGlassMantle","ToyboxGlassMantle",5,300,-1,MinimapAPI.PickupNotCollected,"mantles",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2843 end)
MinimapAPI:AddPickup("ToyboxMetalMantle","ToyboxMetalMantle",5,300,-1,MinimapAPI.PickupNotCollected,"mantles",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2844 end)
MinimapAPI:AddPickup("ToyboxGoldMantle","ToyboxGoldMantle",5,300,-1,MinimapAPI.PickupNotCollected,"mantles",10001,function(p) return not isCanTripped() and iconf:GetCard(p.SubType).PickupSubtype == 2845 end)

MinimapAPI:AddPickup("ToyboxLonelyKey","ToyboxLonelyKey",5,ToyboxMod.PICKUP_LONELY_KEY,0,MinimapAPI.PickupNotCollected,"keys",8000)
MinimapAPI:AddPickup("ToyboxInk1","ToyboxInk1",5,20,ToyboxMod.PICKUP_COIN_INK_1,MinimapAPI.PickupNotCollected,"coins",5001)
MinimapAPI:AddPickup("ToyboxInk2","ToyboxInk2",5,20,ToyboxMod.PICKUP_COIN_INK_2,MinimapAPI.PickupNotCollected,"coins",5051)
MinimapAPI:AddPickup("ToyboxSmorgasbord","ToyboxSmorgasbord",5,ToyboxMod.PICKUP_SMORGASBORD,-1,MinimapAPI.PickupNotCollected,"smorgasbord")

MinimapAPI:AddPickup("ToyboxPyramidSlot","ToyboxPyramidSlot",6,ToyboxMod.SLOT_PYRAMID_DONATION,-1,MinimapAPI.PickupSlotMachineNotBroken,"slots",3000)
MinimapAPI:AddPickup("ToyboxFountainSlot","ToyboxFountainSlot",6,ToyboxMod.SLOT_JUICE_FOUNTAIN,-1,MinimapAPI.PickupSlotMachineNotBroken,"slots",3001)
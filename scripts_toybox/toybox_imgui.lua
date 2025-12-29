

local function getOptionID(name)
	return "ToyboxOption"..name
end

--[ [
if(not ImGui.ElementExists("ToyboxMenu")) then
    ImGui.CreateMenu("ToyboxMenu", "\u{f552} Toybox")

    ImGui.AddElement("ToyboxMenu", "ToyboxOptionsTab", ImGuiElement.MenuItem, "\u{f7d9} Options")
    ImGui.CreateWindow("ToyboxOptionsWindow", "Options")
    ImGui.LinkWindowToElement("ToyboxOptionsWindow", "ToyboxOptionsTab")

	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped, "GENERAL OPTIONS")
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)

	do -- CHAMPION CHANCE
		local optionID = getOptionID("ChampionChance")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"Toybox Champion Chance"
		)
		ImGui.AddSliderFloat("ToyboxOptionsWindow", optionID, "", nil, 0.05, 0, 1, "%.2f")
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, ToyboxMod.CONFIG.MOD_CHAMPION_CHANCE)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				ToyboxMod.CONFIG.MOD_CHAMPION_CHANCE = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"The chance for a Toybox champion to replace a vanilla champion (if unlocked, or if playing as Milcom).\n(Toybox champions are currently unlocked by default)"
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	do -- MANTLE WEIGHT
		local optionID = getOptionID("MantleWeight")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"Mantle Weight"
		)
		ImGui.AddSliderFloat("ToyboxOptionsWindow", optionID, "", nil, 0.5, 0, 2, "%.1f")
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, ToyboxMod.CONFIG.MANTLE_WEIGHT)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				ToyboxMod.CONFIG.MANTLE_WEIGHT = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"The weight of Mantle consumables (if unlocked)"
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	do -- ALPHABET BOX DESC
		local optionID = getOptionID("AlphabetBoxDescriptionPreview")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"Alphabet Box - EID Description Previews"
		)
		ImGui.AddSliderInteger("ToyboxOptionsWindow", optionID, "", nil, 3, 0, 10)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, ToyboxMod.CONFIG.ALPHABETBOX_EID_DISPLAYS)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				ToyboxMod.CONFIG.ALPHABETBOX_EID_DISPLAYS = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"How many items should be previewed in item descriptions while Alphabet Box is held? (Only works if you have EID!)"
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	do -- GOOD JUICE LAG
		local optionID = getOptionID("GoodJuiceLag")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"The Good Juice - Lag Reduction"
		)
		ImGui.AddCombobox("ToyboxOptionsWindow", optionID, "", nil, {"All Particles", "Reduced Particles", "No Particles"}, 0, false)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, ToyboxMod.CONFIG.GOOD_JUICE_LESSLAG)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				ToyboxMod.CONFIG.GOOD_JUICE_LESSLAG = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"Helps reduce lag caused by Good Juice."
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	ImGui.AddText("ToyboxOptionsWindow", "", true, "")
	ImGui.AddText("ToyboxOptionsWindow", "", true, "")
	
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped, "VANILLA TWEAKS")
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)

	do -- GOOD JUICE LAG
		local optionID = getOptionID("GreedChampions")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"Greed Mode Champions"
		)
		ImGui.AddCheckbox("ToyboxOptionsWindow", optionID, "", nil, true)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, ToyboxMod.CONFIG.CHAMPIONS_IN_GREED)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				ToyboxMod.CONFIG.CHAMPIONS_IN_GREED = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"Should champions be able to spawn in Greed Mode?"
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	ImGui.AddText("ToyboxOptionsWindow", "", true, "")
	ImGui.AddText("ToyboxOptionsWindow", "", true, "")

	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped, "FORTNITE FUNNIES")
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)

	do -- MORE STATS
		local optionID = getOptionID("MoreStats")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"More Stats"
		)
		ImGui.AddCheckbox("ToyboxOptionsWindow", optionID, "", nil, false)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, ToyboxMod.CONFIG.MORE_STATS)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				ToyboxMod.CONFIG.MORE_STATS = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"Adds more stats to the UI."
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	do -- ITEM SHADER
		local optionID = getOptionID("EpicItemShaders")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"Cool Item Shader"
		)
		ImGui.AddCombobox("ToyboxOptionsWindow", optionID, "", nil, {"None", "Retro", "Gold (QUALITY 5!)"}, 0, false)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, ToyboxMod.CONFIG.EPIC_ITEM_MODE)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				ToyboxMod.CONFIG.EPIC_ITEM_MODE = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"Applies a cool shader to all spawned items."
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	do -- ITEM SHADER
		local optionID = getOptionID("DadsSlipperColor")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"Dad's Slipper Color"
		)
		ImGui.AddInputColor("ToyboxOptionsWindow", optionID, "", nil, 135/255, 150/255, 189/255)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function(r,g,b)
				ToyboxMod.CONFIG.DADS_SLIPPER_COLOR = Color(r,g,b)
			end
		)

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"Changes the color of Dad's Slipper."
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	do -- MORE STATS
		local optionID = getOptionID("SuperRETROMode")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"Super RETRO Mode"
		)
		ImGui.AddCheckbox("ToyboxOptionsWindow", optionID, "", nil, false)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, ToyboxMod.CONFIG.SUPER_RETROFALL_BROS)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				ToyboxMod.CONFIG.SUPER_RETROFALL_BROS = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"Makes RETROFALL mimic a random dice instead of just The D6."
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	ImGui.AddText("ToyboxOptionsWindow", "", true, "")
	ImGui.AddText("ToyboxOptionsWindow", "", true, "")


	--! UNLOCKS

	ImGui.AddElement("ToyboxMenu", "ToyboxUnlocksTab", ImGuiElement.MenuItem, "\u{f3c1} Unlocks")
    ImGui.CreateWindow("ToyboxUnlocksWindow", "Unlocks")
    ImGui.LinkWindowToElement("ToyboxUnlocksWindow", "ToyboxUnlocksTab")

	local function addPlayerMarkUnlock(playerType, compType, playerName, compName, unlockName)
		local optionID = getOptionID(playerName..compName)

		--ImGui.AddElement("ToyboxUnlocksWindow", "", ImGuiElement.Text, compName)
		ImGui.AddCombobox("ToyboxUnlocksWindow", optionID, compName, nil, {"Not Complete", "Normal Mode", "Hard Mode"}, 0, true)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, Isaac.GetCompletionMark(playerType, compType))
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				Isaac.SetCompletionMark(playerType, compType, v)
				ToyboxMod:checkUnlocks(true, true)
			end
		)
		ImGui.SetTooltip(optionID, unlockName)
		ImGui.AddElement("ToyboxUnlocksWindow", "", ImGuiElement.Separator)
	end
	local function addPlayerUnlocks(playerType, playerName, unlockTable)
		ImGui.AddElement("ToyboxUnlocksWindow", "", ImGuiElement.Separator)
		ImGui.AddElement("ToyboxUnlocksWindow", "", ImGuiElement.TextWrapped, playerName .. " UNLOCKS")
		ImGui.AddElement("ToyboxUnlocksWindow", "", ImGuiElement.Separator)

		ImGui.AddButton("ToyboxUnlocksWindow", getOptionID(playerName.."All Marks"), "All Marks", nil, false)
		ImGui.AddCallback(getOptionID(playerName.."All Marks"),
			ImGuiCallback.Clicked,
			function()
				Isaac.FillCompletionMarks(playerType)
				ToyboxMod:checkUnlocks(true, true)
			end
		)
		ImGui.SetTooltip(getOptionID(playerName.."All Marks"), unlockTable.ALL_MARKS)
		ImGui.SetHelpmarker(getOptionID(playerName.."All Marks"), "Forces full Hard Mode completion.")
		ImGui.AddElement("ToyboxUnlocksWindow", "", ImGuiElement.Separator)

		addPlayerMarkUnlock(playerType, CompletionType.BOSS_RUSH, playerName, "Boss Rush", unlockTable[CompletionType.BOSS_RUSH])
		addPlayerMarkUnlock(playerType, CompletionType.MOMS_HEART, playerName, "Mom's Heart", unlockTable[CompletionType.MOMS_HEART])
		addPlayerMarkUnlock(playerType, CompletionType.HUSH, playerName, "Hush", unlockTable[CompletionType.HUSH])
		addPlayerMarkUnlock(playerType, CompletionType.ISAAC, playerName, "Isaac", unlockTable[CompletionType.ISAAC])
		addPlayerMarkUnlock(playerType, CompletionType.BLUE_BABY, playerName, "Blue Baby", unlockTable[CompletionType.BLUE_BABY])
		addPlayerMarkUnlock(playerType, CompletionType.SATAN, playerName, "Satan", unlockTable[CompletionType.SATAN])
		addPlayerMarkUnlock(playerType, CompletionType.LAMB, playerName, "The Lamb", unlockTable[CompletionType.LAMB])
		addPlayerMarkUnlock(playerType, CompletionType.MEGA_SATAN, playerName, "Mega Satan", unlockTable[CompletionType.MEGA_SATAN])
		addPlayerMarkUnlock(playerType, CompletionType.ULTRA_GREED, playerName, "Greed", unlockTable[CompletionType.ULTRA_GREED])
		--addPlayerMarkUnlock(playerType, CompletionType.ULTRA_GREEDIER, playerName, "Greedier", unlockTable[CompletionType.ULTRA_GREEDIER])
		addPlayerMarkUnlock(playerType, CompletionType.DELIRIUM, playerName, "Delirium", unlockTable[CompletionType.DELIRIUM])
		addPlayerMarkUnlock(playerType, CompletionType.MOTHER, playerName, "Mother", unlockTable[CompletionType.MOTHER])
		addPlayerMarkUnlock(playerType, CompletionType.BEAST, playerName, "The Beast", unlockTable[CompletionType.BEAST])

		ImGui.AddText("ToyboxUnlocksWindow", "", true, "")
		ImGui.AddText("ToyboxUnlocksWindow", "", true, "")
	end

	addPlayerUnlocks(ToyboxMod.PLAYER_ATLAS_A, "ATLAS",
		{
			[CompletionType.BOSS_RUSH] = "\"Rock Candy\"",
			[CompletionType.MOMS_HEART] = "Nothing.",
			[CompletionType.HUSH] = "\"Saltpeter\"",
			[CompletionType.ISAAC] = "\"Ascension\"",
			[CompletionType.BLUE_BABY] = "\"Glass Vessel\"",
			[CompletionType.SATAN] = "\"Missing Page 3\"",
			[CompletionType.LAMB] = "\"Bone Boy\"!",
			[CompletionType.MEGA_SATAN] = "Mantles may appear for other characters.",
			[CompletionType.ULTRA_GREED] = "Normal: \"Gilded Apple\" / Hard: \"Prismstone\"",
			[CompletionType.DELIRIUM] = "\"Hostile Takeover\"",
			[CompletionType.MOTHER] = "\"Amber Fossil\"",
			[CompletionType.BEAST] = "\"Steel Soul\"",
			ALL_MARKS = "Atlas starts with \"Miracle Mantle\". (not added yet)",
		}
	)

	addPlayerUnlocks(ToyboxMod.PLAYER_JONAS_A, "JONAS",
		{
			[CompletionType.BOSS_RUSH] = "\"Jonas' Lock\"",
			[CompletionType.MOMS_HEART] = "Nothing.",
			[CompletionType.HUSH] = "\"Antibiotics\"",
			[CompletionType.ISAAC] = "\"Dad's Prescription\"",
			[CompletionType.BLUE_BABY] = "\"Food Stamps\"",
			[CompletionType.SATAN] = "\"Dr. Bum\"",
			[CompletionType.LAMB] = "\"Clown PHD\"",
			[CompletionType.MEGA_SATAN] = "Jonas' new pill effects may appear while playing as other characters.",
			[CompletionType.ULTRA_GREED] = "Normal: \"Drill\" / Hard: \"Foil Card\"",
			[CompletionType.DELIRIUM] = "\"Giant Capsule\"",
			[CompletionType.MOTHER] = "\"Candy Dispenser\"",
			[CompletionType.BEAST] = "\"Jonas' Mask\"",
			ALL_MARKS = "Nothing.",
		}
	)

	addPlayerUnlocks(ToyboxMod.PLAYER_MILCOM_A, "MILCOM",
		{
			[CompletionType.BOSS_RUSH] = "\"Delivery Box\"",
			[CompletionType.MOMS_HEART] = "Nothing.",
			[CompletionType.HUSH] = "\"Oil Painting\"",
			[CompletionType.ISAAC] = "\"Divided Justice\"",
			[CompletionType.BLUE_BABY] = "\"Paper Plate\"",
			[CompletionType.SATAN] = "\"Misprint\"",
			[CompletionType.LAMB] = "\"Atheism\"",
			[CompletionType.MEGA_SATAN] = "Milcom's new champion colors may appear while playing as other characters.",
			[CompletionType.ULTRA_GREED] = "Normal: \"Golden Calf\" / Hard: \"Green Apple\"",
			[CompletionType.DELIRIUM] = "\"Malice\"",
			[CompletionType.MOTHER] = "\"Effigy\"",
			[CompletionType.BEAST] = "\"Cutout\"",
			ALL_MARKS = "Nothing.",
		}
	)
end
--]]

--[[
    return function()

	if not ImGui.ElementExists('remixMenu') then
		ImGui.CreateMenu('remixMenu', '\u{f5d1} CR')

		ImGui.AddElement('remixMenu', 'remixMenuOptions', ImGuiElement.MenuItem, '\u{f7d9} Options')
		ImGui.CreateWindow('remixWindowOptions', 'Options')
		ImGui.LinkWindowToElement('remixWindowOptions', 'remixMenuOptions')

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.SeparatorText, "Cosmetic")
		
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- apple streaks
			local id = 'remixMenuOptionsAppleStreaks'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Apple Streaks', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.apple_streaks)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.apple_streaks = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "The Apple displays which mode youre in on-screen when activated.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- hud papers
			local id = 'remixMenuOptionsHUDPapers'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Paper HUD', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.hud_papers)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.hud_papers = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Adds a paper backdrop to the HUD for visibility.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- tear sfx
			local id = 'remixMenuOptionsTearSFX'

			ImGui.AddCombobox('remixWindowOptions', id, 'Tear Sounds', function(i, v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.tear_sounds = i
				end
			end, {"Rebirth", "Remix", "Flash"}, 1, true)

			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.tear_sounds)
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.SeparatorText, "Tweaks")

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- flash movement
			local id = 'remixMenuOptionsFlashMovement'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Flash Movement', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.flash_movement)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.flash_movement = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Makes Isaac's movement work the way it does pre-rebirth. Does nothing with gamepad.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- hybrid cam
			local id = 'remixMenuOptionsHybridCamera'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Hybrid Camera', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.hybrid_cam)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.hybrid_cam = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "The camera moves quickly to view where you are firing, and only where youre firing. Does not work if active cam is enabled.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- faster pickups
			local id = 'remixMenuOptionsFasterPickups'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Faster Pickups', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.faster_pickups)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.faster_pickups = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Pickups appear faster.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- friction pickups
			local id = 'remixMenuOptionsFrictionPickups'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Pickup Friction', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.pickup_friction)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.pickup_friction = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Pickups slide less.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- bfast tweak
			local id = 'remixMenuOptionsBfast'
			ImGui.AddCheckbox('remixWindowOptions', id, 'No Breakfasting', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.nobfast == nil then sd.cfg.nobfast = false end
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.nobfast)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.nobfast == nil then sd.cfg.nobfast = v end
					sd.cfg.nobfast = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Item pedestals which contain breakfast after emptying the item pool rapidly cycle between random items from the pool.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- disappearing pedestals
			local id = 'remixMenuOptionsNoPedestals'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Remove Empty Pedestals', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.nopedestal == nil then sd.cfg.nopedestal = false end
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.nopedestal)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.nopedestal == nil then sd.cfg.nopedestal = v end
					sd.cfg.nopedestal = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Item pedestals disappear immediately when emptied.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- eve buff
			local id = 'remixMenuOptionsEveBuff'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Eve Buff', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.eve_buff)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.eve_buff = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Eve now has 'Curse Stacks' which activate themselves and give decaying damage ups the next time you activate Whore of Babylon, and are reset/lost upon deactivation. These are acquired by clearing rooms while Whore of Babylon is inactive.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- samson buff
			local id = 'remixMenuOptionsSamsonBuff'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Samson Buff', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.samson_buff == nil then sd.cfg.samson_buff = false end
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.samson_buff)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.samson_buff == nil then sd.cfg.samson_buff = v end
					sd.cfg.samson_buff = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Starts with donkey jawbone after unlock.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- alt methods
			local id = 'remixMenuOptionsAltMethods'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Alt Character Unlock Methods', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.altmethods == nil then sd.cfg.altmethods = false end
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.altmethods)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.altmethods == nil then sd.cfg.altmethods = v end
					sd.cfg.altmethods = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Lost's mantle, Eve's razor, Maggy's pill, etc. can now be unlocked by beating Mega Satan in Insane Mode with the respective character.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

    end
end
]]
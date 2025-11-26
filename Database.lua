function SellValue_TSP:InitializeDB()
	-- Checking last added item to update the database
	if not SellValue_TradeSkillProfits or not SellValue_TradeSkillProfits.VendorItems or not SellValue_TradeSkillProfits.Profits then
		SellValue_TradeSkillProfits = {
			VendorItems = {
				-- Threads
				[2320]  = 0, -- "Coarse Thread",
				[2321]  = 0, -- "Fine Thread",
				[4291]  = 0, -- "Silken Thread",
				[8343]  = 0, -- "Heavy Silken Thread",
				[14341] = 0, -- "Rune Thread",
				-- Dyes
				[2324]  = 0, -- "Bleach",
				[2325]  = 0, -- "Black Dye",
				[2604]  = 0, -- "Red Dye",
				[2605]  = 0, -- "Green Dye",
				[4340]  = 0, -- "Gray Dye",
				[4341]  = 0, -- "Yellow Dye",
				[4342]  = 0, -- "Purple Dye",
				[6260]  = 0, -- "Blue Dye",
				[6261]  = 0, -- "Orange Dye",
				[10290] = 0, -- "Pink Dye",
				-- Leatherworking
				[4289] = 0, -- "Salt",
				-- Alchemy
				[3371]  = 0, -- "Empty Vial",
				[3372]  = 0, -- "Leaded Vial",
				[8925]  = 0, -- "Crystal Vial",
				[18256] = 0, -- "Imbued Vial",
				-- Blacksmithing / Smelting
				[2880]  = 0, -- "Weak Flux",
				[3466]  = 0, -- "Strong Flux",
				[3857]  = 0, -- "Coal Flux",
				[18567] = 0, -- "Elemental Flux",
				-- Engineering
				[4399] = 0, -- "Wooden Stock",
				[4400] = 0, -- "Heavy Stock",
				[10647] = 0, -- "Engineer's Ink",
				[10648] = 0, -- "Blank Parchment",
			},
			Profits = {}
		}
	end
end
function SellValue_TSP:InitializeDB()
	-- Checking last added item to update the database
	if not SellValue_TradeSkillProfits or not SellValue_TradeSkillProfits.VendorItems or not SellValue_TradeSkillProfits.Profits then
		SellValue_TradeSkillProfits = {
			VendorItems = {
				-- Threads
				[2320]  = {}, -- Coarse Thread
				[2321]  = {}, -- Fine Thread
				[4291]  = {}, -- Silken Thread
				[8343]  = {}, -- Heavy Silken Thread
				[14341] = {}, -- Rune Thread
				-- Dyes
				[2324]  = {}, -- Bleach
				[2325]  = {}, -- Black Dye
				[2604]  = {}, -- Red Dye
				[2605]  = {}, -- Green Dye
				[4340]  = {}, -- Gray Dye
				[4341]  = {}, -- Yellow Dye
				[4342]  = {}, -- Purple Dye
				[6260]  = {}, -- Blue Dye
				[6261]  = {}, -- Orange Dye
				[10290] = {}, -- Pink Dye
				-- Leatherworking
				[4289] = {}, -- Salt,
				-- Alchemy
				[3371]  = {}, -- Empty Vial
				[3372]  = {}, -- Leaded Vial
				[8925]  = {}, -- Crystal Vial
				[18256] = {}, -- Imbued Vial
				-- Blacksmithing / Smelting
				[2880]  = {}, -- Weak Flux
				[3466]  = {}, -- Strong Flux
				[3857]  = {}, -- Coal Flux
				[18567] = {}, -- Elemental Flux
				-- Engineering
				[4399] = {}, -- Wooden Stock
				[4400] = {}, -- Heavy Stock
				[10647] = {}, -- Engineer's Ink
				[10648] = {}, -- Blank Parchment
				-- Cooking
				[2678] = {}, -- Mild Spices
				[2692] = {}, -- Hot Spices
				[3713] = {}, -- Soothing Spices
				[159] = {}, -- Refreshing Spring Water
				[1179] = {}, -- Ice Cold Milk
				[4536] = {}, -- Shiny Red Apple
			},
			Profits = {}
		}
	end
end
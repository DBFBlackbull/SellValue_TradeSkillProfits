function SellValue_TSP:InitializeDB()
	-- Checking last added item to update the database
	if not SellValue_TradeSkillProfits or not SellValue_TradeSkillProfits.VendorItems or not SellValue_TradeSkillProfits.CraftedItems then
		SellValue_TradeSkillProfits = {
			VendorItems = {
				-- Threads
				[2320]  = {BuyPrices = {}, LastUpdated = 0}, -- Coarse Thread
				[2321]  = {BuyPrices = {}, LastUpdated = 0}, -- Fine Thread
				[4291]  = {BuyPrices = {}, LastUpdated = 0}, -- Silken Thread
				[8343]  = {BuyPrices = {}, LastUpdated = 0}, -- Heavy Silken Thread
				[14341] = {BuyPrices = {}, LastUpdated = 0}, -- Rune Thread
				-- Dyes
				[2324]  = {BuyPrices = {}, LastUpdated = 0}, -- Bleach
				[2325]  = {BuyPrices = {}, LastUpdated = 0}, -- Black Dye
				[2604]  = {BuyPrices = {}, LastUpdated = 0}, -- Red Dye
				[2605]  = {BuyPrices = {}, LastUpdated = 0}, -- Green Dye
				[4340]  = {BuyPrices = {}, LastUpdated = 0}, -- Gray Dye
				[4341]  = {BuyPrices = {}, LastUpdated = 0}, -- Yellow Dye
				[4342]  = {BuyPrices = {}, LastUpdated = 0}, -- Purple Dye
				[6260]  = {BuyPrices = {}, LastUpdated = 0}, -- Blue Dye
				[6261]  = {BuyPrices = {}, LastUpdated = 0}, -- Orange Dye
				[10290] = {BuyPrices = {}, LastUpdated = 0}, -- Pink Dye
				-- Leatherworking
				[4289] = {BuyPrices = {}, LastUpdated = 0}, -- Salt,
				-- Alchemy
				[3371]  = {BuyPrices = {}, LastUpdated = 0}, -- Empty Vial
				[3372]  = {BuyPrices = {}, LastUpdated = 0}, -- Leaded Vial
				[8925]  = {BuyPrices = {}, LastUpdated = 0}, -- Crystal Vial
				[18256] = {BuyPrices = {}, LastUpdated = 0}, -- Imbued Vial
				-- Blacksmithing / Smelting
				[2880]  = {BuyPrices = {}, LastUpdated = 0}, -- Weak Flux
				[3466]  = {BuyPrices = {}, LastUpdated = 0}, -- Strong Flux
				[3857]  = {BuyPrices = {}, LastUpdated = 0}, -- Coal Flux
				[18567] = {BuyPrices = {}, LastUpdated = 0}, -- Elemental Flux
				-- Engineering
				[4399]  = {BuyPrices = {}, LastUpdated = 0}, -- Wooden Stock
				[4400]  = {BuyPrices = {}, LastUpdated = 0}, -- Heavy Stock
				[10647] = {BuyPrices = {}, LastUpdated = 0}, -- Engineer's Ink
				[10648] = {BuyPrices = {}, LastUpdated = 0}, -- Blank Parchment
				-- Cooking
				[2678] = {BuyPrices = {}, LastUpdated = 0}, -- Mild Spices
				[2692] = {BuyPrices = {}, LastUpdated = 0}, -- Hot Spices
				[3713] = {BuyPrices = {}, LastUpdated = 0}, -- Soothing Spices
				[159]  = {BuyPrices = {}, LastUpdated = 0}, -- Refreshing Spring Water
				[1179] = {BuyPrices = {}, LastUpdated = 0}, -- Ice Cold Milk
				[4536] = {BuyPrices = {}, LastUpdated = 0}, -- Shiny Red Apple
			},
			CraftedItems = {}
		}
	end
end
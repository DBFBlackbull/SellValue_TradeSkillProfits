local _G = getfenv(0)
local function hooksecurefunc(arg1, arg2, arg3)
	if type(arg1) == "string" then
		arg1, arg2, arg3 = _G, arg1, arg2
	end
	local orig = arg1[arg2]
	arg1[arg2] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
		local x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20 = orig(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)

		arg3(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)

		return x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20
	end
end

SellValue_TSP = CreateFrame("Frame")
function SellValue_TSP:OnAddonLoaded()
	SellValue_TSP:InitializeDB()
end

function SellValue_TSP:OnAddonLoaded()
	self:UnregisterEvent("ADDON_LOADED")
	--self:RegisterEvent("MERCHANT_SHOW")

	self:InitializeDB()
	self:HookTooltip()
end

function SellValue_TSP:SetTooltip(tooltip, profitLow, profitHigh)
	local function colorProfit(profit)
		local color = GREEN_FONT_COLOR_CODE
		if profit < 0 then
			color = RED_FONT_COLOR_CODE
		end

		return color .. profit .. FONT_COLOR_CODE_CLOSE
	end

	local profitLowString = colorProfit(profitLow)
	local line = "Vendor Profit: " .. profitLowString
	if profitHigh ~= profitLow then
		local profitHighString = colorProfit(profitHigh)
		line = line .. " - " .. profitHighString
	end

	tooltip:AddLine(line)
	tooltip:Show()
end

local function contains(t, value)
	for _, v in ipairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

function SellValue_TSP:SaveProfits(craftedItemID, profitMin, profitMax)
	if not SellValue_TradeSkillProfits.Profits[craftedItemID] then
		SellValue_TradeSkillProfits.Profits[craftedItemID] = {}
	end

	if not contains(SellValue_TradeSkillProfits.Profits[craftedItemID], profitMin) then
		table.insert(SellValue_TradeSkillProfits.Profits[craftedItemID], profitMin)
	end
	if not contains(SellValue_TradeSkillProfits.Profits[craftedItemID], profitMax) then
		table.insert(SellValue_TradeSkillProfits.Profits[craftedItemID], profitMax)
	end
end

function SellValue_TSP:HookTooltip()
	-- Hook trade skill tooltip
	hooksecurefunc(GameTooltip, "SetTradeSkillItem", function(tip, tradeItemIndex, reagentIndex)
		-- mousing over a reagent
		if reagentIndex then
			return
		end

		-- the crafted item. Calculate profit
		local craftedItemID = SellValue_ItemIDFromLink(GetTradeSkillItemLink(tradeItemIndex))
		local craftedItemCount = GetTradeSkillNumMade(tradeItemIndex)

		local craftedItemValue = SellValues[craftedItemID] or 0
		local craftValue = craftedItemValue * craftedItemCount

		local totalReagentValueMin, totalReagentValueMax = 0
		for i = 1, GetTradeSkillNumReagents(tradeItemIndex) do
			local reagentItemID = SellValue_ItemIDFromLink(GetTradeSkillReagentItemLink(tradeItemIndex, i))
			local _, _, reagentCount = GetTradeSkillReagentInfo(tradeItemIndex, i)

			local vendorCost = SellValue_TradeSkillProfits.VendorItems[reagentItemID]
			if vendorCost and #vendorCost > 0 then -- # might not work. chat GPT says it does for true arrays. Else use table.getn(vendorCost)
				local minCost = math.min(unpack(vendorCost))
				local maxCost = math.max(unpack(vendorCost))

				totalReagentValueMin = totalReagentValueMin + (minCost * reagentCount)
				totalReagentValueMax = totalReagentValueMax + (maxCost * reagentCount)
			else
				local reagentItemValue = SellValues[reagentItemID] or 0
				local reagentValue = reagentItemValue * reagentCount

				totalReagentValueMin = totalReagentValueMin + reagentValue
				totalReagentValueMax = totalReagentValueMax + reagentValue
			end
		end

		local profitMin = craftValue - totalReagentValueMax
		local profitMax = craftValue - totalReagentValueMin

		SellValue_TSP:SaveProfits(craftedItemID, profitMin, profitMax)
		SellValue_TSP:SetTooltip(GameTooltip, profitMin, profitMax)
	end)

	-- Simple update for vendor items prices on mouse over
	hooksecurefunc(GameTooltip, "SetMerchantItem", function(tip, index)
		local itemID = SellValue_ItemIDFromLink(GetMerchantItemLink(index))
		local _, _, price, stackCount = GetMerchantItemInfo(index)
		if itemID and price and price > 0 and stackCount and stackCount > 0 then
			if not SellValue_TradeSkillProfits.VendorItems[itemID] then
				return
			end

			local pricePerItem = price / stackCount
			if not contains(SellValue_TradeSkillProfits.VendorItems[itemID], pricePerItem) then
				table.insert(SellValue_TradeSkillProfits.VendorItems[itemID], pricePerItem)
				table.sort(SellValue_TradeSkillProfits.VendorItems[itemID])
			end
		end
	end)

	--hooksecurefunc(GameTooltip, "SetCraftItem", function(self, skill, slot)
	--	SellValue_TSP:SetTooltip(GameTooltip, GetCraftReagentItemLink(skill, slot), 1)
	--end)
	--
	--hooksecurefunc(GameTooltip, "SetCraftSpell", function(self, slot)
	--	SellValue_TSP:SetTooltip(GameTooltip, GetCraftItemLink(slot), 1)
	--end)
end

function SellValue_TSP:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "SellValue" then
		return SellValue_TSP:OnAddonLoaded()
	end

	--if event == "MERCHANT_SHOW" then
	--	return SellValue_TSP:MerchantScan()
	--end
end


SellValue_TSP:SetScript("OnEvent", SellValue_TSP.OnEvent)
SellValue_TSP:RegisterEvent("ADDON_LOADED")


--function SellValue_SaveFor(bag, slot, itemID, money)
--	if not (bag and slot and itemID and money) then
--		return
--	end
--
--	local _, stackCount = GetContainerItemInfo(bag, slot)
--	if stackCount and stackCount > 0 then
--		local costOfOne = money / stackCount
--
--		if not SellValues then
--			SellValues = {}
--		end
--
--		SellValues[itemID] = costOfOne
--	end
--end

--function SellValue_TSP:MerchantScan()
--
--	for bag = 0, NUM_BAG_FRAMES do
--		for slot = 1, GetContainerNumSlots(bag) do
--
--			local itemID = SellValue_IDFromLink(GetContainerItemLink(bag, slot))
--			if itemID then
--				SellValue_LastItemMoney = 0
--				SellValue_Tooltip:SetBagItem(bag, slot)
--				SellValue_SaveFor(bag, slot, itemID, SellValue_LastItemMoney)
--			end  -- if item name
--		end  -- for slot
--	end -- for bag
--
--end

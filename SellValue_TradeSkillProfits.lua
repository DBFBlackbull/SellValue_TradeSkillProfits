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

local COPPER_PER_SILVER = 100
local COPPER_PER_GOLD = 10000
local GOLD_COLOR_CODE = "|cffffd100"
local SILVER_COLOR_CODE = "|cffe6e6e6"
local COPPER_COLOR_CODE = "|cffc8602c"

SellValue_TSP = CreateFrame("Frame")
function SellValue_TSP:Print(string)
	-- color maybe #FFD700
	DEFAULT_CHAT_FRAME:AddMessage(GOLD_COLOR_CODE.."[SellValue_TSP]: ".. FONT_COLOR_CODE_CLOSE .. tostring(string))
end

function SellValue_TSP:OnAddonLoaded()
	self:UnregisterEvent("ADDON_LOADED")
	--self:RegisterEvent("MERCHANT_SHOW")

	self:InitializeDB()
	self:HookTooltip()
end

local function moneyToGsc(money)
	local gold = math.floor(math.abs(money) / COPPER_PER_GOLD)
	local silver = math.floor(math.mod(math.abs(money), COPPER_PER_GOLD) / COPPER_PER_SILVER)
	local copper = math.mod(math.abs(money), COPPER_PER_SILVER)
	return gold, silver, copper
end

local function moneyToString(money, showSign)
	local g, s, c = moneyToGsc(money)

	local str = ""
	if g > 0 then
		str = str .. string.format("%s%d%sg", HIGHLIGHT_FONT_COLOR_CODE, g, GOLD_COLOR_CODE)
	end
	if s > 0 then
		str = str .. string.format("%s%d%ss", HIGHLIGHT_FONT_COLOR_CODE, s, SILVER_COLOR_CODE)
	end
	if c > 0 then
		str = str .. string.format("%s%d%sc", HIGHLIGHT_FONT_COLOR_CODE, c, COPPER_COLOR_CODE)
	end

	if showSign then
		if money > 0 then
			str = "+"..str
		else
			str = "-"..str
		end
	end

	return str
end

function SellValue_TSP:SetTooltipVendorPrice(tooltip, low, high)
	local vendorPrice = RED_FONT_COLOR_CODE .. "Vendor Price" .. FONT_COLOR_CODE_CLOSE

	local line = moneyToString(low)
	if low ~= high then
		line = line .. " — " .. moneyToString(high)
	end

	tooltip:AddLine(string.format("%s: %s", vendorPrice, line))
	tooltip:Show()
end

function SellValue_TSP:SetTooltipProfit(tooltip, low, high)
	local color = GREEN_FONT_COLOR_CODE
	if low < 0 then
		color = RED_FONT_COLOR_CODE
	end

	local vendorProfit = color .. "Vendor Profit" .. FONT_COLOR_CODE_CLOSE

	local line = moneyToString(low, true) .. FONT_COLOR_CODE_CLOSE
	if low ~= high then
		line = line .. " — " .. moneyToString(high, true)
	end

	tooltip:AddLine(string.format("%s: %s", vendorProfit, line))
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

function SellValue_TSP:InitializeProfits(craftedItemID)
	if not SellValue_TradeSkillProfits.CraftedItems[craftedItemID] then
		self:ResetProfits(craftedItemID)
	end
end

function SellValue_TSP:ResetProfits(craftedItemID)
	SellValue_TradeSkillProfits.CraftedItems[craftedItemID] = {
		Profits = {},
		LastUpdated = time()
	}
end

function SellValue_TSP:SaveProfits(craftedItemID, profitMin, profitMax)
	self:InitializeProfits(craftedItemID)

	local updated = false
	if not contains(SellValue_TradeSkillProfits.CraftedItems[craftedItemID].Profits, profitMin) then
		table.insert(SellValue_TradeSkillProfits.CraftedItems[craftedItemID].Profits, profitMin)
		updated = true
	end
	if not contains(SellValue_TradeSkillProfits.CraftedItems[craftedItemID].Profits, profitMax) then
		table.insert(SellValue_TradeSkillProfits.CraftedItems[craftedItemID].Profits, profitMax)
		updated = true
	end

	if updated then
		table.sort(SellValue_TradeSkillProfits.CraftedItems[craftedItemID].Profits)
		SellValue_TradeSkillProfits.CraftedItems[craftedItemID].LastUpdated = time()
	end
end

function SellValue_TSP:HookTooltip()
	-- Hook trade skill tooltip
	hooksecurefunc(GameTooltip, "SetTradeSkillItem", function(tip, tradeItemIndex, reagentIndex)
		-- mousing over a reagent. Maybe should be optional
		if reagentIndex then
			local reagentItemID = SellValue_ItemIDFromLink(GetTradeSkillReagentItemLink(tradeItemIndex, reagentIndex))
			local _, _, reagentCount = GetTradeSkillReagentInfo(tradeItemIndex, reagentIndex)
			local vendorPrices = SellValue_TradeSkillProfits.VendorPrices[reagentItemID]

			if vendorPrices and table.getn(vendorPrices) > 0 then
				local minCost = math.min(unpack(vendorPrices))
				local maxCost = math.max(unpack(vendorPrices))
				return self:SetTooltipVendorPrice(GameTooltip, minCost * reagentCount, maxCost * reagentCount)
			end

			local craftedReagent = SellValue_TradeSkillProfits.CraftedItems[reagentItemID]
			if craftedReagent then
				local minProfit = math.min(unpack(craftedReagent.Profits))
				local maxProfit = math.max(unpack(craftedReagent.Profits))
				if minProfit < 0 and maxProfit < 0 then
					return self:SetTooltipProfit(GameTooltip, minProfit * reagentCount, maxProfit * reagentCount)
				end
			end

			return
		end

		-- the crafted item. Calculate profit
		local craftedItemID = SellValue_ItemIDFromLink(GetTradeSkillItemLink(tradeItemIndex))
		local craftedItemCount = GetTradeSkillNumMade(tradeItemIndex)

		local craftedItemValue = SellValues[craftedItemID] or 0
		local craftValue = craftedItemValue * craftedItemCount

		local totalReagentValueMin, totalReagentValueMax = 0, 0
		for i = 1, GetTradeSkillNumReagents(tradeItemIndex) do
			local reagentItemID = SellValue_ItemIDFromLink(GetTradeSkillReagentItemLink(tradeItemIndex, i))
			local reagentName, _, reagentCount = GetTradeSkillReagentInfo(tradeItemIndex, i)
			local reagentVendorValue = SellValues[reagentItemID] or 0
			local reagentValueMin, reagentValueMax = 0, 0

			local vendorPrices = SellValue_TradeSkillProfits.VendorPrices[reagentItemID]
			if vendorPrices then -- if it is a vendor item a price must be found
				if table.getn(vendorPrices) == 0 then
					return self:Print("Missing vendor buy price for "..reagentName..". Please visit a vendor")
				end
				reagentValueMin = math.min(unpack(vendorPrices))
				reagentValueMax = math.max(unpack(vendorPrices))
			elseif SellValue_TradeSkillProfits.CraftedItems[reagentItemID] then
				local craftedReagent = SellValue_TradeSkillProfits.CraftedItems[reagentItemID]
				local craftedItem = SellValue_TradeSkillProfits.CraftedItems[craftedItemID]
				if craftedItem and craftedItem.LastUpdated < craftedReagent.LastUpdated then
					self:ResetProfits(craftedItemID)
				end

				local minProfit = math.min(unpack(craftedReagent.Profits))
				local maxProfit = math.max(unpack(craftedReagent.Profits))

				-- Crafted item only has to compensate for negative profits
				-- Positive profits do not add extra profit
				-- It is assumed that the crafting of the reagent is sensical
				reagentValueMin = minProfit > 0 and reagentVendorValue or reagentVendorValue + math.abs(minProfit)
				reagentValueMax = maxProfit > 0 and reagentVendorValue or reagentVendorValue + math.abs(maxProfit)
			else
				reagentValueMin = reagentVendorValue
				reagentValueMax = reagentVendorValue
			end

			totalReagentValueMin = totalReagentValueMin + (reagentValueMin * reagentCount)
			totalReagentValueMax = totalReagentValueMax + (reagentValueMax * reagentCount)
		end

		local profitMin = craftValue - totalReagentValueMax
		local profitMax = craftValue - totalReagentValueMin

		self:SaveProfits(craftedItemID, profitMin, profitMax)
		self:SetTooltipProfit(GameTooltip, profitMin, profitMax)
	end)

	-- Simple update for vendor items prices on mouse over
	hooksecurefunc(GameTooltip, "SetMerchantItem", function(tip, index)
		local itemID = SellValue_ItemIDFromLink(GetMerchantItemLink(index))
		local _, _, price, stackCount = GetMerchantItemInfo(index)
		if itemID and price and price > 0 and stackCount and stackCount > 0 then
			if not SellValue_TradeSkillProfits.VendorPrices[itemID] then
				return
			end

			local pricePerItem = price / stackCount
			if not contains(SellValue_TradeSkillProfits.VendorPrices[itemID], pricePerItem) then
				table.insert(SellValue_TradeSkillProfits.VendorPrices[itemID], pricePerItem)
				table.sort(SellValue_TradeSkillProfits.VendorPrices[itemID])
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
	if event == "ADDON_LOADED" and arg1 == "SellValue_TradeSkillProfits" then
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

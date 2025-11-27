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
function SellValue_TSP:Print(string)
	-- color maybe #FFD700
	DEFAULT_CHAT_FRAME:AddMessage("[SellValue_TSP]: " .. tostring(string))
end

function SellValue_TSP:OnAddonLoaded()
	SellValue_TSP:InitializeDB()
end

function SellValue_TSP:OnAddonLoaded()
	self:UnregisterEvent("ADDON_LOADED")
	--self:RegisterEvent("MERCHANT_SHOW")

	self:InitializeDB()
	self:HookTooltip()
end

local function colorString(money)
	local color = GREEN_FONT_COLOR_CODE
	if money < 0 then
		color = RED_FONT_COLOR_CODE
	end

	return color .. money .. FONT_COLOR_CODE_CLOSE
end

function SellValue_TSP:SetTooltip(tooltip, label, low, high)
	local line = colorString(low)
	if low ~= high then
		line = line .. " - " .. colorString(high)
	end
	tooltip:AddLine(format("%s: %s", label, line))
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
			local _, _, reagentCount = GetTradeSkillReagentInfo(tradeItemIndex, i)
			local vendorItem = SellValue_TradeSkillProfits.VendorItems[reagentItemID]
			if vendorItem.BuyPrice then
				local minCost = math.min(unpack(vendorItem.BuyPrice))
				local maxCost = math.max(unpack(vendorItem.BuyPrice))
				self:SetTooltip(GameTooltip, "Vendor Price", minCost * reagentCount, maxCost * reagentCount)
			end

			return
		end

		-- the crafted item. Calculate profit
		local craftedItemID = SellValue_ItemIDFromLink(GetTradeSkillItemLink(tradeItemIndex))
		self:InitializeProfits(craftedItemID)
		local craftedItemCount = GetTradeSkillNumMade(tradeItemIndex)

		local craftedItemValue = SellValues[craftedItemID] or 0
		local craftValue = craftedItemValue * craftedItemCount

		local totalReagentValueMin, totalReagentValueMax = 0, 0
		for i = 1, GetTradeSkillNumReagents(tradeItemIndex) do
			local reagentItemID = SellValue_ItemIDFromLink(GetTradeSkillReagentItemLink(tradeItemIndex, i))
			local reagentName, _, reagentCount = GetTradeSkillReagentInfo(tradeItemIndex, i)
			local reagentVendorValue = SellValues[reagentItemID] or 0
			local reagentValueMin, reagentValueMax = 0, 0

			local vendorItem = SellValue_TradeSkillProfits.VendorItems[reagentItemID]
			if vendorItem then -- if it is a vendor item a price must be found
				if #vendorItem.BuyPrice == 0 then -- Might not work. Use table.getn() as fallback
					return self:Print(format("No vendor prices recorded for %d - %s", reagentItemID, reagentName))
				end

				reagentValueMin = math.min(unpack(vendorItem.BuyPrice))
				reagentValueMax = math.max(unpack(vendorItem.BuyPrice))
			elseif SellValue_TradeSkillProfits.CraftedItems[reagentItemID] then
				local craftedReagent = SellValue_TradeSkillProfits.CraftedItems[reagentItemID]
				local craftedItem = SellValue_TradeSkillProfits.CraftedItems[craftedItemID]
				if craftedItem.LastUpdated < craftedReagent.LastUpdated then
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
		self:SetTooltip(GameTooltip, "Vendor Profit", profitMin, profitMax)
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
			if not contains(SellValue_TradeSkillProfits.VendorItems[itemID].BuyPrice, pricePerItem) then
				table.insert(SellValue_TradeSkillProfits.VendorItems[itemID].BuyPrice, pricePerItem)
				table.sort(SellValue_TradeSkillProfits.VendorItems[itemID].BuyPrice)
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

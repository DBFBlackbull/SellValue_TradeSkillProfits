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

function SellValue_TSP:SetTooltip(tooltip, itemLink, stackCount)
	-- profit logic
end


function SellValue_TSP:HookTooltip()
	-- Hook trade skill tooltip
	hooksecurefunc(GameTooltip, "SetTradeSkillItem", function(tip, tradeItemIndex, reagentIndex)
		local itemLink, stackCount, _

		if reagentIndex then
			itemLink = GetTradeSkillReagentItemLink(tradeItemIndex, reagentIndex)
			_, _, stackCount = GetTradeSkillReagentInfo(tradeItemIndex, reagentIndex)
		else
			itemLink = GetTradeSkillItemLink(tradeItemIndex)
			stackCount = GetTradeSkillNumMade(tradeItemIndex)
		end

		SellValue_TSP:SetTooltip(GameTooltip, itemLink, stackCount)
	end)

	hooksecurefunc(GameTooltip, "SetCraftItem", function(self, skill, slot)
		SellValue_TSP:SetTooltip(GameTooltip, GetCraftReagentItemLink(skill, slot), 1)
	end)

	hooksecurefunc(GameTooltip, "SetCraftSpell", function(self, slot)
		SellValue_TSP:SetTooltip(GameTooltip, GetCraftItemLink(slot), 1)
	end)
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

function SellValue_TSP:MerchantScan()

	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, GetContainerNumSlots(bag) do

			local itemID = SellValue_IDFromLink(GetContainerItemLink(bag, slot))
			if itemID then
				SellValue_LastItemMoney = 0
				SellValue_Tooltip:SetBagItem(bag, slot)
				SellValue_SaveFor(bag, slot, itemID, SellValue_LastItemMoney)
			end  -- if item name
		end  -- for slot
	end -- for bag

end

function SellValue_TSP:ItemIDFromLink(itemLink)
	if not itemLink then
		return
	end

	local foundID, _, itemID = string.find(itemLink, "item:(%d+)")
	if not foundID then
		return
	end

	return tonumber(itemID)
end

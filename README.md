# SellValue_TradeSkillProfits
Adds vendor profits for crafted items to tooltips for WoW Vanilla 1.12.1

## Requirements
The SellValue addon found here: https://github.com/DBFBlackbull/SellValue

## Features

- Display vendor profits for crafted items in the tooltip.
- Using vendor buy prices for reagents bought at vendor.
- Some profits will have a lower and higher value due to variable vendor buy prices for reagents, due to reputation and rank discounts.
- Crafted items that are also reagents will:
  - include any losses in the profits of the final craft
  - ignore any profits in the profits of the final craft
- When opening your trade skills, all skills will be scanned and profits calculated
- When opening any vendor, all items in the vendor window will be scanned and vendor prices recorded

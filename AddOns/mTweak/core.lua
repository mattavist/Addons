
---------------------------------------------------- Some slash commands
SlashCmdList["FRAME"] = function()
    ChatFrame1:AddMessage(GetMouseFocus():GetName())
end
SLASH_FRAME1 = "/frame"
SLASH_FRAME2 = "/gn"

SlashCmdList["RELOADUI"] = function() ReloadUI() end
SLASH_RELOADUI1 = "/rl"

SlashCmdList["RCSLASH"] = function() DoReadyCheck() end
SLASH_RCSLASH1 = "/rc"

---------------------------------------------------- Changing some variables
SetCVar("screenshotQuality", 6)

---------------------------------------------------- Not Sure
local fontName = "Interface\\AddOns\\mTweak\\media\\font.ttf"
local fontHeight = 24
local function FS_SetFont()
	DAMAGE_TEXT_FONT = fontName
	COMBAT_TEXT_HEIGHT = fontHeight
	COMBAT_TEXT_CRIT_MAXHEIGHT = fontHeight + 2
	COMBAT_TEXT_CRIT_MINHEIGHT = fontHeight - 2
	local fName, fHeight, fFlags = CombatTextFont:GetFont()
	CombatTextFont:SetFont(fontName, fontHeight, fFlags)
end
FS_SetFont()


------Sells Greys
local function OnEvent()
	for bag=0,4 do
		for slot=0,GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link and select(3, GetItemInfo(link)) == 0 then
				--ShowMerchantSellCursor(1)
				UseContainerItem(bag, slot)
			end
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("MERCHANT_SHOW")
f:SetScript("OnEvent", OnEvent)
if MerchantFrame:IsVisible() then OnEvent() end

---------------------|Created by DanielTheDeveloper|-----------------------|

local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local PLAYER_VISIBLE_ITEM_1_ENTRYID  = 283
local PLAYER_VISIBLE_ITEM_3_ENTRYID  = 287
local PLAYER_VISIBLE_ITEM_4_ENTRYID  = 289
local PLAYER_VISIBLE_ITEM_5_ENTRYID  = 291
local PLAYER_VISIBLE_ITEM_6_ENTRYID  = 293
local PLAYER_VISIBLE_ITEM_7_ENTRYID  = 295
local PLAYER_VISIBLE_ITEM_8_ENTRYID  = 297
local PLAYER_VISIBLE_ITEM_9_ENTRYID  = 299
local PLAYER_VISIBLE_ITEM_10_ENTRYID  = 301
local PLAYER_VISIBLE_ITEM_15_ENTRYID  = 311
local PLAYER_VISIBLE_ITEM_16_ENTRYID  = 313
local PLAYER_VISIBLE_ITEM_17_ENTRYID  = 315
local PLAYER_VISIBLE_ITEM_18_ENTRYID  = 317
local PLAYER_VISIBLE_ITEM_19_ENTRYID  = 319

function TableSetHelper(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

local EquipmentSlotFrameNames = {"CharacterHeadSlot", "CharacterShoulderSlot", "CharacterBackSlot", "CharacterChestSlot", "CharacterShirtSlot", "CharacterTabardSlot", "CharacterWristSlot", "CharacterHandsSlot", "CharacterWaistSlot", "CharacterLegsSlot", "CharacterFeetSlot", "CharacterMainHandSlot", "CharacterSecondaryHandSlot", "CharacterRangedSlot"}
EquipmentSlotFrameNames = TableSetHelper(EquipmentSlotFrameNames)

local TransmogHandlers = AIO.AddHandlers("Transmog", {})
local currentSlotItemIds = nil -- hold ids and icon paths
local currentPage = 1
local currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
local morePages = false

local itemButtons = {}

local currentTooltipSlot = nil

-- TODO timer with wait time if pressed to fast. wait at least 1 second before accepting another call
-- TODO I key for opening the panel. Add to micro bar down at the bottom

-----------------------------------------------------------------------------------|
------------------------------------|Frames|---------------------------------------|
-----------------------------------------------------------------------------------|
-- Create the base frame.

function TransmogHandlers.SetEquipmentTransmogInfoClient(player, tooltipSlot)
	if ( currentTooltipSlot == tooltipSlot ) then
		GameTooltip:AddLine("Item is transmogrified!", 1, 0, 0)
	end
end

GameTooltip:HookScript("OnTooltipCleared", function(tooltip, ...)
	currentTooltipSlot = nil
end)

GameTooltip:HookScript("OnTooltipSetItem", function(tooltip, ...)
	local name, link = tooltip:GetItem()
	local ownerFrame, anchor = tooltip:GetOwner()
	local slotName = ownerFrame:GetName()
	if ( currentTooltipSlot == slotName ) then
		return;
	end
	currentTooltipSlot = slotName
	if ( EquipmentSlotFrameNames[slotName] ) then
		if ( not tooltip:IsEquippedItem() ) then
			tooltip:AddLine(" ")
			tooltip:AddLine("This item is a transmog and purely cosmetic!", 1, 0, 0)
			return;
		end
		
		local slotId = nil
		if ( slotName == "CharacterHeadSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_1_ENTRYID
		elseif ( slotName == "CharacterShoulderSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_3_ENTRYID
		elseif ( slotName == "CharacterShirtSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_4_ENTRYID
		elseif ( slotName == "CharacterChestSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_5_ENTRYID
		elseif ( slotName == "CharacterWaistSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_6_ENTRYID
		elseif ( slotName == "CharacterLegsSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_7_ENTRYID
		elseif ( slotName == "CharacterWristSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_8_ENTRYID
		elseif ( slotName == "CharacterHandsSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_9_ENTRYID
		elseif ( slotName == "CharacterHandsSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_10_ENTRYID
		elseif ( slotName == "CharacterBackSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_15_ENTRYID
		elseif ( slotName == "CharacterMainHandSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_16_ENTRYID
		elseif ( slotName == "CharacterSecondaryHandSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_17_ENTRYID
		elseif ( slotName == "CharacterRangedSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_18_ENTRYID
		elseif ( slotName == "CharacterTabardSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_19_ENTRYID
		end
		
		if ( slotId ) then
			--AIO.Handle("Transmog", "SetEquipmentTransmogInfo", slotId, currentTooltipSlot) TODO This will only works with cached slots?? Inf loop when trying to call server and back
		end
		return;
	end
	-- just search db for item in accoumt_transmog
	tooltip:Show()
end)

local function OnHideMainFrame(btn)
	PlaySound("INTERFACESOUND_CHARWINDOWCLOSE", "master")
end

local mainFrame = CreateFrame("Frame", "TransmogFrame", UIParent, "UIPanelDialogTemplate") --, "UIPanelDialogTemplate")

local function HideMainFrame()
    mainFrame:Hide()
end

mainFrame:SetSize(1000, 800)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetPoint("CENTER")
mainFrame:SetToplevel(true)
mainFrame:SetClampedToScreen(true)
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnHide", mainFrame.StopMovingOrSizing)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
mainFrame:SetFrameLevel(frameLevel+1)

_G["TransmogFrame"] = mainFrame
tinsert(UISpecialFrames, mainFrame:GetName()) 

--local backdropInfo =
					--{						
					--	bgFile = "Interface\\Transmog\\UI-PaperBackground", 
					--	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
					--	tile = false, tileEdge = true, tileSize = 16, edgeSize = 16, 
					--	insets = { left = 4, right = 4, top = 4, bottom = 4 }
					--};


--mainFrame:SetBackdrop(backdropInfo)
--mainFrame:SetBackdropColor(1,1,1,1);

--local backgroundFrame = CreateFrame("Frame", nil, mainFrame)
--backgroundFrame:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 0)
--backgroundFrame:SetWidth(1000-16)
--backgroundFrame:SetHeight(600-35)
--backgroundFrame:SetHeight(mainFrame:GetHeight()-35)

--local backgroundTexture = mainFrame:CreateTexture()
--backgroundTexture:SetTexture("Interface\\Transmog\\UI-PaperBackground.blp")
--tex:SetMask("Interface/ChatFrame/UI-ChatIcon-HotS")
--backgroundTexture:SetTexCoord(0, 1, 0, 1)
--backgroundTexture:SetAllPoints()

-- This enables saving of the position of the frame over reload of the UI or restarting game
AIO.SavePosition(mainFrame)

mainFrame:Hide()
function TransmogHandlers.TransmogFrame(player)
    mainFrame:Show()
end

mainFrame:SetScript("OnHide", OnHideMainFrame)

local innerFrame = CreateFrame("Frame", "InnerFrame", mainFrame)
innerFrame:SetPoint("TOPLEFT", 0, -18)
innerFrame:EnableMouse(true)
innerFrame:SetWidth(mainFrame:GetWidth()-18)
innerFrame:SetHeight(mainFrame:GetHeight()-18)

local function OnClickItemTransmogButton(btn, buttonType)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	local itemId = btn:GetID()
	if ( buttonType == "RightButton" ) then
		DressUpItemLink("item:"..itemId..":0:0:0:0:0:0:0")
		return;
	end
	local itemId = btn:GetID()
	AIO.Handle("Transmog", "EquipTransmogItem", itemId, currentSlot)
end

local function OnClickResetAllButton(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_1_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_3_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_4_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_5_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_6_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_7_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_8_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_9_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_10_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_15_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_16_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_17_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_18_ENTRYID)
	AIO.Handle("Transmog", "UnequipTransmogItem", PLAYER_VISIBLE_ITEM_19_ENTRYID)
end

local function OnLeaveItemToolTip(btn)
	GameTooltip:Hide()
end

local function OnEnterItemToolTip(btn)
	local itemId = btn:GetID()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("item:"..itemId..":0:0:0:0:0:0:0")
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Transmog unlocked from this item", 0, 0, 1)
	GameTooltip:AddLine("Right click to preview item", 1, 0, 0)
	GameTooltip:Show()
end

local backdropInfo =
					{						
						bgFile = "Interface\\Transmog\\UI-PaperBackground", 
						edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
						tile = false, tileEdge = true, tileSize = 16, edgeSize = 16, 
						insets = { left = 4, right = 4, top = 4, bottom = 4 }
					};

function InitTabSlots()
	local lastSlot
	local firstInRowSlot
	for i = 1, 8, 1 do
	local itemChild
	if ( i == 1 ) then
		itemChild = CreateFrame("Frame", nil, mainFrame) 
		itemChild:SetPoint("TOPLEFT", 85, -70)
		firstInRowSlot = itemChild
	else
		if ( i == 5 ) then
			itemChild = CreateFrame("Frame", nil, firstInRowSlot)
			itemChild:SetPoint("RIGHT", 0, -290)
			firstInRowSlot = itemChild
		else
			itemChild = CreateFrame("Button", nil, lastSlot)
			itemChild:SetPoint("RIGHT", 210, 0)
		end
	end
	
	itemChild:SetWidth(200)
	itemChild:SetHeight(280)
	itemChild:SetBackdrop(backdropInfo)
	--itemChild:SetClipsChildren(true)
	local rightTopItemFrame = CreateFrame("Frame", nil, itemChild)
	rightTopItemFrame:SetPoint("TOPRIGHT", -5, -5)
	rightTopItemFrame:SetSize(45, 225)
	local rightTopTexture = rightTopItemFrame:CreateTexture()
	rightTopTexture:SetTexture(DressUpTexturePath().."2")
	rightTopTexture:SetAllPoints()
	local rightBottomItemFrame = CreateFrame("Frame", nil, itemChild)
	rightBottomItemFrame:SetPoint("BOTTOMRIGHT", -5, -30)
	rightBottomItemFrame:SetSize(45, 85)
	local rightBottomTexture = rightBottomItemFrame:CreateTexture()
	rightBottomTexture:SetTexture(DressUpTexturePath().."4")
	rightBottomTexture:SetAllPoints()
	local leftTopItemFrame = CreateFrame("Frame", nil, itemChild)
	leftTopItemFrame:SetPoint("TOPLEFT", 5, -5)
	leftTopItemFrame:SetSize(145, 225)
	local leftTopTexture = leftTopItemFrame:CreateTexture()
	leftTopTexture:SetTexture(DressUpTexturePath().."1")
	leftTopTexture:SetAllPoints()
	local leftBottomItemFrame = CreateFrame("Frame", nil, itemChild)
	leftBottomItemFrame:SetPoint("BOTTOMLEFT", 5, -30)
	leftBottomItemFrame:SetSize(145, 85)
	local leftBottomTexture = leftBottomItemFrame:CreateTexture()
	leftBottomTexture:SetTexture(DressUpTexturePath().."3")
	leftBottomTexture:SetAllPoints()
	local itemModel = CreateFrame("DressUpModel", "ItemModel", itemChild, "ModelTemplate")
	itemModel:SetPoint("CENTER", 0, -20)
	itemModel:SetSize(256, 256)
	itemModel:SetUnit("player")
	itemModel:Hide()
	local itemButton = CreateFrame("Button", nil, leftBottomItemFrame, "ItemButtonTemplate")
	itemButton:SetPoint("BOTTOMLEFT", 5, 40)
	itemButton:SetScript("OnClick", OnClickItemTransmogButton)
	itemButton:SetScript("OnEnter", OnEnterItemToolTip)
	itemButton:SetScript("OnLeave", OnLeaveItemToolTip)
	itemButton:RegisterForClicks("AnyUp");
	itemButton:Disable()
	lastSlot = itemChild
	itemChild.itemModel = itemModel
	itemChild.itemButton = itemButton
	table.insert(itemButtons, itemChild)
	end
	
	--for i = 1, 56, 1 do -- 8x7 slots
		--local itemChild
		--if ( i == 1 ) then
			--itemChild = CreateFrame("Button", nil, innerFrame, "ItemButtonTemplate")
			--itemChild:SetPoint("TOPLEFT", 70, -70)
			--firstInRowSlot = itemChild
		--else
			--if ( i == 9 or i == 17 or i == 25 or i == 33 or i == 41 or i == 49 ) then
				--itemChild = CreateFrame("Button", nil, firstInRowSlot, "ItemButtonTemplate")
				--itemChild:SetPoint("RIGHT", 0, -50)
				--firstInRowSlot = itemChild
			--else
				--itemChild = CreateFrame("Button", nil, lastSlot, "ItemButtonTemplate")
				--itemChild:SetPoint("RIGHT", 117.2, 0)
			--end
		--end
		
		--itemChild:SetScript("OnClick", OnClickItemTransmogButton)
		--itemChild:SetScript("OnEnter", OnEnterItemToolTip)
		--itemChild:SetScript("OnLeave", OnLeaveItemToolTip)
		--itemChild:RegisterForClicks("AnyUp");
		--itemChild:Disable()
		--lastSlot = itemChild
		--table.insert(itemButtons, itemChild)
	--end
end

InitTabSlots()

-- Create item buttons in array of 8 width and 7 height. Keeep empty/only slot if none and disable slot hover!
-- Get icons with id from server! In current slot item ids if possible
-- alos return if there is more then 1 page and then show or hide pagination buttons etc.

local resetButton = CreateFrame("Button", "ResetButton", mainFrame, "UIPanelButtonTemplate")
resetButton:SetPoint("BOTTOMRIGHT", -40, 32)
resetButton:SetSize(100, 30)
resetButton:SetText("Reset")
resetButton:RegisterForClicks("AnyUp")
resetButton:EnableMouse(true)
resetButton:SetToplevel(true)
resetButton:Enable()

local resetAllButton = CreateFrame("Button", "ResetAllButton", resetButton, "UIPanelButtonTemplate")
resetAllButton:SetPoint("LEFT", -110, 0)
resetAllButton:SetSize(100, 30)
resetAllButton:SetText("Reset All")
resetAllButton:RegisterForClicks("AnyUp")
resetAllButton:EnableMouse(true)
resetAllButton:SetToplevel(true)
resetAllButton:Enable()
resetAllButton:SetScript("OnClick", OnClickResetAllButton)

local searchFontString = mainFrame:CreateFontString("SearchFontString", "MEDIUM", "GameTooltipText")
searchFontString:SetPoint("BOTTOMLEFT", 40, 40)
searchFontString:SetText("Search:")

local itemSearchInput = CreateFrame("EditBox", "ItemSearchInput", mainFrame, "InputBoxTemplate")
itemSearchInput:SetSize(200, 30)
itemSearchInput:SetAutoFocus(false)
itemSearchInput:SetToplevel(true)
itemSearchInput:EnableMouse(true)
itemSearchInput:SetText("|cff808080Click here and start typing...|r")
itemSearchInput:SetPoint("LEFT", searchFontString, "LEFT", searchFontString:GetWidth() + 10, 0)
itemSearchInput:SetMaxLetters(255)

local function ClearSearchInputFocus()
	itemSearchInput:ClearFocus()
end

local isInputHovered = false

local function EnterSearchInput()
	isInputHovered = true
end

local function LeaveSearchInput()
	isInputHovered = false
end

local function SetSearchInputFocus()
	if ( isInputHovered ) then
		itemSearchInput:SetText("")
		itemSearchInput:SetFocus()
	end
end

itemSearchInput:SetScript("OnEscapePressed", ClearSearchInputFocus)
itemSearchInput:SetScript("OnEnter", EnterSearchInput)
itemSearchInput:SetScript("OnLeave", LeaveSearchInput)
itemSearchInput:SetScript("OnMouseUp", SetSearchInputFocus)

local function OnClickNextPage(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	currentPage = currentPage + 1
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
end

local function OnClickPrevPage(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	if ( currentPage == 1 ) then
		return;
	end
	currentPage = currentPage - 1
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
end

local leftButton = CreateFrame("Button", "LeftButton", mainFrame, "UIPanelButtonTemplate")
leftButton:SetPoint("BOTTOM", -80, 92)
leftButton:SetSize(60, 30)
leftButton:RegisterForClicks("AnyUp")
leftButton:EnableMouse(true)
leftButton:SetToplevel(true)
leftButton:SetScript("OnClick", OnClickPrevPage)
leftButton:Disable()
local leftFontString = leftButton:CreateFontString("LeftFontString")
leftFontString:SetFont("Fonts\\Arrows.ttf", 11, nil)
leftFontString:SetShadowOffset(1, -1)
leftFontString:SetPoint("CENTER", 0, 2)
leftButton:SetFontString(leftFontString)
leftButton:SetText("d")

local rightButton = CreateFrame("Button", "RightButton", mainFrame, "UIPanelButtonTemplate")
rightButton:SetPoint("BOTTOM", 80, 92)
rightButton:SetSize(60, 30)
rightButton:RegisterForClicks("AnyUp")
rightButton:EnableMouse(true)
rightButton:SetToplevel(true)
rightButton:SetScript("OnClick", OnClickNextPage)
rightButton:Disable()
local rightFontString = rightButton:CreateFontString("RightFontString")
rightFontString:SetFont("Fonts\\Arrows.ttf", 11, nil)
rightFontString:SetShadowOffset(1, -1)
rightFontString:SetPoint("CENTER", 0, 2)
rightButton:SetFontString(rightFontString)
rightButton:SetText("F")

local paginationText = mainFrame:CreateFontString("PaginationText", nil, "GameFontNormal")
paginationText:SetText("1")
paginationText:SetPoint("BOTTOM", 0, 100)

local function OnClickResetCurrentTransmogSlot(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	AIO.Handle("Transmog", "UnequipTransmogItem", currentSlot)
end
resetButton:SetScript("OnClick", OnClickResetCurrentTransmogSlot)

local headTab = CreateFrame("Button", "HeadTab", mainFrame, "CharacterFrameTabButtonTemplate")
headTab:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, -24)
headTab:SetText("Head")
headTab:SetFrameLevel(frameLevel)
PanelTemplates_SelectTab(headTab)
PanelTemplates_TabResize(headTab, 0)

local shoulderTab = CreateFrame("Button", "ShoulderTab", mainFrame, "CharacterFrameTabButtonTemplate")
shoulderTab:SetText("Shoulder")
shoulderTab:SetPoint("LEFT", headTab, "LEFT", headTab:GetWidth() - 10, 0)
shoulderTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(shoulderTab)
PanelTemplates_TabResize(shoulderTab, 0)

local shirtTab = CreateFrame("Button", "ShirtTab", mainFrame, "CharacterFrameTabButtonTemplate")
shirtTab:SetText("Shirt")
shirtTab:SetPoint("LEFT", shoulderTab, "LEFT", shoulderTab:GetWidth() - 10, 0)
shirtTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(shirtTab)
PanelTemplates_TabResize(shirtTab, 0)

local chestTab = CreateFrame("Button", "ChestTab", mainFrame, "CharacterFrameTabButtonTemplate")
chestTab:SetText("Chest")
chestTab:SetPoint("LEFT", shirtTab, "LEFT", shirtTab:GetWidth() - 10, 0)
chestTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(chestTab)
PanelTemplates_TabResize(chestTab, 0)

local waistTab = CreateFrame("Button", "WaistTab", mainFrame, "CharacterFrameTabButtonTemplate")
waistTab:SetText("Waist")
waistTab:SetPoint("LEFT", chestTab, "LEFT", chestTab:GetWidth() - 10, 0)
waistTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(waistTab)
PanelTemplates_TabResize(waistTab, 0)

local legsTab = CreateFrame("Button", "LegsTab", mainFrame, "CharacterFrameTabButtonTemplate")
legsTab:SetText("Legs")
legsTab:SetPoint("LEFT", waistTab, "LEFT", waistTab:GetWidth() - 10, 0)
legsTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(legsTab)
PanelTemplates_TabResize(legsTab, 0)

local feetTab = CreateFrame("Button", "FeetTab", mainFrame, "CharacterFrameTabButtonTemplate")
feetTab:SetText("Feet")
feetTab:SetPoint("LEFT", legsTab, "LEFT", legsTab:GetWidth() - 10, 0)
feetTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(feetTab)
PanelTemplates_TabResize(feetTab, 0)

local wristTab = CreateFrame("Button", "WristTab", mainFrame, "CharacterFrameTabButtonTemplate")
wristTab:SetText("Wrist")
wristTab:SetPoint("LEFT", feetTab, "LEFT", feetTab:GetWidth() - 10, 0)
wristTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(wristTab)
PanelTemplates_TabResize(wristTab, 0)

local handsTab = CreateFrame("Button", "wristTab", mainFrame, "CharacterFrameTabButtonTemplate")
handsTab:SetText("Hands")
handsTab:SetPoint("LEFT", wristTab, "LEFT", wristTab:GetWidth() - 10, 0)
handsTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(handsTab)
PanelTemplates_TabResize(handsTab, 0)

local backTab = CreateFrame("Button", "BackTab", mainFrame, "CharacterFrameTabButtonTemplate")
backTab:SetText("Back")
backTab:SetPoint("LEFT", handsTab, "LEFT", handsTab:GetWidth() - 10, 0)
backTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(backTab)
PanelTemplates_TabResize(backTab, 0)

local mainTab = CreateFrame("Button", "MainTab", mainFrame, "CharacterFrameTabButtonTemplate")
mainTab:SetText("Main Hand")
mainTab:SetPoint("LEFT", backTab, "LEFT", backTab:GetWidth() - 10, 0)
mainTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(mainTab)
PanelTemplates_TabResize(mainTab, 0)

local offTab = CreateFrame("Button", "OffTab", mainFrame, "CharacterFrameTabButtonTemplate")
offTab:SetText("Off Hand")
offTab:SetPoint("LEFT", mainTab, "LEFT", mainTab:GetWidth() - 10, 0)
offTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(offTab)
PanelTemplates_TabResize(offTab, 0)

local rangedTab = CreateFrame("Button", "RangedTab", mainFrame, "CharacterFrameTabButtonTemplate")
rangedTab:SetText("Ranged")
rangedTab:SetPoint("LEFT", offTab, "LEFT", offTab:GetWidth() - 10, 0)
rangedTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(rangedTab)
PanelTemplates_TabResize(rangedTab, 0);

local tabardTab = CreateFrame("Button", "TabardTab", mainFrame, "CharacterFrameTabButtonTemplate")
tabardTab:SetText("Tabard")
tabardTab:SetPoint("LEFT", rangedTab, "LEFT", rangedTab:GetWidth() - 10, 0)
tabardTab:SetFrameLevel(frameLevel)
PanelTemplates_DeselectTab(tabardTab)
PanelTemplates_TabResize(tabardTab, 0);

local title = mainFrame:CreateFontString(nil, nil, "GameFontNormal")
title:SetPoint("TOP", -9, -9)
title:SetText("Transmog")

local transmogButton = CreateFrame("Button", "TransmogButton", UIParent, "UIPanelButtonTemplate")
transmogButton:SetPoint("CENTER")
transmogButton:SetSize(100, 30)
transmogButton:SetToplevel(true)
transmogButton:SetClampedToScreen(true)
-- Enable dragging of frame
transmogButton:SetMovable(true)
transmogButton:EnableMouse(true)
transmogButton:RegisterForDrag("LeftButton")
transmogButton:SetScript("OnDragStart", transmogButton.StartMoving)
transmogButton:SetScript("OnHide", transmogButton.StopMovingOrSizing)
transmogButton:SetScript("OnDragStop", transmogButton.StopMovingOrSizing)
transmogButton:SetText("Transmogs")

AIO.SavePosition(transmogButton)

local function OnClickTransmogButton(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	isInputHovered = false
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, 1)
	if ( mainFrame:IsShown() ) then
		mainFrame:Hide()
		return;
	end
	itemSearchInput:SetText("|cff808080Click here and start typing...|r")
	mainFrame:Show()
end
transmogButton:SetScript("OnClick", OnClickTransmogButton)

function TransmogHandlers.InitTab(player, newSlotItemIds, page, hasMorePages) -- Lua table starts from 1 not 0!
	currentSlotItemIds = newSlotItemIds
	paginationText:SetText(page)
	
	if ( hasMorePages ) then
		rightButton:Enable()
	else
		rightButton:Disable()
	end
	
	if ( page > 1 ) then
		leftButton:Enable()
	else
		leftButton:Disable()
	end
	
	-- Todo add pagination and reset tab buttons here later
	for i, child in ipairs(itemButtons) do
		if ( currentSlotItemIds[i] == nil ) then
			child:SetID(0)
			child.itemButton:SetID(0)
			SetItemButtonTexture(child.itemButton, "")
			child.itemButton:Disable()
			child.itemModel:Hide()
		else
			child:SetID(currentSlotItemIds[i])
			child.itemButton:SetID(currentSlotItemIds[i])
			SetItemButtonTexture(child.itemButton, GetItemIcon(currentSlotItemIds[i]))
			child.itemButton:Enable()
			child.itemModel:Show()
			if ( currentSlot == PLAYER_VISIBLE_ITEM_15_ENTRYID ) then
				child.itemModel:SetRotation(180, false)
			else
				child.itemModel:SetRotation(0, false)
			end
			child.itemModel:Undress()
			child.itemModel:TryOn(currentSlotItemIds[i])
		end
	end
end

local function SetSearchTab()
	PlaySound("INTERFACESOUND_CHARWINDOWTAB", "master")
	currentPage = 1
	paginationText:SetText("1")
	AIO.Handle("Transmog", "SetSearchCurrentSlotItemIds", currentSlot, currentPage, itemSearchInput:GetText())
	itemSearchInput:ClearFocus()
end
itemSearchInput:SetScript("OnEnterPressed", SetSearchTab)

local function DisableAllTabs()
	PanelTemplates_DeselectTab(headTab)
	PanelTemplates_DeselectTab(shoulderTab)
	PanelTemplates_DeselectTab(shirtTab)
	PanelTemplates_DeselectTab(chestTab)
	PanelTemplates_DeselectTab(waistTab)
	PanelTemplates_DeselectTab(legsTab)
	PanelTemplates_DeselectTab(feetTab)
	PanelTemplates_DeselectTab(wristTab)
	PanelTemplates_DeselectTab(handsTab)
	PanelTemplates_DeselectTab(backTab)
	PanelTemplates_DeselectTab(mainTab)
	PanelTemplates_DeselectTab(offTab)
	PanelTemplates_DeselectTab(rangedTab)
	PanelTemplates_DeselectTab(tabardTab)
end

local function SetTab()
	if ( itemSearchInput:GetText() ~= "" and itemSearchInput:GetText() ~= "|cff808080Click here and start typing...|r") then
		SetSearchTab()
		DisableAllTabs()
		return;
	end
	PlaySound("INTERFACESOUND_CHARWINDOWTAB", "master")
	currentPage = 1
	paginationText:SetText("1")
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
	DisableAllTabs()
end

local function OnClickHeadTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
	SetTab()
	PanelTemplates_SelectTab(headTab)
end
headTab:SetScript("OnClick", OnClickHeadTab)

local function OnClickShoulderTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_3_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(shoulderTab)
end
shoulderTab:SetScript("OnClick", OnClickShoulderTab)

local function OnClickShirtTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_4_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(shirtTab)
end
shirtTab:SetScript("OnClick", OnClickShirtTab)

local function OnClickChestTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_5_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(chestTab)
end
chestTab:SetScript("OnClick", OnClickChestTab)

local function OnClickWaistTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_6_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(waistTab)
end
waistTab:SetScript("OnClick", OnClickWaistTab)

local function OnClickLegsTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_7_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(legsTab)
end
legsTab:SetScript("OnClick", OnClickLegsTab)

local function OnClickFeetTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_8_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(feetTab)
end
feetTab:SetScript("OnClick", OnClickFeetTab)

local function OnClickWristTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_9_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(wristTab)
end
wristTab:SetScript("OnClick", OnClickWristTab)

local function OnClickHandsTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_10_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(handsTab)
end
handsTab:SetScript("OnClick", OnClickHandsTab)

local function OnClickBackTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_15_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(backTab)
end
backTab:SetScript("OnClick", OnClickBackTab)

local function OnClickMainTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_16_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(mainTab)
end
mainTab:SetScript("OnClick", OnClickMainTab)

local function OnClickOffTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_17_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(offTab)
end
offTab:SetScript("OnClick", OnClickOffTab)

local function OnClickRangedTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_18_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(rangedTab)
end
rangedTab:SetScript("OnClick", OnClickRangedTab)

local function OnClickTabardTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_19_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(tabardTab)
end
tabardTab:SetScript("OnClick", OnClickTabardTab)

--local function OnClickButton(btn)
    --AIO.Handle("Transmog", "Print", headTab:GetName(), headTab)
--end
--shoulderTab:SetScript("OnClick", OnClickButton)
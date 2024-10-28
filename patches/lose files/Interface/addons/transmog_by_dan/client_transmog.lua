---------------------|Created by DanielTheDeveloper|-----------------------|

local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local TransmogHandlers = AIO.AddHandlers("Transmog", {})

local function OnEvent(self, event)
	AIO.Handle("Transmog", "LoadPlayer")
end

-- TODO set equipment button textures to equipped transmog (For empty an emptry transmog icon placeholder) and revert when closing or reopening! AFter that edit GameTooltip nad make it custom if no item is equipped and transmog window on

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)

local CALC = 281

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

local EmptyEquipmentIconBackgroundPath = "Interface\\paperdoll\\UI-PaperDoll-Slot-"
local EquipmentIconTypes = {"Head", "", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrists", "Hands", "", "", "", "", "Back", "MainHand", "SecondaryHand", "Ranged", "Tabard"}


originalHeadTransmogId = originalHeadTransmogId or nil
originalShoudlerTransmogId = originalShoudlerTransmogId or nil
originalShirtTransmogId = originalShirtTransmogId or nil
originalChestTransmogId = originalChestTransmogId or nil
originalWaistTransmogId = originalWaistTransmogId or nil
originalLegsTransmogId = originalLegsTransmogId or nil
originalFeetTransmogId = originalFeetTransmogId or nil
originalWristTransmogId = originalWristTransmogId or nil
originalHandsTransmogId = originalHandsTransmogId or nil
originalBackTransmogId = originalBackTransmogId or nil
originalMainHandTransmogId = originalMainHandTransmogId or nil
originalOffHandTransmogId = originalOffHandTransmogId or nil
originalRangedTransmogId = originalRangedTransmogId or nil
originalTabardTransmogId = originalTabardTransmogId or nil

AIO.AddSavedVarChar("originalHeadTransmogId")
AIO.AddSavedVarChar("originalShoudlerTransmogId")
AIO.AddSavedVarChar("originalShirtTransmogId")
AIO.AddSavedVarChar("originalChestTransmogId")
AIO.AddSavedVarChar("originalWaistTransmogId")
AIO.AddSavedVarChar("originalLegsTransmogId")
AIO.AddSavedVarChar("originalFeetTransmogId")
AIO.AddSavedVarChar("originalWristTransmogId")
AIO.AddSavedVarChar("originalHandsTransmogId")
AIO.AddSavedVarChar("originalBackTransmogId")
AIO.AddSavedVarChar("originalMainHandTransmogId")
AIO.AddSavedVarChar("originalOffHandTransmogId")
AIO.AddSavedVarChar("originalRangedTransmogId")
AIO.AddSavedVarChar("originalTabardTransmogId")

currentHeadTransmogId =  originalHeadTransmogId
currentShoudlerTransmogId = originalShoudlerTransmogId
currentShirtTransmogId = originalShirtTransmogId
currentChestTransmogId = originalChestTransmogId
currentWaistTransmogId = originalWaistTransmogId
currentLegsTransmogId = originalLegsTransmogId
currentFeetTransmogId = originalFeetTransmogId
currentWristTransmogId = originalWristTransmogId
currentHandsTransmogId = originalHandsTransmogId 
currentBackTransmogId = originalBackTransmogId
currentMainHandTransmogId = originalMainHandTransmogId
currentOffHandTransmogId = originalOffHandTransmogId
currentRangedTransmogId = originalRangedTransmogId
currentTabardTransmogId = originalTabardTransmogId


function TableSetHelper(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

function Transmog_CalculateSlotReverse(slot)
	local reverseSlot = (slot - CALC) / 2
	return reverseSlot;
end

local EquipmentSlotFrameNames = {"CharacterHeadSlot", "CharacterShoulderSlot", "CharacterBackSlot", "CharacterChestSlot", "CharacterShirtSlot", "CharacterTabardSlot", "CharacterWristSlot", "CharacterHandsSlot", "CharacterWaistSlot", "CharacterLegsSlot", "CharacterFeetSlot", "CharacterMainHandSlot", "CharacterSecondaryHandSlot", "CharacterRangedSlot"}
EquipmentSlotFrameNames = TableSetHelper(EquipmentSlotFrameNames)

local currentSlotItemIds = nil -- hold ids and icon paths
local currentPage = 1
local currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
local morePages = false
local itemButtons = {}
local currentTooltipSlot = nil
local isInputHovered = false
local backdropInfo =
					{						
						bgFile = "Interface\\Transmog\\UI-PaperBackground", 
						edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
						tile = false, tileEdge = true, tileSize = 16, edgeSize = 16, 
						insets = { left = 4, right = 4, top = 4, bottom = 4 }
					};


-- TODO timer with wait time if pressed to fast. wait at least 1 second before accepting another call
-- TODO I key for opening the panel. Add to micro bar down at the bottom

function SetItemButtonTexture(button, texture)
	if ( not button ) then
		return;
	end

	if (button.Icon or button.icon or (button:GetName() ~= nil and _G[button:GetName()] ~= nil and _G[button:GetName().."IconTexture"] ~= nil)) then
		local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
		if ( texture ) then
			icon:Show();
			_G[button:GetName().."IconTexture"]:SetTexture(texture);
		else
			icon:Hide();
		end
	end
end

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
		--if ( not name ) then 
			--GameTooltip:SetHyperlink("item:"..itemId..":0:0:0:0:0:0:0")
		--end
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
			slotId = PLAYER_VISIBLE_ITEM_9_ENTRYID
		elseif ( slotName == "CharacterHandsSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_10_ENTRYID
		elseif ( slotName == "CharacterFeetSlot" ) then
			slotId = PLAYER_VISIBLE_ITEM_8_ENTRYID
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

--local mainBackground = TransmogFrame:CreateTexture("BackgroundTransmogFrame", nil)
--mainBackground:SetSize(TransmogFrame:GetWidth()-12, TransmogFrame:GetHeight()-32)
--mainBackground:SetPoint("BOTTOM", 2, 7)
--mainBackground:SetTexture("Interface\\Transmog\\CollectionsBackgroundTile", "REPEAT", "REPEAT")
--mainBackground:SetVertTile(true)
--mainBackground:SetHorizTile(true)

--local mainLeftTopBackground = TransmogFrame:CreateTexture("LeftTopTransmogFrame", "OVERLAY")
--mainLeftTopBackground:SetSize(87.04, 74.24)
--mainLeftTopBackground:SetPoint("TOPLEFT", 9, -26.5)
--mainLeftTopBackground:SetTexture("Interface\\Transmog\\Collections")
--mainLeftTopBackground:SetTexCoord(0, 0.17, 0.02, 0.148)

--local mainRightTopBackground = TransmogFrame:CreateTexture("RightTopTransmogFrame", "OVERLAY")
--mainRightTopBackground:SetSize(87.04, 74.24)
--mainRightTopBackground:SetPoint("TOPRIGHT", -8, -25)
--mainRightTopBackground:SetTexture("Interface\\Transmog\\Collections")
--mainRightTopBackground:SetTexCoord(0.83, 1, 0.855, 0.98)
--mainRightTopBackground:SetTexCoord(1, 1, 1, 1, 1, 1, 1, 1)
--mainRightTopBackground:SetTexCoord(0, 0.17, 0.02, 0.148)

--local mainRightBottomBackground = TransmogFrame:CreateTexture("RightBottomTransmogFrame", "OVERLAY")
--mainRightBottomBackground:SetSize(-87.04, -74.24)
--mainRightBottomBackground:SetPoint("BOTTOMRIGHT", -92.04, 83.74)
--mainRightBottomBackground:SetTexture("Interface\\Transmog\\Collections")
--mainRightBottomBackground:SetTexCoord(0, 0.17, 0.02, 0.148)

local function SetCharacterFrameTransmogItemButtonTextures()
	--if ( TransmogFrame:IsShown() ) then
		local textureName = "Interface\\Icons\\INV_Mask_01"
		if ( currentHeadTransmogId ~= nil and currentHeadTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentHeadTransmogId)
		elseif (currentHeadTransmogId == 0) then
			SetItemButtonTexture(CharacterHeadSlot, textureName) -- TODO Add for everything
		end


		if ( currentShoudlerTransmogId ~= nil and currentShoudlerTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentShoudlerTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterShoulderSlot, textureName)


		if ( currentShirtTransmogId ~= nil and currentShirtTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentShirtTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterShirtSlot, textureName)


		if ( currentChestTransmogId ~= nil and currentChestTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentChestTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterChestSlot, textureName)


		if ( currentWaistTransmogId ~= nil and currentWaistTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentWaistTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterWaistSlot, textureName)


		if ( currentLegsTransmogId ~= nil and currentLegsTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentLegsTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterLegsSlot, textureName)


		if ( currentFeetTransmogId ~= nil and currentFeetTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentFeetTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterFeetSlot, textureName)


		if ( currentWristTransmogId ~= nil and currentWristTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentWristTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterWristSlot, textureName)


		if ( currentHandsTransmogId ~= nil and currentHandsTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentHandsTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterHandsSlot, textureName)


		if ( currentBackTransmogId ~= nil and currentBackTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentBackTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterBackSlot, textureName)


		if ( currentMainHandTransmogId ~= nil and currentMainHandTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentMainHandTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterMainHandSlot, textureName)


		if ( currentOffHandTransmogId ~= nil and currentOffHandTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentOffHandTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterSecondaryHandSlot, textureName)


		if ( currentRangedTransmogId ~= nil and currentRangedTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentRangedTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterRangedSlot, textureName)


		if ( currentTabardTransmogId ~= nil and currentTabardTransmogId ~= 0 ) then
			textureName = GetItemIcon(currentTabardTransmogId)
		else
			textureName = "Interface\\Icons\\INV_Mask_01"
		end
		SetItemButtonTexture(CharacterTabardSlot, textureName)
		return;
	--end
end

local function ResetCharacterFrameTransmogItemButtonTextures()
	PaperDollItemSlotButton_Update(CharacterHeadSlot)
	PaperDollItemSlotButton_Update(CharacterShoulderSlot)
	PaperDollItemSlotButton_Update(CharacterShirtSlot)
	PaperDollItemSlotButton_Update(CharacterChestSlot)
	PaperDollItemSlotButton_Update(CharacterWaistSlot)
	PaperDollItemSlotButton_Update(CharacterLegsSlot)
	PaperDollItemSlotButton_Update(CharacterFeetSlot)
	PaperDollItemSlotButton_Update(CharacterWristSlot)
	PaperDollItemSlotButton_Update(CharacterHandsSlot)
	PaperDollItemSlotButton_Update(CharacterBackSlot)
	PaperDollItemSlotButton_Update(CharacterMainHandSlot)
	PaperDollItemSlotButton_Update(CharacterSecondaryHandSlot)
	PaperDollItemSlotButton_Update(CharacterRangedSlot)
	PaperDollItemSlotButton_Update(CharacterTabardSlot)
end

function LoadTransmogsFromCurrentIds()
	CharacterModelFrameFake:SetUint("player")
	CharacterModelFrame:SetUnit("player")
	CharacterModelFrame:Undress()
	if ( currentHeadTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentHeadTransmogId) end
	if ( currentShoudlerTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentShoudlerTransmogId) end
	if ( currentShirtTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentShirtTransmogId) end
	if ( currentChestTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentChestTransmogId) end
	if ( currentWaistTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentWaistTransmogId) end
	if ( currentLegsTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentLegsTransmogId) end
	if ( currentFeetTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentFeetTransmogId) end
	if ( currentWristTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentWristTransmogId) end
	if ( currentHandsTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentHandsTransmogId) end
	if ( currentBackTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentBackTransmogId) end
	--if ( currentMainHandTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentMainHandTransmogId, "MAINHANDSLOT") end
	--if ( currentOffHandTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentOffHandTransmogId, "SECONDARYHANDSLOT") end
	--if ( currentRangedTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentRangedTransmogId) end
	if ( currentTabardTransmogId ~= nil ) then CharacterModelFrame:TryOn(currentTabardTransmogId) end
	ResetCharacterFrameTransmogItemButtonTextures()
end

local function OnClickItemTransmogButton(btn, buttonType)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	LoadTransmogsFromCurrentIds()
	local itemId = btn:GetID()
	local textureName = GetItemIcon(itemId)
	if ( currentSlot == PLAYER_VISIBLE_ITEM_1_ENTRYID ) then
		currentHeadTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterHeadSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_3_ENTRYID ) then
		currentShoudlerTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterShoulderSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_4_ENTRYID ) then
		currentShirtTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterShirtSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_5_ENTRYID ) then
		currentChestTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterChestSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_6_ENTRYID ) then
		currentWaistTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterWaistSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_7_ENTRYID ) then
		currentLegsTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterLegsSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_8_ENTRYID ) then
		currentFeetTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterFeetSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_9_ENTRYID ) then
		currentWristTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterWristSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_10_ENTRYID ) then
		currentHandsTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterHandsSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_15_ENTRYID ) then
		currentBackTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterBackSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_16_ENTRYID ) then
		currentMainHandTransmogId = itemId
		CharacterModelFrame:TryOn(itemId, "MAINHANDSLOT")
		SetItemButtonTexture(CharacterMainHandSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_17_ENTRYID ) then
		currentOffHandTransmogId = itemId
		CharacterModelFrame:TryOn(itemId, "SECONDARYHANDSLOT")
		SetItemButtonTexture(CharacterSecondaryHandSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_18_ENTRYID ) then
		currentRangedTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterRangedSlot, textureName)
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_19_ENTRYID ) then
		currentTabardTransmogId = itemId
		CharacterModelFrame:TryOn(itemId)
		SetItemButtonTexture(CharacterTabardSlot, textureName)
	end
end

function OnClickResetAllButton(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	currentHeadTransmogId = 0
	currentShoudlerTransmogId = 0
	currentShirtTransmogId = 0
	currentChestTransmogId = 0
	currentWaistTransmogId = 0
	currentLegsTransmogId = 0
	currentFeetTransmogId = 0
	currentWristTransmogId = 0
	currentHandsTransmogId = 0
	currentBackTransmogId = 0
	currentMainHandTransmogId = 0
	currentOffHandTransmogId = 0
	currentRangedTransmogId = 0
	currentTabardTransmogId = 0
	CharacterModelFrame:SetUnit("player")
	CharacterModelFrame:Undress()
	ResetCharacterFrameTransmogItemButtonTextures()
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
	GameTooltip:AddLine("Click to preview item", 1, 0, 0)
	GameTooltip:Show()
end

local function InitTabSlots()
	local lastSlot
	local firstInRowSlot
	for i = 1, 8, 1 do
		local itemChild
		if ( i == 1 ) then
			itemChild = CreateFrame("Frame", "ItemChild"..i, TransmogFrame) 
			itemChild:SetPoint("TOPLEFT", 85, -70)
			firstInRowSlot = itemChild
		else
			if ( i == 5 ) then
				itemChild = CreateFrame("Frame", "ItemChild"..i, firstInRowSlot)
				itemChild:SetPoint("RIGHT", 0, -290)
				firstInRowSlot = itemChild
			else
				itemChild = CreateFrame("Button", "ItemChild"..i, lastSlot)
				itemChild:SetPoint("RIGHT", 210, 0)
			end
		end
		
		--itemChild:SetFrameLevel(6)
		itemChild:SetWidth(200)
		itemChild:SetHeight(280)
		itemChild:SetBackdrop(backdropInfo)
		local rightTopItemFrame = CreateFrame("Frame", "RightTopItemFrame"..i, itemChild)
		rightTopItemFrame:SetPoint("TOPRIGHT", -4, -5)
		rightTopItemFrame:SetSize(46, 225)
		local rightTopTexture = rightTopItemFrame:CreateTexture()
		rightTopTexture:SetTexture(DressUpTexturePath().."2")
		rightTopTexture:SetAllPoints()
		local rightBottomItemFrame = CreateFrame("Frame", "RightBottomItemFrame"..i, itemChild)
		rightBottomItemFrame:SetPoint("BOTTOMRIGHT", -4, -30)
		rightBottomItemFrame:SetSize(46, 85)
		local rightBottomTexture = rightBottomItemFrame:CreateTexture()
		rightBottomTexture:SetTexture(DressUpTexturePath().."4")
		rightBottomTexture:SetAllPoints()
		local leftTopItemFrame = CreateFrame("Frame", "LeftTopItemFrame"..i, itemChild)
		leftTopItemFrame:SetPoint("TOPLEFT", 4, -5)
		leftTopItemFrame:SetSize(146, 225)
		local leftTopTexture = leftTopItemFrame:CreateTexture()
		leftTopTexture:SetTexture(DressUpTexturePath().."1")
		leftTopTexture:SetAllPoints()
		local leftBottomItemFrame = CreateFrame("Frame", "LeftBottomItemFrame"..i, itemChild)
		leftBottomItemFrame:SetPoint("BOTTOMLEFT", 4, -30)
		leftBottomItemFrame:SetSize(146, 85)
		local leftBottomTexture = leftBottomItemFrame:CreateTexture()
		leftBottomTexture:SetTexture(DressUpTexturePath().."3")
		leftBottomTexture:SetAllPoints()
		local itemModel = CreateFrame("DressUpModel", "ItemModel"..i, itemChild)
		itemModel:SetPoint("CENTER", 0, -20)
		itemModel:SetSize(256, 256)
		itemModel:Hide()
		-- local itemButtonLeft = CreateFrame("Button", "ItemModel"..i.."RotateLeftButton", ItemModel)
		-- itemButtonLeft:SetPoint("TOPLEFT", itemChild, "TOPLEFT")
		-- itemButtonLeft:SetFrameLevel(30)
		-- itemButtonLeft:SetSize(35, 35)
		-- itemButtonLeft:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
		-- itemButtonLeft:SetScript("OnClick", function(self) Model_RotateLeft(self:GetParent()) end)
		-- itemButtonLeft:SetNormalTexture("Interface\\Buttons\\UI-RotationLeft-Button-Up")
		-- itemButtonLeft:SetPushedTexture("Interface\\Buttons\\UI-RotationLeft-Button-Down")
		-- itemButtonLeft:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round", "ADD")
		-- local itemButtonRight = CreateFrame("Button", "ItemModel"..i.."RotateRightButton", ItemModel)
		-- itemButtonRight:SetPoint("TOPLEFT", itemButtonLeft, "TOPRIGHT")
		-- itemButtonRight:SetFrameLevel(30)
		-- itemButtonRight:SetSize(35, 35)
		-- itemButtonRight:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
		-- itemButtonRight:SetScript("OnClick", function(self) Model_RotateRight(self:GetParent()) end)
		-- itemButtonRight:SetNormalTexture("Interface\\Buttons\\UI-RotationRight-Button-Up")
		-- itemButtonRight:SetPushedTexture("Interface\\Buttons\\UI-RotationRight-Button-Down")
		-- itemButtonRight:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round", "ADD")
		local itemButton = CreateFrame("Button", "ItemButton"..i, leftBottomItemFrame, "ItemButtonTemplate")
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
end

function EnterSearchInput()
	isInputHovered = true
end

function LeaveSearchInput()
	isInputHovered = false
end

function SetSearchInputFocus()
	if ( isInputHovered ) then
		ItemSearchInput:SetText("")
		ItemSearchInput:SetFocus()
	end
end

function OnClickNextPage(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	currentPage = currentPage + 1
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
end

function OnClickPrevPage(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	if ( currentPage == 1 ) then
		return;
	end
	currentPage = currentPage - 1
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
end

function PaperDollFrame_OnEvent(self, event, ...)
	local unit = ...;
	if ( event == "PLAYER_ENTERING_WORLD" or
		event == "UNIT_MODEL_CHANGED" and unit == "player" ) then
		PaperDollFrame_SetLevel()
		CharacterModelFrameFake:SetUnit("player"); -- custom code
		return;
	elseif ( event == "VARIABLES_LOADED" ) then
		-- Set defaults if no settings for the dropdowns
		if ( GetCVar("playerStatLeftDropdown") == "" or GetCVar("playerStatRightDropdown") == "" ) then
			local temp, classFileName = UnitClass("player");
			classFileName = strupper(classFileName);
			SetCVar("playerStatLeftDropdown", "PLAYERSTAT_BASE_STATS");
			if ( classFileName == "MAGE" or classFileName == "PRIEST" or classFileName == "WARLOCK" or classFileName == "DRUID" ) then
				SetCVar("playerStatRightDropdown", "PLAYERSTAT_SPELL_COMBAT");
			elseif ( classFileName == "HUNTER" ) then
				SetCVar("playerStatRightDropdown", "PLAYERSTAT_RANGED_COMBAT");
			else
				SetCVar("playerStatRightDropdown", "PLAYERSTAT_MELEE_COMBAT");
			end
		end
		PaperDollFrame_UpdateStats(self);
	elseif ( event == "KNOWN_TITLES_UPDATE" or (event == "UNIT_NAME_UPDATE" and unit == "player")) then
		PlayerTitleFrame_UpdateTitles();
	end

	if ( not self:IsVisible() ) then
		return;
	end

	if ( unit == "player" ) then
		if ( event == "UNIT_LEVEL" ) then
			PaperDollFrame_SetLevel();
		elseif ( event == "UNIT_DAMAGE" or event == "PLAYER_DAMAGE_DONE_MODS" or event == "UNIT_ATTACK_SPEED" or event == "UNIT_RANGEDDAMAGE" or event == "UNIT_ATTACK" or event == "UNIT_STATS" or event == "UNIT_RANGED_ATTACK_POWER" ) then
			PaperDollFrame_UpdateStats();
		elseif ( event == "UNIT_RESISTANCES" ) then
			PaperDollFrame_SetResistances();
			PaperDollFrame_UpdateStats();
		elseif ( event == "UNIT_RANGED_ATTACK_POWER" ) then
			PaperDollFrame_SetRangedAttack();
		end
	end

	if ( event == "COMBAT_RATING_UPDATE" ) then
		PaperDollFrame_UpdateStats();
	end
end

function PaperDollItemSlotButton_Update(self)
	local textureName = GetInventoryItemTexture("player", self:GetID());
	local cooldown = _G[self:GetName().."Cooldown"];
	if ( textureName ) then
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, GetInventoryItemCount("player", self:GetID()));
		if ( GetInventoryItemBroken("player", self:GetID()) ) then
			SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
			SetItemButtonNormalTextureVertexColor(self, 0.9, 0, 0);
		else
			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
			SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
		end
		if ( cooldown ) then
			local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
			CooldownFrame_SetTimer(cooldown, start, duration, enable);
		end
		self.hasItem = 1;
	else
		local textureName = self.backgroundTextureName;
		if ( self.checkRelic and UnitHasRelicSlot("player") ) then
			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
		end
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, 0);
		SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
		if ( cooldown ) then
			cooldown:Hide();
		end
		self.hasItem = nil;
	end

	SetCharacterFrameTransmogItemButtonTextures()
	
	if ( not GearManagerDialog:IsShown() ) then
		self.ignored = nil;
	end
	
	if ( self.ignored and self.ignoreTexture ) then
		self.ignoreTexture:Show();
	elseif ( self.ignoreTexture ) then
		self.ignoreTexture:Hide();
	end

	PaperDollItemSlotButton_UpdateLock(self);

	-- Update repair all button status
	MerchantFrame_UpdateGuildBankRepair();
	MerchantFrame_UpdateCanRepairAll();
end

function OnClickResetCurrentTransmogSlot(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	if ( currentSlot == PLAYER_VISIBLE_ITEM_1_ENTRYID ) then
		currentHeadTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_3_ENTRYID ) then
		currentShoudlerTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_4_ENTRYID ) then
		currentShirtTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_5_ENTRYID ) then
		currentChestTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_6_ENTRYID ) then
		currentWaistTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_7_ENTRYID ) then
		currentLegsTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_8_ENTRYID ) then
		currentFeetTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_9_ENTRYID ) then
		currentWristTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_10_ENTRYID ) then
		currentHandsTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_15_ENTRYID ) then
		currentBackTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_16_ENTRYID ) then
		currentMainHandTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_17_ENTRYID ) then
		currentOffHandTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_18_ENTRYID ) then
		currentRangedTransmogId = 0
	elseif ( currentSlot == PLAYER_VISIBLE_ITEM_19_ENTRYID ) then
		currentTabardTransmogId = 0
	end
	LoadTransmogsFromCurrentIds()
end

function TransmogHandlers.LoadTransmogsAfterSave(player)
	LoadTransmogsFromCurrentIds()
end

function OnClickApplyAllowTransmogs(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	if ( currentHeadTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentHeadTransmogId, PLAYER_VISIBLE_ITEM_1_ENTRYID) end
	if ( currentShoudlerTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentShoudlerTransmogId, PLAYER_VISIBLE_ITEM_3_ENTRYID) end
	if ( currentShirtTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentShirtTransmogId, PLAYER_VISIBLE_ITEM_4_ENTRYID) end
	if ( currentChestTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentChestTransmogId, PLAYER_VISIBLE_ITEM_5_ENTRYID) end
	if ( currentWaistTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentWaistTransmogId, PLAYER_VISIBLE_ITEM_6_ENTRYID) end
	if ( currentLegsTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentLegsTransmogId, PLAYER_VISIBLE_ITEM_7_ENTRYID) end
	if ( currentFeetTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentFeetTransmogId, PLAYER_VISIBLE_ITEM_8_ENTRYID) end
	if ( currentWristTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentWristTransmogId, PLAYER_VISIBLE_ITEM_9_ENTRYID) end
	if ( currentHandsTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentHandsTransmogId, PLAYER_VISIBLE_ITEM_10_ENTRYID) end
	if ( currentBackTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentBackTransmogId, PLAYER_VISIBLE_ITEM_15_ENTRYID) end
	if ( currentMainHandTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentMainHandTransmogId, PLAYER_VISIBLE_ITEM_16_ENTRYID) end
	if ( currentOffHandTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentOffHandTransmogId, PLAYER_VISIBLE_ITEM_17_ENTRYID) end
	if ( currentRangedTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentRangedTransmogId, PLAYER_VISIBLE_ITEM_18_ENTRYID) end
	if ( currentTabardTransmogId ~= nil ) then AIO.Handle("Transmog", "EquipTransmogItem", currentTabardTransmogId, PLAYER_VISIBLE_ITEM_19_ENTRYID) end
	originalHeadTransmogId =  currentHeadTransmogId
	originalShoudlerTransmogId = currentShoudlerTransmogId
	originalShirtTransmogId = currentShirtTransmogId
	originalChestTransmogId = currentChestTransmogId
	originalWaistTransmogId = currentWaistTransmogId
	originalLegsTransmogId = currentLegsTransmogId
	originalFeetTransmogId = currentFeetTransmogId
	originalWristTransmogId = currentWristTransmogId
	originalHandsTransmogId = currentHandsTransmogId
	originalBackTransmogId = currentBackTransmogId
	originalMainHandTransmogId = currentMainHandTransmogId
	originalOffHandTransmogId = currentOffHandTransmogId
	originalRangedTransmogId = currentRangedTransmogId
	originalTabardTransmogId = currentTabardTransmogId
	LoadTransmogsFromCurrentIds()
end

local function TransmogTabTooltip(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine("Transmog")
	GameTooltip:Show()
end

function TransmogHandlers.InitTab(player, newSlotItemIds, page, hasMorePages)
	currentSlotItemIds = newSlotItemIds
	TransmogPaginationText:SetText("Page "..page)
	
	if ( hasMorePages ) then
		RightButton:Enable()
	else
		RightButton:Disable()
	end
	
	if ( page > 1 ) then
		LeftButton:Enable()
	else
		LeftButton:Disable()
	end
	
	for i, child in ipairs(itemButtons) do
		if ( currentSlotItemIds[i] == nil ) then
			child:SetID(0)
			child.itemButton:SetID(0)
			child.itemButton:Disable()
			child.itemModel:Hide()
		    SetItemButtonTexture(child.itemButton, EmptyEquipmentIconBackgroundPath..EquipmentIconTypes[Transmog_CalculateSlotReverse(currentSlot)])
		else
			child:SetID(currentSlotItemIds[i])
			child.itemButton:SetID(currentSlotItemIds[i])
			local textureName = GetItemIcon(currentSlotItemIds[i])
			SetItemButtonTexture(child.itemButton, textureName)
			child.itemButton:Enable()
			child.itemModel:Show()
			child.itemModel:SetUnit("player")
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

function SetSearchTab()
	PlaySound("INTERFACESOUND_CHARWINDOWTAB", "master")
	currentPage = 1
	TransmogPaginationText:SetText("Page 1")
	AIO.Handle("Transmog", "SetSearchCurrentSlotItemIds", currentSlot, currentPage, ItemSearchInput:GetText())
	ItemSearchInput:ClearFocus()
end

function DisableAllTabs()
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

function SetTab()
	if ( ItemSearchInput:GetText() ~= "" and ItemSearchInput:GetText() ~= "|cff808080Click here and start typing...|r") then
		SetSearchTab()
		DisableAllTabs()
		return;
	end
	PlaySound("INTERFACESOUND_CHARWINDOWTAB", "master")
	currentPage = 1
	TransmogPaginationText:SetText("Page 1")
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
	DisableAllTabs()
end

function TransmogHandlers.SetTransmogItemIdClient(player, slot, id, realItemId)
	if ( tonumber(slot) == PLAYER_VISIBLE_ITEM_1_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentHeadTransmogId == nil or currentHeadTransmogId == 0 ) and realItemId ~= id ) then
			currentHeadTransmogId = id
			originalHeadTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentHeadTransmogId ~= nil and currentHeadTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentHeadTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentHeadTransmogId = realItemId
			originalHeadTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_3_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentShoudlerTransmogId == nil or currentShoudlerTransmogId == 0 ) and realItemId ~= id ) then
			currentShoudlerTransmogId = id
			originalShoudlerTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentShoudlerTransmogId ~= nil and currentShoudlerTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentShoudlerTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentShoudlerTransmogId = realItemId
			originalShoudlerTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_4_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentShirtTransmogId == nil or currentShirtTransmogId == 0 ) and realItemId ~= id ) then
			currentShirtTransmogId = id
			originalShirtTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentShirtTransmogId ~= nil and currentShirtTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentShirtTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentShirtTransmogId = realItemId
			originalShirtTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_5_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentChestTransmogId == nil or currentChestTransmogId == 0 ) and realItemId ~= id ) then
			currentChestTransmogId = id
			originalChestTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentChestTransmogId ~= nil and currentChestTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentChestTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentChestTransmogId = realItemId
			originalChestTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_6_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentWaistTransmogId == nil or currentWaistTransmogId == 0 ) and realItemId ~= id ) then
			currentWaistTransmogId = id
			originalWaistTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentWaistTransmogId ~= nil and currentWaistTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentWaistTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentWaistTransmogId = realItemId
			originalWaistTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_7_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentLegsTransmogId == nil or currentLegsTransmogId == 0 ) and realItemId ~= id ) then
			currentLegsTransmogId = id
			originalLegsTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentLegsTransmogId ~= nil and currentLegsTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentLegsTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentLegsTransmogId = realItemId
			originalLegsTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_8_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentFeetTransmogId == nil or currentFeetTransmogId == 0 ) and realItemId ~= id ) then
			currentFeetTransmogId = id
			originalFeetTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentFeetTransmogId ~= nil and currentFeetTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentFeetTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentFeetTransmogId = realItemId
			originalFeetTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_9_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentWristTransmogId == nil or currentWristTransmogId == 0 ) and realItemId ~= id ) then
			currentWristTransmogId = id
			originalWristTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentWristTransmogId ~= nil and currentWristTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentWristTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentWristTransmogId = realItemId
			originalWristTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_10_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentHandsTransmogId == nil or currentHandsTransmogId == 0 ) and realItemId ~= id ) then
			currentHandsTransmogId = id
			originalHandsTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentHandsTransmogId ~= nil and currentHandsTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentHandsTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentHandsTransmogId = realItemId
			originalHandsTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_15_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentBackTransmogId == nil or currentBackTransmogId == 0 ) and realItemId ~= id ) then
			currentBackTransmogId = id
			originalBackTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentBackTransmogId ~= nil and currentBackTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentBackTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentBackTransmogId = realItemId
			originalBackTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_16_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentMainHandTransmogId == nil or currentMainHandTransmogId == 0 ) and realItemId ~= id ) then
			currentMainHandTransmogId = id
			originalMainHandTransmogId = id
			--CharacterModelFrame:TryOn(id)
		elseif ( currentMainHandTransmogId ~= nil and currentMainHandTransmogId ~= 0 ) then
			--CharacterModelFrame:TryOn(currentMainHandTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentMainHandTransmogId = realItemId
			originalMainHandTransmogId = realItemId
			--CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_17_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentOffHandTransmogId == nil or currentOffHandTransmogId == 0 ) and realItemId ~= id ) then
			currentOffHandTransmogId = id
			originalOffHandTransmogId = id
			--CharacterModelFrame:TryOn(id)
		elseif ( currentOffHandTransmogId ~= nil and currentOffHandTransmogId ~= 0 ) then
			--CharacterModelFrame:TryOn(currentOffHandTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentOffHandTransmogId = realItemId
			originalOffHandTransmogId = realItemId
			--CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_18_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentRangedTransmogId == nil or currentRangedTransmogId == 0 ) and realItemId ~= id ) then
			currentRangedTransmogId = id
			originalRangedTransmogId = id
			--CharacterModelFrame:TryOn(id)
		elseif ( currentRangedTransmogId ~= nil and currentRangedTransmogId ~= 0 ) then
			--CharacterModelFrame:TryOn(currentRangedTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentRangedTransmogId = realItemId
			originalRangedTransmogId = realItemId
			--CharacterModelFrame:TryOn(realItemId)
		end
	elseif ( tonumber(slot) == PLAYER_VISIBLE_ITEM_19_ENTRYID ) then
		if ( id ~= 0 and id ~= nil and ( currentTabardTransmogId == nil or currentTabardTransmogId == 0 ) and realItemId ~= id ) then
			currentTabardTransmogId = id
			originalTabardTransmogId = id
			CharacterModelFrame:TryOn(id)
		elseif ( currentTabardTransmogId ~= nil and currentTabardTransmogId ~= 0 ) then
			CharacterModelFrame:TryOn(currentTabardTransmogId)
		elseif ( id ~= 0 and realItemId ~= 0 and realItemId ~= nil ) then
			currentTabardTransmogId = realItemId
			originalTabardTransmogId = realItemId
			CharacterModelFrame:TryOn(realItemId)
		end
	end
	ResetCharacterFrameTransmogItemButtonTextures()
end

local function OnClickHeadTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
	SetTab()
	PanelTemplates_SelectTab(headTab)
end

local function OnClickShoulderTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_3_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(shoulderTab)
end

local function OnClickShirtTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_4_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(shirtTab)
end

local function OnClickChestTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_5_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(chestTab)
end

local function OnClickWaistTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_6_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(waistTab)
end

local function OnClickLegsTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_7_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(legsTab)
end

local function OnClickFeetTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_8_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(feetTab)
end

local function OnClickWristTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_9_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(wristTab)
end

local function OnClickHandsTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_10_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(handsTab)
end

local function OnClickBackTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_15_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(backTab)
end

local function OnClickMainTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_16_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(mainTab)
end

local function OnClickOffTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_17_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(offTab)
end

local function OnClickRangedTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_18_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(rangedTab)
end

local function OnClickTabardTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_19_ENTRYID
    SetTab()
	PanelTemplates_SelectTab(tabardTab)
end

local function OnEventEnterWorldReloadTransmogIds(self, event)
	if ( event == "PLAYER_ENTERING_WORLD") then
		AIO.Handle("Transmog", "SetTransmogItemIds")
	else
		AIO.Handle("Transmog", "OnUnequipItem")
		ResetCharacterFrameTransmogItemButtonTextures()
		if ( TransmogFrame:IsShown() ) then
			LoadTransmogsFromCurrentIds()
		end
	end
end

function OnTransmogFrameLoad(self)
	-- get transmog ids and cache them on client
	ItemSearchInput:SetText("|cff808080Click here and start typing...|r")
	ItemSearchInput:SetScript("OnEnterPressed", SetSearchTab)
	
	InitTabSlots()
	
	local leftFontString = LeftButton:GetFontString()
	leftFontString:SetShadowOffset(1, -1)
	leftFontString:SetPoint("CENTER", 0, 2)
	
	local rightFontString = RightButton:GetFontString()
	rightFontString:SetShadowOffset(1, -1)
	rightFontString:SetPoint("CENTER", 0, 2)

	headTab = CreateFrame("Button", "HeadTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	headTab:SetPoint("BOTTOMLEFT", TransmogFrame, "BOTTOMLEFT", 0, -24)
	headTab:SetText("Head")
	headTab:SetFrameLevel(frameLevel)
	PanelTemplates_SelectTab(headTab)
	PanelTemplates_TabResize(headTab, 0)

	shoulderTab = CreateFrame("Button", "ShoulderTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	shoulderTab:SetText("Shoulder")
	shoulderTab:SetPoint("LEFT", headTab, "LEFT", headTab:GetWidth() - 10, 0)
	shoulderTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(shoulderTab)
	PanelTemplates_TabResize(shoulderTab, 0)

	shirtTab = CreateFrame("Button", "ShirtTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	shirtTab:SetText("Shirt")
	shirtTab:SetPoint("LEFT", shoulderTab, "LEFT", shoulderTab:GetWidth() - 10, 0)
	shirtTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(shirtTab)
	PanelTemplates_TabResize(shirtTab, 0)

	chestTab = CreateFrame("Button", "ChestTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	chestTab:SetText("Chest")
	chestTab:SetPoint("LEFT", shirtTab, "LEFT", shirtTab:GetWidth() - 10, 0)
	chestTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(chestTab)
	PanelTemplates_TabResize(chestTab, 0)

	waistTab = CreateFrame("Button", "WaistTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	waistTab:SetText("Waist")
	waistTab:SetPoint("LEFT", chestTab, "LEFT", chestTab:GetWidth() - 10, 0)
	waistTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(waistTab)
	PanelTemplates_TabResize(waistTab, 0)

	legsTab = CreateFrame("Button", "LegsTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	legsTab:SetText("Legs")
	legsTab:SetPoint("LEFT", waistTab, "LEFT", waistTab:GetWidth() - 10, 0)
	legsTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(legsTab)
	PanelTemplates_TabResize(legsTab, 0)

	feetTab = CreateFrame("Button", "FeetTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	feetTab:SetText("Feet")
	feetTab:SetPoint("LEFT", legsTab, "LEFT", legsTab:GetWidth() - 10, 0)
	feetTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(feetTab)
	PanelTemplates_TabResize(feetTab, 0)

	wristTab = CreateFrame("Button", "WristTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	wristTab:SetText("Wrist")
	wristTab:SetPoint("LEFT", feetTab, "LEFT", feetTab:GetWidth() - 10, 0)
	wristTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(wristTab)
	PanelTemplates_TabResize(wristTab, 0)

	handsTab = CreateFrame("Button", "wristTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	handsTab:SetText("Hands")
	handsTab:SetPoint("LEFT", wristTab, "LEFT", wristTab:GetWidth() - 10, 0)
	handsTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(handsTab)
	PanelTemplates_TabResize(handsTab, 0)

	backTab = CreateFrame("Button", "BackTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	backTab:SetText("Back")
	backTab:SetPoint("LEFT", handsTab, "LEFT", handsTab:GetWidth() - 10, 0)
	backTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(backTab)
	PanelTemplates_TabResize(backTab, 0)

	mainTab = CreateFrame("Button", "MainTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	mainTab:SetText("Main Hand")
	mainTab:SetPoint("LEFT", backTab, "LEFT", backTab:GetWidth() - 10, 0)
	mainTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(mainTab)
	PanelTemplates_TabResize(mainTab, 0)

	offTab = CreateFrame("Button", "OffTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	offTab:SetText("Off Hand")
	offTab:SetPoint("LEFT", mainTab, "LEFT", mainTab:GetWidth() - 10, 0)
	offTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(offTab)
	PanelTemplates_TabResize(offTab, 0)

	rangedTab = CreateFrame("Button", "RangedTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	rangedTab:SetText("Ranged")
	rangedTab:SetPoint("LEFT", offTab, "LEFT", offTab:GetWidth() - 10, 0)
	rangedTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(rangedTab)
	PanelTemplates_TabResize(rangedTab, 0);

	tabardTab = CreateFrame("Button", "TabardTab", TransmogFrame, "CharacterFrameTabButtonTemplate")
	tabardTab:SetText("Tabard")
	tabardTab:SetPoint("LEFT", rangedTab, "LEFT", rangedTab:GetWidth() - 10, 0)
	tabardTab:SetFrameLevel(frameLevel)
	PanelTemplates_DeselectTab(tabardTab)
	PanelTemplates_TabResize(tabardTab, 0);
	
	characterTransmogTab = CreateFrame("CheckButton", "CharacterFrameTab6", CharacterFrame, "SpellBookSkillLineTabTemplate")
	characterTransmogTab:SetSize(32, 32);
	characterTransmogTab:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", 0, -48)
	characterTransmogTab:Show()
	innerCharacterTransmogTab = characterTransmogTab:CreateTexture("Item", "ARTWORK")
	innerCharacterTransmogTab:SetTexture("Interface\\Icons\\INV_Mask_01")
	innerCharacterTransmogTab:SetAllPoints()
	innerCharacterTransmogTab:Show()
	characterTransmogTab:SetScript("OnEnter", TransmogTabTooltip)
	characterTransmogTab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	characterTransmogTab:SetScript("OnClick", function(self) if ( TransmogFrame:IsShown() ) then TransmogFrame:Hide() return; end TransmogFrame:Show() end)

	PaperDollFrame:SetScript("OnShow", PaperDollFrame_OnShow)
	
	headTab:SetScript("OnClick", OnClickHeadTab)
	shoulderTab:SetScript("OnClick", OnClickShoulderTab)
	shirtTab:SetScript("OnClick", OnClickShirtTab)
	chestTab:SetScript("OnClick", OnClickChestTab)
	waistTab:SetScript("OnClick", OnClickWaistTab)
	legsTab:SetScript("OnClick", OnClickLegsTab)
	feetTab:SetScript("OnClick", OnClickFeetTab)
	wristTab:SetScript("OnClick", OnClickWristTab)
	handsTab:SetScript("OnClick", OnClickHandsTab)
	backTab:SetScript("OnClick", OnClickBackTab)
	mainTab:SetScript("OnClick", OnClickMainTab)
	offTab:SetScript("OnClick", OnClickOffTab)
	rangedTab:SetScript("OnClick", OnClickRangedTab)
	tabardTab:SetScript("OnClick", OnClickTabardTab)
	
	-- This enables saving of the position of the frame over reload of the UI or restarting game
	AIO.SavePosition(TransmogFrame)
	TransmogFrame:RegisterForDrag("LeftButton");

	_G["TransmogFrame"] = TransmogFrame
	tinsert(UISpecialFrames, TransmogFrame:GetName())
	TransmogFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	TransmogFrame:RegisterEvent("UNIT_MODEL_CHANGED")
	TransmogFrame:SetScript("OnEvent", OnEventEnterWorldReloadTransmogIds)
end

function OnClickTransmogButton(self)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	currentHeadTransmogId = originalHeadTransmogId
	currentShoudlerTransmogId = originalShoudlerTransmogId
	currentShirtTransmogId = originalShirtTransmogId
	currentChestTransmogId = originalChestTransmogId
	currentWaistTransmogId = originalWaistTransmogId
	currentLegsTransmogId = originalLegsTransmogId
	currentFeetTransmogId = originalFeetTransmogId
	currentWristTransmogId = originalWristTransmogId
	currentHandsTransmogId = originalHandsTransmogId
	currentBackTransmogId = originalBackTransmogId
	currentMainHandTransmogId = originalMainHandTransmogId
	currentOffHandTransmogId = originalOffHandTransmogId
	currentRangedTransmogId = originalRangedTransmogId
	currentTabardTransmogId = originalTabardTransmogId
	ResetCharacterFrameTransmogItemButtonTextures()
	CharacterModelFrame:Show()
	CharacterModelFrameFake:Hide()
	currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
	SetTab()
	PanelTemplates_SelectTab(headTab)
	characterTransmogTab:SetChecked(true)
	isInputHovered = false
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, 1)
	ItemSearchInput:SetText("|cff808080Click here and start typing...|r")
	LoadTransmogsFromCurrentIds()
end

function OnHideTransmogFrame(self)
	PlaySound("INTERFACESOUND_CHARWINDOWCLOSE", "master")
	currentHeadTransmogId = originalHeadTransmogId
	currentShoudlerTransmogId = originalShoudlerTransmogId
	currentShirtTransmogId = originalShirtTransmogId
	currentChestTransmogId = originalChestTransmogId
	currentWaistTransmogId = originalWaistTransmogId
	currentLegsTransmogId = originalLegsTransmogId
	currentFeetTransmogId = originalFeetTransmogId
	currentWristTransmogId = originalWristTransmogId
	currentHandsTransmogId = originalHandsTransmogId
	currentBackTransmogId = originalBackTransmogId
	currentMainHandTransmogId = originalMainHandTransmogId
	currentOffHandTransmogId = originalOffHandTransmogId
	currentRangedTransmogId = originalRangedTransmogId
	currentTabardTransmogId = originalTabardTransmogId
	ResetCharacterFrameTransmogItemButtonTextures()
	CharacterModelFrame:Hide()
	CharacterModelFrameFake:SetUnit("player")
	CharacterModelFrameFake:Show()
	characterTransmogTab:SetChecked(false)
end

function PaperDollFrame_OnShow(self)
	--PaperDollFrame_SetGuild();
	PaperDollFrame_SetLevel();
	PaperDollFrame_SetResistances();
	PaperDollFrame_UpdateStats();
	if ( UnitHasRelicSlot("player") ) then
		CharacterAmmoSlot:Hide();
	else
		CharacterAmmoSlot:Show();
	end
	if ( not PlayerTitlePickerScrollFrame.titles ) then
		PlayerTitleFrame_UpdateTitles();	
	end
	
	CharacterModelFrameFake:SetUnit("player")
	if ( TransmogFrame:IsShown() ) then -- custom code
		characterTransmogTab:SetChecked(true)
		CharacterModelFrame:Show()
		CharacterModelFrameFake:Hide()
		else
		characterTransmogTab:SetChecked(false)
		CharacterModelFrame:Hide()
		CharacterModelFrameFake:Show()
	end

	LoadTransmogsFromCurrentIds()
	-- end custom code
end

--local function OnClickButton(btn)
    --AIO.Handle("Transmog", "Print", headTab:GetName(), headTab)
--end
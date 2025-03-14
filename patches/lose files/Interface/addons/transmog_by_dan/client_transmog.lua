---------------------|Created by DanielTheDeveloper|-----------------------|

local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local TransmogHandlers = AIO.AddHandlers("Transmog", {})

local function OnEvent(self, event)
	AIO.Handle("Transmog", "LoadPlayer")
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)

local CALC = 281

PLAYER_VISIBLE_ITEM_1_ENTRYID  = 283
PLAYER_VISIBLE_ITEM_3_ENTRYID  = 287
PLAYER_VISIBLE_ITEM_4_ENTRYID  = 289
PLAYER_VISIBLE_ITEM_5_ENTRYID  = 291
PLAYER_VISIBLE_ITEM_6_ENTRYID  = 293
PLAYER_VISIBLE_ITEM_7_ENTRYID  = 295
PLAYER_VISIBLE_ITEM_8_ENTRYID  = 297
PLAYER_VISIBLE_ITEM_9_ENTRYID  = 299
PLAYER_VISIBLE_ITEM_10_ENTRYID  = 301
PLAYER_VISIBLE_ITEM_15_ENTRYID  = 311
PLAYER_VISIBLE_ITEM_16_ENTRYID  = 313
PLAYER_VISIBLE_ITEM_17_ENTRYID  = 315
PLAYER_VISIBLE_ITEM_18_ENTRYID  = 317
PLAYER_VISIBLE_ITEM_19_ENTRYID  = 319

function Transmog_CalculateSlotReverse(slot)
	local reverseSlot = (slot - CALC) / 2
	return reverseSlot;
end

local SLOT_IDS = {
    Head = PLAYER_VISIBLE_ITEM_1_ENTRYID,
    Shoulder = PLAYER_VISIBLE_ITEM_3_ENTRYID,
    Shirt = PLAYER_VISIBLE_ITEM_4_ENTRYID,
    Chest = PLAYER_VISIBLE_ITEM_5_ENTRYID,
    Waist = PLAYER_VISIBLE_ITEM_6_ENTRYID,
    Legs = PLAYER_VISIBLE_ITEM_7_ENTRYID,
    Feet = PLAYER_VISIBLE_ITEM_8_ENTRYID,
    Wrist = PLAYER_VISIBLE_ITEM_9_ENTRYID,
    Hands = PLAYER_VISIBLE_ITEM_10_ENTRYID,
    Back = PLAYER_VISIBLE_ITEM_15_ENTRYID,
    MainHand = PLAYER_VISIBLE_ITEM_16_ENTRYID,
    SecondaryHand = PLAYER_VISIBLE_ITEM_17_ENTRYID,
    Ranged = PLAYER_VISIBLE_ITEM_18_ENTRYID,
    Tabard = PLAYER_VISIBLE_ITEM_19_ENTRYID,
}

function TableSetHelper(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

local EMPTY_TEXTURE = "Interface\\AddOns\\transmog_by_dan\\assets\\Transmog-Icon"
local EMPTY_EQUIPMENT_ICON_BACKGROUND_PATH = "Interface\\paperdoll\\UI-PaperDoll-Slot-"
local EQUIPMENT_ICON_TYPES = {"Head", "", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrists", "Hands", "", "", "", "", "Chest", "MainHand", "SecondaryHand", "Ranged", "Tabard"}
-- List of character item frames that will be used
local EQUIPMENT_SLOT_FRAME_NAMES = {"CharacterHeadSlot", "CharacterShoulderSlot", "CharacterBackSlot", "CharacterChestSlot", "CharacterShirtSlot", "CharacterTabardSlot", "CharacterWristSlot", "CharacterHandsSlot", "CharacterWaistSlot", "CharacterLegsSlot", "CharacterFeetSlot", "CharacterMainHandSlot", "CharacterSecondaryHandSlot", "CharacterRangedSlot"}
EQUIPMENT_SLOT_FRAME_NAMES = TableSetHelper(EQUIPMENT_SLOT_FRAME_NAMES)

TRANSMOG_SLOT_MAPPING = {
	[PLAYER_VISIBLE_ITEM_1_ENTRYID] = "Head",
	[PLAYER_VISIBLE_ITEM_3_ENTRYID] = "Shoulder",
	[PLAYER_VISIBLE_ITEM_4_ENTRYID] = "Shirt",
	[PLAYER_VISIBLE_ITEM_5_ENTRYID] = "Chest",
	[PLAYER_VISIBLE_ITEM_6_ENTRYID] = "Waist",
	[PLAYER_VISIBLE_ITEM_7_ENTRYID] = "Legs",
	[PLAYER_VISIBLE_ITEM_8_ENTRYID] = "Feet",
	[PLAYER_VISIBLE_ITEM_9_ENTRYID] = "Wrist",
	[PLAYER_VISIBLE_ITEM_10_ENTRYID] = "Hands",
	[PLAYER_VISIBLE_ITEM_15_ENTRYID] = "Back",
	[PLAYER_VISIBLE_ITEM_16_ENTRYID] = "MainHand",
	[PLAYER_VISIBLE_ITEM_17_ENTRYID] = "SecondaryHand",
	[PLAYER_VISIBLE_ITEM_18_ENTRYID] = "Ranged",
	[PLAYER_VISIBLE_ITEM_19_ENTRYID] = "Tabard"
}

-- Cached globals for performance
local GetItemIcon, SetItemButtonTexture, PlaySound, CreateFrame, GameTooltip = 
      GetItemIcon, SetItemButtonTexture, PlaySound, CreateFrame, GameTooltip

-- State management
local itemButtons = {}
local isInputHovered = false
local currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID

originalTransmogIds = originalTransmogIds or {}
AIO.AddSavedVarChar("originalTransmogIds")
currentTransmogIds = {}
for k, v in pairs(originalTransmogIds) do
	currentTransmogIds[k] = v
end


local currentSlotItemIds = nil -- hold ids and icon paths
local currentPage = 1
local morePages = false
local itemButtons = {}
local currentTooltipSlot = nil
local isInputHovered = false


-- TODO Add spam preventing measures

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
	
	-- Check if ownerFrame is valid
	if not ownerFrame then
		return  -- If ownerFrame is nil, just return and do nothing
	end
	
	local slotName = ownerFrame:GetName()
	if ( currentTooltipSlot == slotName ) then
		return;
	end
	currentTooltipSlot = slotName
	if ( EQUIPMENT_SLOT_FRAME_NAMES[slotName] ) then
		--if ( not name ) then 
			--GameTooltip:SetHyperlink("item:"..itemId..":0:0:0:0:0:0:0")
		--end
		if ( not tooltip:IsEquippedItem() ) then
			tooltip:AddLine(" ")
			tooltip:AddLine("This item is a transmog and purely cosmetic!", 1, 0, 0)
			return;
		end
		
        -- TODO remove Character and Slot from string slotName to search slot id in table
		if ( slotId ) then
            -- TODO just search db for item in accoumt_transmog
			--AIO.Handle("Transmog", "SetEquipmentTransmogInfo", slotId, currentTooltipSlot) TODO This will only work with cached slots?? Inf loop when trying to call server and back
		end
		return;
	end
	tooltip:Show()
end)

function UpdateSlotTexture(slotName, isTransmogFrame)
    local slotFrame
	if isTransmogFrame then
		slotFrame = _G["TransmogCharacter" .. slotName .. "Slot"]
	else
		slotFrame = _G["Character" .. slotName .. "Slot"]
	end
	local transmogId = currentTransmogIds[slotName]
	if ( transmogId ~= nil and transmogId ~= 0 ) then
		SetItemButtonTexture(slotFrame, GetItemIcon(transmogId))
	elseif ( transmogId == 0 ) then
		SetItemButtonTexture(slotFrame, EMPTY_TEXTURE)
	end
end

function UpdateAllSlotTextures()
    for slotName, _ in pairs(SLOT_IDS) do
        PaperDollItemSlotButton_Update(_G["Character" .. slotName .. "Slot"])
		TransmogItemSlotButton_Update(_G["TransmogCharacter" .. slotName .. "Slot"])
    end
end

function LoadTransmogsFromCurrentIds()
    TransmogModelFrame:SetUnit("player")
    TransmogModelFrame:Undress()

    for slotName, transmogId in pairs(currentTransmogIds) do
        if transmogId and slotName ~= "MainHand" and slotName ~= "SecondaryHand" and slotName ~= "Ranged" then
            TransmogModelFrame:TryOn(transmogId)
        end
    end
    
    UpdateAllSlotTextures()
end

local function OnClickItemTransmogButton(btn, buttonType)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	LoadTransmogsFromCurrentIds()
	local itemId = btn:GetID()
	local textureName = GetItemIcon(itemId)
	local slotName = TRANSMOG_SLOT_MAPPING[currentSlot]
	currentTransmogIds[slotName] = itemId
	TransmogModelFrame:TryOn(itemId)
	UpdateAllSlotTextures()
    --SetItemButtonTexture(_G["Character" .. slotName .. "Slot"], textureName)
end

function OnClickResetAllButton(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
    for slotName, _ in pairs(SLOT_IDS) do
        currentTransmogIds[slotName] = 0
    end
	TransmogModelFrame:SetUnit("player")
	TransmogModelFrame:Undress()
    UpdateAllSlotTextures()
end

function OnClickDeleteAllButton(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
    for slotName, slotId in pairs(SLOT_IDS) do
        currentTransmogIds[slotName] = nil
		originalTransmogIds[slotName] = nil
		AIO.Handle("Transmog", "EquipTransmogItem", nil, slotId)
    end
    LoadTransmogsFromCurrentIds()
	TransmogModelFrame:SetUnit("player")
	TransmogModelFrame:Undress()
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

function InitTabSlots()
    local lastSlot
    local firstInRowSlot
    local rowOffset = 150  -- Horizontal spacing between grids
    local verticalOffset = -260  -- Initial vertical position
    local startX, startY = 480, verticalOffset  -- Starting position for the first grid

    -- Helper function to create frames for visual assets
    local function CreateItemFrame(parent, index, texture, width, height, point, xOffset, yOffset)
        local frame = CreateFrame("Frame", parent:GetName().."Frame"..index, parent)
        frame:SetPoint(point, xOffset, yOffset)
        frame:SetSize(width, height)
        local textureFrame = frame:CreateTexture(nil, "BACKGROUND")
        textureFrame:SetTexture(texture)
        textureFrame:SetAllPoints()
        return frame
    end

    for i = 1, 8 do
        local itemChild

        if i == 1 then
            -- First grid in the first row
            itemChild = CreateFrame("Frame", "ItemChild"..i, TransmogFrame, "TransmogItemWrapperTemplate")
            itemChild:SetPoint("TOPLEFT", startX, startY)  -- Starting position for the first grid
            firstInRowSlot = itemChild
        elseif i <= 4 then
            -- First four grids (first row), positioned horizontally with 0-pixel offset
            itemChild = CreateFrame("Frame", "ItemChild"..i, TransmogFrame, "TransmogItemWrapperTemplate")
            itemChild:SetPoint("LEFT", lastSlot, "RIGHT", 0, 0)  -- 0-pixel offset between grids
        elseif i == 5 then
            -- Start of the second row, anchored to the bottom-left of the first grid
            itemChild = CreateFrame("Frame", "ItemChild"..i, TransmogFrame, "TransmogItemWrapperTemplate")
            itemChild:SetPoint("TOPLEFT", firstInRowSlot, "BOTTOMLEFT", 0, 0)  -- 0-pixel offset between rows x & y
            firstInRowSlot = itemChild
        else
            -- Following grids (second row), positioned horizontally with 0-pixel offset
            itemChild = CreateFrame("Frame", "ItemChild"..i, TransmogFrame, "TransmogItemWrapperTemplate")
            itemChild:SetPoint("LEFT", lastSlot, "RIGHT", 0, 0)  -- 0-pixel offset between rows x & y
        end

        -- Create visual assets for the grid (top, bottom, left, right frames)
        local rightTopItemFrame = CreateItemFrame(itemChild, i, DressUpTexturePath().."2", 34, 142, "TOPRIGHT", -4, -4)
        local rightBottomItemFrame = CreateItemFrame(itemChild, i, DressUpTexturePath().."4", 34, 53, "BOTTOMRIGHT", -4, -18)
        local leftTopItemFrame = CreateItemFrame(itemChild, i, DressUpTexturePath().."1", 109, 142, "TOPLEFT", 4, -4)
        local leftBottomItemFrame = CreateItemFrame(itemChild, i, DressUpTexturePath().."3", 109, 53, "BOTTOMLEFT", 4, -18)

        -- Create the 3D model for this grid
        local itemModel = CreateFrame("DressUpModel", "ItemModel"..i, itemChild)
        itemModel:SetPoint("CENTER", 0, 0)
        itemModel:SetSize(142, 172)
        itemModel:Hide()

        -- Create the button for this grid
        local itemButton = CreateFrame("Button", "ItemButton"..i, leftBottomItemFrame, "TransmogItemButtonTemplate")
        itemButton:SetPoint("BOTTOMLEFT", 6, 28)
        itemButton:SetScript("OnClick", OnClickItemTransmogButton)
        itemButton:SetScript("OnEnter", OnEnterItemToolTip)
        itemButton:SetScript("OnLeave", OnLeaveItemToolTip)
        itemButton:RegisterForClicks("AnyUp")
        itemButton:Disable()

        -- Store the model and button in the grid frame
        itemChild.itemModel = itemModel
        itemChild.itemButton = itemButton
        table.insert(itemButtons, itemChild)

        lastSlot = itemChild
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

-- function PaperDollItemSlotButton_Update(self)
-- 	for slotName, _ in pairs(SLOT_IDS) do
--         UpdateSlotTexture(slotName, false)
--     end

-- 	local textureName = GetInventoryItemTexture("player", self:GetID());
-- 	local cooldown = _G[self:GetName().."Cooldown"];
-- 	if ( textureName ) then
-- 		SetItemButtonTexture(self, textureName);
-- 		SetItemButtonCount(self, GetInventoryItemCount("player", self:GetID()));
-- 		if ( GetInventoryItemBroken("player", self:GetID()) ) then
-- 			SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
-- 			SetItemButtonNormalTextureVertexColor(self, 0.9, 0, 0);
-- 		else
-- 			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
-- 			SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
-- 		end
-- 		if ( cooldown ) then
-- 			local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
-- 			CooldownFrame_SetTimer(cooldown, start, duration, enable);
-- 		end
-- 		self.hasItem = 1;
-- 	else
-- 		local textureName = self.backgroundTextureName;
-- 		if ( self.checkRelic and UnitHasRelicSlot("player") ) then
-- 			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
-- 		end
-- 		SetItemButtonTexture(self, textureName);
-- 		SetItemButtonCount(self, 0);
-- 		SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
-- 		SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
-- 		if ( cooldown ) then
-- 			cooldown:Hide();
-- 		end
-- 		self.hasItem = nil;
-- 	end
	
-- 	if ( not GearManagerDialog:IsShown() ) then
-- 		self.ignored = nil;
-- 	end
	
-- 	if ( self.ignored and self.ignoreTexture ) then
-- 		self.ignoreTexture:Show();
-- 	elseif ( self.ignoreTexture ) then
-- 		self.ignoreTexture:Hide();
-- 	end

-- 	PaperDollItemSlotButton_UpdateLock(self);

-- 	-- Update repair all button status
-- 	MerchantFrame_UpdateGuildBankRepair();
-- 	MerchantFrame_UpdateCanRepairAll();
-- end

function TransmogItemSlotButton_Update(self)
	local textureName = GetInventoryItemTexture("player", self:GetID());
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
		self.hasItem = nil;
	end

	for slotName, _ in pairs(SLOT_IDS) do
        UpdateSlotTexture(slotName, true)
    end

	PaperDollItemSlotButton_UpdateLock(self);
end

function OnClickResetCurrentTransmogSlot(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
    local slotName = TRANSMOG_SLOT_MAPPING[currentSlot]
    currentTransmogIds[slotName] = 0
    UpdateSlotTexture(slotName, false)
	UpdateSlotTexture(slotName, true)
	AIO.Handle("Transmog", "EquipTransmogItem", 0, currentSlot)
	originalTransmogIds[slotName] = transmogId
    LoadTransmogsFromCurrentIds()
end

-- Why delete only working without the transmog 0 applied? Why transmog 0?!
function OnClickDeleteCurrentTransmogSlot(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
    local slotName = TRANSMOG_SLOT_MAPPING[currentSlot]
    currentTransmogIds[slotName] = nil
    originalTransmogIds[slotName] = nil
    AIO.Handle("Transmog", "EquipTransmogItem", nil, currentSlot)
    LoadTransmogsFromCurrentIds()
end

function TransmogHandlers.LoadTransmogsAfterSave(player)
	LoadTransmogsFromCurrentIds()
end

-- language support
-- fallback = enUS
local CLIENT_FALLBACK_LANG = 0
local LANG_ID_TABLE = {
    ["enUS"] = 0,
    ["frFR"] = 2,
    ["deDE"] = 3,
}

local function HandleLocale()
    local langId = LANG_ID_TABLE[GetLocale()]
    if not langId then
        langId = CLIENT_FALLBACK_LANG
    end

    return langId
end

function TransmogHandlers.GetLocale(player, item, count)
    AIO.Handle("Transmog", "LootItemLocale", item, count, HandleLocale())
end

function OnClickApplyAllowTransmogs(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
    for slotName, entryId in pairs(SLOT_IDS) do
        local transmogId = currentTransmogIds[slotName]
        AIO.Handle("Transmog", "EquipTransmogItem", transmogId, entryId)
        originalTransmogIds[slotName] = transmogId
    end
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
    
    if (hasMorePages) then
        RightButton:Enable()
    else
        RightButton:Disable()
    end
    
    if (page > 1) then
        LeftButton:Enable()
    else
        LeftButton:Disable()
    end

    for i, child in ipairs(itemButtons) do
        if (currentSlotItemIds[i] == nil) then
            child:SetID(0)
            child.itemButton:SetID(0)
            child.itemButton:Disable()
            child.itemModel:Hide()
            SetItemButtonTexture(child.itemButton, EMPTY_EQUIPMENT_ICON_BACKGROUND_PATH..EQUIPMENT_ICON_TYPES[Transmog_CalculateSlotReverse(currentSlot)])
        else
            child:SetID(currentSlotItemIds[i])
            child.itemButton:SetID(currentSlotItemIds[i])
            local textureName = GetItemIcon(currentSlotItemIds[i])
            SetItemButtonTexture(child.itemButton, textureName)
            child.itemButton:Enable()
            child.itemModel:Show()
            child.itemModel:SetUnit("player")
            child.itemModel:Undress()
            child.itemModel:TryOn(currentSlotItemIds[i])
            child.itemModel:SetPoint("CENTER", 0, -15)

            -- Set model adjustments based on the slot
            if (currentSlot == PLAYER_VISIBLE_ITEM_1_ENTRYID) then -- Head
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(0)
                child.itemModel:SetScale(1.0)  -- Set scale for Head
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_3_ENTRYID) then -- Shoulder
                child.itemModel:SetPoint("CENTER", 1, 0)
                child.itemModel:SetRotation(45, true)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(3)  -- Set scale for Shoulder
				child.itemModel:SetFacing(-0.6)
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_4_ENTRYID) then -- Shirt
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.0)  -- Set scale for Shirt
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_5_ENTRYID) then -- Chest
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.2)  -- Set scale for Chest
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_6_ENTRYID) then -- Waist
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(0.9)  -- Set scale for Waist
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_7_ENTRYID) then -- Legs
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.1)  -- Set scale for Legs
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_8_ENTRYID) then -- Feet
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.0)  -- Set scale for Feet
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_9_ENTRYID) then -- Wrist
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.0)  -- Set scale for Wrist
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_10_ENTRYID) then -- Hands
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.1)  -- Set scale for Hands
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_15_ENTRYID) then -- Back
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.0)  -- Set scale for Back
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_16_ENTRYID) then -- Main Hand
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.0)  -- Set scale for Main Hand
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_17_ENTRYID) then -- Secondary Hand
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.0)  -- Set scale for Secondary Hand
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_18_ENTRYID) then -- Ranged
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.0)  -- Set scale for Ranged
            elseif (currentSlot == PLAYER_VISIBLE_ITEM_19_ENTRYID) then -- Tabard
                child.itemModel:SetPoint("CENTER", 0, 0)
                child.itemModel:SetRotation(90, false)
                child.itemModel:SetCamera(1)
                child.itemModel:SetScale(1.0)  -- Set scale for Tabard
            else
                -- Set the rotation of other items to 0
                child.itemModel:SetRotation(0, false)
                -- Set default position
                child.itemModel:SetPoint("CENTER", 0, -15)
                -- Set default zoom (0 is default zoom level)
                child.itemModel:SetCamera(1)  -- Adjust zoom level for other items
                -- Set default scale for other items
                child.itemModel:SetScale(1.0)
            end
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

function SetTab()
	if ( ItemSearchInput:GetText() ~= "" and ItemSearchInput:GetText() ~= "|cff808080Click here and start typing...|r") then
		SetSearchTab()
		return;
	end
	PlaySound("INTERFACESOUND_CHARWINDOWTAB", "master")
	currentPage = 1
	TransmogPaginationText:SetText("Page 1")
	for slot, value in pairs(SLOT_IDS) do
		_G["TransmogCharacter"..slot.."Slot"].toastTexture:SetTexture("Interface\\AddOns\\transmog_by_dan\\assets\\Transmog-Overlay-Toast")
		_G["TransmogCharacter"..slot.."Slot"].resetButton:Hide()
		_G["TransmogCharacter"..slot.."Slot"].deleteButton:Hide()
	end
	_G["TransmogCharacter"..TRANSMOG_SLOT_MAPPING[currentSlot].."Slot"].toastTexture:SetTexture("Interface\\AddOns\\transmog_by_dan\\assets\\Transmog-Overlay-Selected")
	_G["TransmogCharacter"..TRANSMOG_SLOT_MAPPING[currentSlot].."Slot"].resetButton:Show()
	_G["TransmogCharacter"..TRANSMOG_SLOT_MAPPING[currentSlot].."Slot"].deleteButton:Show()
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
end

function TransmogHandlers.SetTransmogItemIdClient(player, slot, id, realItemId)
    -- Get the transmog part name based on the slot
    local part = TRANSMOG_SLOT_MAPPING[tonumber(slot)]
    if part then
        -- If the part is found, use the current and original transmog tables
        local currentTransmogId = currentTransmogIds[part]
        local originalTransmogId = originalTransmogIds[part]
        
        if (id ~= 0 and id ~= nil and (currentTransmogId == nil or currentTransmogId == 0) and realItemId ~= id) then
            currentTransmogIds[part] = id
            originalTransmogIds[part] = id
		if (part ~= "MainHand" and part ~= "SecondaryHandSlot" and part ~= "Ranged") then
			TransmogModelFrame:TryOn(id)
		end
        elseif (currentTransmogId ~= nil and currentTransmogId ~= 0) then
			if (part ~= "MainHand" and part ~= "SecondaryHandSlot" and part ~= "Ranged") then
				TransmogModelFrame:TryOn(currentTransmogId)
			end
        elseif (id ~= 0 and realItemId ~= 0 and realItemId ~= nil) then
            currentTransmogIds[part] = realItemId
            originalTransmogIds[part] = realItemId
			if (part ~= "MainHand" and part ~= "SecondaryHandSlot" and part ~= "Ranged") then
				TransmogModelFrame:TryOn(realItemId)
			end
        end
    end

    -- Reset all slot textures
    UpdateAllSlotTextures()
end

function OnClickHeadTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
	SetTab()
end

function OnClickShoulderTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_3_ENTRYID
    SetTab()
end

function OnClickShirtTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_4_ENTRYID
    SetTab()
end

function OnClickChestTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_5_ENTRYID
    SetTab()
end

function OnClickWaistTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_6_ENTRYID
    SetTab()
end

function OnClickLegsTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_7_ENTRYID
    SetTab()
end

function OnClickFeetTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_8_ENTRYID
    SetTab()
end

function OnClickWristTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_9_ENTRYID
    SetTab()
end

function OnClickHandsTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_10_ENTRYID
    SetTab()
end

function OnClickBackTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_15_ENTRYID
    SetTab()
end

function OnClickMainTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_16_ENTRYID
    SetTab()
end

function OnClickOffTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_17_ENTRYID
    SetTab()
end

function OnClickRangedTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_18_ENTRYID
    SetTab()
end

function OnClickTabardTab(btn)
	currentSlot = PLAYER_VISIBLE_ITEM_19_ENTRYID
    SetTab()
end

local function OnEventEnterWorldReloadTransmogIds(self, event)
	if ( event == "PLAYER_ENTERING_WORLD") then
		AIO.Handle("Transmog", "SetTransmogItemIds")
	else
		AIO.Handle("Transmog", "OnUnequipItem")
		UpdateAllSlotTextures()
		if ( TransmogFrame:IsShown() ) then
			LoadTransmogsFromCurrentIds()
		end
	end
end

function TransmogItemSlotButton_OnEnter(self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local slotName = self:GetName():gsub("Transmog", ""):gsub("Character", ""):gsub("Slot", "")
	local transmogId = currentTransmogIds[slotName] or originalTransmogIds[slotName]
	if transmogId then
		GameTooltip:SetHyperlink("item:"..transmogId..":0:0:0:0:0:0:0")
		--GameTooltip_ClearMoney(GameTooltip)
		--GameTooltip_ClearStatusBars(GameTooltip)
		--GameTooltip:Show()
		CursorUpdate(self)
		return
	end
	GameTooltip:SetInventoryItem("player", self:GetID())
	CursorUpdate(self)
end

function TransmogItemSlotButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local slotName = self:GetName():gsub("Transmog", "")
	local id, textureName, checkRelic = GetInventorySlotInfo(strsub(slotName,10))
	self:SetID(id)
	local texture = _G["Transmog"..slotName.."IconTexture"]
	texture:SetTexture(textureName)
	self.backgroundTextureName = textureName
	self.checkRelic = checkRelic
	self.UpdateTooltip = TransmogItemSlotButton_OnEnter
	--itemSlotButtons[id] = self;
end

function OnTransmogFrameLoad(self)
	ItemSearchInput:SetText("|cff808080Click here and start typing...|r")
	ItemSearchInput:SetScript("OnEnterPressed", SetSearchTab)
	
	InitTabSlots()
	
	local leftFontString = LeftButton:GetFontString()
	leftFontString:SetShadowOffset(1, -1)
	leftFontString:SetPoint("CENTER", 0, 2)
	
	local rightFontString = RightButton:GetFontString()
	rightFontString:SetShadowOffset(1, -1)
	rightFontString:SetPoint("CENTER", 0, 2)
	
	characterTransmogTab = CreateFrame("CheckButton", "CharacterFrameTab6", CharacterFrame, "SpellBookSkillLineTabTemplate")
	characterTransmogTab:SetSize(32, 32);
	characterTransmogTab:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", 0, -48)
	characterTransmogTab:Show()
	innerCharacterTransmogTab = characterTransmogTab:CreateTexture("Item", "ARTWORK")
	innerCharacterTransmogTab:SetTexture("Interface\\AddOns\\transmog_by_dan\\assets\\Transmog-Icon")
	innerCharacterTransmogTab:SetAllPoints()
	innerCharacterTransmogTab:Show()
	characterTransmogTab:SetScript("OnEnter", TransmogTabTooltip)
	characterTransmogTab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	characterTransmogTab:SetScript("OnClick", function(self) if ( TransmogFrame:IsShown() ) then TransmogFrame:Hide() return; end TransmogFrame:Show() end)
	TransmogCloseButton:SetScript("OnClick", function(self) if ( TransmogFrame:IsShown() ) then TransmogFrame:Hide() return; end TransmogFrame:Show() end)

	PaperDollFrame:SetScript("OnShow", PaperDollFrame_OnShow)

	
	-- This enables saving of the position of the frame over reload of the UI or restarting game
	AIO.SavePosition(TransmogFrame)
	TransmogFrame:RegisterForDrag("LeftButton");

	_G["TransmogFrame"] = TransmogFrame
	tinsert(UISpecialFrames, TransmogFrame:GetName())
	TransmogFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	TransmogFrame:RegisterEvent("UNIT_MODEL_CHANGED")
	TransmogFrame:SetScript("OnEvent", OnEventEnterWorldReloadTransmogIds)

	SetItemButtonTexture(_G["SaveButton"], "Interface\\AddOns\\transmog_by_dan\\assets\\Transmog-Icon")

	UpdateAllSlotTextures()
end

function OnClickTransmogButton(self)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	for slot, _ in pairs(SLOT_IDS) do
		currentTransmogIds[slot] = originalTransmogIds[slot]
	end
	TransmogModelFrame:SetUnit("player")
	currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
	SetTab()
	characterTransmogTab:SetChecked(true)
	isInputHovered = false
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, 1)
	ItemSearchInput:SetText("|cff808080Click here and start typing...|r")
	LoadTransmogsFromCurrentIds()
end

function OnHideTransmogFrame(self)
	PlaySound("INTERFACESOUND_CHARWINDOWCLOSE", "master")
	for slot, _ in pairs(SLOT_IDS) do
		currentTransmogIds[slot] = originalTransmogIds[slot]
	end
	UpdateAllSlotTextures()
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
	
	-- custom code
	if ( TransmogFrame:IsShown() ) then
		characterTransmogTab:SetChecked(true)
		else
		characterTransmogTab:SetChecked(false)
	end

	LoadTransmogsFromCurrentIds()
	-- end custom code
end

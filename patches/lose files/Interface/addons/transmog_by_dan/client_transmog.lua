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

local EMPTY_TEXTURE = "Interface\\Icons\\INV_Mask_01"
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
local backdropInfo =
					{						
						bgFile = "Interface\\Transmog\\UI-PaperBackground", 
						edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
						tile = false, tileEdge = true, tileSize = 16, edgeSize = 16, 
						insets = { left = 4, right = 4, top = 4, bottom = 4 }
					};


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
			--AIO.Handle("Transmog", "SetEquipmentTransmogInfo", slotId, currentTooltipSlot) TODO This will only works with cached slots?? Inf loop when trying to call server and back
		end
		return;
	end
	tooltip:Show()
end)

function UpdateSlotTexture(slotName)
    local slotFrame = _G["Character" .. slotName .. "Slot"]
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
    end
end

function LoadTransmogsFromCurrentIds()
    CharacterModelFrameFake:SetUnit("player")
    CharacterModelFrame:SetUnit("player")
    CharacterModelFrame:Undress()
    
    for slotName, transmogId in pairs(currentTransmogIds) do
        if transmogId then
            CharacterModelFrame:TryOn(transmogId)
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
	CharacterModelFrame:TryOn(itemId)
    SetItemButtonTexture(_G["Character" .. slotName .. "Slot"], textureName)
end

function OnClickResetAllButton(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
    for slotName, _ in pairs(SLOT_IDS) do
        currentTransmogIds[slotName] = 0
    end
	CharacterModelFrame:SetUnit("player")
	CharacterModelFrame:Undress()
    UpdateAllSlotTextures()
end

function OnClickDeleteAllButton(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
    for slotName, _ in pairs(SLOT_IDS) do
        currentTransmogIds[slotName] = nil
    end
	CharacterModelFrame:SetUnit("player")
	CharacterModelFrame:Undress()
	OnClickApplyAllowTransmogs()
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

	for slotName, _ in pairs(SLOT_IDS) do
        UpdateSlotTexture(slotName)
    end
	
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
    local slotName = TRANSMOG_SLOT_MAPPING[currentSlot]
    currentTransmogIds[slotName] = 0
    UpdateSlotTexture(slotName)
    LoadTransmogsFromCurrentIds()
end

function OnClickDeleteCurrentTransmogSlot(btn)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
    local slotName = TRANSMOG_SLOT_MAPPING[currentSlot]
    currentTransmogIds[slotName] = nil
    originalTransmogIds[slotName] = nil
    AIO.Handle("Transmog", "EquipTransmogItem", nil, currentSlot)
    LoadTransmogsFromCurrentIds()
    UpdateSlotTexture(slotName)
end

function TransmogHandlers.LoadTransmogsAfterSave(player)
	LoadTransmogsFromCurrentIds()
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
		    SetItemButtonTexture(child.itemButton, EMPTY_EQUIPMENT_ICON_BACKGROUND_PATH..EQUIPMENT_ICON_TYPES[Transmog_CalculateSlotReverse(currentSlot)])
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
			CharacterModelFrame:TryOn(id)
		end
        elseif (currentTransmogId ~= nil and currentTransmogId ~= 0) then
			if (part ~= "MainHand" and part ~= "SecondaryHandSlot" and part ~= "Ranged") then
				CharacterModelFrame:TryOn(currentTransmogId)
			end
        elseif (id ~= 0 and realItemId ~= 0 and realItemId ~= nil) then
            currentTransmogIds[part] = realItemId
            originalTransmogIds[part] = realItemId
			if (part ~= "MainHand" and part ~= "SecondaryHandSlot" and part ~= "Ranged") then
				CharacterModelFrame:TryOn(realItemId)
			end
        end
    end

    -- Reset all slot textures
    UpdateAllSlotTextures()
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
		UpdateAllSlotTextures()
		if ( TransmogFrame:IsShown() ) then
			LoadTransmogsFromCurrentIds()
		end
	end
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

	UpdateAllSlotTextures()
end

function OnClickTransmogButton(self)
	PlaySound("GAMEGENERICBUTTONPRESS", "master")
	for slot, _ in pairs(SLOT_IDS) do
		currentTransmogIds[slot] = originalTransmogIds[slot]
	end
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
	for slot, _ in pairs(SLOT_IDS) do
		currentTransmogIds[slot] = originalTransmogIds[slot]
	end
	UpdateAllSlotTextures()
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
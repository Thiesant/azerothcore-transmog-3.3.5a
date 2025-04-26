-- Created by DanielTheDeveloper
-- Contribution of Marotheit
-- Alternate version by Thiesant
-- V2.4.1a 

local AIO = AIO or require("AIO")
if AIO.AddAddon() then
	return
end

local TransmogHandlers = AIO.AddHandlers("Transmog", {})

local function OnEvent(self, event)
	AIO.Handle("Transmog", "LoadPlayer")
end

-- language support
-- fallback = enUS
local CLIENT_FALLBACK_LANG = 0
local LANG_ID_TABLE = {
	["enUS"] = 0,
	["frFR"] = 2,
	["deDE"] = 3,
	["esES"] = 6,
	["ruRU"] = 8,
}

local function HandleLocale()
	local langId = LANG_ID_TABLE[GetLocale()]
	if not langId then
		langId = CLIENT_FALLBACK_LANG
	end
	
	return langId
end

if not C_Timer then
	C_Timer = {}
	function C_Timer.After(seconds, func)
		local frame = CreateFrame("Frame")
		frame:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = (self.elapsed or 0) + elapsed
			if self.elapsed >= seconds then
				func()
				self:SetScript("OnUpdate", nil)
			end
		end)
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)

local CALC = 281

PLAYER_VISIBLE_ITEM_1_ENTRYID   = 283
PLAYER_VISIBLE_ITEM_3_ENTRYID   = 287
PLAYER_VISIBLE_ITEM_4_ENTRYID   = 289
PLAYER_VISIBLE_ITEM_5_ENTRYID   = 291
PLAYER_VISIBLE_ITEM_6_ENTRYID   = 293
PLAYER_VISIBLE_ITEM_7_ENTRYID   = 295
PLAYER_VISIBLE_ITEM_8_ENTRYID   = 297
PLAYER_VISIBLE_ITEM_9_ENTRYID   = 299
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

local EMPTY_TEXTURE = "Interface\\AddOns\\Transmogrify\\Assets\\Transmog-Icon-Inactive"
local EMPTY_EQUIPMENT_ICON_BACKGROUND_PATH = "Interface\\paperdoll\\UI-PaperDoll-Slot-"
local EQUIPMENT_ICON_TYPES = {"Head", "", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrists", "Hands", "", "", "", "", "Chest", "MainHand", "SecondaryHand", "Ranged", "Tabard"}
-- List of character item frames that will be used
local EQUIPMENT_SLOT_FRAME_NAMES = {"CharacterHeadSlot", "CharacterShoulderSlot", "CharacterBackSlot", "CharacterChestSlot", "CharacterShirtSlot", "CharacterTabardSlot", "CharacterWristSlot", "CharacterHandsSlot", "CharacterWaistSlot", "CharacterLegsSlot", "CharacterFeetSlot", "CharacterMainHandSlot", "CharacterSecondaryHandSlot", "CharacterRangedSlot"}
EQUIPMENT_SLOT_FRAME_NAMES = TableSetHelper(EQUIPMENT_SLOT_FRAME_NAMES)

TRANSMOG_SLOT_MAPPING = {
	[PLAYER_VISIBLE_ITEM_1_ENTRYID]  = "Head",
	[PLAYER_VISIBLE_ITEM_3_ENTRYID]  = "Shoulder",
	[PLAYER_VISIBLE_ITEM_4_ENTRYID]  = "Shirt",
	[PLAYER_VISIBLE_ITEM_5_ENTRYID]  = "Chest",
	[PLAYER_VISIBLE_ITEM_6_ENTRYID]  = "Waist",
	[PLAYER_VISIBLE_ITEM_7_ENTRYID]  = "Legs",
	[PLAYER_VISIBLE_ITEM_8_ENTRYID]  = "Feet",
	[PLAYER_VISIBLE_ITEM_9_ENTRYID]  = "Wrist",
	[PLAYER_VISIBLE_ITEM_10_ENTRYID] = "Hands",
	[PLAYER_VISIBLE_ITEM_15_ENTRYID] = "Back",
	[PLAYER_VISIBLE_ITEM_16_ENTRYID] = "MainHand",
	[PLAYER_VISIBLE_ITEM_17_ENTRYID] = "SecondaryHand",
	[PLAYER_VISIBLE_ITEM_18_ENTRYID] = "Ranged",
	[PLAYER_VISIBLE_ITEM_19_ENTRYID] = "Tabard"
}

-- Cached globals for performance
local	GetItemIcon, SetItemButtonTexture, PlaySound, CreateFrame, GameTooltip = GetItemIcon, SetItemButtonTexture, PlaySound, CreateFrame, GameTooltip

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
	-- TransmogModelFrame:Undress()

	local showHelm = GetCVar("showHelm") == "1"
	local showCloak = GetCVar("showCloak") == "1"

	for slotName, transmogId in pairs(currentTransmogIds) do
		local skip = false

		-- Skip slots where we don't want to preview if hidden and no transmog
		if slotName == "Head" and not showHelm and (transmogId == nil or transmogId == 0) then
			skip = true
		elseif slotName == "Back" and not showCloak and (transmogId == nil or transmogId == 0) then
			skip = true
		elseif (slotName == "MainHand" or slotName == "SecondaryHand" or slotName == "Ranged") and (transmogId == nil or transmogId == 0) then
			skip = true
		end

		if transmogId and transmogId ~= 0 and not skip then
			TransmogModelFrame:TryOn(transmogId)
		end
	end
	
	UpdateAllSlotTextures()
end
local function OnClickItemTransmogButton(btn, buttonType)
	PlaySound("igMainMenuOptionCheckBoxOn", "sfx")
	LoadTransmogsFromCurrentIds()
	local itemId = btn:GetID()
	local textureName = GetItemIcon(itemId)
	local slotName = TRANSMOG_SLOT_MAPPING[currentSlot]
	currentTransmogIds[slotName] = itemId
	TransmogModelFrame:TryOn(itemId)
	UpdateAllSlotTextures()
	--SetItemButtonTexture(_G["Character" .. slotName .. "Slot"], textureName)
end

function OnClickHideAllButton(btn)
	PlaySound("Glyph_MinorDestroy", "sfx")

	TransmogModelFrame:SetUnit("player")
	TransmogModelFrame:Undress()

	for slotName, slotId in pairs(SLOT_IDS) do
		currentTransmogIds[slotName] = 0
		originalTransmogIds[slotName] = 0
		AIO.Handle("Transmog", "EquipTransmogItem", 0, slotId)
	end

	UpdateAllSlotTextures()
end

function OnClickRestoreAllButton(btn)
	PlaySound("Glyph_MajorCreate", "sfx")

	for slotName, slotId in pairs(SLOT_IDS) do
		currentTransmogIds[slotName] = nil
		originalTransmogIds[slotName] = nil
		AIO.Handle("Transmog", "EquipTransmogItem", nil, slotId)
	end

	-- Ask server to re-send the updated item IDs (real/transmog)
	AIO.Handle("Transmog", "SetTransmogItemIds")
end

function OnLeaveHideToolTip(btn)
	GameTooltip:Hide()
end

local PREVIEW_ITEM_TOOLTIP_TEXTS = {
	[0] = "Click to preview this item.",                             -- enUS
	[2] = "Cliquez pour prévisualiser cet objet.",                   -- frFR
	[3] = "Klicken, um dieses Objekt anzusehen.",                    -- deDE
	[6] = "Haz clic para previsualizar este objeto.",                -- esES
	[8] = "Нажмите, чтобы предварительно просмотреть этот предмет.", -- ruRU
}

function OnEnterItemToolTip(btn)
	local localeID = HandleLocale()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("item:"..btn:GetID()..":0:0:0:0:0:0:0")
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(PREVIEW_ITEM_TOOLTIP_TEXTS[localeID] or PREVIEW_ITEM_TOOLTIP_TEXTS[0], 0, 1, 0)  -- Click to preview text
	GameTooltip:Show()
end

local TRANSMOGRIFY_TOOLTIP_TEXTS = {
	[0] = "Transmogrify",       -- enUS
	[2] = "Transmogrifier",     -- frFR
	[3] = "Transmogrifizieren", -- deDE
	[6] = "Transfigurar",       -- esES
	[8] = "Трансмогрификация",  -- ruRU
}

local TRANSMOGRIFY_TOOLTIP_DESC = {
	[0] = "Click to transmogrify the selected item.",                      -- enUS
	[2] = "Cliquez pour transmogrifier l'objet sélectionné.",              -- frFR
	[3] = "Klicke, um den ausgewählten Gegenstand zu transmogrifizieren.", -- deDE
	[6] = "Haz clic para transmogrificar el objeto seleccionado.",         -- esES
	[8] = "Нажмите, чтобы трансмогрифицировать выбранный предмет.",        -- ruRU
}

function TransmogrifyToolTip(btn)
	local localeID = HandleLocale()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine(TRANSMOGRIFY_TOOLTIP_TEXTS[localeID] or TRANSMOGRIFY_TOOLTIP_TEXTS[0], 1, 1, 1)
	GameTooltip:AddLine(TRANSMOGRIFY_TOOLTIP_DESC[localeID] or TRANSMOGRIFY_TOOLTIP_DESC[0], 1, 0.8, 0)
	GameTooltip:Show()
end

local RESTORE_ITEM_TOOLTIP_TEXTS = {
	[0] = "Restore Item Appearance",                -- enUS
	[2] = "Restaurer l'apparence de l'objet",       -- frFR
	[3] = "Gegenstandsappearance wiederherstellen", -- deDE
	[6] = "Restaurar apariencia del objeto",        -- esES
	[8] = "Восстановить внешний вид предмета",      -- ruRU
}

local RESTORE_ITEM_TOOLTIP_DESC = {
	[0] = "Click to restore this item's appearance.",                       -- enUS
	[2] = "Cliquez pour restaurer l'apparence de cet objet.",               -- frFR
	[3] = "Klicke, um das Aussehen dieses Gegenstands wiederherzustellen.", -- deDE
	[6] = "Haz clic para restaurar la apariencia de este objeto.",          -- esES
	[8] = "Нажмите, чтобы восстановить внешний вид этого предмета.",        -- ruRU
}

function RestoreItemToolTip(btn)
	local localeID = HandleLocale()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine(RESTORE_ITEM_TOOLTIP_TEXTS[localeID] or RESTORE_ITEM_TOOLTIP_TEXTS[0], 1, 1, 1)
	GameTooltip:AddLine(RESTORE_ITEM_TOOLTIP_DESC[localeID] or RESTORE_ITEM_TOOLTIP_DESC[0], 1, 0.8, 0)
	GameTooltip:Show()
end


local HIDE_ITEM_TOOLTIP_TEXTS = {
	[0] = "Hide Item",            -- enUS
	[2] = "Cacher l'objet",       -- frFR
	[3] = "Gegenstand verbergen", -- deDE
	[6] = "Ocultar objeto",       -- esES
	[8] = "Скрыть предмет",       -- ruRU
}

local HIDE_ITEM_TOOLTIP_DESC = {
	[0] = "Click to hide this item.",                     -- enUS
	[2] = "Cliquez pour cacher cet objet.",               -- frFR
	[3] = "Klicken, um diesen Gegenstand zu verstecken.", -- deDE
	[6] = "Haz clic para ocultar este objeto.",           -- esES
	[8] = "Нажмите, чтобы скрыть этот предмет.",          -- ruRU
}

function HideItemToolTip(btn)
	local localeID = HandleLocale()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine(HIDE_ITEM_TOOLTIP_TEXTS[localeID] or HIDE_ITEM_TOOLTIP_TEXTS[0], 1, 1, 1)
	GameTooltip:AddLine(HIDE_ITEM_TOOLTIP_DESC[localeID] or HIDE_ITEM_TOOLTIP_DESC[0], 1, 0.8, 0)
	GameTooltip:Show()
end

local RESTORE_ALL_ITEMS_TOOLTIP_TEXTS = {
	[0] = "Restore All Items",                 -- enUS
	[2] = "Restaurer tous les objets",         -- frFR
	[3] = "Alle Gegenstände wiederherstellen", -- deDE
	[6] = "Restaurar todos los objetos",       -- esES
	[8] = "Восстановить все предметы",         -- ruRU
}

local RESTORE_ALL_ITEMS_TOOLTIP_DESC = {
	[0] = "Click to restore all hidden items to their original state.",                           -- enUS
	[2] = "Cliquez pour restaurer tous les objets cachés à leur état d'origine.",                 -- frFR
	[3] = "Klicke, um alle versteckten Gegenstände in ihren Originalzustand wiederherzustellen.", -- deDE
	[6] = "Haz clic para restaurar todos los objetos ocultos a su estado original.",              -- esES
	[8] = "Нажмите, чтобы восстановить все скрытые предметы в их исходное состояние.",            -- ruRU
}

function RestoreAllItemsToolTip(btn)
	local localeID = HandleLocale()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine(RESTORE_ALL_ITEMS_TOOLTIP_TEXTS[localeID] or RESTORE_ALL_ITEMS_TOOLTIP_TEXTS[0], 1, 1, 1)
	GameTooltip:AddLine(RESTORE_ALL_ITEMS_TOOLTIP_DESC[localeID] or RESTORE_ALL_ITEMS_TOOLTIP_DESC[0], 1, 0.8, 0)
	GameTooltip:Show()
end


local HIDE_ALL_ITEMS_TOOLTIP_TEXTS = {
	[0] = "Hide All Items",             -- enUS
	[2] = "Cacher tous les objets",     -- frFR
	[3] = "Alle Gegenstände verbergen", -- deDE
	[6] = "Ocultar todos los objetos",  -- esES
	[8] = "Скрыть все предметы",        -- ruRU
}

local HIDE_ALL_ITEMS_TOOLTIP_DESC = {
	[0] = "Click to hide all equipped items.",                       -- enUS
	[2] = "Cliquez pour cacher tous les objets équipés.",            -- frFR
	[3] = "Klicke, um alle ausgerüsteten Gegenstände zu verbergen.", -- deDE
	[6] = "Haz clic para ocultar todos los objetos equipados.",      -- esES
	[8] = "Нажмите, чтобы скрыть все экипированные предметы.",       -- ruRU
}

function HideAllItemsToolTip(btn)
	local localeID = HandleLocale()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine(HIDE_ALL_ITEMS_TOOLTIP_TEXTS[localeID] or HIDE_ALL_ITEMS_TOOLTIP_TEXTS[0], 1, 1, 1)
	GameTooltip:AddLine(HIDE_ALL_ITEMS_TOOLTIP_DESC[localeID] or HIDE_ALL_ITEMS_TOOLTIP_DESC[0], 1, 0.8, 0)
	GameTooltip:Show()
end


local SHOW_CLOAK_TOOLTIP_L0 = {
	[0] = "Toggle Cloak Display",                                 -- enUS
	[2] = "Basculer l'affichage de la cape",                      -- frFR
	[3] = "Umhang ein-/ausblenden",                               -- deDE
	[6] = "Alternar capa",                                        -- esES
	[8] = "Переключить отображение плаща",                        -- ruRU
}

local SHOW_CLOAK_TOOLTIP_L1 = {
	[0] = " ",                                                    -- enUS
	[2] = " ",                                                    -- frFR
	[3] = " ",                                                    -- deDE
	[6] = " ",                                                    -- esES
	[8] = " ",                                                    -- ruRU
}

local SHOW_CLOAK_TOOLTIP_L2 = {
	[0] = "Same as the \"Show Cloak\" Cvar in the",               -- enUS
	[2] = "Même fonction que la case \"Afficher la cape\"",       -- frFR
	[3] = "Gleiche Funktion wie das Kontrollkästchen",            -- deDE
	[6] = "Misma función que la casilla \"Mostrar",               -- esES
	[8] = "Та же функция, что и флажок \"Показать",               -- ruRU
}

local SHOW_CLOAK_TOOLTIP_L3 = {
	[0] = "interface options. No effect on the",                  -- enUS
	[2] = "dans les options de l'interface. Aucun effet",         -- frFR
	[3] = "Umhang\" in den Interface-Optionen. Keine Auswirkung", -- deDE
	[6] = "capa\" en las opciones de la interfaz. No afectará",   -- esES
	[8] = "плащ\" в настройках интерфейса. Это не влияет",        -- ruRU
}

local SHOW_CLOAK_TOOLTIP_L4 = {
	[0] = "transmogrify preview.",                                -- enUS
	[2] = "sur la prévisu de transmogrification.",                -- frFR
	[3] = "auf die Transmogrifikationsvorschau.",                 -- deDE
	[6] = "la vista previa de transfiguración.",                  -- esES
	[8] = "на окно трансмогрификации.",                           -- ruRU
}



function ShowCloakToolTip(btn)
	local localeID = HandleLocale()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine(SHOW_CLOAK_TOOLTIP_L0[localeID] or SHOW_CLOAK_TOOLTIP_L0[0], 1, 1, 1)
	GameTooltip:AddLine(SHOW_CLOAK_TOOLTIP_L1[localeID] or SHOW_CLOAK_TOOLTIP_L1[0], 1, 0.8, 0)
	GameTooltip:AddLine(SHOW_CLOAK_TOOLTIP_L2[localeID] or SHOW_CLOAK_TOOLTIP_L2[0], 1, 0.8, 0)
	GameTooltip:AddLine(SHOW_CLOAK_TOOLTIP_L3[localeID] or SHOW_CLOAK_TOOLTIP_L3[0], 1, 0.8, 0)
	GameTooltip:AddLine(SHOW_CLOAK_TOOLTIP_L4[localeID] or SHOW_CLOAK_TOOLTIP_L4[0], 1, 0.8, 0)
	GameTooltip:Show()
end

local SHOW_HELM_TOOLTIP_L0 = {
	[0] = "Toggle Character Helm Display",                       -- enUS
	[2] = "Basculer l'affichage du casque",                      -- frFR
	[3] = "Schalter für die Charakterhelmanzeige",               -- deDE
	[6] = "Alternar la visualización del casco",                 -- esES
	[8] = "Переключить отображение шлема",                       -- ruRU
}

local SHOW_HELM_TOOLTIP_L1 = {
	[0] = " ",                                                   -- enUS
	[2] = " ",                                                   -- frFR
	[3] = " ",                                                   -- deDE
	[6] = " ",                                                   -- esES
	[8] = " ",                                                   -- ruRU
}

local SHOW_HELM_TOOLTIP_L2 = {
	[0] = "Same as the \"Show Helm\" Cvar in the",               -- enUS
	[2] = "Même fonction que la case \"Afficher le casque\"",    -- frFR
	[3] = "Gleiche Funktion wie das Kontrollkästchen",           -- deDE
	[6] = "Misma función que la casilla \"Mostrar",              -- esES
	[8] = "Та же функция, что и флажок \"Показать",              -- ruRU
}

local SHOW_HELM_TOOLTIP_L3 = {
	[0] = "interface options. No effect on the",                 -- enUS
	[2] = "dans les options de l'interface. Aucun effet",        -- frFR
	[3] = "Helm\" in den Interface-Optionen. Keine Auswirkung",  -- deDE
	[6] = "casco\" en las opciones de la interfaz. No afectará", -- esES
	[8] = "шлем\" в настройках интерфейса. Это не влияет",       -- ruRU
}

local SHOW_HELM_TOOLTIP_L4 = {
	[0] = "transmogrify preview.",                               -- enUS
	[2] = "sur la prévisu de transmogrification.",               -- frFR
	[3] = "auf die Transmogrifikationsvorschau.",                -- deDE
	[6] = "la vista previa de transfiguración.",                 -- esES
	[8] = "на окно трансмогрификации.",                          -- ruRU
}

function ShowHelmToolTip(btn)
	local localeID = HandleLocale()
	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine(SHOW_HELM_TOOLTIP_L0[localeID] or SHOW_HELM_TOOLTIP_L0[0], 1, 1, 1)
	GameTooltip:AddLine(SHOW_HELM_TOOLTIP_L1[localeID] or SHOW_HELM_TOOLTIP_L1[0], 1, 0.8, 0)
	GameTooltip:AddLine(SHOW_HELM_TOOLTIP_L2[localeID] or SHOW_HELM_TOOLTIP_L2[0], 1, 0.8, 0)
	GameTooltip:AddLine(SHOW_HELM_TOOLTIP_L3[localeID] or SHOW_HELM_TOOLTIP_L3[0], 1, 0.8, 0)
	GameTooltip:AddLine(SHOW_HELM_TOOLTIP_L4[localeID] or SHOW_HELM_TOOLTIP_L4[0], 1, 0.8, 0)
	GameTooltip:Show()
end

function InitTabSlots()
	local lastSlot
	local firstInRowSlot
	local rowOffset = 150  -- Horizontal spacing between grids
	local verticalOffset = -260  -- Initial vertical position
	local startX, startY = 485, verticalOffset  -- Starting position for the first grid

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
	PlaySound("igAbiliityPageTurn", "sfx")
	currentPage = currentPage + 1
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
end

function OnClickPrevPage(btn)
	PlaySound("igAbiliityPageTurn", "sfx")
	if ( currentPage == 1 ) then
		return;
	end
	currentPage = currentPage - 1
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, currentPage)
end

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

function OnClickHideCurrentTransmogSlot(btn)
	PlaySound("ArcaneMissileImpacts", "sfx")
	local parent = btn:GetParent()
	if not parent then return end

	local slotName = parent:GetName():gsub("TransmogCharacter", ""):gsub("Slot", "")
	local slotId = SLOT_IDS[slotName]
	if not slotId then return end

	currentTransmogIds[slotName] = 0
	UpdateSlotTexture(slotName, false)
	UpdateSlotTexture(slotName, true)
	AIO.Handle("Transmog", "EquipTransmogItem", 0, slotId)
	originalTransmogIds[slotName] = 0
	LoadTransmogsFromCurrentIds()
end

function OnClickRestoreCurrentTransmogSlot(btn)
	PlaySound("Glyph_MinorCreate", "sfx")
	local parent = btn:GetParent()
	if not parent then return end

	local slotName = parent:GetName():gsub("TransmogCharacter", ""):gsub("Slot", "")
	local slotId = SLOT_IDS[slotName]
	if not slotId then return end

	currentTransmogIds[slotName] = nil
	originalTransmogIds[slotName] = nil
	AIO.Handle("Transmog", "EquipTransmogItem", nil, slotId)
	LoadTransmogsFromCurrentIds()
end

function TransmogHandlers.LoadTransmogsAfterSave(player)
	LoadTransmogsFromCurrentIds()
end

local RECOVER_TOOLTIP_TEXT = {
	[0] = "Recover transmogs from quests with multiple-choice rewards.",                    -- enUS
	[2] = "Récupérer les transmogrifications des quêtes à récompenses à choix multiple.",   -- frFR
	[3] = "Transmogs aus Quests mit mehreren Belohnungsoptionen wiederherstellen.",         -- deDE
	[6] = "Recuperar transfiguraciones de misiones con recompensas de elección múltiple.",  -- esES
	[8] = "Восстановить трансмоги из заданий с выбором награды."                            -- ruRU
}
local RECOVER_TOOLTIP_DESCRIPTION = {
	[0] = "Click to recover quest appearance rewards.",       -- enUS
	[2] = "Cliquez pour récupérer les apparences de quêtes.", -- frFR
	[3] = "Klicke, um Quest-Transmogs wiederherzustellen.",   -- deDE
	[6] = "Haz clic para recuperar apariencias de misiones.", -- esES
	[8] = "Нажмите, чтобы восстановить трансмоги из заданий." -- ruRU
}
local localeID = HandleLocale()
RecoverTransmogTooltipTitle = RECOVER_TOOLTIP_TEXT[localeID] or RECOVER_TOOLTIP_TEXT[0]
RecoverTransmogTooltipDesc  = RECOVER_TOOLTIP_DESCRIPTION[localeID]  or RECOVER_TOOLTIP_DESCRIPTION[0]

function TransmogHandlers.GetLocale(player, item, count)
	local langId = HandleLocale()
	AIO.Handle("Transmog", "LootItemLocale", item, count, HandleLocale())
end

function OnClickApplyAllowTransmogs(btn)
	PlaySound("Distract Impact", "sfx")
	for slotName, entryId in pairs(SLOT_IDS) do
		local transmogId = currentTransmogIds[slotName]
		AIO.Handle("Transmog", "EquipTransmogItem", transmogId, entryId)
		originalTransmogIds[slotName] = transmogId
	end
	LoadTransmogsFromCurrentIds()
end

local TRANSMOG_LABELS = {
	[0] = "Transmogrify",		-- enUS
	[2] = "Transmogrifier",		-- frFR
	[3] = "Transmogrifizieren",	-- deDE
	[6] = "Transmogrificar",	-- esES
	[8] = "Трансмогрификация",	-- ruRU
}

local function TransmogTabTooltip(btn)
	local localeID = HandleLocale()
	local label = TRANSMOG_LABELS[localeID] or TRANSMOG_LABELS[0]

	GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
	GameTooltip:AddLine(label, 1, 1, 1)
	GameTooltip:Show()
end

local PAGE_TEXTS = {
	[0] = "Page %d",         -- enUS
	[2] = "Page %d",         -- frFR
	[3] = "Seite %d",        -- deDE
	[6] = "Página %d",       -- esES
	[8] = "Страница %d",     -- ruRU
}

function TransmogHandlers.InitTab(player, newSlotItemIds, page, hasMorePages)
	local localeID = HandleLocale()
	currentSlotItemIds = newSlotItemIds
	TransmogPaginationText:SetText(string.format(PAGE_TEXTS[localeID] or PAGE_TEXTS[0], page))

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
			child.itemModel:SetPoint("CENTER", 0, -15)
			
			-- TODO Camera? currently not usable because of lacking ultrawide support
			--if currentSlot == PLAYER_VISIBLE_ITEM_1_ENTRYID then
				--child.itemModel:SetPoint("CENTER", 0, 0)
				--child.itemModel:SetCamera(0)
			--else
				--child.itemModel:SetPoint("CENTER", 0, -15)
				--child.itemModel:SetCamera(1)
				--child.itemModel:SetViewTranslation(0.2, 0.2)
				--child.itemModel:Show()
			--end
		end
	end
end

local SEARCH_PLACEHOLDER_TEXTS = {
	[0] = "Filter Item Appearance", -- enUS
	[2] = "Filtrer une apparence",  -- frFR
	[3] = "Aussehen filtern",       -- deDE
	[6] = "Filtrar apariencia",     -- esES
	[8] = "Фильтр внешности"        -- ruRU
}

function SetSearchTab()
	PlaySound("igSpellBookSpellIconPickup", "sfx")
	currentPage = 1
	TransmogPaginationText:SetText("Page 1")
	AIO.Handle("Transmog", "SetSearchCurrentSlotItemIds", currentSlot, currentPage, ItemSearchInput:GetText())
	ItemSearchInput:ClearFocus()
end

function SetTab()
	local localeID = HandleLocale()
	local placeholder = SEARCH_PLACEHOLDER_TEXTS[localeID] or SEARCH_PLACEHOLDER_TEXTS[0]
	local formattedPlaceholder = "|cff808080" .. placeholder .. "|r"

	if ( ItemSearchInput:GetText() ~= "" and ItemSearchInput:GetText() ~= formattedPlaceholder ) then
		SetSearchTab()
		return;
	end
	PlaySound("igSpellBookSpellIconPickup", "sfx")
	currentPage = 1
	TransmogPaginationText:SetText("Page 1")
	for slot, value in pairs(SLOT_IDS) do
		_G["TransmogCharacter"..slot.."Slot"].toastTexture:SetTexture("Interface\\AddOns\\Transmogrify\\Assets\\Transmog-Overlay-Toast")
		_G["TransmogCharacter"..slot.."Slot"].restoreButton:Hide()
		_G["TransmogCharacter"..slot.."Slot"].hideButton:Hide()
	end
	_G["TransmogCharacter"..TRANSMOG_SLOT_MAPPING[currentSlot].."Slot"].toastTexture:SetTexture("Interface\\AddOns\\Transmogrify\\Assets\\Transmog-Overlay-Selected")
	_G["TransmogCharacter"..TRANSMOG_SLOT_MAPPING[currentSlot].."Slot"].restoreButton:Show()
	_G["TransmogCharacter"..TRANSMOG_SLOT_MAPPING[currentSlot].."Slot"].hideButton:Show()
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

	-- Restore all slot textures
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

function InitializeCloakHelmCheckboxes()
	ShowCloakCheckBox:SetChecked(ShowingCloak())
	ShowCloakCheckBox:SetScript("OnClick", function(self)
		local value = self:GetChecked() and "1" or "0"
		if value == "1" then
			PlaySound("igMainMenuOptionCheckBoxOn", "sfx")
		else
			PlaySound("igMainMenuOptionCheckBoxOff", "sfx")
		end
		ShowCloak(value == "1")
	end)
	
	ShowHelmCheckBox:SetChecked(ShowingHelm())
	ShowHelmCheckBox:SetScript("OnClick", function(self)
		local value = self:GetChecked() and "1" or "0"
		if value == "1" then
			PlaySound("igMainMenuOptionCheckBoxOn", "sfx")
		else
			PlaySound("igMainMenuOptionCheckBoxOff", "sfx")
		end
		ShowHelm(value == "1")
	end)
	
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	frame:SetScript("OnEvent", function(self, event, unit)
		if unit == "player" then
			ShowCloakCheckBox:SetChecked(ShowingCloak())
			ShowHelmCheckBox:SetChecked(ShowingHelm())
		end
	end)
end

function TransmogModelMouseRotation(modelFrame)
	local rotationArea = CreateFrame("Frame", modelFrame:GetName().."RotationArea", modelFrame)
	rotationArea:SetSize(160, 280)
	rotationArea:SetPoint("CENTER", 0, 0)
	
	-- Highlight the rotation area for development
	-- local texture = rotationArea:CreateTexture(nil, "OVERLAY")
	-- texture:SetAllPoints()
	-- texture:SetTexture(1, 0, 0, 0.3)
	
	rotationArea:EnableMouse(true)
	modelFrame.isMouseRotating = false
	modelFrame.lastCursorX = 0
	
	rotationArea:SetScript("OnMouseDown", function(frame, button)
		if button == "LeftButton" then
			modelFrame.isMouseRotating = true
			modelFrame.lastCursorX = GetCursorPosition()
			if not _G["TransmogMouseCapture"] then
				local captureFrame = CreateFrame("Frame", "TransmogMouseCapture", UIParent)
				captureFrame:SetFrameStrata("TOOLTIP")
				captureFrame:SetAllPoints(UIParent)
				captureFrame:EnableMouse(true)
				captureFrame:Hide()
				captureFrame:SetScript("OnMouseUp", function(captureFrame, button)
					if button == "LeftButton" and modelFrame.isMouseRotating then
						modelFrame.isMouseRotating = false
						modelFrame:SetScript("OnUpdate", nil)
						captureFrame:Hide()
					end
				end)
			end
			
			TransmogMouseCapture:Show()
			
			modelFrame:SetScript("OnUpdate", function()
				if modelFrame.isMouseRotating then
					local currentX = GetCursorPosition()
					-- Controls mouse rotation speed
					local diff = (currentX - modelFrame.lastCursorX) * 0.02
					modelFrame:SetFacing(modelFrame:GetFacing() + diff)
					modelFrame.lastCursorX = currentX
				end
			end)
		end
	end)
	
	rotationArea:SetScript("OnMouseUp", function(frame, button)
		if button == "LeftButton" and modelFrame.isMouseRotating then
			modelFrame.isMouseRotating = false
			modelFrame:SetScript("OnUpdate", nil)
			if _G["TransmogMouseCapture"] then
				TransmogMouseCapture:Hide()
			end
		end
	end)
	
	modelFrame:HookScript("OnHide", function(frame)
		if modelFrame.isMouseRotating then
			modelFrame.isMouseRotating = false
			modelFrame:SetScript("OnUpdate", nil)
			if _G["TransmogMouseCapture"] then
				TransmogMouseCapture:Hide()
			end
		end
	end)
	
	rotationArea:SetScript("OnLeave", function(frame)
		GameTooltip:Hide()
	end)
	
	modelFrame.rotationArea = rotationArea
end

function OnTransmogFrameLoad(self)
	local localeID = HandleLocale()
	
	local TITLE_TEXTS = {
		[0] = "Transmogrify",           -- enUS
		[2] = "Transmogrifier",         -- frFR
		[3] = "Transmogrifizieren",     -- deDE
		[6] = "Transfigurar",           -- esES
		[8] = "Трансмогрификация"       -- ruRU
	}
	
	if TransmogFrame.TitleText then
	TransmogFrame.TitleText:SetText(TITLE_TEXTS[localeID] or TITLE_TEXTS[0])
	end
	
	local SUBTITLE_TEXTS = {
		[0] = "Item Appearances",       -- enUS
		[2] = "Apparences d'objets",    -- frFR
		[3] = "Gegenstands-Transmogs",  -- deDE
		[6] = "Apariencias de objetos", -- esES
		[8] = "Внешности предметов"     -- ruRU
	}
	
	if TransmogFrame.SubtitleText then
		TransmogFrame.SubtitleText:SetText(SUBTITLE_TEXTS[localeID] or SUBTITLE_TEXTS[0])
	end
	
	local SHOW_CLOAK_TEXTS = {
		[0] = "Show Cloak",        -- enUS
		[2] = "Montrer cape",      -- frFR
		[3] = "Cloak anzeigen",    -- deDE
		[6] = "Mostrar capa",      -- esES
		[8] = "Показать плащ",     -- ruRU
	}
	
	if ShowCloakText then
		ShowCloakText:SetText(SHOW_CLOAK_TEXTS[localeID] or SHOW_CLOAK_TEXTS[0])
	end
	
	local SHOW_HELM_TEXTS = {
		[0] = "Show Helm",        -- enUS
		[2] = "Montrer casque",   -- frFR
		[3] = "Helm anzeigen",    -- deDE
		[6] = "Mostrar casco",    -- esES
		[8] = "Показать шлем",    -- ruRU
	}
	
	if ShowHelmText then
	ShowHelmText:SetText(SHOW_HELM_TEXTS[localeID] or SHOW_HELM_TEXTS[0])
	end
	
	if ItemSearchInput then
		local localeID = HandleLocale()
		local placeholder = SEARCH_PLACEHOLDER_TEXTS[localeID] or SEARCH_PLACEHOLDER_TEXTS[0]
		local formattedPlaceholder = "|cff808080" .. placeholder .. "|r"
		ItemSearchInput:SetText(formattedPlaceholder)
	end
	ItemSearchInput:SetScript("OnEnterPressed", SetSearchTab)
	
	InitTabSlots()
	
	characterTransmogTab = CreateFrame("CheckButton", "CharacterFrameTab6", CharacterFrame, "SpellBookSkillLineTabTemplate")
	characterTransmogTab:SetSize(32, 32);
	characterTransmogTab:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", 0, -48)
	characterTransmogTab:Show()
	innerCharacterTransmogTab = characterTransmogTab:CreateTexture("Item", "ARTWORK")
	innerCharacterTransmogTab:SetTexture("Interface\\AddOns\\Transmogrify\\Assets\\Transmog-Icon")
	innerCharacterTransmogTab:SetAllPoints()
	innerCharacterTransmogTab:Show()
	characterTransmogTab:SetScript("OnEnter", TransmogTabTooltip)
	characterTransmogTab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	characterTransmogTab:SetScript("OnClick", function(self) if ( TransmogFrame:IsShown() ) then TransmogFrame:Hide() return; end TransmogFrame:Show() end)
	TransmogCloseButton:SetScript("OnClick", function(self) if ( TransmogFrame:IsShown() ) then TransmogFrame:Hide() return; end TransmogFrame:Show() end)

	PaperDollFrame:SetScript("OnShow", PaperDollFrame_OnShow)
	InitializeCloakHelmCheckboxes()
	
	-- This enables saving of the position of the frame over reload of the UI or restarting game
	AIO.SavePosition(TransmogFrame)
	TransmogFrame:RegisterForDrag("LeftButton");

	_G["TransmogFrame"] = TransmogFrame
	tinsert(UISpecialFrames, TransmogFrame:GetName())
	TransmogFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	TransmogFrame:RegisterEvent("UNIT_MODEL_CHANGED")
	TransmogFrame:SetScript("OnEvent", OnEventEnterWorldReloadTransmogIds)

	SetItemButtonTexture(_G["SaveButton"], "Interface\\AddOns\\Transmogrify\\Assets\\Transmog-Icon")

	TransmogModelMouseRotation(TransmogModelFrame)

	UpdateAllSlotTextures()
end

function OnClickTransmogButton(self)
	PlaySound("AchievementMenuOpen", "sfx")
	for slot, _ in pairs(SLOT_IDS) do
		currentTransmogIds[slot] = originalTransmogIds[slot]
	end
	TransmogModelFrame:SetUnit("player")
	currentSlot = PLAYER_VISIBLE_ITEM_1_ENTRYID
	SetTab()
	characterTransmogTab:SetChecked(true)
	isInputHovered = false
	AIO.Handle("Transmog", "SetCurrentSlotItemIds", currentSlot, 1)
	LoadTransmogsFromCurrentIds()
	ShowCloakCheckBox:SetChecked(ShowingCloak())
	ShowHelmCheckBox:SetChecked(ShowingHelm())
end

function OnHideTransmogFrame(self)
	PlaySound("AchievementMenuClose", "sfx")
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

local SET_NONE_LABEL = {
	[0] = "None",         -- enUS
	[2] = "Aucun",        -- frFR
	[3] = "Keiner",       -- deDE
	[6] = "Ninguno",      -- esES
	[8] = "Нет",          -- ruRU
}

local DEFAULT_SET_NAME = {
	[0] = "None",         -- enUS
	[2] = "Aucun",        -- frFR
	[3] = "Keiner",       -- deDE
	[6] = "Ninguno",      -- esES
	[8] = "Нет",          -- ruRU
}

local SET_LABEL = {
	[0] = "Set: %s",      -- enUS
	[2] = "Set : %s",     -- frFR
	[3] = "Set: %s",      -- deDE
	[6] = "Conjunto: %s", -- esES
	[8] = "Комплект: %s", -- ruRU
}

local currentTransmogSetId = nil
local availableSets = {}

function TransmogSetButton_OnLoad(self)
	local localeID = HandleLocale()
	currentTransmogSetName = DEFAULT_SET_NAME[localeID] or DEFAULT_SET_NAME[0]
	self:SetText(string.format(SET_LABEL[localeID] or SET_LABEL[0], currentTransmogSetName))
end

function TransmogHandlers.PreviewTransmogSetClient(player, setItems)
	currentTransmogIds = {}

	for _, entry in ipairs(setItems) do
		local slot = tonumber(entry.slot)
		local itemId = tonumber(entry.item)

		local slotName = TRANSMOG_SLOT_MAPPING[slot]
		if slotName then
			currentTransmogIds[slotName] = itemId
		end
	end

	LoadTransmogsFromCurrentIds()
end

local NO_SET_AVAILABLE_TEXT = {
	[0] = "No set available",           -- enUS
	[2] = "Aucun set disponible",       -- frFR
	[3] = "Kein Set verfügbar",         -- deDE
	[6] = "Ningún conjunto disponible", -- esES
	[8] = "Нет доступных комплектов"    -- ruRU
}

local RENAME_SET_TEXT = {
	[0] = "Rename selected set",             -- enUS
	[2] = "Renommer le set sélectionné",     -- frFR
	[3] = "Ausgewähltes Set umbenennen",     -- deDE
	[6] = "Renombrar conjunto seleccionado", -- esES
	[8] = "Переименовать выбранный комплект" -- ruRU
}

local DELETE_SET_TEXT = {
	[0] = "|cffff2020Delete this set|r",        -- enUS
	[2] = "|cffff2020Supprimer ce set|r",       -- frFR
	[3] = "|cffff2020Dieses Set löschen|r",     -- deDE
	[6] = "|cffff2020Eliminar este conjunto|r", -- esES
	[8] = "|cffff2020Удалить этот комплект|r"   -- ruRU
}

local SAVE_APPEARANCE_TEXT = {
	[0] = "|cff00ff00Save current appearance|r",          -- enUS
	[2] = "|cff00ff00Sauvegarder l'apparence actuelle|r", -- frFR
	[3] = "|cff00ff00Aktuelles Aussehen speichern|r",     -- deDE
	[6] = "|cff00ff00Guardar apariencia actual|r",        -- esES
	[8] = "|cff00ff00Сохранить текущий облик|r"           -- ruRU
}

local RENAME_SET_PROMPT_TEXT = {
	[0] = "Enter the new name for the set:",         -- enUS
	[2] = "Entrez le nouveau nom pour le set :",     -- frFR
	[3] = "Neuen Namen für das Set eingeben:",       -- deDE
	[6] = "Introduce el nuevo nombre del conjunto:", -- esES
	[8] = "Введите новое название комплекта:"        -- ruRU
}

local DELETE_SET_PROMPT_TEXT = {
	[0] = "Are you sure you want to delete the set: |cffffff00%s|r?",     -- enUS
	[2] = "Êtes-vous sûr de vouloir supprimer le set : |cffffff00%s|r ?", -- frFR
	[3] = "Möchtest du das Set wirklich löschen: |cffffff00%s|r?",        -- deDE
	[6] = "¿Seguro que quieres eliminar el conjunto: |cffffff00%s|r?",    -- esES
	[8] = "Вы уверены, что хотите удалить комплект: |cffffff00%s|r?"      -- ruRU
}

local DELETE_CONFIRM_BUTTON_TEXT = {
	[0] = "|cffff2020Delete|r",    -- enUS
	[2] = "|cffff2020Supprimer|r", -- frFR
	[3] = "|cffff2020Löschen|r",   -- deDE
	[6] = "|cffff2020Eliminar|r",  -- esES
	[8] = "|cffff2020Удалить|r"    -- ruRU
}

local CANCEL_BUTTON_TEXT = {
	[0] = "Cancel",    -- enUS
	[2] = "Annuler",   -- frFR
	[3] = "Abbrechen", -- deDE
	[6] = "Cancelar",  -- esES
	[8] = "Отмена"     -- ruRU
}

local RENAME_BUTTON_TEXT = {
	[0] = "Rename",       -- enUS
	[2] = "Renommer",     -- frFR
	[3] = "Umbenennen",   -- deDE
	[6] = "Renombrar",    -- esES
	[8] = "Переименовать" -- ruRU
}


function OnClickTransmogSetButton(self)
	AIO.Handle("Transmog", "LoadTransmogSets")

	C_Timer.After(0.1, function()
		local menu = {}
		local localeID = HandleLocale()

		if #availableSets == 0 then
			table.insert(menu, {
				text = NO_SET_AVAILABLE_TEXT[localeID] or NO_SET_AVAILABLE_TEXT[0],
				isTitle = true,
				notCheckable = true
			})
		else
			for _, set in ipairs(availableSets) do
				table.insert(menu, {
					text = set.set_name,
					notCheckable = true,
					func = function()
						currentTransmogSetId = set.set_id
						currentTransmogSetName = set.set_name
						TransmogSetButton:SetText(string.format(SET_LABEL[localeID] or SET_LABEL[0], currentTransmogSetName))
						AIO.Handle("Transmog", "PreviewTransmogSet", set.set_id)
					end
				})
			end
		end

		if currentTransmogSetId then
			table.insert(menu, { text = " ", isTitle = true, notCheckable = true })
			table.insert(menu, {
				text = RENAME_SET_TEXT[localeID] or RENAME_SET_TEXT[0],
				notCheckable = true,
				func = OnClickRenameSetButton
			})
			table.insert(menu, {
				text = DELETE_SET_TEXT[localeID] or DELETE_SET_TEXT[0],
				notCheckable = true,
				func = OnClickDeleteSetButton
			})
		end

		table.insert(menu, {
			text = SAVE_APPEARANCE_TEXT[localeID] or SAVE_APPEARANCE_TEXT[0],
			notCheckable = true,
			func = OnClickSaveSetButton
		})

		EasyMenu(menu, CreateFrame("Frame", "TransmogSetMenu", UIParent, "UIDropDownMenuTemplate"), self, -25, -7, "MENU")
	end)
end


function TransmogHandlers.ReceiveTransmogSetList(player, sets)
	availableSets = {}
	for _, set in ipairs(sets) do
		table.insert(availableSets, set)
	end
end

function TemporaryTransmogSetForSave()
	local data = {}

	for slotName, itemId in pairs(currentTransmogIds) do
		for slotId, name in pairs(TRANSMOG_SLOT_MAPPING) do
			if name == slotName then
				table.insert(data, { slot = slotId, item = itemId })
			end
		end
	end

	return data
end

local SET_LABEL_TEXT = {
	[0] = "Set",        -- enUS
	[2] = "Set",        -- frFR
	[3] = "Set",        -- deDE
	[6] = "Conjunto",   -- esES
	[8] = "Комплект",   -- ruRU
}

local NEW_SET_ENTRY_TEXT = {
	[0] = "Creating a new set:",         -- enUS
	[2] = "Création d'un nouveau set :", -- frFR
	[3] = "Erstellen eines neuen Sets:", -- deDE
	[6] = "Creando un nuevo conjunto:",  -- esES
	[8] = "Создание нового комплекта:",  -- ruRU
}

function OnClickSaveSetButton()
	if currentTransmogSetId then
		ShowSaveSetConfirmation()
	else
		local id = (#availableSets > 0 and availableSets[#availableSets].set_id + 1) or 1
		local name = string.format("%s %d", SET_LABEL_TEXT[localeId] or SET_LABEL_TEXT[0], id)  -- Translate "Set" and append the id

		local transmogData = TemporaryTransmogSetForSave()
		AIO.Handle("Transmog", "SaveTransmogSet", id, name, transmogData)

		currentTransmogSetId = id
		currentTransmogSetName = name
		TransmogSetButton:SetText(string.format("%s : %s", SET_LABEL_TEXT[localeId] or SET_LABEL_TEXT[0], currentTransmogSetName))  -- Localize "Set :"

		print(NEW_SET_ENTRY_TEXT[localeId] or NEW_SET_ENTRY_TEXT[0], name)
	end
end

local SAVE_SET_PROMPT_TEXT = {
	[0] = "Do you want to replace the existing set?\nSet Name: |cffffff00%s|r",       -- enUS
	[2] = "Souhaitez-vous remplacer le set existant ?\nNom du set : |cffffff00%s|r",  -- frFR
	[3] = "Möchten Sie das vorhandene Set ersetzen?\nSet-Name: |cffffff00%s|r",       -- deDE
	[6] = "¿Quieres reemplazar el set existente?\nNombre del set: |cffffff00%s|r",    -- esES
	[8] = "Вы хотите заменить существующий комплект?\nИмя комплекта: |cffffff00%s|r", -- ruRU
}

local SAVE_SET_CONFIRM_BUTTON_TEXT = {
	[0] = "Replace",    -- enUS
	[2] = "Remplacer",  -- frFR
	[3] = "Ersetzen",   -- deDE
	[6] = "Reemplazar", -- esES
	[8] = "Заменить",   -- ruRU
}

local CREATE_NEW_SET_TEXT = {
	[0] = "New set",        -- enUS
	[2] = "Nouveau set",    -- frFR
	[3] = "Neues Set",      -- deDE
	[6] = "Nuevo conjunto", -- esES
	[8] = "Новый комплект", -- ruRU
}

local REPLACE_SET_TEXT = {
	[0] = "Replacing the existing set:",         -- enUS
	[2] = "Remplacement du set existant :",      -- frFR
	[3] = "Ersetzen des bestehenden Sets:",      -- deDE
	[6] = "Reemplazando el conjunto existente:", -- esES
	[8] = "Замена существующего комплекта:",     -- ruRU
}


function ShowSaveSetConfirmation()
	local localeID = HandleLocale()
	local dialog = StaticPopupDialogs["TRANSMOG_SAVE_SET_CONFIRM"]
	if not dialog then
		StaticPopupDialogs["TRANSMOG_SAVE_SET_CONFIRM"] = {
			text = SAVE_SET_PROMPT_TEXT[localeID] or SAVE_SET_PROMPT_TEXT[0],
			button1 = SAVE_SET_CONFIRM_BUTTON_TEXT[localeID] or SAVE_SET_CONFIRM_BUTTON_TEXT[0], -- Remplacer
			button2 = CREATE_NEW_SET_TEXT[localeID] or CREATE_NEW_SET_TEXT[0],  -- Créer un nouveau
			button3 = CANCEL_BUTTON_TEXT[localeID] or CANCEL_BUTTON_TEXT[0],  -- Annuler
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
			OnAccept = function(self, data)
				local id = currentTransmogSetId
				local name = currentTransmogSetName
				local data = TemporaryTransmogSetForSave()
				AIO.Handle("Transmog", "SaveTransmogSet", id, name, data)
				print(REPLACE_SET_TEXT[localeId] or REPLACE_SET_TEXT[0], name)
			end,
			OnCancel = function(self, data, reason)
				if reason == "clicked" then
					local id = (#availableSets > 0 and availableSets[#availableSets].set_id + 1) or 1
					local name = "Set " .. id
					AIO.Handle("Transmog", "SaveTransmogSet", id, name, data)
					currentTransmogSetId = id
					currentTransmogSetName = name
					TransmogSetButton:SetText("Set : " .. currentTransmogSetName)
					print(CREATE_NEW_SET_TEXT[localeId] or CREATE_NEW_SET_TEXT[0], name)
				end
			end
		}
	end

	StaticPopup_Show("TRANSMOG_SAVE_SET_CONFIRM", currentTransmogSetName or "Aucun")
end

function ShowRenameSetConfirmation()
	local localeID = HandleLocale()
	if not StaticPopupDialogs["TRANSMOG_RENAME_SET_CONFIRM"] then
		StaticPopupDialogs["TRANSMOG_RENAME_SET_CONFIRM"] = {
			text = RENAME_SET_PROMPT_TEXT[localeID] or RENAME_SET_PROMPT_TEXT[0],
			button1 = RENAME_BUTTON_TEXT[localeID] or RENAME_BUTTON_TEXT[0],
			button2 = CANCEL_BUTTON_TEXT[localeID] or CANCEL_BUTTON_TEXT[0],
			hasEditBox = true,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 4,
			OnShow = function(self)
				self.editBox:SetText(currentTransmogSetName or "")
				self.editBox:SetFocus()
			end,
			OnAccept = function(self)
				local newName = self.editBox:GetText()
				if currentTransmogSetId then
					AIO.Handle("Transmog", "RenameTransmogSet", currentTransmogSetId, newName)
					currentTransmogSetName = newName
					TransmogSetButton:SetText(string.format(SET_LABEL[localeID] or SET_LABEL[0], newName))
				end
			end,
		}
	end
	
	StaticPopup_Show("TRANSMOG_RENAME_SET_CONFIRM")
end

local NO_SET_SELECTED_TO_RENAME = {
	[0] = "No transmog set selected to rename.",                   -- enUS
	[2] = "Aucun set sélectionné à renommer.",                     -- frFR
	[3] = "Kein Set zum Umbenennen ausgewählt.",                   -- deDE
	[6] = "No se ha seleccionado ningún conjunto para renombrar.", -- esES
	[8] = "Ни один набор не выбран для переименования."            -- ruRU
}

function OnClickRenameSetButton()
	local localeID = HandleLocale()
	if currentTransmogSetId then
		ShowRenameSetConfirmation()
	else
		print(NO_SET_SELECTED_TO_RENAME[localeID] or NO_SET_SELECTED_TO_RENAME[0])
	end
end

function ShowDeleteSetConfirmation()
	local localeID = HandleLocale()
	
	if not StaticPopupDialogs["TRANSMOG_DELETE_SET_CONFIRM"] then
		StaticPopupDialogs["TRANSMOG_DELETE_SET_CONFIRM"] = {
			text = DELETE_SET_PROMPT_TEXT[localeID] or DELETE_SET_PROMPT_TEXT[0],
			button1 = DELETE_CONFIRM_BUTTON_TEXT[localeID] or DELETE_CONFIRM_BUTTON_TEXT[0],
			button2 = CANCEL_BUTTON_TEXT[localeID] or CANCEL_BUTTON_TEXT[0],
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 5,
			OnShow = function(self)
				local name = currentTransmogSetName or (SET_NONE_LABEL[localeID] or SET_NONE_LABEL[0])
				self.text:SetFormattedText(DELETE_SET_PROMPT_TEXT[localeID] or DELETE_SET_PROMPT_TEXT[0], name)
			end,
			OnAccept = function()
				if currentTransmogSetId then
					AIO.Handle("Transmog", "DeleteTransmogSet", currentTransmogSetId)
					currentTransmogSetId = nil
					currentTransmogSetName = SET_NONE_LABEL[localeID] or SET_NONE_LABEL[0]
					TransmogSetButton:SetText(string.format(SET_LABEL[localeID] or SET_LABEL[0], currentTransmogSetName))
				end
			end,
		}
	end

	local name = currentTransmogSetName or (SET_NONE_LABEL[localeID] or SET_NONE_LABEL[0])
	StaticPopup_Show("TRANSMOG_DELETE_SET_CONFIRM", name)
end

local NO_SET_SELECTED_TO_DELETE = {
	[0] = "No transmog set selected to delete.",                  -- enUS
	[2] = "Aucun set sélectionné à supprimer.",                   -- frFR
	[3] = "Kein Set zum Löschen ausgewählt.",                     -- deDE
	[6] = "No se ha seleccionado ningún conjunto para eliminar.", -- esES
	[8] = "Ни один набор не выбран для удаления."                 -- ruRU
}

function OnClickDeleteSetButton()
	local localeID = HandleLocale()
	if currentTransmogSetId then
		ShowDeleteSetConfirmation()
	else
		print(NO_SET_SELECTED_TO_DELETE[localeID] or NO_SET_SELECTED_TO_DELETE[0])
	end
end

function RecoverMissingTransmogs()
	PlaySound("Glyph_MajorCreate", "sfx")
	-- SendChatMessage(".recovertransmog", "SAY")
	local locale = HandleLocale()
	AIO.Handle("Transmog", "RecoverQuestTransmogs", locale)
end
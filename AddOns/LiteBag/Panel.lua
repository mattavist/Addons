--[[----------------------------------------------------------------------------

  LiteBag/Panel.lua

  Copyright 2013-2016 Mike Battersby

  Released under the terms of the GNU General Public License version 2 (GPLv2).
  See the file LICENSE.txt.

----------------------------------------------------------------------------]]--

local MIN_COLUMNS = 8
local DEFAULT_SCALE = 1.0

-- These are the gaps between the buttons
local BUTTON_X_GAP, BUTTON_Y_GAP = 5, 4

-- Because this Panel should overlay a PortraitFrame, this will position the
-- buttons into the Inset part of the PortraitFrame.
local LEFT_OFFSET, TOP_OFFSET = 14, 70
local RIGHT_OFFSET, BOTTOM_OFFSET = 15, 35


function LiteBagPanel_Initialize(self, bagIDs)
    LiteBag_Debug("Panel Initialize " .. self:GetName())

    -- Create the dummy container frames, so each itembutton can be parented
    -- by one allowing us to use all the Blizzard container frame code

    for i, id in ipairs(bagIDs) do
        local name = format("%sContainerFrame%d", self:GetName(), i)
        local bagFrame = CreateFrame("Frame", name, self)
        bagFrame:SetID(id)
        tinsert(self.bagFrames, bagFrame)
    end

    if tContains(bagIDs, BANK_CONTAINER) then
        self.isBank = true
    end

    if tContains(bagIDs, BACKPACK_CONTAINER) then
        self.isBackpack = true
    end

    -- Set up the bag buttons with their bag IDs

    for i, b in ipairs(self.bagButtons) do
        if bagIDs[i] then
            b:SetID(bagIDs[i])
            LiteBagBagButton_Update(b)
            b:Show()
            self.itemButtonsByBag[bagIDs[i]] = { }
        else
            b:Hide()
        end
    end

    -- And update ourself for the bag sizes. Need to watch PLAYER_LOGIN
    -- because the size of the bags isn't known until then the first
    -- time you start the game.
    self:RegisterEvent("PLAYER_LOGIN")
end

function LiteBagPanel_UpdateBagSlotCounts(self)
    LiteBag_Debug("Panel UpdateBagSlotCounts " .. self:GetName())
    local n = 0

    for _, b in ipairs(self.bagButtons) do
        wipe(self.itemButtonsByBag[b:GetID()])
        LiteBagBagButton_Update(b)
    end

    for _, bag in ipairs(self.bagFrames) do
        local bagID = bag:GetID()
        for slot = 1, GetContainerNumSlots(bagID) do
            n = n + 1
            if not self.itemButtons[n] then
                local name = format("%sItemButton%d", self:GetName(), n)
                self.itemButtons[n] = CreateFrame("Button", name, nil, "LiteBagItemButtonTemplate")
                self.itemButtons[n]:SetSize(37, 37)
            end
            self.itemButtons[n]:SetID(slot)
            self.itemButtons[n]:SetParent(bag)
            self.itemButtonsByBag[bagID][slot] = self.itemButtons[n]
        end
    end

    self.size = n
end

local function inDiffBag(a, b)
    return a:GetParent():GetID() ~= b:GetParent():GetID()
end

local LAYOUTS = { }

LAYOUTS.normal =
    function (self, ncols)
        local grid = { }
        local row

        for i = 1, self.size do
            if i % ncols == 1 then
                row = { }
                tinsert(grid, row)
            end
            tinsert(row, self.itemButtons[i])
        end

        return false, grid
    end

LAYOUTS.reverse =
    function (self, ncols)
        local grid = { }
        local row

        for i = 1, self.size do
            if i % ncols == 1 then
                row = { }
                tinsert(grid, 1, row)
            end
            tinsert(row, self.itemButtons[i])
        end

        return true, grid
    end

LAYOUTS.bag =
    function (self, ncols)
        local grid = { }
        local row

        for i = 1, self.size do
            if i == 1 or #row % ncols == 0 or inDiffBag(self.itemButtons[i-1], self.itemButtons[i]) then
                row = { }
                tinsert(grid, row)
            end
            tinsert(row, self.itemButtons[i])
        end

        return false, grid
    end

LAYOUTS.blizzard =
    function (self, ncols)
        local grid = { }
        local row

        local n = 1

        for b = #self.bagFrames, 1, -1 do
            local bagID = self.bagFrames[b]:GetID()
            for j = 1, #self.itemButtonsByBag[bagID] do
                if n % ncols == 1 then
                    row = { }
                    tinsert(grid, row)
                end
                tinsert(row, self.itemButtonsByBag[bagID][j])
                n = n + 1
            end
        end

        return false, grid
    end

function LiteBagPanel_LayoutButtons(self, rightToLeft, buttonGrid)
    local destAnchor, srcRowAnchor, srcColAnchor, xOff, yOff, xGap, yGap

    if rightToLeft then
        destAnchor, srcRowAnchor, srcColAnchor = "TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT"
        xOff, xGap = -RIGHT_OFFSET, -BUTTON_X_GAP
    else
        destAnchor, srcRowAnchor, srcColAnchor = "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT"
        xOff, xGap = LEFT_OFFSET, BUTTON_X_GAP
    end

    local anchorTo = self

    local ncols = 0
    local n = 1

    for i = 1, #buttonGrid do
        for j = 1, #buttonGrid[i] do
            local itemButton = buttonGrid[i][j]
            itemButton:ClearAllPoints()
            itemButton:SetShown(true)
            if i == 1 and j == 1 then
                itemButton:SetPoint(destAnchor, self, xOff, -TOP_OFFSET)
            elseif j == 1 then
                itemButton:SetPoint(destAnchor, anchorTo, srcColAnchor, 0, -BUTTON_Y_GAP)
            else
                itemButton:SetPoint(destAnchor, anchorTo, srcRowAnchor, xGap, 0)
            end
            anchorTo = itemButton
            n = n + 1
            ncols = max(ncols, j)
        end
        anchorTo = buttonGrid[i][1]
    end

    -- Hide the leftovers

    while n <= #self.itemButtons do
        self.itemButtons[n]:Hide()
        n = n + 1
    end

    local w, h = buttonGrid[1][1]:GetSize()
    local nrows = #buttonGrid

    local totalW = ncols * w + (ncols-1) * BUTTON_X_GAP
    local totalH = nrows * h + (nrows-1) * BUTTON_Y_GAP

    return totalW, totalH
end

-- Note again, this is overlayed onto a Portrait frame, so there is
-- padding on the edges to align the buttons into the inset.

function LiteBagPanel_UpdateSizeAndLayout(self)
    LiteBag_Debug("Panel UpdateSize " .. self:GetName())

    local ncols = LiteBag_GetFrameOption(self, "columns") or
                    self.defaultColumns or
                    MIN_COLUMNS
    local layout = LiteBag_GetFrameOption(self, "layout")

    if not layout or not LAYOUTS[layout] then
        layout = "normal"
    end

    local rightToLeft, buttonGrid = LAYOUTS[layout](self, ncols)

    local w, h = LiteBagPanel_LayoutButtons(self, rightToLeft, buttonGrid)

    local frameW = w + LEFT_OFFSET + RIGHT_OFFSET
    local frameH = h + TOP_OFFSET + BOTTOM_OFFSET

    LiteBag_Debug(format("Panel SetSize %d,%d", frameW, frameH))

    self:SetSize(frameW, frameH)

end

function LiteBagPanel_SetWidth(self, width)
    LiteBag_Debug(format("Panel SetWidth %s %d", self:GetName(), width))
    local w = self.itemButtons[1]:GetWidth()
    local ncols = floor( (width - LEFT_OFFSET - RIGHT_OFFSET + BUTTON_X_GAP) / (w + BUTTON_X_GAP) )
    ncols = min(ncols, self.size)
    ncols = max(ncols, MIN_COLUMNS)
    LiteBag_SetFrameOption(self, "columns", ncols)
    LiteBagPanel_UpdateSizeAndLayout(self)
end

function LiteBagPanel_HighlightBagButtons(self, bagID)
    for i, b in ipairs(self.itemButtonsByBag[bagID]) do
        if i > self.size then return end
        b:LockHighlight()
    end
end

function LiteBagPanel_UnhighlightBagButtons(self, bagID)
    for i, b in ipairs(self.itemButtonsByBag[bagID]) do
        if i > self.size then return end
        b:UnlockHighlight()
    end
end

function LiteBagPanel_ClearNewItems(self)
    for i, b in ipairs(self.itemButtons) do
        if i > self.size then return end
        LiteBagItemButton_ClearNewItem(b)
    end
end

function LiteBagPanel_UpdateItemButtonsByBag(self, bag)
    for _,b in ipairs(self.itemButtonsByBag[bag] or {}) do
        LiteBagItemButton_Update(b)
    end
end

function LiteBagPanel_UpdateItemButtons(self)
    if LE_EXPANSION_BATTLE_FOR_AZEROTH then
        ContainerFrame_CloseSpecializedTutorialForItem(self)
    end

    for i, b in ipairs(self.itemButtons) do
        if i > self.size then return end
        LiteBagItemButton_Update(b)
    end
end

function LiteBagPanel_UpdateItemUpgrades(self)
    for i, b in ipairs(self.itemButtons)  do
        if i > self.size then return end
        LiteBagItemButton_UpdateItemUpgrade(b)
    end
end

function LiteBagPanel_UpdateCooldowns(self)
    for i, b in ipairs(self.itemButtons)  do
        if i > self.size then return end
        LiteBagItemButton_UpdateCooldown(b)
    end
end

function LiteBagPanel_UpdateSearchResults(self)
    for i, b in ipairs(self.itemButtons) do
        if i > self.size then return end
        LiteBagItemButton_UpdateFiltered(b)
    end
end

function LiteBagPanel_UpdateLocked(self)
    for i, b in ipairs(self.itemButtons) do
        if i > self.size then return end
        LiteBagItemButton_UpdateLocked(b)
    end
end

function LiteBagPanel_UpdateQuality(self)
    for i, b in ipairs(self.itemButtons) do
        if i > self.size then return end
        LiteBagItemButton_UpdateQuality(b)
    end
end

function LiteBagPanel_UpdateQuestTextures(self)
    for i, b in ipairs(self.itemButtons) do
        if i > self.size then return end
        LiteBagItemButton_UpdateQuestTexture(b)
    end
end

function LiteBagPanel_OnLoad(self)
    self.size = 0
    self.itemButtons = { }
    self.itemButtonsByBag = { }
    self.bagFrames = { }
end

function LiteBagPanel_OnShow(self)
    LiteBag_Debug("Panel OnShow " .. self:GetName())
    LiteBagPanel_UpdateBagSlotCounts(self)
    LiteBagPanel_UpdateSizeAndLayout(self)
    LiteBagPanel_UpdateItemButtons(self)

    self:RegisterEvent("BAG_CLOSED")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("ITEM_LOCK_CHANGED")
    self:RegisterEvent("BAG_UPDATE_COOLDOWN")
    self:RegisterEvent("INVENTORY_SEARCH_UPDATE")
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
    self:RegisterEvent("BAG_NEW_ITEMS_UPDATED")
    self:RegisterEvent("BAG_SLOT_FLAGS_UPDATED")
    self:RegisterEvent("BANK_BAG_SLOT_FLAGS_UPDATED")
    self:RegisterEvent("MERCHANT_SHOW")
    self:RegisterEvent("MERCHANT_CLOSED")
    self:RegisterEvent("UNIT_INVENTORY_CHANGED")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    if self.isBank then
        self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    end
end

function LiteBagPanel_OnHide(self)
    LiteBag_Debug("Panel OnHide " .. self:GetName())
    -- Judging by the code in FrameXML/ContainerFrame.lua items are tagged
    -- by the server as "new" in some cases, and you're supposed to clear
    -- the new flag after you see it the first time.
    LiteBagPanel_ClearNewItems(self)

    if LE_EXPANSION_BATTLE_FOR_AZEROTH then
        ContainerFrame_CloseSpecializedTutorialForItem(self)
    end

    self:UnregisterEvent("BAG_CLOSED")
    self:UnregisterEvent("BAG_UPDATE")
    self:UnregisterEvent("ITEM_LOCK_CHANGED")
    self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
    self:UnregisterEvent("INVENTORY_SEARCH_UPDATE")
    self:UnregisterEvent("QUEST_ACCEPTED")
    self:UnregisterEvent("UNIT_QUEST_LOG_CHANGED")
    self:UnregisterEvent("BAG_NEW_ITEMS_UPDATED")
    self:UnregisterEvent("BAG_SLOT_FLAGS_UPDATED")
    self:UnregisterEvent("BANK_BAG_SLOT_FLAGS_UPDATED")
    self:UnregisterEvent("MERCHANT_SHOW")
    self:UnregisterEvent("MERCHANT_CLOSED")
    self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
    self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    if self.isBank then
        self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
    end
end

-- These events are only registered while the panel is shown, so we can call
-- the update functions without worrying that we don't need to.
--
-- Some events that fire a lot have specific code to just update the
-- bags or changes that they fire for (where possible).  Others are
-- rare enough it's OK to call LiteBagPanel_UpdateItemButtons to do everything.
function LiteBagPanel_OnEvent(self, event, ...)
    local arg1, arg2 = ...
    LiteBag_Debug(format("Panel OnEvent %s %s %s %s", self:GetName(), event, tostring(arg1), tostring(arg2)))

    if event == "PLAYER_LOGIN" then
        LiteBagPanel_UpdateBagSlotCounts(self)
        return
    end

    if event == "MERCHANT_SHOW" or event == "MERCHANT_CLOSED" then
        LiteBagPanel_UpdateQuality(self)
        return
    end

    if event == "BAG_CLOSED" then
        -- BAG_CLOSED fires when you drag a bag out of a slot but for the
        -- bank GetContainerNumSlots doesn't return the updated size yet,
        -- so we have to wait until BAG_UPDATE_DELAYED fires.
        self:RegisterEvent("BAG_UPDATE_DELAYED")
        return
    end

    if event == "BAG_UPDATE_DELAYED" then
        self:UnregisterEvent("BAG_UPDATE_DELAYED")
        LiteBagPanel_UpdateBagSlotCounts(self)
        LiteBagPanel_UpdateSizeAndLayout(self)
        LiteBagPanel_UpdateItemButtons(self)
        return
    end

    -- XXX FIXME XXX
    -- Once had the vendor disappear in the middle of a mass sale and
    -- the items did not unlock despite actually selling.

    if event == "ITEM_LOCK_CHANGED" then
        -- bag, slot = arg1, arg2
        if arg1 and arg2 and self.itemButtonsByBag[arg1] then
            if arg1 == BANK_CONTAINER and arg2 > NUM_BANKGENERIC_SLOTS then
                return
            end
            LiteBagItemButton_UpdateLocked(self.itemButtonsByBag[arg1][arg2])
        end
        return
    end

    if event == "BAG_UPDATE_COOLDOWN" then
        LiteBagPanel_UpdateCooldowns(self)
        return
    end

    if event == "QUEST_ACCEPTED" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player") then
        LiteBagPanel_UpdateQuestTextures(self)
        return
    end

    if event == "INVENTORY_SEARCH_UPDATE" then
        LiteBagPanel_UpdateSearchResults(self)
        return
    end

    if event == "PLAYERBANKSLOTS_CHANGED" then
        -- slot = arg1
        if self.isBank then
            if arg1 > NUM_BANKGENERIC_SLOTS then
                LiteBagPanel_UpdateBagSlotCounts(self)
            end
            LiteBagPanel_UpdateItemButtons(self)
        end
        return
    end

    if event == "UNIT_INVENTORY_CHANGED" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        LiteBagPanel_UpdateItemUpgrades(self)
        return
    end

    if event == "BAG_UPDATE" then
        -- bag = arg1
        LiteBagPanel_UpdateItemButtonsByBag(self, arg1)
        return
    end

    if event == "BAG_SLOT_FLAGS_UPDATED" then
        -- bag = arg1
        LiteBagPanel_UpdateItemButtonsByBag(self, arg1)
        return
    end

    if event == "BANK_BAG_SLOT_FLAGS_UPDATED" then
        -- bag = arg1 + NUM_BAG_SLOTS
        LiteBagPanel_UpdateItemButtonsByBag(self, arg1 + NUM_BAG_SLOTS)
        return
    end

    -- Default action for the below plus whatever is added by plugins
    --
    -- BAG_NEW_ITEMS_UPDATED 

    LiteBagPanel_UpdateItemButtons(self)
end

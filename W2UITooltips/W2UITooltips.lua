-- W2UI Tooltips: gives Blizzard's tooltips W2UI's styled border everywhere, rather than
-- only while they're shown over W2UI's own windows.
--
-- It uses W2UI's own styling function (W2UI.Theme:StyleEquipmentMenuFrame), so the look
-- matches W2UI exactly and follows any changes W2UI makes to it. The styled pieces are
-- textures attached to the tooltip that size themselves with it, so they only need to be
-- created once. They're stored under this addon's own key, so W2UI's show/hide logic for
-- its own pieces never touches them. The one thing that needs ongoing care is Blizzard's
-- default border (the tooltip's NineSlice), which Blizzard - and W2UI, when restoring a
-- tooltip it styled - can show again; it's hidden again whenever that happens.

local TOOLTIP_NAMES = {
    "GameTooltip",
    "ShoppingTooltip1",
    "ShoppingTooltip2",
    "ItemRefTooltip",
    "ItemRefShoppingTooltip1",
    "ItemRefShoppingTooltip2",
}

local STORAGE_KEY = "W2UITooltipsFramePieces"

-- How far W2UI's border extends past each tooltip edge (W2UI's frame outset).
local BORDER_OUTSET = 5

local function keepHidden(nineSlice)
    nineSlice:Hide()
end

--- Apply W2UI's border to a tooltip and keep Blizzard's default border hidden.
--- @param tooltip table
local function styleTooltip(tooltip)
    W2UI.Theme:StyleEquipmentMenuFrame(tooltip, { storageKey = STORAGE_KEY })

    -- Tooltips are clamped to the screen by their own edges, which would leave the border
    -- partly off screen at the edges. Clamp by the border's edges instead.
    tooltip:SetClampRectInsets(-BORDER_OUTSET, BORDER_OUTSET, BORDER_OUTSET, -BORDER_OUTSET)

    local nineSlice = tooltip.NineSlice
    if nineSlice then
        nineSlice:Hide()
        -- Post-hooks only change artwork, never tooltip contents or native handlers.
        hooksecurefunc(nineSlice, "Show", keepHidden)
        hooksecurefunc(nineSlice, "SetShown", keepHidden)
    end
end

-- W2UI's border extends past each tooltip's edge (by BORDER_OUTSET), but Blizzard
-- places comparison tooltips edge to edge, so neighbouring borders would overlap. After
-- Blizzard anchors them, push each side-by-side attachment apart by both borders' outsets.
local COMPARISON_GAP = 9

--- Re-apply a tooltip's horizontal edge-to-edge anchors with COMPARISON_GAP between them.
--- @param tooltip table
local function spaceComparisonTooltip(tooltip)
    local points = {}
    for i = 1, tooltip:GetNumPoints() do
        points[i] = { tooltip:GetPoint(i) }
    end

    for _, point in ipairs(points) do
        local anchor, relativeTo, relativePoint, _, offsetY = unpack(point)
        if anchor == "LEFT" or anchor == "TOPLEFT" then
            tooltip:SetPoint(anchor, relativeTo, relativePoint, COMPARISON_GAP, offsetY)
        elseif anchor == "RIGHT" or anchor == "TOPRIGHT" then
            tooltip:SetPoint(anchor, relativeTo, relativePoint, -COMPARISON_GAP, offsetY)
        end
    end
end

local function spaceComparisonTooltips(manager, primaryShown, secondaryShown)
    local tooltip = manager.tooltip
    local shoppingTooltips = tooltip and tooltip.shoppingTooltips
    if not shoppingTooltips then return end

    if primaryShown and shoppingTooltips[1] then
        spaceComparisonTooltip(shoppingTooltips[1])
    end
    if secondaryShown and shoppingTooltips[2] then
        spaceComparisonTooltip(shoppingTooltips[2])
    end
end

--- Space out ShoppingTooltip1/2 when shown. Used after TipTac re-anchors them, which it
--- does with its own copy of Blizzard's anchoring, undoing the gap from the hook above.
local function spaceShownComparisonTooltips()
    for _, tooltip in ipairs({ ShoppingTooltip1, ShoppingTooltip2 }) do
        if tooltip:IsShown() then
            spaceComparisonTooltip(tooltip)
        end
    end
end

-- The unit health bar sits just below the tooltip's bottom edge (1px, per Blizzard's XML),
-- where W2UI's border now extends (by its outset, 5). Drop the bar below the border, keeping
-- Blizzard's 2px side insets. Blizzard only anchors it once, in XML, so this sticks.
local HEALTH_BAR_OFFSET_Y = -7

local function moveHealthBar()
    local healthBar = GameTooltip.StatusBar
    if not healthBar then return end

    healthBar:ClearAllPoints()
    healthBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 2, HEALTH_BAR_OFFSET_Y)
    healthBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -2, HEALTH_BAR_OFFSET_Y)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")

    local theme = W2UI and W2UI.Theme
    if not (theme and theme.StyleEquipmentMenuFrame) then return end

    for _, name in ipairs(TOOLTIP_NAMES) do
        local tooltip = _G[name]
        if tooltip then
            styleTooltip(tooltip)
        end
    end

    moveHealthBar()

    if TooltipComparisonManager and TooltipComparisonManager.AnchorShoppingTooltips then
        hooksecurefunc(TooltipComparisonManager, "AnchorShoppingTooltips", spaceComparisonTooltips)
    end

    -- The gap is set rather than added, so applying it after both is harmless.
    if TipTac and TipTac.RefreshAnchorShoppingTooltips then
        hooksecurefunc(TipTac, "RefreshAnchorShoppingTooltips", spaceShownComparisonTooltips)
    end
end)

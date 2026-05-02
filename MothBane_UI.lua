-- Settings frame and minimap button.
if not MothBane_CoverShouldBeActive then return end

local function GetVersion()
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local v = C_AddOns.GetAddOnMetadata("MothBane", "Version")
        if v and v ~= "" then return v end
    end
    if GetAddOnMetadata then
        local v = GetAddOnMetadata("MothBane", "Version")
        if v and v ~= "" then return v end
        for i = 1, (GetNumAddOns and GetNumAddOns() or 0) do
            if GetAddOnInfo(i) == "MothBane" then
                v = GetAddOnMetadata(i, "Version")
                if v and v ~= "" then return v end
                break
            end
        end
    end
    return nil
end
local ENABLE_DEBUG_UI = MothBane_EnableDebugUI

local MIN_W, MIN_H = 380, (ENABLE_DEBUG_UI and 380 or 220)
local MAX_W, MAX_H = 560, 520
local PAD = 24
local COLUMN_H_PAD = 28
local SECTION_GAP = 20
local ROW_GAP = 10
local COMPACT_MAX_H = 260

local function CreateSettingsFrame()
    local f = CreateFrame("Frame", "MothBane_SettingsFrame", UIParent, "BackdropTemplate")
    local w = 400
    local h = ENABLE_DEBUG_UI and 520 or 310
    f:SetSize(w, h)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:Hide()

    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        f:SetBackdropColor(0.09, 0.09, 0.12, 0.97)
        f:SetBackdropBorderColor(0.45, 0.38, 0.28, 0.9)
    else
        local bg = f:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(f)
        bg:SetColorTexture(0.09, 0.09, 0.12, 0.97)
    end

    local titleBg = CreateFrame("Frame", nil, f, "BackdropTemplate")
    titleBg:SetPoint("TOPLEFT", 12, -10)
    titleBg:SetPoint("TOPRIGHT", -12, -10)
    titleBg:SetHeight(36)
    titleBg:SetScript("OnMouseDown", function() f:StartMoving() end)
    titleBg:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)
    local titleIcon = titleBg:CreateTexture(nil, "OVERLAY")
    titleIcon:SetSize(22, 22)
    titleIcon:SetPoint("LEFT", titleBg, "LEFT", 10, 0)
    titleIcon:SetTexture(MothBane_MOTH_IMAGE_PATH or "")
    titleIcon:SetTexCoord(0, 1, 0, 1)
    local title = titleBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", titleIcon, "RIGHT", 6, 0)
    title:SetFont(title:GetFont(), 18, "OUTLINE")
    title:SetTextColor(1, 0.92, 0.55)
    title:SetShadowColor(0, 0, 0, 0.9)
    title:SetShadowOffset(1, -1)
    title:SetText("MothBane")
    local titleVer = titleBg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    titleVer:SetPoint("LEFT", title, "RIGHT", 6, 0)
    titleVer:SetTextColor(0.75, 0.72, 0.6)
    local function setHeaderVersion()
        local ver = GetVersion()
        titleVer:SetText(ver and ("v " .. ver) or "")
    end
    setHeaderVersion()

    -- Layout: margin, indent and position offsets.
    local top = titleBg
    local margin, indent, rightCol = 12, 12, 200
    local panelInset, outputPadding = 4, 24
    local outputBottom, bottomBtnLeft, bottomBtnBottom = 58, 28, 10
    local off, offRight = margin, margin
    if titleBg.SetBackdrop then
        titleBg:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        titleBg:SetBackdropColor(0.18, 0.15, 0.1, 0.85)
        titleBg:SetBackdropBorderColor(0.35, 0.3, 0.22, 0.9)
    end

    local leftColAnchor = CreateFrame("Frame", nil, f)
    leftColAnchor:SetPoint("TOPLEFT", top, "BOTTOMLEFT", margin + indent, 0)
    leftColAnchor:SetSize(1, 1)

    local leftHeadingAnchor = CreateFrame("Frame", nil, f)
    leftHeadingAnchor:SetPoint("TOPLEFT", top, "BOTTOMLEFT", margin, 0)
    leftHeadingAnchor:SetSize(1, 1)

    local rightColAnchor = CreateFrame("Frame", nil, f)
    rightColAnchor:SetPoint("TOPLEFT", top, "BOTTOMLEFT", rightCol, 0)
    rightColAnchor:SetSize(1, 1)

    local debugHeadingAnchor = CreateFrame("Frame", nil, f)
    debugHeadingAnchor:SetPoint("TOPLEFT", top, "BOTTOMLEFT", margin, 0)
    debugHeadingAnchor:SetSize(1, 1)

    local function SectionTitle(text, anchor, down)
        local lab = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lab:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -down)
        lab:SetTextColor(0.72, 0.68, 0.6)
        lab:SetText(text)
        return lab
    end

    local function CustomDropdown(parent, width, options, getValue, setValue)
        local getVal = getValue
        local setVal = setValue
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(width, 28)
        btn:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        btn:SetBackdropColor(0.18, 0.15, 0.12, 1)
        btn:SetBackdropBorderColor(0.42, 0.35, 0.26, 0.9)
        btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
        btn:GetHighlightTexture():SetVertexColor(0.4, 0.4, 0.45, 0.4)
        local preview = btn:CreateTexture(nil, "OVERLAY")
        preview:SetSize(18, 18)
        preview:SetPoint("LEFT", 8, 0)
        local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", preview, "RIGHT", 6, 0)
        label:SetPoint("RIGHT", -24, 0)
        label:SetJustifyH("LEFT")
        local arrowTex = btn:CreateTexture(nil, "OVERLAY")
        arrowTex:SetSize(12, 12)
        arrowTex:SetPoint("RIGHT", -6, 0)
        arrowTex:SetTexture("Interface\\Buttons\\UI-DropDownArrow")
        arrowTex:SetTexCoord(0, 1, 0, 1)
        arrowTex:SetVertexColor(0.7, 0.68, 0.62, 1)
        function btn:Refresh()
            local v = getVal()
            for _, o in ipairs(options) do
                if o.value == v then
                    label:SetText(o.label or tostring(v))
                    if o.color then
                        preview:SetColorTexture(o.color[1] or 0, o.color[2] or 0, o.color[3] or 0, o.color[4] or 1)
                        preview:SetTexCoord(0, 1, 0, 1)
                        preview:Show()
                        label:ClearAllPoints()
                        label:SetPoint("LEFT", preview, "RIGHT", 6, 0)
                        label:SetPoint("RIGHT", -24, 0)
                    elseif o.icon and o.icon ~= "" then
                        preview:SetTexture(o.icon)
                        preview:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                        preview:Show()
                        label:ClearAllPoints()
                        label:SetPoint("LEFT", preview, "RIGHT", 6, 0)
                        label:SetPoint("RIGHT", -24, 0)
                    else
                        preview:Hide()
                        label:ClearAllPoints()
                        label:SetPoint("LEFT", 8, 0)
                        label:SetPoint("RIGHT", -24, 0)
                    end
                    break
                end
            end
        end
        local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        popup:SetFrameStrata("TOOLTIP")
        popup:SetClampedToScreen(true)
        popup:Hide()
        popup:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        popup:SetBackdropColor(0.18, 0.15, 0.1, 0.95)
        popup:SetBackdropBorderColor(0.42, 0.35, 0.26, 0.9)
        local rowHeight = 26
        local rows = {}
        for i, o in ipairs(options) do
            local row = CreateFrame("Button", nil, popup)
            row:SetHeight(rowHeight)
            row:EnableMouse(true)
            row:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
            row:GetHighlightTexture():SetVertexColor(0.35, 0.35, 0.4, 0.5)
            if o.color then
                local swatch = row:CreateTexture(nil, "OVERLAY")
                swatch:SetSize(18, 18)
                swatch:SetPoint("LEFT", 8, 0)
                swatch:SetColorTexture(o.color[1] or 0, o.color[2] or 0, o.color[3] or 0, o.color[4] or 1)
                local lab = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                lab:SetPoint("LEFT", swatch, "RIGHT", 6, 0)
                lab:SetText(o.label or tostring(o.value))
                lab:SetJustifyH("LEFT")
                lab:SetTextColor(0.92, 0.9, 0.85, 1)
            elseif o.icon and o.icon ~= "" then
                local icon = row:CreateTexture(nil, "OVERLAY")
                icon:SetSize(18, 18)
                icon:SetPoint("LEFT", 8, 0)
                icon:SetTexture(o.icon)
                icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                local lab = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                lab:SetPoint("LEFT", icon, "RIGHT", 6, 0)
                lab:SetText(o.label or tostring(o.value))
                lab:SetJustifyH("LEFT")
                lab:SetTextColor(0.92, 0.9, 0.85, 1)
            else
                local lab = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                lab:SetPoint("LEFT", 10, 0)
                lab:SetText(o.label or tostring(o.value))
                lab:SetJustifyH("LEFT")
                lab:SetTextColor(0.92, 0.9, 0.85, 1)
            end
            row:SetScript("OnClick", function()
                setVal(o.value)
                popup:Hide()
                btn:Refresh()
            end)
            rows[i] = row
        end
        popup:SetSize(width + 4, #rows * rowHeight + 4)
        for i = 1, #rows do
            local yOff = -2 - (i - 1) * rowHeight
            rows[i]:SetPoint("TOPLEFT", popup, "TOPLEFT", 2, yOff)
            rows[i]:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -2, yOff)
        end
        local closeOnClick
        btn:SetScript("OnClick", function()
            if popup:IsShown() then popup:Hide(); return end
            popup:ClearAllPoints()
            popup:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", -2, -2)
            popup:Show()
            if closeOnClick then closeOnClick:Show() end
        end)
        closeOnClick = CreateFrame("Button", nil, UIParent)
        closeOnClick:SetFrameStrata("TOOLTIP")
        closeOnClick:SetAllPoints(UIParent)
        closeOnClick:EnableMouse(true)
        closeOnClick:Hide()
        closeOnClick:SetScript("OnClick", function()
            closeOnClick:Hide()
            popup:Hide()
        end)
        popup:SetScript("OnHide", function() if closeOnClick then closeOnClick:Hide() end end)
        btn:Refresh()
        return btn
    end

    SectionTitle("General", leftHeadingAnchor, off)
    off = off + 22
    local enabled = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
    enabled:SetPoint("TOPLEFT", top, "BOTTOMLEFT", margin + indent, -off)
    enabled.Text:SetText("Enable MothBane")
    enabled.Text:SetWordWrap(false)
    enabled.Text:SetTextColor(0.92, 0.9, 0.85)
    enabled:SetChecked(MothBaneDB.enabled)
    enabled:SetScript("OnClick", function(self)
        MothBaneDB.enabled = self:GetChecked()
        if MothBane_CoverShouldBeActive() then MothBane_UpdateSpotCovers(); MothBane_StartCoverUpdates() else MothBane_StopCoverTicker() end
    end)
    off = off + 28

    local showMinimapBtn = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
    showMinimapBtn:SetPoint("TOPLEFT", top, "BOTTOMLEFT", margin + indent, -off)
    showMinimapBtn.Text:SetText("Show minimap button")
    showMinimapBtn.Text:SetWordWrap(false)
    showMinimapBtn.Text:SetTextColor(0.92, 0.9, 0.85)
    showMinimapBtn:SetChecked(MothBaneDB.showMinimapButton ~= false)
    showMinimapBtn:SetScript("OnClick", function(self)
        MothBaneDB.showMinimapButton = self:GetChecked()
        if MothBane_MinimapButton then
            if MothBaneDB.showMinimapButton then MothBane_MinimapButton:Show() else MothBane_MinimapButton:Hide() end
        end
    end)
    off = off + 28
    off = off + 16

    SectionTitle("Minimap display", leftHeadingAnchor, off)
    off = off + 22
    local styleLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    styleLabel:SetPoint("TOPLEFT", top, "BOTTOMLEFT", margin + indent, -off)
    styleLabel:SetTextColor(0.88, 0.86, 0.82)
    styleLabel:SetText("Replace Blizzard treasure with:")

    local shadowColor = { 0.22, 0.24, 0.18, 0.96 }
    local styleOptions = {
        { value = "dark", label = "Shadow", color = shadowColor },
        { value = "icon", label = "Moth", icon = MothBane_MOTH_IMAGE_PATH or "" },
    }
    local function setStyle(value)
        MothBaneDB.coverStyle = value
        if MothBane_CoverFrames then
            for i = 1, #MothBane_CoverFrames do
                if MothBane_CoverFrames[i].tex and MothBane_ApplyCoverAppearance then MothBane_ApplyCoverAppearance(MothBane_CoverFrames[i].tex) end
            end
        end
        if MothBane_CoverShouldBeActive() then MothBane_UpdateSpotCovers(); MothBane_StartCoverUpdates() else MothBane_StopCoverTicker() end
    end
    local styleSelector = CustomDropdown(f, 140, styleOptions,
        function() return MothBaneDB.coverStyle or "icon" end,
        setStyle)
    styleSelector:SetPoint("LEFT", styleLabel, "RIGHT", 10, 0)
    off = off + 36

    local rightSectionTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rightSectionTitle:SetPoint("TOPLEFT", rightColAnchor, "TOPLEFT", 0, -offRight)
    rightSectionTitle:SetTextColor(0.72, 0.68, 0.6)
    rightSectionTitle:SetText("Icon scale")
    offRight = offRight + 22
    local scaleOptions = {
        { value = 0.75, label = "Small" },
        { value = 1, label = "Medium" },
        { value = 1.25, label = "Large" },
    }
    local function setScale(value)
        MothBaneDB.coverScale = value
        if MothBane_CoverShouldBeActive() then MothBane_UpdateSpotCovers(); MothBane_StartCoverUpdates() end
    end
    local scaleSelector = CustomDropdown(f, 110, scaleOptions,
        function() return MothBaneDB.coverScale or 1 end,
        setScale)
    scaleSelector:SetPoint("TOPLEFT", rightColAnchor, "TOPLEFT", indent, -offRight)

    local debug, edit
    if ENABLE_DEBUG_UI then
        SectionTitle("Debug", debugHeadingAnchor, off)
        off = off + 22
        debug = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
        debug:SetPoint("TOPLEFT", top, "BOTTOMLEFT", margin + indent, -off)
        debug.Text:SetText("Log Glowing Moth hook activity to output")
        debug.Text:SetWordWrap(false)
        debug.Text:SetTextColor(0.92, 0.9, 0.85)
        debug:SetChecked(MothBaneDB.debug)
        debug:SetScript("OnClick", function(self) MothBaneDB.debug = self:GetChecked() end)
        off = off + 28

        local outputLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        outputLabel:SetPoint("TOPLEFT", top, "BOTTOMLEFT", (panelInset + outputPadding) - margin, -off)
        outputLabel:SetTextColor(0.65, 0.62, 0.58)
        outputLabel:SetText("Output (Ctrl+C to copy)")

        local outputBg = CreateFrame("Frame", nil, f, "BackdropTemplate")
        outputBg:SetPoint("TOPLEFT", outputLabel, "BOTTOMLEFT", 0, -4)
        outputBg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -(panelInset + outputPadding), outputBottom)
        outputBg:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        outputBg:SetBackdropColor(0.18, 0.15, 0.1, 0.95)
        outputBg:SetBackdropBorderColor(0.32, 0.28, 0.22, 0.9)

        local scroll = CreateFrame("ScrollFrame", "MothBane_OutputScroll", outputBg, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 0, -4)
        scroll:SetPoint("BOTTOMRIGHT", -20, 4)
        edit = CreateFrame("EditBox", "MothBane_OutputEdit", scroll)
        edit:SetMultiLine(true)
        edit:SetAutoFocus(false)
        edit:SetFontObject(ChatFontNormal)
        edit:SetWidth(scroll:GetWidth())
        edit:SetHeight(120)
        edit:SetTextInsets(4, 4, 4, 4)
        scroll:SetScrollChild(edit)
        edit:SetText("Run \"Test now\" or enable Debug. Output appears here.")
        local sb = _G["MothBane_OutputScrollScrollBar"]
        if sb then
            sb:SetWidth(10)
            sb:Show()
            local thumb = sb.GetThumbTexture and sb:GetThumbTexture() or sb.ThumbTexture
            if thumb and thumb.SetColorTexture then thumb:SetColorTexture(0.38, 0.33, 0.26, 0.9) end
        end
    end

    if ENABLE_DEBUG_UI then
        local testBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        testBtn:SetSize(100, 24)
        testBtn:SetPoint("BOTTOMLEFT", bottomBtnLeft, bottomBtnBottom)
        testBtn:SetText("Test now")
        testBtn:SetScript("OnClick", function() if MothBane_RunTest then MothBane_RunTest() end end)
        local reloadBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        reloadBtn:SetSize(80, 24)
        reloadBtn:SetPoint("LEFT", testBtn, "RIGHT", 8, 0)
        reloadBtn:SetText("Reload")
        reloadBtn:SetScript("OnClick", function() ReloadUI() end)
    end

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(100, 24)
    closeBtn:SetPoint("BOTTOMRIGHT", -24, 10)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    f:SetScript("OnShow", function()
        if setHeaderVersion then setHeaderVersion() end
        enabled:SetChecked(MothBaneDB.enabled)
        showMinimapBtn:SetChecked(MothBaneDB.showMinimapButton ~= false)
        if debug then debug:SetChecked(MothBaneDB.debug) end
        if styleSelector then styleSelector:Refresh() end
        if scaleSelector then scaleSelector:Refresh() end
        if edit and MothBane_GetLogLines then
            local logLines = MothBane_GetLogLines()
            if logLines and #logLines > 0 then edit:SetText(table.concat(logLines, "\n")) end
        end
    end)

    return f
end

local function UpdateMinimapButtonPosition(btn)
    local minimap = _G.Minimap
    if not minimap or not btn then return end
    local angle = (MothBaneDB.minimapAngle or 90) * (math.pi / 180)
    local r = (minimap:GetWidth() or 150) * 0.5 + 8
    local x = math.cos(angle) * r
    local y = math.sin(angle) * r
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", minimap, "CENTER", x, y)
end

-- Left-click options; right-drag to move.
local function CreateMinimapButton()
    local minimap = _G.Minimap
    if not minimap then return end
    local btn = CreateFrame("Button", "MothBane_MinimapButton", minimap)
    btn:SetSize(24, 24)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    UpdateMinimapButtonPosition(btn)
    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture(MothBane_MOTH_IMAGE_PATH or "")
    tex:SetTexCoord(0, 1, 0, 1)
    btn.dragging = false
    btn.dragButton = nil
    btn.leftDown = false
    btn:SetScript("OnMouseDown", function(_, mb)
        btn.downX, btn.downY = GetCursorPosition()
        if mb == "LeftButton" then
            btn.leftDown = true
        elseif mb == "RightButton" then
            btn.dragging = true
            btn.dragButton = "RightButton"
        end
    end)
    btn:SetScript("OnMouseUp", function(_, mb)
        local x, y = GetCursorPosition()
        local distSq = (x - btn.downX)^2 + (y - btn.downY)^2
        if mb == "LeftButton" then
            if btn.leftDown and distSq < 49 and MothBane_ShowSettings then
                MothBane_ShowSettings()
            end
            btn.leftDown = false
        elseif mb == "RightButton" and btn.dragging and btn.dragButton == "RightButton" then
            btn.dragging = false
            btn.dragButton = nil
        end
    end)
    btn:SetScript("OnUpdate", function(self)
        if not self.dragging then return end
        local minimap = _G.Minimap
        if not minimap then return end
        local mx, my = minimap:GetCenter()
        local scale = minimap:GetEffectiveScale()
        local cx = GetCursorPosition() / scale
        local cy = select(2, GetCursorPosition()) / scale
        local dx, dy = cx - mx, cy - my
        local angle = math.atan2(dy, dx) * (180 / math.pi)
        MothBaneDB.minimapAngle = angle
        UpdateMinimapButtonPosition(self)
    end)
    btn:SetScript("OnEnter", function(self)
        if self.dragging then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        do local v = GetVersion(); GameTooltip:SetText(v and ("MothBane v" .. v) or "MothBane") end
        GameTooltip:AddLine("Left-click: Options", 0.2, 0.8, 0.2)
        GameTooltip:AddLine("Right-click drag: Move", 0.2, 0.8, 0.2)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    if MothBaneDB.showMinimapButton ~= false then btn:Show() else btn:Hide() end
end

function MothBane_ShowSettings()
    if not MothBane_SettingsFrame then CreateSettingsFrame() end
    if MothBane_SettingsFrame and MothBane_SettingsFrame.Show then
        if MothBane_SettingsFrame:IsShown() then MothBane_SettingsFrame:Hide()
        else MothBane_SettingsFrame:Show() end
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        loader:UnregisterEvent("PLAYER_ENTERING_WORLD")
        C_Timer.After(0.5, CreateMinimapButton)
    end
end)

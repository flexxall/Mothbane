-- MothBane: custom Glowing Moth minimap cues (shadow or moth). /mothbane, minimap button.
-- Set false for release build.
local ENABLE_DEBUG_UI = false

local TARGET = "Glowing Moth"

if not C_VignetteInfo or not C_VignetteInfo.GetVignettes or not C_VignetteInfo.GetVignetteInfo then
    return
end

if not MothBaneDB then MothBaneDB = {} end
if MothBaneDB.enabled == nil then MothBaneDB.enabled = true end
if MothBaneDB.debug == nil then MothBaneDB.debug = false end
if not MothBaneDB.width then MothBaneDB.width = 380 end
if not MothBaneDB.height then MothBaneDB.height = (ENABLE_DEBUG_UI and 300 or 240) end
-- coverStyle: dark | icon (shadow or moth)
if MothBaneDB.coverStyle == nil then MothBaneDB.coverStyle = "icon" end
if MothBaneDB.coverStyle == "none" or MothBaneDB.coverStyle == "image" then MothBaneDB.coverStyle = "icon" end
if MothBaneDB.showMinimapButton == nil then MothBaneDB.showMinimapButton = true end
if MothBaneDB.minimapAngle == nil then MothBaneDB.minimapAngle = 90 end
if MothBaneDB.coverScale == nil then MothBaneDB.coverScale = 1 end

local origGetVignettes = C_VignetteInfo.GetVignettes
local origGetInfo = C_VignetteInfo.GetVignetteInfo

local function isMothName(name)
    return name and (name == TARGET or strmatch(name, "Glowing Moth"))
end

local logLines = {}
local LOG_MAX = 50
local function LogToWindow(msg)
    if not msg or msg == "" then return end
    tinsert(logLines, strtrim(tostring(msg)))
    if #logLines > LOG_MAX then tremove(logLines, 1) end
    if MothBane_OutputEdit then
        MothBane_OutputEdit:SetText(table.concat(logLines, "\n"))
        MothBane_OutputEdit:SetCursorPosition(string.len(MothBane_OutputEdit:GetText()))
    end
end

local lastGetVignettesPrint = 0
local getVignettesPrintGap = 2

C_VignetteInfo.GetVignettes = function()
    local list = origGetVignettes()
    if not MothBaneDB.enabled then return list end
    if not list or #list == 0 then return list end
    local out = {}
    local filtered = 0
    for i = 1, #list do
        local id = list[i]
        local info = origGetInfo(id)
        if not info or not info.name or not isMothName(info.name) then
            tinsert(out, id)
        else
            filtered = filtered + 1
        end
    end
    if MothBaneDB.debug and filtered > 0 then
        local t = GetTime()
        if t - lastGetVignettesPrint >= getVignettesPrintGap then
            lastGetVignettesPrint = t
            LogToWindow("GetVignettes: filtered " .. filtered .. " Glowing Moth(s)")
        end
    end
    return out
end

C_VignetteInfo.GetVignetteInfo = function(id)
    local info = origGetInfo(id)
    if not MothBaneDB.enabled then return info end
    if info and isMothName(info.name) then
        if MothBaneDB.debug then
            LogToWindow("GetVignetteInfo: Glowing Moth (onMinimap=false)")
        end
        info.onMinimap = false
        info.atlasName = nil
    end
    return info
end

-- Draw overlays on moth vignette world positions on the minimap.
local coverPool = {}
local coverFrames = {}

local COVER_ATLAS_ICON = "VignetteLoot"
local MOTH_IMAGE_PATH = "Interface\\AddOns\\MothBane\\Art\\mothbane"
local COVER_SIZE_DEFAULT = 16
local COVER_SIZE_ICON = 24
local LERP_SPEED = 0.35
local MINIMAP_BORDER_INSET = 8

local function ApplyCoverAppearance(tex)
    if not tex then return end
    local style = MothBaneDB.coverStyle or "icon"
    if style == "icon" then
        tex:SetTexture(MOTH_IMAGE_PATH)
        tex:SetTexCoord(0, 1, 0, 1)
    else
        tex:SetColorTexture(0.22, 0.24, 0.18, 0.96)
    end
end

local function GetOrCreateCover()
    for i = 1, #coverFrames do
        local f = coverFrames[i]
        if not f.inUse then f.inUse = true; ApplyCoverAppearance(f.tex); return f end
    end
    local minimap = _G.Minimap
    if not minimap then return nil end
    local f = CreateFrame("Frame", nil, minimap)
    f:SetSize(16, 16)
    f:SetFrameStrata(minimap:GetFrameStrata())
    f:SetFrameLevel(minimap:GetFrameLevel() + 12)
    f:EnableMouse(false)
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    ApplyCoverAppearance(tex)
    f.tex = tex
    f.inUse = true
    tinsert(coverFrames, f)
    return f
end
local function ReleaseCover(frame)
    if not frame then return end
    frame.inUse = nil
    frame:Hide()
    frame.guid = nil
    frame.vx = nil
    frame.vy = nil
    frame.px = nil
    frame.py = nil
end

local function MapPositionToMinimapOffset(vx, vy, uiMapID)
    if not C_Map or not C_Map.GetPlayerMapPosition or not C_Map.GetMapWorldSize then return nil end
    local pos = C_Map.GetPlayerMapPosition(uiMapID, "player")
    if not pos then return nil end
    local px, py = pos.x, pos.y
    if not px or not py then return nil end
    local W, H = C_Map.GetMapWorldSize(uiMapID)
    if not W or not H or W <= 0 or H <= 0 then return nil end
    local dx = (vx - px) * W
    local dy = (vy - py) * H
    local R = (C_Minimap and C_Minimap.GetViewRadius and C_Minimap.GetViewRadius()) or 100
    if R <= 0 then return nil end
    if GetCVar("rotateMinimap") == "1" then
        local facing = GetPlayerFacing()
        if facing then
            local c, s = math.cos(facing), math.sin(facing)
            local dx2 = dx * c + dy * s
            local dy2 = -dx * s + dy * c
            dx, dy = dx2, dy2
        end
    end
    local offX = dx / R
    local offY = dy / R
    if offX * offX + offY * offY > 1 then return nil end
    local minimap = _G.Minimap
    if not minimap then return nil end
    local mw = minimap:GetWidth() or 200
    local mh = minimap:GetHeight() or 200
    return offX * (mw * 0.5), -offY * (mh * 0.5)
end

local function CoverShouldBeActive()
    local style = MothBaneDB.coverStyle or "icon"
    return MothBaneDB.enabled and (style == "dark" or style == "icon")
end

local function ClampToCircle(x, y, maxDist)
    if maxDist <= 0 then return 0, 0 end
    local dist = math.sqrt(x * x + y * y)
    if dist <= maxDist then return x, y end
    if dist < 1e-6 then return maxDist, 0 end
    local s = maxDist / dist
    return x * s, y * s
end

local function UpdateCoverPositions()
    if not next(coverPool) then return end
    local minimap = _G.Minimap
    if not minimap then return end
    local mw = minimap:GetWidth() or 200
    local mh = minimap:GetHeight() or 200
    local radius = math.min(mw, mh) * 0.5
    local uiMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if not uiMapID then return end
    local style = MothBaneDB.coverStyle or "icon"
    local scale = MothBaneDB.coverScale or 1
    local szBase = (style == "icon") and COVER_SIZE_ICON or COVER_SIZE_DEFAULT
    local sz = math.max(8, math.min(48, math.floor(szBase * scale)))
    local maxDist = math.max(0, radius - MINIMAP_BORDER_INSET - (sz * 0.5))
    for guid, f in pairs(coverPool) do
        if f.vx and f.vy then
            local mx, my = MapPositionToMinimapOffset(f.vx, f.vy, uiMapID)
            if mx and my then
                local dist = math.sqrt(mx * mx + my * my)
                if dist > maxDist then
                    f:Hide()
                else
                    if f.px == nil then f.px = mx; f.py = my end
                    f.px = f.px + (mx - f.px) * LERP_SPEED
                    f.py = f.py + (my - f.py) * LERP_SPEED
                    f.px, f.py = ClampToCircle(f.px, f.py, maxDist)
                    f:SetSize(sz, sz)
                    f:ClearAllPoints()
                    f:SetPoint("CENTER", Minimap, "CENTER", f.px, f.py)
                    f:Show()
                end
            else
                f:Hide()
            end
        end
    end
end

local function UpdateSpotCovers()
    if not CoverShouldBeActive() then
        for guid, f in pairs(coverPool) do
            ReleaseCover(f)
            coverPool[guid] = nil
        end
        return
    end
    local raw = origGetVignettes()
    local uiMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if not raw or not uiMapID then
        for guid, f in pairs(coverPool) do ReleaseCover(f); coverPool[guid] = nil end
        return
    end
    local seen = {}
    for i = 1, #raw do
        local guid = raw[i]
        local info = origGetInfo(guid)
        if info and isMothName(info.name) then
            seen[guid] = true
            local pos = C_VignetteInfo.GetVignettePosition(guid, uiMapID)
            if pos then
                local vx, vy
                if pos.GetXY then vx, vy = pos:GetXY() else vx, vy = pos.x, pos.y end
                if vx and vy then
                    local f = coverPool[guid] or GetOrCreateCover()
                    if f then
                        coverPool[guid] = f
                        f.guid = guid
                        f.vx = vx
                        f.vy = vy
                        f.px = nil
                        f.py = nil
                        ApplyCoverAppearance(f.tex)
                        f:Show()
                    end
                end
            end
        end
    end
    for guid, f in pairs(coverPool) do
        if not seen[guid] then
            ReleaseCover(f)
            coverPool[guid] = nil
        end
    end
    if next(coverPool) then UpdateCoverPositions() end
    if not next(coverPool) and coverListTicker then
        coverListTicker:Cancel()
        coverListTicker = nil
    end
end

local coverListTicker
local coverUpdateFrame
local function StartCoverUpdates()
    if coverUpdateFrame then return end
    coverUpdateFrame = CreateFrame("Frame")
    coverUpdateFrame:SetScript("OnUpdate", function()
        if not CoverShouldBeActive() or not next(coverPool) then return end
        UpdateCoverPositions()
    end)
    if not coverListTicker then
        coverListTicker = C_Timer.NewTicker(0.5, UpdateSpotCovers)
    end
end
local function StopCoverTicker()
    if coverListTicker then
        coverListTicker:Cancel()
        coverListTicker = nil
    end
    if coverUpdateFrame then
        coverUpdateFrame:SetScript("OnUpdate", nil)
        coverUpdateFrame = nil
    end
    for guid, f in pairs(coverPool) do ReleaseCover(f); coverPool[guid] = nil end
end

local coverEvents = CreateFrame("Frame")
coverEvents:RegisterEvent("VIGNETTES_UPDATED")
coverEvents:SetScript("OnEvent", function(_, event)
    if event == "VIGNETTES_UPDATED" then
        if CoverShouldBeActive() then
            UpdateSpotCovers()
            StartCoverUpdates()
        else
            StopCoverTicker()
        end
    end
end)
C_Timer.After(1, function()
    if CoverShouldBeActive() then
        UpdateSpotCovers()
        StartCoverUpdates()
    end
end)

-- Expose for UI
MothBane_EnableDebugUI = ENABLE_DEBUG_UI
MothBane_CoverShouldBeActive = CoverShouldBeActive
MothBane_UpdateSpotCovers = UpdateSpotCovers
MothBane_StartCoverUpdates = StartCoverUpdates
MothBane_StopCoverTicker = StopCoverTicker
MothBane_ApplyCoverAppearance = ApplyCoverAppearance
MothBane_CoverFrames = coverFrames
MothBane_LogToWindow = LogToWindow
MothBane_MOTH_IMAGE_PATH = MOTH_IMAGE_PATH

function MothBane_RunTest()
    local raw = origGetVignettes()
    local total = raw and #raw or 0
    local moths = 0
    if raw then
        for i = 1, #raw do
            local info = origGetInfo(raw[i])
            if info and isMothName(info.name) then moths = moths + 1 end
        end
    end
    local filtered = C_VignetteInfo.GetVignettes()
    local shown = filtered and #filtered or 0
    LogToWindow("--- Test ---")
    LogToWindow("Raw vignettes: " .. total .. "  |  Moths in list: " .. moths .. "  |  After filter: " .. shown)
    if moths > 0 and total > 0 then
        LogToWindow("Hooks work (we filter " .. moths .. " moth(s)).")
        LogToWindow("If the moth still shows on the minimap, the game is NOT using these APIs to draw it.")
    else
        LogToWindow("No Glowing Moth in vignette list right now (or not in range).")
    end
end

function MothBane_GetLogLines()
    return logLines
end

SLASH_MOTHBANE1 = "/mothbane"
SlashCmdList["MOTHBANE"] = function(msg)
    msg = strlower(strtrim(msg or ""))
    if msg == "debug" then
        if not ENABLE_DEBUG_UI then return end
        MothBaneDB.debug = not MothBaneDB.debug
        LogToWindow("Debug " .. (MothBaneDB.debug and "ON" or "OFF"))
        return
    end
    if msg == "on" or msg == "1" then MothBaneDB.enabled = true; LogToWindow("MothBane enabled"); return end
    if msg == "off" or msg == "0" then MothBaneDB.enabled = false; LogToWindow("MothBane disabled"); return end
    if MothBane_ShowSettings then MothBane_ShowSettings() end
end

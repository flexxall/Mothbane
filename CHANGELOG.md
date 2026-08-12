# Changelog

All notable changes to MothBane are documented here.

## [0.0.7] - 2026-08-11

### Fixed
- **Action Bar Taint Crash** — Removed global `C_VignetteInfo` API hooks that were corrupting `GameTooltip` state and triggering secret number comparison errors on action buttons (`Blizzard_SharedXML/LayoutFrame.lua`).
- **Settings Frame Initialization** — Removed an early return guard in `Settings.lua` that prevented the settings window and minimap button from initializing when loaded out of order.
- **Tooltip & API Deprecations** — Modernized `GetAddOnMetadata` calls to `C_AddOns.GetAddOnMetadata` and corrected `GameTooltip` anchoring parameters.

### Performance
- **Minimap Button Dragging** — Optimized cursor position tracking in `OnUpdate` to reduce global API calls during button movement.

## [0.0.6] - 2026-06-19

### Compatibility
- **WoW Retail 12.0.7** — TOC updated so the addon loads on the latest Midnight patch (Blizzard **Interface** ID **120007**).

## [0.0.5] - 2026-05-02

### Compatibility
- **WoW Retail 12.0.5** — TOC updated so the addon loads on that patch (Blizzard **Interface** ID **120005**).

### Changed
- README expanded for CurseForge/GitHub project overview (features, slash commands).

## [0.0.4] - 2025-03-04

### Added
- Settings panel with Enable, minimap button visibility, replace style (Shadow / Moth), and icon scale.
- Minimap button: left-click opens options, right-click drag to move.
- Slash commands: `/mothbane`, `/mothbane on|off`, `/mothbane debug` (dev build).
- Optional debug UI with log output and Test now (when enabled in build).

### Changed
- Shadow style uses a dark color swatch in the UI matching the minimap overlay.
- Dropdown shows current selection with icon/color preview.

### Fixed
- Output and panel padding respect frame backdrop insets.

---

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

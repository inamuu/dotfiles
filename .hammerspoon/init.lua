-- Hammerspoon window layout helpers (wide monitor friendly)
--
-- Requirements covered:
-- - Multiple size ratios (1:1, 2:1, 1:2, 1:1:1)
-- - Pattern-based relayout via hotkeys (user-editable)
-- - Menu bar always available (custom menu + Hammerspoon stays running)
-- - Launch apps if not running, then place windows when ready

hs.window.animationDuration = 0

local function log(fmt, ...)
  hs.printf("[tile] " .. fmt, ...)
end

-- Auto-start Hammerspoon at login.
-- (This sets/updates macOS Login Items for Hammerspoon.)
pcall(function()
  hs.autoLaunch(true)
end)

if not hs.accessibilityState() then
  hs.alert.show("Hammerspoon: アクセシビリティ権限が必要です")
  log("accessibilityState=false (window move/resize will not work)")
end

-- Bundle IDs are more stable than app names.
local APPS = {
  chrome  = { name = "Google Chrome", bundleIDs = { "com.google.Chrome" } },
  -- WezTerm bundleID may differ by build/channel; try common candidates.
  wezterm = { name = "WezTerm",       bundleIDs = { "com.github.wez.wezterm", "com.github.wez.wezterm-gui" } },
  slack   = { name = "Slack",         bundleIDs = { "com.tinyspeck.slackmacgap" } },
  obsidian = { name = "Obsidian",     bundleIDs = { "md.obsidian" } },
  finder  = { name = "Finder",        bundleIDs = { "com.apple.finder" } },
}

-- User config: edit these hotkeys freely.
-- Example: Ctrl+Cmd+Option+1 => pattern1
local HOTKEY_SPECS = {
  { mods = { "ctrl", "cmd", }, key = "1", pattern = "pattern1" },
  { mods = { "ctrl", "cmd", }, key = "2", pattern = "pattern2" },
  { mods = { "ctrl", "cmd", }, key = "3", pattern = "pattern3" },
  { mods = { "ctrl", "cmd", }, key = "4", pattern = "pattern4" },
  { mods = { "ctrl", "cmd", }, key = "5", pattern = "pattern5" },
  { mods = { "ctrl", "cmd", }, key = "6", pattern = "pattern6" },
  { mods = { "ctrl", "cmd", }, key = "7", pattern = "pattern7" },
  -- Utilities
  { mods = { "ctrl", "cmd", }, key = "r", pattern = "__reload__" },
}

-- Ctrl+Cmd+Option+Q: quit (almost) all apps.
-- Safety: requires double-press within this window.
local QUIT_ALL = {
  -- Note: Ctrl+Cmd+Q is macOS "Lock Screen" and may win even if bound here.
  hotkey = { mods = { "ctrl", "cmd", "alt" }, key = "q" },
  confirmSeconds = 1.5,
  excludedNames = {
    -- Helpers sometimes have different bundle IDs; name matching is a pragmatic fallback.
    "Raycast",
    "Homerow",
  },
  excludedBundleIDs = {
    "org.hammerspoon.Hammerspoon",
    "com.raycast.macos",
    "com.superultra.Homerow",
    "com.apple.loginwindow",
    "com.apple.NotificationCenter",
    "com.apple.controlcenter",
  },
  excludedBundleIDPrefixes = {
    -- Cover helper/background processes under the same identifier namespace.
    "com.raycast.macos",
    "com.superultra.Homerow",
  },
  excludeFinder = true,
}

-- Pattern definitions:
-- weights: column weights (e.g. {2,1} => 66%/34%)
-- apps: ordered list mapped to columns left->right
local PATTERNS = {
  pattern1 = { title = "2:1 Chrome + WezTerm", weights = { 2, 1 }, apps = { APPS.chrome, APPS.wezterm } },
  pattern2 = { title = "2:1 Chrome + Slack",   weights = { 2, 1 }, apps = { APPS.chrome, APPS.slack } },
  pattern3 = { title = "2:1 Chrome + WezTerm", weights = { 2, 1 }, apps = { APPS.chrome, APPS.wezterm } },
  pattern4 = { title = "1:1 Chrome + WezTerm", weights = { 1, 1 }, apps = { APPS.chrome, APPS.wezterm } },
  pattern5 = { title = "1:2 Chrome + WezTerm", weights = { 1, 2 }, apps = { APPS.chrome, APPS.wezterm } },
  pattern6 = { title = "1:1 WezTerm + Finder", weights = { 1, 1 }, apps = { APPS.wezterm, APPS.finder } },
  pattern7 = { title = "1:1:1 Chrome + WezTerm + Slack", weights = { 1, 1, 1 }, apps = { APPS.chrome, APPS.wezterm, APPS.slack } },
}

local function sum(tbl)
  local s = 0
  for _, v in ipairs(tbl) do s = s + v end
  return s
end

local function framesForWeights(screenFrame, weights)
  local total = sum(weights)
  local frames = {}

  local x = screenFrame.x
  local wRemaining = screenFrame.w

  for i, weight in ipairs(weights) do
    local w
    if i == #weights then
      w = wRemaining
    else
      w = math.floor(screenFrame.w * (weight / total))
      w = math.max(1, math.min(w, wRemaining))
    end
    table.insert(frames, hs.geometry.rect(x, screenFrame.y, w, screenFrame.h))
    x = x + w
    wRemaining = wRemaining - w
  end

  return frames
end

local function targetScreen()
  local win = hs.window.frontmostWindow()
  if win and win:screen() then return win:screen() end
  return hs.screen.primaryScreen()
end

local function launchOrFocus(app)
  if app.bundleIDs then
    for _, bid in ipairs(app.bundleIDs) do
      if hs.application.launchOrFocusByBundleID(bid) then return true end
    end
  end
  if app.name then
    return hs.application.launchOrFocus(app.name)
  end
  return false
end

local function appInstance(app)
  if app.bundleIDs then
    for _, bid in ipairs(app.bundleIDs) do
      local inst = hs.application.get(bid)
      if inst then return inst end
    end
  end
  if app.name then
    return hs.appfinder.appFromName(app.name)
  end
  return nil
end

local function firstStandardWindow(app)
  local inst = appInstance(app)
  if not inst then return nil end

  local wins = inst:allWindows()
  for _, w in ipairs(wins) do
    -- standardWindow covers typical user windows (excludes popovers, etc.)
    if w:isStandard() and w:isVisible() then
      return w
    end
  end
  -- Fall back to any standard window even if not visible.
  for _, w in ipairs(wins) do
    if w:isStandard() then return w end
  end
  return nil
end

local function ensureWindow(app, timeoutSeconds, onReady)
  launchOrFocus(app)

  local startAt = hs.timer.secondsSinceEpoch()
  local function tick()
    local w = firstStandardWindow(app)
    if w then
      onReady(w)
      return
    end
    if (hs.timer.secondsSinceEpoch() - startAt) >= timeoutSeconds then
      -- Give up quietly; menu/hotkey still completes for other apps.
      hs.alert.show("Window not found: " .. (app.name or "?"))
      log("timeout waiting window: %s", app.name or "?")
      return
    end
    hs.timer.doAfter(0.2, tick)
  end

  hs.timer.doAfter(0.1, tick)
end

local function placeWindow(win, screen, frame)
  if not win then return end

  -- Can't resize/move fullscreen windows; attempt to exit fullscreen first.
  local function apply()
    -- Move to target screen first to avoid wrong scaling on multi-monitor setups.
    win:moveToScreen(screen)
    win:setFrame(frame)
    win:raise()
  end

  if win:isMinimized() then
    win:unminimize()
  end

  if win:isFullScreen() then
    win:setFullScreen(false)
    hs.timer.doAfter(0.3, apply)
    return
  end

  apply()
end

local function applyPattern(patternKey)
  local p = PATTERNS[patternKey]
  if not p then
    hs.alert.show("Unknown pattern: " .. tostring(patternKey))
    return
  end

  local screen = targetScreen()
  local sf = screen:frame()
  local frames = framesForWeights(sf, p.weights)

  for i, app in ipairs(p.apps) do
    local frame = frames[i]
    if frame then
      ensureWindow(app, 8, function(win)
        placeWindow(win, screen, frame)
      end)
    end
  end

  hs.alert.show(p.title)
  log("applied pattern=%s title=%s", patternKey, p.title)
end

-- Menu bar (resident)
local menubar = hs.menubar.new()
if menubar then
  menubar:setTitle("Tile")
  local function menuItems()
    local items = {}
    table.insert(items, { title = "Reload Config", fn = hs.reload })
    table.insert(items, { title = "Open Console", fn = hs.openConsole })
    table.insert(items, { title = "-" })
    for key, p in pairs(PATTERNS) do
      table.insert(items, { title = key .. ": " .. p.title, fn = function() applyPattern(key) end })
    end
    return items
  end
  menubar:setMenu(menuItems)
end

-- Hotkeys
for _, spec in ipairs(HOTKEY_SPECS) do
  if spec.pattern == "__reload__" then
    hs.hotkey.bind(spec.mods, spec.key, function()
      hs.reload()
    end)
  else
    hs.hotkey.bind(spec.mods, spec.key, function()
      applyPattern(spec.pattern)
    end)
  end
end

-- Quit all apps hotkey
do
  local pending = false

  local function hasPrefix(s, prefix)
    return type(s) == "string" and type(prefix) == "string" and s:sub(1, #prefix) == prefix
  end

  local function nameMatches(app)
    local n = app:name()
    if not n or not QUIT_ALL.excludedNames then return false end
    for _, ex in ipairs(QUIT_ALL.excludedNames) do
      if n == ex then return true end
    end
    return false
  end

  local function isExcluded(bundleID)
    if not bundleID then return true end
    for _, bid in ipairs(QUIT_ALL.excludedBundleIDs) do
      if bid == bundleID then return true end
    end
    if QUIT_ALL.excludedBundleIDPrefixes then
      for _, pfx in ipairs(QUIT_ALL.excludedBundleIDPrefixes) do
        if hasPrefix(bundleID, pfx) then return true end
      end
    end
    if QUIT_ALL.excludeFinder and bundleID == "com.apple.finder" then return true end
    return false
  end

  local function quitAllNow()
    local killed = 0
    for _, app in ipairs(hs.application.runningApplications()) do
      local bid = app:bundleID()
      local excluded = isExcluded(bid) or nameMatches(app)
      log("quit-all: app=%s bundleID=%s excluded=%s", tostring(app:name()), tostring(bid), tostring(excluded))
      if not excluded then
        -- Graceful quit (same as Cmd+Q)
        app:kill()
        killed = killed + 1
      end
    end
    hs.alert.show(("Quit %d apps"):format(killed))
    log("quit-all executed: %d apps", killed)
  end

  hs.hotkey.bind(QUIT_ALL.hotkey.mods, QUIT_ALL.hotkey.key, function()
    if pending then
      pending = false
      quitAllNow()
      return
    end
    pending = true
    hs.alert.show(("Press again within %.1fs to quit all apps"):format(QUIT_ALL.confirmSeconds))
    hs.timer.doAfter(QUIT_ALL.confirmSeconds, function()
      pending = false
    end)
  end)
end

-- Helpful watcher: reload config automatically when this file changes.
hs.pathwatcher.new(hs.configdir, hs.reload):start()
hs.alert.show("Hammerspoon loaded")
log("loaded: configdir=%s", hs.configdir)

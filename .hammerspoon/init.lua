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
  wezterm  = { name = "WezTerm",  bundleIDs = { "com.github.wez.wezterm", "com.github.wez.wezterm-gui" } },
  slack    = { name = "Slack",    bundleIDs = { "com.tinyspeck.slackmacgap" } },
  obsidian = { name = "Obsidian", bundleIDs = { "md.obsidian" } },
  finder   = { name = "Finder",   bundleIDs = { "com.apple.finder" } },
  acta     = { name = "Acta",     bundleIDs = { "com.inamuu.acta" } },
}

-- User config: edit these hotkeys freely.
-- Example: Ctrl+Cmd+; => layout modal
local HOTKEY_SPECS = {
  -- Layout modal (prefix key)
  { mods = { "ctrl", "cmd", }, key = ";", pattern = "__layout_modal__" },
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
local RATIO_VARIANTS_2 = {
  { id = "11", title = "1:1", weights = { 1, 1 } },
  { id = "21", title = "2:1", weights = { 2, 1 } },
  { id = "12", title = "1:2", weights = { 1, 2 } },
}

local APP_CODEBOOK = {
  c = { title = "Chrome", app = APPS.chrome },
  w = { title = "WezTerm", app = APPS.wezterm },
  s = { title = "Slack", app = APPS.slack },
  o = { title = "Obsidian", app = APPS.obsidian },
  f = { title = "Finder", app = APPS.finder },
  a = { title = "Acta", app = APPS.acta },
}

-- Code order used to generate sets/patterns.
local APP_CODE_ORDER = { "c", "w", "s", "o", "f", "a" }

local function appSetTitle(codes)
  local parts = {}
  for _, code in ipairs(codes) do
    local e = APP_CODEBOOK[code]
    table.insert(parts, e and e.title or "?")
  end
  return table.concat(parts, " + ")
end

local APP_SETS = {}
do
  local codes = APP_CODE_ORDER

  -- 2-app permutations (order matters: left->right)
  for _, a in ipairs(codes) do
    for _, b in ipairs(codes) do
      if a ~= b then
        local key = a .. b
        APP_SETS[key] = {
          title = appSetTitle({ a, b }),
          apps = { APP_CODEBOOK[a].app, APP_CODEBOOK[b].app },
          codes = { a, b },
        }
      end
    end
  end

  -- 3-app permutations (order matters: left->right)
  for _, a in ipairs(codes) do
    for _, b in ipairs(codes) do
      if a ~= b then
        for _, c in ipairs(codes) do
          if c ~= a and c ~= b then
            local key = a .. b .. c
            APP_SETS[key] = {
              title = appSetTitle({ a, b, c }),
              apps = { APP_CODEBOOK[a].app, APP_CODEBOOK[b].app, APP_CODEBOOK[c].app },
              codes = { a, b, c },
            }
          end
        end
      end
    end
  end
end

local function patternKey(setKey, ratioID)
  return ("%s_%s"):format(setKey, ratioID)
end

local PATTERNS = {}
do
  -- 2-app sets: 1:1 / 2:1 / 1:2
  for setKey, set in pairs(APP_SETS) do
    if #set.apps == 2 then
      for _, v in ipairs(RATIO_VARIANTS_2) do
        local key = patternKey(setKey, v.id)
        PATTERNS[key] = {
          title = ("%s %s"):format(v.title, set.title),
          weights = v.weights,
          apps = set.apps,
        }
      end
    end
  end

  -- 3-app sets: 1:1:1
  for setKey, set in pairs(APP_SETS) do
    if #set.apps == 3 then
      PATTERNS[patternKey(setKey, "111")] = {
        title = ("1:1:1 %s"):format(set.title),
        weights = { 1, 1, 1 },
        apps = set.apps,
      }
    end
  end
end

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

-- Layout modal
--
-- Rationale: patterns quickly exceed what Ctrl+Cmd+1..9 can cover.
-- Use a 3-stroke flow: Prefix -> choose apps (2-3 keys) -> choose ratio.
local function buildLayoutModal()
  local modal = hs.hotkey.modal.new()
  local state = { setKey = nil, picked = {} }
  local helpAlertSeconds = 12
  local statusAlertSeconds = 2.0
  local lastAlertID = nil

  local function closeModalAlert()
    if lastAlertID then
      hs.alert.closeSpecific(lastAlertID)
      lastAlertID = nil
    end
  end

  local function showModalAlert(text, seconds)
    -- Avoid stale overlays hanging around after selections.
    closeModalAlert()
    lastAlertID = hs.alert.show(text, hs.alert.defaultStyle, targetScreen(), seconds)
  end

  local function helpText()
    return table.concat({
      "HammerSpoon",
      "----------------------",
      "Apps: Chrome=c WezTerm=w Slack=s Acta=a o=Obsidian f=Finder",
      "Ratio: 1:1=1   2:1=2   1:2=3 (3 apps is only 1)",
      "Cancel: Esc",
    }, "\n")
  end

  function modal:entered()
    state.setKey = nil
    state.picked = {}
    showModalAlert(helpText(), helpAlertSeconds)
  end

  function modal:exited()
    closeModalAlert()
  end

  modal:bind({}, "escape", function() modal:exit() end)

  modal:bind({}, "delete", function()
    state.setKey = nil
    state.picked = {}
    showModalAlert(helpText(), helpAlertSeconds)
  end)
  modal:bind({}, "forwarddelete", function()
    state.setKey = nil
    state.picked = {}
    showModalAlert(helpText(), helpAlertSeconds)
  end)

  local function pickApp(code)
    return function()
      if not APP_CODEBOOK[code] then return end

      for _, c in ipairs(state.picked) do
        if c == code then
          showModalAlert("Tile: 同じアプリは複数選べません", statusAlertSeconds)
          return
        end
      end

      table.insert(state.picked, code)
      if #state.picked > 3 then
        state.picked = { code }
      end

      local key = table.concat(state.picked, "")
      local set = APP_SETS[key]
      if set and (#state.picked == 2 or #state.picked == 3) then
        state.setKey = key
        showModalAlert(("Tile: set=%s  ratio(1/2/3)"):format(set.title), statusAlertSeconds)
        return
      end

      state.setKey = nil
      showModalAlert(("Tile: pick=%s"):format(appSetTitle(state.picked)), statusAlertSeconds)
    end
  end

  for code, _ in pairs(APP_CODEBOOK) do
    modal:bind({}, code, pickApp(code))
  end

  local function applyRatio(ratioID)
    return function()
      if not state.setKey then
        showModalAlert("Tile: まずアプリを2つ(または3つ)選択してください (c/w/s/o/f)", statusAlertSeconds)
        return
      end

      local set = APP_SETS[state.setKey]
      if set and #set.apps == 3 and ratioID ~= "111" then
        showModalAlert("Tile: 3アプリは 1 のみ対応です", statusAlertSeconds)
        return
      end

      closeModalAlert()
      applyPattern(patternKey(state.setKey, ratioID))
      modal:exit()
    end
  end

  modal:bind({}, "1", function()
    local set = state.setKey and APP_SETS[state.setKey] or nil
    if set and #set.apps == 3 then
      applyRatio("111")()
      return
    end
    applyRatio("11")()
  end)
  modal:bind({}, "2", applyRatio("21"))
  modal:bind({}, "3", applyRatio("12"))

  return modal
end

local LAYOUT_MODAL = buildLayoutModal()

-- Menu bar (resident)
local menubar = hs.menubar.new()
if menubar then
  menubar:setTitle("Tile")
  local function menuItems()
    local items = {}
    table.insert(items, { title = "Reload Config", fn = hs.reload })
    table.insert(items, { title = "Open Console", fn = hs.openConsole })
    table.insert(items, { title = "-" })
    local keys = {}
    for key, _ in pairs(PATTERNS) do table.insert(keys, key) end
    table.sort(keys)
    for _, key in ipairs(keys) do
      local p = PATTERNS[key]
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
  elseif spec.pattern == "__layout_modal__" then
    hs.hotkey.bind(spec.mods, spec.key, function()
      LAYOUT_MODAL:enter()
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

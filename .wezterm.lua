
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()



local config = {

  -- Font
  font = wezterm.font {
    family = 'UDEV Gothic 35', weight = 'Bold',
    -- family = 'Hack Nerd Font Mono', weight = 'Bold',
  },
  font_size = 16.0,

  -- ime
  use_ime = true,

  -- Color Scheme: https://wezfurlong.org/wezterm/colorschemes/index.html
  -- color_scheme = 'Dracula (Official)',
  -- color_scheme = 'darkmoss (base16)',
  color_scheme = 'Dracula (Gogh)',

  -- KeyBindings
  leader = { key = 'o', mods = 'CTRL', timeout_milliseconds = 2000 },

  -- Split pane
  keys = {
    { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal },
    { key = '-', mods = 'LEADER', action = wezterm.action.SplitVertical },
    -- Enable copy mode
    { key = 'v', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
    -- Move pane
    { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
    { key = '1', mods = 'LEADER', action = wezterm.action.ActivatePaneByIndex(0) },
    { key = '2', mods = 'LEADER', action = wezterm.action.ActivatePaneByIndex(1) },
    { key = '3', mods = 'LEADER', action = wezterm.action.ActivatePaneByIndex(2) },
    { key = '4', mods = 'LEADER', action = wezterm.action.ActivatePaneByIndex(3) },
    { key = '5', mods = 'LEADER', action = wezterm.action.ActivatePaneByIndex(4) },
    { key = '6', mods = 'LEADER', action = wezterm.action.ActivatePaneByIndex(5) },
    { key = '7', mods = 'LEADER', action = wezterm.action.ActivatePaneByIndex(6) },
    { key = '8', mods = 'LEADER', action = wezterm.action.ActivatePaneByIndex(7) },
    -- Others
    { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\n') },

    -- MultiPane
    {
      key = 'q',
      mods = 'LEADER',
      action = wezterm.action.Multiple {
        wezterm.action.SplitPane { direction = 'Up', size = { Percent = 50 } },
        wezterm.action.SplitPane { direction = 'Down', size = { Percent = 50 } },
      },
    },
  },

  -- SearchMode
  key_tables = {
    search_mode = {
      { key = 'Enter',     mods = 'NONE', action = wezterm.action.CopyMode 'PriorMatch' },
      {
        key = 'Escape',
        mods = 'NONE',
        action = wezterm.action.Multiple {
          wezterm.action.CopyMode 'ClearPattern',
          wezterm.action.CopyMode 'Close',
        }
      },
      { key = 'n',         mods = 'CTRL', action = wezterm.action.CopyMode 'NextMatch' },
      { key = 'p',         mods = 'CTRL', action = wezterm.action.CopyMode 'PriorMatch' },
      { key = 'r',         mods = 'CTRL', action = wezterm.action.CopyMode 'CycleMatchType' },
      { key = 'u',         mods = 'CTRL', action = wezterm.action.CopyMode 'ClearPattern' },
      { key = 'PageUp',    mods = 'NONE', action = wezterm.action.CopyMode 'PriorMatchPage' },
      { key = 'PageDown',  mods = 'NONE', action = wezterm.action.CopyMode 'NextMatchPage' },
      { key = 'UpArrow',   mods = 'NONE', action = wezterm.action.CopyMode 'PriorMatch' },
      { key = 'DownArrow', mods = 'NONE', action = wezterm.action.CopyMode 'NextMatch' },
    }
  },

  -- Window
  window_background_opacity = 0.90,

  -- Scroll
  enable_scroll_bar = true,

  -- Copy
  scrollback_lines = 10000,
}

-- and finally, return the configuration to wezterm
return config

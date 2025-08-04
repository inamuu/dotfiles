
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

local act = wezterm.action


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
    { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal },
    { key = '-', mods = 'LEADER', action = act.SplitVertical },
    -- Enable copy mode
    { key = 'v', mods = 'LEADER', action = act.ActivateCopyMode },
    -- Move pane
    { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
    { key = '1', mods = 'LEADER', action = act.ActivatePaneByIndex(0) },
    { key = '2', mods = 'LEADER', action = act.ActivatePaneByIndex(1) },
    { key = '3', mods = 'LEADER', action = act.ActivatePaneByIndex(2) },
    { key = '4', mods = 'LEADER', action = act.ActivatePaneByIndex(3) },
    { key = '5', mods = 'LEADER', action = act.ActivatePaneByIndex(4) },
    { key = '6', mods = 'LEADER', action = act.ActivatePaneByIndex(5) },
    { key = '7', mods = 'LEADER', action = act.ActivatePaneByIndex(6) },
    { key = '8', mods = 'LEADER', action = act.ActivatePaneByIndex(7) },
    -- Others
    { key = 'Enter', mods = 'SHIFT', action = act.SendString('\n') },

    -- MultiPane: #TODO
    {
      key = 'q',
      mods = 'LEADER',
      action = act.Multiple {
        act.SplitPane { direction = 'Down', size = { Percent = 50 } },
        act.SplitPane { direction = 'Down', size = { Percent = 50 } },
      },
    },
  },

  -- SearchMode
  key_tables = {
    search_mode = {
      { key = 'Enter',     mods = 'NONE', action = act.CopyMode 'PriorMatch' },
      {
        key = 'Escape',
        mods = 'NONE',
        action = act.Multiple {
          act.CopyMode 'ClearPattern',
          act.CopyMode 'Close',
        }
      },
      { key = 'n',         mods = 'CTRL', action = act.CopyMode 'NextMatch' },
      { key = 'p',         mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
      { key = 'r',         mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
      { key = 'u',         mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
      { key = 'PageUp',    mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
      { key = 'PageDown',  mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
      { key = 'UpArrow',   mods = 'NONE', action = act.CopyMode 'PriorMatch' },
      { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
    }
  },

  -- Window
  window_background_opacity = 0.90,

  -- Scroll
  enable_scroll_bar = true,

  -- Copy
  scrollback_lines = 30000,
}

-- and finally, return the configuration to wezterm
return config


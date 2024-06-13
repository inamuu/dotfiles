
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()



local config = {

  -- Font
  font = wezterm.font {
    family = 'Hack Nerd Font Mono', weight = 'Bold',
  },
  font_size = 16.0,

  -- Color Scheme: https://wezfurlong.org/wezterm/colorschemes/index.html
  -- color_scheme = 'Dracula (Official)',
  -- color_scheme = 'Dracula+',
  color_scheme = 'Dracula (Gogh)',
  -- color_scheme = 'darkmoss (base16)',
  -- color_scheme = 'SeaShells',

  -- KeyBindings
  leader = { key = 'o', mods = 'CTRL', timeout_milliseconds = 2000 },
  keys = {
    {
      key = '|',
      mods = 'LEADER|SHIFT',
      action = wezterm.action.SplitPane {
        direction = 'Right',
        size = { Percent = 50 },
      },
    },
    {
      key = '-',
      mods = 'LEADER',
      action = wezterm.action.SplitPane {
        direction = 'Down',
        size = { Percent = 50 },
      },
    },
    { key = 'v', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
    { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
  },

  -- Window
  window_background_opacity = 0.90
}

-- and finally, return the configuration to wezterm
return config

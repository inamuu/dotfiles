
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

  -- Color Scheme
  -- color_scheme = 'Dracula (Official)',
  -- color_scheme = 'Dracula+',
  color_scheme = 'Dracula (Gogh)',
  -- color_scheme = 'darkmoss (base16)',
  -- color_scheme = 'SeaShells',

  -- Window
  keys = {
    {
      key = '|',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitPane {
        direction = 'Right',
        size = { Percent = 50 },
      },
    },
  {
      key = '%',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.SplitPane {
        direction = 'Down',
        size = { Percent = 50 },
      },
    }
  }
}

-- and finally, return the configuration to wezterm
return config


-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

local config = {
  font = wezterm.font { 
    family = 'Hack Nerd Font Mono', weight = 'Bold',
  },
  font_size = 16.0,

-- Color Scheme
-- For example, changing the color scheme:
-- color_scheme = 'Darcula (base16)'
color_scheme = 'Dracula (Official)'
-- color_scheme = 'darkmoss (base16)'
-- color_scheme = 'duskfox'

}

-- and finally, return the configuration to wezterm
return config

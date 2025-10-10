
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

    -- Workspace: https://wezterm.org/config/lua/keyassignment/SwitchToWorkspace.html
    { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' , title = "Select workspace" },},
    {
      key = 'c',
      mods = 'LEADER',
      action = act.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = 'Bold' } },
          { Foreground = { AnsiColor = 'Fuchsia' } },
          { Text = 'Enter name for new workspace' },
        },
        action = wezterm.action_callback(function(window, pane, line)
          -- line will be `nil` if they hit escape without entering anything
          -- An empty string if they just hit enter
          -- Or the actual line of text they wrote
          if line then
            window:perform_action(
              act.SwitchToWorkspace {
                name = line,
              },
              pane
            )
          end
        end),
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

-- Set window title to workspace name
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local workspace = wezterm.mux.get_active_workspace()
  return workspace
end)

-- Change color scheme based on workspace
wezterm.on('update-status', function(window, pane)
  local workspace = window:active_workspace()
  local overrides = window:get_config_overrides() or {}

  -- defaultワークスペースはDraculaのまま
  if workspace == 'default' then
    overrides.color_scheme = 'Dracula (Gogh)'
  else
    -- ワークスペース名のハッシュ値で色を決定
    local hash = 0
    for i = 1, #workspace do
      hash = hash + string.byte(workspace, i)
    end

    local color_schemes = {
      'Tokyo Night',
      'Gruvbox Dark (Gogh)',
      'Monokai (dark) (terminal.sexy)',
      'Night Owl (Gogh)',
    }

    local scheme_index = (hash % #color_schemes) + 1
    overrides.color_scheme = color_schemes[scheme_index]
  end

  window:set_config_overrides(overrides)
end)

-- and finally, return the configuration to wezterm
return config


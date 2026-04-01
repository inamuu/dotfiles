-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

local act = wezterm.action
local palette = {
	shadow = "#05030B",
	bg = "#09061A",
	bg_alt = "#140B24",
	chrome = "#1B1030",
	chrome_dim = "#11081D",
	panel = "#23133D",
	panel_alt = "#322053",
	violet = "#8A5CFF",
	hot_pink = "#FF4FA3",
	cyan = "#22D3EE",
	gold = "#FFD166",
	orange = "#FF8A00",
	lime = "#A7F432",
	fg = "#F9F4FF",
	fg_muted = "#D9CFF0",
	fg_dim = "#9A8DB8",
	selection = "#45306C",
}

local function active_tab_if_single_pane(window, message)
	local mux_window = window:mux_window()
	if not mux_window then
		return nil
	end

	local tab = mux_window:active_tab()
	if not tab then
		return nil
	end

	local panes = tab:panes_with_info()
	if #panes ~= 1 then
		window:toast_notification("WezTerm", message, nil, 3000)
		return nil
	end

	return tab
end

local function apply_single_pane_layout(window, pane, message, layout)
	if not active_tab_if_single_pane(window, message) then
		return
	end

	layout(pane)
end

local function split_left_main(window, pane)
	apply_single_pane_layout(
		window,
		pane,
		"Leader+1 は単一ペインのタブでのみ左右 70:30 分割します",
		function(target)
			target:split({ direction = "Right", size = 0.3 })
		end
	)
end

local function split_right_main(window, pane)
	apply_single_pane_layout(
		window,
		pane,
		"Leader+2 は単一ペインのタブでのみ左右 30:70 分割します",
		function(target)
			target:split({ direction = "Right", size = 0.7 })
		end
	)
end

local function split_into_three(window, pane)
	apply_single_pane_layout(
		window,
		pane,
		"Leader+3 は単一ペインのタブでのみ左 1 + 右上下 2 の 3 分割をします",
		function(target)
			local right = target:split({ direction = "Right", size = 0.5 })
			right:split({ direction = "Bottom", size = 0.5 })
		end
	)
end

local function split_into_four(window, pane)
	apply_single_pane_layout(
		window,
		pane,
		"Leader+4 は単一ペインのタブでのみ 2x2 分割します",
		function(target)
			local right = target:split({ direction = "Right", size = 0.5 })
			target:split({ direction = "Bottom", size = 0.5 })
			right:split({ direction = "Bottom", size = 0.5 })
		end
	)
end

local function split_top_main(window, pane)
	apply_single_pane_layout(
		window,
		pane,
		"Leader+5 は単一ペインのタブでのみ上下 70:30 分割します",
		function(target)
			target:split({ direction = "Bottom", size = 0.3 })
		end
	)
end

local function split_bottom_main(window, pane)
	apply_single_pane_layout(
		window,
		pane,
		"Leader+6 は単一ペインのタブでのみ上下 30:70 分割します",
		function(target)
			target:split({ direction = "Bottom", size = 0.7 })
		end
	)
end

local function split_into_three_columns(window, pane)
	apply_single_pane_layout(
		window,
		pane,
		"Leader+7 は単一ペインのタブでのみ縦 3 分割します",
		function(target)
			target:split({ direction = "Right", size = 1 / 3 })
			target:split({ direction = "Right", size = 0.5 })
		end
	)
end

local function split_into_three_rows(window, pane)
	apply_single_pane_layout(
		window,
		pane,
		"Leader+8 は単一ペインのタブでのみ横 3 分割します",
		function(target)
			target:split({ direction = "Bottom", size = 1 / 3 })
			target:split({ direction = "Bottom", size = 0.5 })
		end
	)
end

local function split_left_main_with_right_stack(window, pane)
	apply_single_pane_layout(
		window,
		pane,
		"Leader+9 は単一ペインのタブでのみ左大 + 右上下の 3 分割をします",
		function(target)
			local right = target:split({ direction = "Right", size = 1 / 3 })
			right:split({ direction = "Bottom", size = 0.5 })
		end
	)
end

local function split_top_main_with_bottom_columns(window, pane)
	apply_single_pane_layout(
		window,
		pane,
		"Leader+0 は単一ペインのタブでのみ上大 + 下左右の 3 分割をします",
		function(target)
			local bottom = target:split({ direction = "Bottom", size = 1 / 3 })
			bottom:split({ direction = "Right", size = 0.5 })
		end
	)
end

local function flash_copy_status(window, pane)
	window:set_right_status("📋 Copied!")
	wezterm.time.call_after(3, function()
		window:emit("update-status", window, pane)
	end)
end

local function show_mode_toast(window, title, message, timeout)
	window:toast_notification("WezTerm", title .. ": " .. message, nil, timeout or 2500)
end

local function enter_copy_mode(window, pane)
	show_mode_toast(window, "COPY", "selection mode", 1800)
	window:perform_action(act.ActivateCopyMode, pane)
end

local function enter_quick_select(window, pane)
	show_mode_toast(window, "SELECT", "quick select mode", 1800)
	window:perform_action(act.QuickSelect, pane)
end

local function copy_previous_command_and_output(window, pane)
	window:perform_action(act.ActivateCopyMode, pane)
	window:perform_action(act.CopyMode({ MoveBackwardZoneOfType = "Input" }), pane)
	window:perform_action(act.CopyMode({ SetSelectionMode = "Cell" }), pane)
	window:perform_action(act.CopyMode({ MoveForwardZoneOfType = "Prompt" }), pane)
	window:perform_action(act.CopyMode("MoveUp"), pane)
	window:perform_action(act.CopyMode("MoveToEndOfLineContent"), pane)

	-- Let copy mode commit the selection before copying it to the clipboard.
	wezterm.time.call_after(0.05, function()
		window:perform_action(
			act.Multiple({
				{ CopyTo = "ClipboardAndPrimarySelection" },
				{ CopyMode = "Close" },
				{ ScrollToBottom = {} },
			}),
			pane
		)
		flash_copy_status(window, pane)
	end)
end

local function toggle_zoom_with_notice(window, pane)
	window:perform_action(act.TogglePaneZoomState, pane)
	wezterm.time.call_after(0.05, function()
		local message = "pane restored"
		local mux_window = window:mux_window()
		if mux_window then
			local active_tab = mux_window:active_tab()
			if active_tab then
				for _, pane_info in ipairs(active_tab:panes_with_info()) do
					if pane_info.pane:pane_id() == pane:pane_id() then
						if pane_info.is_zoomed then
							message = "pane maximized"
						end
						break
					end
				end
			end
		end
		show_mode_toast(window, "ZOOM", message, 2200)
	end)
end

local function enter_resize_mode(window, pane)
	show_mode_toast(window, "RESIZE", "hjkl to resize", 1800)
	window:perform_action(
		act.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
			timeout_milliseconds = 2000,
			until_unknown = true,
		}),
		pane
	)
end

local function push_status_segment(segments, bg, fg, text)
	table.insert(segments, { Background = { Color = bg } })
	table.insert(segments, { Foreground = { Color = fg } })
	table.insert(segments, { Attribute = { Intensity = "Bold" } })
	table.insert(segments, { Text = text })
end

local config = {
	-- auto reloadd
	automatically_reload_config = true,

	-- Font
	font = wezterm.font({
		family = "UDEV Gothic 35",
		-- family = 'UDEV Gothic 35', weight = 'Bold',
		-- family = 'Hack Nerd Font Mono', weight = 'Bold',
	}),
	font_size = 16.5,
	line_height = 1.06,
	pane_select_font_size = 56,
	command_palette_bg_color = "#170C29",
	command_palette_fg_color = palette.fg,
	command_palette_font_size = 19.0,
	command_palette_rows = 16,

	-- ime
	use_ime = true,

	-- Allow terminal apps such as Neovim to receive Cmd/Super modified keys.
	enable_kitty_keyboard = true,

	-- Cursor
	default_cursor_style = "BlinkingBar",
	cursor_blink_rate = 450,

	-- Color Scheme: https://wezfurlong.org/wezterm/colorschemes/index.html
	color_scheme = "Night Owl (Gogh)",

	colors = {
		foreground = palette.fg,
		background = palette.shadow,
		cursor_bg = palette.gold,
		cursor_fg = palette.shadow,
		cursor_border = palette.cyan,
		selection_bg = palette.selection,
		selection_fg = palette.fg,
		scrollbar_thumb = palette.violet,
		compose_cursor = palette.orange,
		split = palette.hot_pink,
		tab_bar = {
			background = palette.chrome_dim,
			active_tab = {
				bg_color = palette.hot_pink,
				fg_color = palette.shadow,
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = palette.panel,
				fg_color = palette.fg_dim,
			},
			inactive_tab_hover = {
				bg_color = palette.panel_alt,
				fg_color = palette.fg,
			},
			new_tab = {
				bg_color = palette.chrome_dim,
				fg_color = palette.cyan,
			},
			new_tab_hover = {
				bg_color = palette.panel_alt,
				fg_color = palette.gold,
				italic = true,
			},
		},
	},

	-- KeyBindings
	leader = { key = "o", mods = "CTRL", timeout_milliseconds = 2000 },

	-- Split pane
	keys = {
		{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal },
		{ key = "-", mods = "LEADER", action = act.SplitVertical },

		-- Show pane labels overlay (press Leader then "o")
		-- Note: WezTerm cannot trigger an action on "leader press only"; it always needs the next key.
		-- PaneSelect exits automatically when you type the label; expanding the alphabet reduces cases
		-- where you need to type 2 characters (and the overlay appears to "stick").
		{
			key = "o",
			mods = "LEADER",
			action = act.PaneSelect({
				alphabet = "1234567890",
				mode = "Activate",
				show_pane_ids = false,
			}),
		},

		-- Enable copy mode
		{ key = "v", mods = "LEADER", action = wezterm.action_callback(enter_copy_mode) },
		-- Resize pane directly, then keep resizing with h/j/k/l
		{ key = "h", mods = "LEADER", action = act.Multiple({ act.AdjustPaneSize({ "Left", 5 }), act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 2000, until_unknown = true }) }) },
		{ key = "j", mods = "LEADER", action = act.Multiple({ act.AdjustPaneSize({ "Down", 5 }), act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 2000, until_unknown = true }) }) },
		{ key = "k", mods = "LEADER", action = act.Multiple({ act.AdjustPaneSize({ "Up", 5 }), act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 2000, until_unknown = true }) }) },
		{ key = "l", mods = "LEADER", action = act.Multiple({ act.AdjustPaneSize({ "Right", 5 }), act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 2000, until_unknown = true }) }) },
		-- Move pane
		{ key = "H", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
		{ key = "J", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
		{ key = "K", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
		{ key = "L", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
		-- Resize mode
		{
			key = "r",
			mods = "LEADER",
			action = wezterm.action_callback(enter_resize_mode),
		},
		-- Layout presets
		{ key = "1", mods = "LEADER", action = wezterm.action_callback(split_left_main) },
		{ key = "2", mods = "LEADER", action = wezterm.action_callback(split_right_main) },
		{ key = "3", mods = "LEADER", action = wezterm.action_callback(split_into_three) },
		{ key = "4", mods = "LEADER", action = wezterm.action_callback(split_into_four) },
		{ key = "5", mods = "LEADER", action = wezterm.action_callback(split_top_main) },
		{ key = "6", mods = "LEADER", action = wezterm.action_callback(split_bottom_main) },
		{ key = "7", mods = "LEADER", action = wezterm.action_callback(split_into_three_columns) },
		{ key = "8", mods = "LEADER", action = wezterm.action_callback(split_into_three_rows) },
		{ key = "9", mods = "LEADER", action = wezterm.action_callback(split_left_main_with_right_stack) },
		{ key = "0", mods = "LEADER", action = wezterm.action_callback(split_top_main_with_bottom_columns) },
		-- Pane zoom
		{ key = "z", mods = "LEADER", action = wezterm.action_callback(toggle_zoom_with_notice) },
		-- Current pane close
		{ key = "w", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
		-- Quick select mode
		{ key = "Space", mods = "LEADER", action = wezterm.action_callback(enter_quick_select) },
		-- Others
		{ key = "Enter", mods = "SHIFT", action = act.SendString("\n") },

		-- Workspace: 選択と作成を統合（モダンデザイン）
		{
			key = "s",
			mods = "LEADER",
			action = wezterm.action_callback(function(window, pane)
				local mux = wezterm.mux
				local workspaces = mux.get_workspace_names()
				local current_workspace = window:active_workspace()

				if #workspaces > 0 then
					-- 既存のworkspaceがある場合：fuzzy選択 + 新規作成オプション
					local choices = {}

					-- Workspace一覧を作成
					for idx, name in ipairs(workspaces) do
						local is_current = (name == current_workspace)
						local icon = is_current and "●" or "○"
						local status = is_current and " (current)" or ""

						table.insert(choices, {
							id = name,
							label = wezterm.format({
								{ Foreground = { Color = "#8BE9FD" } }, -- Cyan
								{ Text = icon .. " " },
								{ Foreground = { Color = "#F8F8F2" } }, -- White
								{ Attribute = { Intensity = is_current and "Bold" or "Normal" } },
								{ Text = name },
								{ Foreground = { Color = "#6272A4" } }, -- Comment gray
								{ Attribute = { Intensity = "Normal" } },
								{ Text = status },
							}),
						})
					end

					-- セパレーター
					table.insert(choices, {
						id = "__separator__",
						label = wezterm.format({
							{ Foreground = { Color = "#44475A" } },
							{
								Text = "─────────────────────────────────",
							},
						}),
					})

					-- 新規作成オプション
					table.insert(choices, {
						id = "__new__",
						label = wezterm.format({
							{ Foreground = { Color = "#50FA7B" } }, -- Green
							{ Text = "✨ " },
							{ Foreground = { Color = "#F8F8F2" } },
							{ Attribute = { Intensity = "Bold" } },
							{ Text = "Create New Workspace" },
						}),
					})

					window:perform_action(
						act.InputSelector({
							title = wezterm.format({
								{ Foreground = { Color = "#BD93F9" } }, -- Purple
								{ Attribute = { Intensity = "Bold" } },
								{ Text = "  Workspaces " },
								{ Foreground = { Color = "#6272A4" } },
								{ Attribute = { Intensity = "Normal" } },
								{ Text = " (" .. #workspaces .. " active)" },
							}),
							choices = choices,
							fuzzy = true,
							fuzzy_description = wezterm.format({
								{ Foreground = { Color = "#6272A4" } },
								{ Text = "Type to filter • ↑↓ Navigate • Enter Select • Esc Cancel" },
							}),
							action = wezterm.action_callback(function(win, p, id, label)
								if not id then
									return
								end
								if id == "__new__" then
									-- 新規作成モード
									win:perform_action(
										act.PromptInputLine({
											description = wezterm.format({
												{ Foreground = { Color = "#50FA7B" } },
												{ Text = "✨ " },
												{ Foreground = { Color = "#BD93F9" } },
												{ Attribute = { Intensity = "Bold" } },
												{ Text = "New Workspace Name" },
												{ Foreground = { Color = "#6272A4" } },
												{ Attribute = { Intensity = "Normal" } },
												{ Text = "  │  Enter a unique name" },
											}),
											action = wezterm.action_callback(function(w, pa, line)
												if line and line ~= "" then
													w:perform_action(act.SwitchToWorkspace({ name = line }), pa)
												end
											end),
										}),
										p
									)
								elseif id ~= "__separator__" then
									-- 既存workspaceを選択
									win:perform_action(act.SwitchToWorkspace({ name = id }), p)
								end
							end),
						}),
						pane
					)
				else
					-- 既存workspaceがない場合：直接作成
					window:perform_action(
						act.PromptInputLine({
							description = wezterm.format({
								{ Foreground = { Color = "#50FA7B" } },
								{ Text = "✨ " },
								{ Foreground = { Color = "#BD93F9" } },
								{ Attribute = { Intensity = "Bold" } },
								{ Text = "New Workspace Name" },
								{ Foreground = { Color = "#6272A4" } },
								{ Attribute = { Intensity = "Normal" } },
								{ Text = "  │  Enter a unique name" },
							}),
							action = wezterm.action_callback(function(win, p, line)
								if line and line ~= "" then
									win:perform_action(act.SwitchToWorkspace({ name = line }), p)
								end
							end),
						}),
						pane
					)
				end
			end),
		},
		{
			key = "g",
			mods = "LEADER",
			action = wezterm.action_callback(function(window, pane)
				launch_ghq_project_workspace(window, pane)
			end),
		},
		-- 直前のコマンドと出力をコピー
		{
			key = "x",
			mods = "LEADER",
			action = wezterm.action_callback(copy_previous_command_and_output),
		},
	},

	-- SearchMode
	key_tables = {
		resize_pane = {
			{ key = "h", mods = "NONE", action = act.AdjustPaneSize({ "Left", 5 }) },
			{ key = "j", mods = "NONE", action = act.AdjustPaneSize({ "Down", 5 }) },
			{ key = "k", mods = "NONE", action = act.AdjustPaneSize({ "Up", 5 }) },
			{ key = "l", mods = "NONE", action = act.AdjustPaneSize({ "Right", 5 }) },
			{ key = "Escape", mods = "NONE", action = act.PopKeyTable },
			{ key = "Enter", mods = "NONE", action = act.PopKeyTable },
		},
		search_mode = {
			{ key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
			{
				key = "Escape",
				mods = "NONE",
				action = act.Multiple({
					act.CopyMode("ClearPattern"),
					act.CopyMode("Close"),
				}),
			},
			{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
			{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
			{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
			{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
			{ key = "PageUp", mods = "NONE", action = act.CopyMode("PriorMatchPage") },
			{ key = "PageDown", mods = "NONE", action = act.CopyMode("NextMatchPage") },
			{ key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
			{ key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
		},
	},

	-- Window
	animation_fps = 120,
	max_fps = 120,
	background = {
		{
			source = {
				Gradient = {
					colors = { "#0A1024", "#2D1B69", "#A12670", "#FF7A18" },
					orientation = { Linear = { angle = -45.0 } },
					interpolation = "Basis",
					blend = "Rgb",
				},
			},
			width = "100%",
			height = "100%",
			opacity = 1.0,
		},
		{
			source = {
				Gradient = {
					colors = { "#0D0B2A", "#102A43", "#05D9E8" },
					orientation = {
						Radial = { cx = 0.82, cy = -0.15, radius = 1.05 },
					},
					interpolation = "Basis",
					blend = "Rgb",
				},
			},
			width = "100%",
			height = "100%",
			opacity = 0.18,
		},
		{
			source = { File = "/usr/local/pictures/wallpaper4.png" },
			width = "Cover",
			height = "Cover",
			opacity = 0.20,
			hsb = {
				hue = 1.0,
				saturation = 1.25,
				brightness = 0.16,
			},
			attachment = { Parallax = 0.05 },
		},
		{
			source = { Color = palette.shadow },
			width = "100%",
			height = "100%",
			opacity = 0.45,
		},
	},
	-- TUI が塗る背景（lazytree など）も少し透かす
	text_background_opacity = 0.88,
	window_padding = {
		left = 16,
		right = 12,
		top = 12,
		bottom = 8,
	},
	window_frame = {
		font = wezterm.font({ family = "Roboto", weight = "Bold" }),
		font_size = 12.0,
		active_titlebar_bg = palette.chrome_dim,
		inactive_titlebar_bg = palette.bg_alt,
		active_titlebar_fg = palette.fg,
		inactive_titlebar_fg = palette.fg_dim,
		active_titlebar_border_bottom = palette.violet,
		inactive_titlebar_border_bottom = palette.chrome,
		button_fg = palette.fg_muted,
		button_bg = palette.chrome_dim,
		button_hover_fg = palette.shadow,
		button_hover_bg = palette.gold,
		border_left_width = "0.35cell",
		border_right_width = "0.35cell",
		border_bottom_height = "0.25cell",
		border_top_height = "0.25cell",
		border_left_color = palette.violet,
		border_right_color = palette.hot_pink,
		border_bottom_color = palette.orange,
		border_top_color = palette.cyan,
	},

	-- Tab bar
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = false,
	window_decorations = "RESIZE",
	status_update_interval = 250,
	use_fancy_tab_bar = false,
	show_tabs_in_tab_bar = true,
	show_new_tab_button_in_tab_bar = false,
	show_tab_index_in_tab_bar = false,
	tab_max_width = 32,

	-- Scroll
	enable_scroll_bar = true,

	-- Copy
	scrollback_lines = 30000,

	-- Pane
	inactive_pane_hsb = {
		saturation = 0.75,
		brightness = 0.30,
	},
}

-- macOS: leader待機に入った瞬間にIMEをOFF(英数/ABCへ)に寄せる。
-- 事前条件:
-- - メニューバーに「入力メニュー」を表示している
-- - WezTerm にアクセシビリティ権限がある（System Events操作のため）
local function macos_ime_off()
	if not wezterm.target_triple or not wezterm.target_triple:find("apple") then
		return
	end

	local script = [[
tell application "System Events"
  tell process "SystemUIServer"
    try
      set theItem to (first menu bar item of menu bar 1 whose description is "text input")
      click theItem
      tell menu 1 of theItem
        if exists menu item "ABC" then
          click menu item "ABC"
        else if exists menu item "英数" then
          click menu item "英数"
        else if exists menu item "U.S." then
          click menu item "U.S."
        else if exists menu item "Alphanumeric" then
          click menu item "Alphanumeric"
        end if
      end tell
    end try
  end tell
  key code 53
end tell
]]
	-- 失敗してもWezTerm側の動作は継続させたいので、結果は捨てる
	wezterm.run_child_process({ "/usr/bin/osascript", "-e", script })
end

-- リポジトリ名を取得する関数
local function get_repo_name(cwd_path)
	if not cwd_path then
		return ""
	end

	-- .gitディレクトリを探してリポジトリルートを見つける
	local path = cwd_path
	while path ~= "/" and path ~= "" do
		local git_dir = path .. "/.git"
		local f = io.open(git_dir, "r")
		if f then
			f:close()
			-- リポジトリルートのディレクトリ名を返す
			return path:match("([^/]+)/?$") or path
		end
		-- 親ディレクトリに移動
		path = path:match("(.*)/[^/]+/?$") or ""
	end

	-- .gitが見つからなかったらカレントディレクトリ名を返す
	return cwd_path:match("([^/]+)/?$") or cwd_path
end

local function trim(value)
	if not value then
		return ""
	end

	return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split_lines(value)
	local lines = {}
	for line in (value or ""):gmatch("[^\r\n]+") do
		local item = trim(line)
		if item ~= "" then
			table.insert(lines, item)
		end
	end
	return lines
end

local function workspace_exists(name)
	for _, workspace in ipairs(wezterm.mux.get_workspace_names()) do
		if workspace == name then
			return true
		end
	end

	return false
end

local function workspace_mux_window(name)
	for _, mux_window in ipairs(wezterm.mux.all_windows()) do
		if mux_window:get_workspace() == name then
			return mux_window
		end
	end

	return nil
end

local function notify_error(window, message, detail)
	local body = message
	if detail and detail ~= "" then
		body = body .. ": " .. detail
	end
	window:toast_notification("WezTerm", body, nil, 4000)
end

local function login_shell_path()
	return os.getenv("SHELL") or "/bin/zsh"
end

local function run_login_shell_command(command)
	return wezterm.run_child_process({ login_shell_path(), "-ilc", command })
end

local function list_ghq_projects(window)
	local ok_root, root_stdout, root_stderr = run_login_shell_command("ghq root")
	if not ok_root then
		notify_error(window, "ghq root に失敗しました", trim(root_stderr))
		return nil, nil
	end

	local ghq_root = trim(root_stdout)
	if ghq_root == "" then
		notify_error(window, "ghq root の結果が空です", trim(root_stderr))
		return nil, nil
	end

	local ok_list, list_stdout, list_stderr = run_login_shell_command("ghq list")
	if not ok_list then
		notify_error(window, "ghq list に失敗しました", trim(list_stderr))
		return nil, nil
	end

	local projects = split_lines(list_stdout)
	if #projects == 0 then
		notify_error(window, "ghq 管理下のリポジトリが見つかりません", trim(list_stderr))
		return nil, nil
	end

	return ghq_root, projects
end

local function format_project_choice(repo)
	local repo_name = repo:match("([^/]+)$") or repo
	return wezterm.format({
		{ Foreground = { Color = palette.gold } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = "◆ " .. repo_name },
		{ Foreground = { Color = palette.fg_dim } },
		{ Attribute = { Intensity = "Normal" } },
		{ Text = "   " .. repo },
	})
end

local function apply_project_workspace_layout(window, workspace_name, repo_path, attempt, open_nvim)
	attempt = attempt or 1

	local mux_window = workspace_mux_window(workspace_name)
	if not mux_window then
		if attempt >= 20 then
			notify_error(window, "workspace の生成待ちでタイムアウトしました", workspace_name)
			return
		end
		wezterm.time.call_after(0.1, function()
			apply_project_workspace_layout(window, workspace_name, repo_path, attempt + 1, open_nvim)
		end)
		return
	end

	local tab = mux_window:active_tab()
	if not tab then
		if attempt >= 20 then
			notify_error(window, "workspace にタブが作成されませんでした", workspace_name)
			return
		end
		wezterm.time.call_after(0.1, function()
			apply_project_workspace_layout(window, workspace_name, repo_path, attempt + 1, open_nvim)
		end)
		return
	end

	local panes = tab:panes_with_info()
	if #panes == 0 then
		if attempt >= 20 then
			notify_error(window, "workspace に pane が作成されませんでした", workspace_name)
			return
		end
		wezterm.time.call_after(0.1, function()
			apply_project_workspace_layout(window, workspace_name, repo_path, attempt + 1, open_nvim)
		end)
		return
	end

	if #panes > 1 then
		return
	end

	local top = tab:active_pane() or panes[1].pane
	if not top then
		notify_error(window, "workspace の pane を取得できませんでした", workspace_name)
		return
	end

	local bottom = top:split({
		direction = "Bottom",
		size = 0.2,
		cwd = repo_path,
	})
	bottom:split({
		direction = "Right",
		size = 0.5,
		cwd = repo_path,
	})
	top:activate()
	tab:set_title(get_repo_name(repo_path))

	if open_nvim then
		wezterm.time.call_after(0.05, function()
			top:send_text("exec nvim\n")
		end)
	end
end

local function launch_ghq_project_workspace(window, pane)
	window:toast_notification("WezTerm", "Loading GHQ projects...", nil, 1200)

	local ghq_root, projects = list_ghq_projects(window)
	if not ghq_root or not projects then
		return
	end

	local choices = {}
	for _, repo in ipairs(projects) do
		table.insert(choices, {
			id = repo,
			label = format_project_choice(repo),
		})
	end

	window:perform_action(
		act.InputSelector({
			title = wezterm.format({
				{ Foreground = { Color = palette.hot_pink } },
				{ Attribute = { Intensity = "Bold" } },
				{ Text = "  GHQ Projects " },
				{ Foreground = { Color = palette.fg_dim } },
				{ Attribute = { Intensity = "Normal" } },
				{ Text = " (" .. #projects .. " repos)" },
			}),
			choices = choices,
			fuzzy = true,
			fuzzy_description = wezterm.format({
				{ Foreground = { Color = palette.fg_dim } },
				{ Text = "Type to filter • Enter opens workspace • Esc cancels" },
			}),
			action = wezterm.action_callback(function(win, p, id)
				if not id then
					return
				end

				local workspace_name = id
				local repo_path = ghq_root .. "/" .. id
				local existed = workspace_exists(workspace_name)

				win:perform_action(
					act.SwitchToWorkspace({
						name = workspace_name,
						spawn = {
							cwd = repo_path,
							args = { login_shell_path(), "-il" },
						},
					}),
					p
				)

				if not existed then
					wezterm.time.call_after(0.15, function()
						apply_project_workspace_layout(win, workspace_name, repo_path, 1, true)
					end)
				end
			end),
		}),
		pane
	)
end

local function tab_label(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end

	local cwd_uri = tab_info.active_pane.current_working_dir
	if cwd_uri then
		local repo = get_repo_name(cwd_uri.file_path)
		if repo ~= "" then
			return repo
		end
	end

	return tab_info.active_pane.title
end

wezterm.on("augment-command-palette", function(window, pane)
	return {
		{
			brief = "Open GHQ Project Workspace",
			doc = "Select a ghq repository",
			action = wezterm.action_callback(function(win, p)
				launch_ghq_project_workspace(win, p)
			end),
		},
	}
end)

-- Set window title to workspace name
wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
	local workspace = wezterm.mux.get_active_workspace()
	local prefix = tab.active_pane.is_zoomed and "[ZOOM] " or ""
	return prefix .. workspace
end)

-- Change color scheme based on workspace
local function render_status(window, pane)
	local workspace = window:active_workspace()
	local overrides = window:get_config_overrides() or {}
	local mux_window = window:mux_window()
	local active_key_table = window:active_key_table()
	local zoomed = false

	-- leaderがアクティブになった瞬間だけIMEをOFFに寄せる
	local leader_active = false
	if window.leader_is_active then
		leader_active = window:leader_is_active()
	end
	wezterm.GLOBAL.__leader_active_by_window = wezterm.GLOBAL.__leader_active_by_window or {}
	local win_id = window:window_id()
	local prev_leader_active = wezterm.GLOBAL.__leader_active_by_window[win_id] or false
	if leader_active and not prev_leader_active then
		wezterm.GLOBAL.__leader_active_by_window[win_id] = true
		macos_ime_off()
	elseif (not leader_active) and prev_leader_active then
		wezterm.GLOBAL.__leader_active_by_window[win_id] = false
	end

	-- defaultワークスペースはDraculaのまま
	if workspace == "default" then
		overrides.color_scheme = "Night Owl (Gogh)"
	else
		-- ワークスペース名のハッシュ値で色を決定
		local hash = 0
		for i = 1, #workspace do
			hash = hash + string.byte(workspace, i)
		end

		local color_schemes = {
			"Dracula (Official)",
			"Tokyo Night",
			"Monokai (dark) (terminal.sexy)",
			"Night Owl (Gogh)",
		}

		local scheme_index = (hash % #color_schemes) + 1
		overrides.color_scheme = color_schemes[scheme_index]
	end
	window:set_config_overrides(overrides)

	-- アクティブpaneの「今どこ？」が分かるように、workspace + cwd + pane id を出す
	local cwd_uri = pane:get_current_working_dir()
	local cwd_path = cwd_uri and cwd_uri.file_path or nil
	local where = ""
	if cwd_path then
		where = get_repo_name(cwd_path)
	end

	local pane_label = tostring(pane:pane_id())
	if mux_window then
		local active_tab = mux_window:active_tab()
		if active_tab then
			local panes = active_tab:panes_with_info()
			for index, pane_info in ipairs(panes) do
				if pane_info.pane:pane_id() == pane:pane_id() then
					pane_label = string.format("%d/%d", index, #panes)
					zoomed = pane_info.is_zoomed or false
					break
				end
			end
		end
	end

	local context_label = where ~= "" and where or pane:get_title()
	local mode_name = "NORMAL"
	local mode_bg = palette.panel_alt

	if active_key_table == "copy_mode" then
		mode_name = "COPY"
		mode_bg = palette.gold
	elseif active_key_table == "search_mode" then
		mode_name = "SEARCH"
		mode_bg = palette.cyan
	elseif active_key_table == "resize_pane" then
		mode_name = "RESIZE"
		mode_bg = palette.violet
	elseif active_key_table and active_key_table ~= "" then
		mode_name = string.upper(active_key_table)
		mode_bg = palette.violet
	end

	local left_status = {}
	push_status_segment(left_status, palette.hot_pink, palette.shadow, " MODE ")
	if leader_active then
		push_status_segment(left_status, palette.orange, palette.shadow, " LEADER ")
	end
	push_status_segment(left_status, mode_bg, palette.shadow, " " .. mode_name .. " ")
	if zoomed then
		push_status_segment(left_status, palette.lime, palette.shadow, " ZOOM ")
	end
	push_status_segment(left_status, palette.chrome, palette.fg, " " .. workspace .. " ")

	window:set_left_status(wezterm.format(left_status))

	local status = wezterm.format({
		{ Background = { Color = palette.chrome } },
		{ Foreground = { Color = palette.fg } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = " pane " .. pane_label .. " " },
		{ Background = { Color = palette.bg_alt } },
		{ Foreground = { Color = palette.gold } },
		{ Text = " " .. wezterm.truncate_right(context_label, 24) .. " " },
	})
	window:set_right_status(status)
end

wezterm.on("update-status", render_status)
wezterm.on("update-right-status", render_status)

-- Tab style
local LEFT_DIVIDER = wezterm.nerdfonts.ple_upper_left_triangle
local RIGHT_DIVIDER = wezterm.nerdfonts.ple_lower_right_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = palette.panel
	local foreground = palette.fg_dim
	local edge_background = palette.chrome_dim
	local accent = "•"
	local badge = ""

	if tab.is_active then
		background = palette.hot_pink
		foreground = palette.shadow
		accent = "✦"
	elseif hover then
		background = palette.violet
		foreground = palette.fg
		accent = "◆"
	end

	local edge_foreground = background
	if tab.active_pane.is_zoomed then
		badge = "[ZOOM] "
	end

	local title = string.format(
		" %s %d %s%s ",
		accent,
		tab.tab_index + 1,
		badge,
		wezterm.truncate_right(tab_label(tab), math.max(max_width - 8, 6))
	)
	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = RIGHT_DIVIDER },

		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },

		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = LEFT_DIVIDER },
	}
end)

-- Use the defaults as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- make task numbers clickable
-- the first matched regex group is captured in $1.
table.insert(config.hyperlink_rules, {
	regex = [[\b(arn:aws:[^\s]+)\b]],
	format = "https://console.aws.amazon.com/go/view?arn=$1",
})

-- and finally, return the configuration to wezterm
return config

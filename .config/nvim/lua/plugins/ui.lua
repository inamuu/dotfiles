local p = require("config.palette")

-- starship.toml の neon_luxe パレットと同じ値・役割で揃える（ステータスライン用）。
-- bufferline / colorscheme には影響させず、lualine の色の使い方だけ starship に合わせる。
local wz = {
	shadow = "#0A1A2A",
	chrome = "#1C344C",
	panel = "#234A6B",
	panel_alt = "#2E5E85",
	violet = "#6FA8DC", -- os / username
	hot = "#4FD1C5", -- git_branch / character(success)
	cyan = "#4A9FD6", -- git_status
	sky = "#6EB8E8",
	gold = "#A8D8F0", -- directory
	orange = "#5FA3D6", -- git_state / character(error)
	lime = "#5EDCB5",
	fg = "#F0F7FC",
	muted = "#A8BCCF",
}

return {
	{
		"akinsho/bufferline.nvim",
		opts = function(_, opts)
			opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
				always_show_bufferline = true,
				separator_style = "slant",
				show_close_icon = false,
				show_buffer_close_icons = false,
				diagnostics_indicator = function(_, _, diagnostics, context)
					if context.buffer:current() then
						return ""
					end

					local parts = {}
					if diagnostics.error then
						table.insert(parts, " " .. diagnostics.error)
					end
					if diagnostics.warning then
						table.insert(parts, " " .. diagnostics.warning)
					end
					if diagnostics.info then
						table.insert(parts, " " .. diagnostics.info)
					end
					return #parts > 0 and (" " .. table.concat(parts, " ")) or ""
				end,
				offsets = {
					{
						filetype = "NvimTree",
						text = " Explorer ",
						highlight = "Directory",
						text_align = "left",
						separator = true,
					},
					{
						filetype = "neo-tree",
						text = " Explorer ",
						highlight = "Directory",
						text_align = "left",
						separator = true,
					},
					{
						filetype = "snacks_layout_box",
					},
				},
			})

			opts.highlights = function(defaults)
				local hl = vim.deepcopy(defaults.highlights or {})
				hl.fill = { bg = p.bg_dark }
				hl.background = { bg = p.bg_dark, fg = p.comment }
				hl.buffer_visible = { bg = p.bg_sidebar, fg = p.fg_muted }
				hl.buffer_selected = { bg = p.panel, fg = p.fg, bold = true }
				hl.duplicate = { bg = p.bg_dark, fg = p.comment, italic = true }
				hl.duplicate_visible = { bg = p.bg_sidebar, fg = p.fg_muted, italic = true }
				hl.duplicate_selected = { bg = p.panel, fg = p.cyan, italic = true, bold = true }
				hl.separator = { fg = p.bg_dark, bg = p.bg_dark }
				hl.separator_visible = { fg = p.bg_dark, bg = p.bg_sidebar }
				hl.separator_selected = { fg = p.bg_dark, bg = p.panel }
				hl.close_button = { fg = p.comment, bg = p.bg_dark }
				hl.close_button_visible = { fg = p.fg_muted, bg = p.bg_sidebar }
				hl.close_button_selected = { fg = p.magenta, bg = p.panel }
				hl.modified = { fg = p.yellow, bg = p.bg_dark }
				hl.modified_visible = { fg = p.yellow, bg = p.bg_sidebar }
				hl.modified_selected = { fg = p.yellow, bg = p.panel }
				hl.indicator_selected = { fg = p.cyan, bg = p.panel }
				hl.pick_selected = { fg = p.bg_dark, bg = p.yellow, bold = true }
				hl.pick_visible = { fg = p.bg_dark, bg = p.cyan, bold = true }
				hl.pick = { fg = p.bg_dark, bg = p.magenta, bold = true }
				hl.tab = { bg = p.bg_dark, fg = p.comment }
				hl.tab_selected = { bg = p.panel, fg = p.fg, bold = true }
				hl.tab_separator = { bg = p.bg_dark, fg = p.bg_dark }
				hl.tab_separator_selected = { bg = p.panel, fg = p.bg_dark }
				hl.info = { fg = p.cyan, bg = p.bg_dark }
				hl.info_visible = { fg = p.cyan, bg = p.bg_sidebar }
				hl.info_selected = { fg = p.cyan, bg = p.panel, bold = true }
				hl.warning = { fg = p.yellow, bg = p.bg_dark }
				hl.warning_visible = { fg = p.yellow, bg = p.bg_sidebar }
				hl.warning_selected = { fg = p.yellow, bg = p.panel, bold = true }
				hl.error = { fg = p.red, bg = p.bg_dark }
				hl.error_visible = { fg = p.red, bg = p.bg_sidebar }
				hl.error_selected = { fg = p.red, bg = p.panel, bold = true }
				hl.hint = { fg = p.green, bg = p.bg_dark }
				hl.hint_visible = { fg = p.green, bg = p.bg_sidebar }
				hl.hint_selected = { fg = p.green, bg = p.panel, bold = true }
				hl.offset_separator = { fg = p.border, bg = p.bg_dark }
				return hl
			end
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			local icons = LazyVim.config.icons

			-- モードごとのアクセント色（starship の character の配色に対応）
			local mode_color = {
				n = wz.hot, -- success
				i = wz.hot,
				v = wz.violet, -- visual
				V = wz.violet,
				["\22"] = wz.violet, -- visual block
				c = wz.lime,
				R = wz.gold, -- replace
				t = wz.lime,
			}

			local function mode_theme(accent)
				return {
					a = { bg = accent, fg = wz.shadow, gui = "bold" },
					b = { bg = "NONE", fg = accent },
					c = { bg = "NONE", fg = wz.muted },
				}
			end

			opts.options = {
					theme = {
						normal = mode_theme(wz.hot),
						insert = mode_theme(wz.hot),
						visual = mode_theme(wz.violet),
						replace = mode_theme(wz.gold),
						command = mode_theme(wz.lime),
						terminal = mode_theme(wz.lime),
						inactive = mode_theme(wz.muted),
					},
					globalstatus = vim.o.laststatus == 3,
					disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
					component_separators = "",
					section_separators = "",
				}

				opts.sections = {
					lualine_a = {
						{
							"mode",
							icon = "",
							color = function()
								return { bg = mode_color[vim.fn.mode()] or wz.hot, fg = wz.shadow, gui = "bold" }
							end,
							padding = { left = 1, right = 1 },
						},
					},
					lualine_b = {
						{ "branch", icon = "", color = { fg = wz.hot } },
					},
					lualine_c = {
						{
							LazyVim.lualine.pretty_path({ length = 3, modified_hl = "Directory", directory_hl = "Comment" }),
							color = { fg = wz.gold },
						},
					},
					lualine_x = {
						{
							"diagnostics",
							symbols = {
								error = icons.diagnostics.Error,
								warn = icons.diagnostics.Warn,
								info = icons.diagnostics.Info,
								hint = icons.diagnostics.Hint,
							},
						},
						{ "filetype", icon_only = false, color = { fg = wz.muted } },
					},
					lualine_y = {},
					lualine_z = {
						{ "location", color = { fg = wz.cyan } },
					},
				}

				opts.inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{ LazyVim.lualine.pretty_path({ length = 2 }), color = { fg = wz.muted } },
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				}

				opts.extensions = { "neo-tree", "nvim-tree", "lazy", "fzf" }
		end,
	},
	{
		"folke/noice.nvim",
		opts = function(_, opts)
			opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, {
				format = {
					search_down = { icon = "", view = "cmdline_popup" },
					search_up = { icon = "", view = "cmdline_popup" },
				},
			})
			opts.views = vim.tbl_deep_extend("force", opts.views or {}, {
				cmdline_popup = {
					win_options = {
						winblend = 0,
					},
				},
			})
		end,
	},
}

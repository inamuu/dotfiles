local p = require("config.palette")

return {
	{ "ellisonleao/gruvbox.nvim" },
	{ "Mofiqul/dracula.nvim" },
	{
		"folke/tokyonight.nvim",
		opts = {
			style = "night",
			transparent = true,
			terminal_colors = true,
			lualine_bold = true,
			styles = {
				comments = { italic = true },
				keywords = { italic = true, bold = true },
				functions = { bold = true },
				variables = {},
				sidebars = "transparent",
				floats = "dark",
			},
			on_colors = function(colors)
				colors.bg = p.bg
				colors.bg_dark = p.bg_dark
				colors.bg_float = p.bg_float
				colors.bg_popup = p.bg_float
				colors.bg_sidebar = p.bg_sidebar
				colors.bg_statusline = p.panel
				colors.bg_visual = p.selection
				colors.border = p.border
				colors.comment = p.comment
				colors.fg = p.fg
				colors.fg_dark = p.fg_muted
				colors.fg_gutter = p.gutter
				colors.blue = p.blue
				colors.cyan = p.cyan
				colors.magenta = p.magenta
				colors.purple = p.purple
				colors.orange = p.orange
				colors.yellow = p.yellow
				colors.green = p.green
				colors.red = p.red
				colors.git = {
					add = p.green,
					change = p.cyan,
					delete = p.red,
				}
			end,
			on_highlights = function(hl, colors)
				hl.FloatBorder = { fg = p.border, bg = p.bg_float }
				hl.FloatTitle = { fg = p.yellow, bg = p.bg_float, bold = true }
				hl.NormalFloat = { bg = p.bg_float }
				hl.Pmenu = { fg = p.fg, bg = p.bg_float }
				hl.PmenuSel = { fg = p.fg, bg = p.panel_alt, bold = true }
				hl.PmenuSbar = { bg = p.bg_sidebar }
				hl.PmenuThumb = { bg = p.border }
				hl.Visual = { bg = p.selection }
				hl.Search = { fg = p.bg_dark, bg = p.yellow, bold = true }
				hl.IncSearch = { fg = p.bg_dark, bg = p.orange, bold = true }
				hl.CurSearch = { fg = p.bg_dark, bg = p.magenta, bold = true }
				hl.WinSeparator = { fg = p.border, bg = "NONE", bold = true }
				hl.TelescopeTitle = { fg = p.bg_dark, bg = p.magenta, bold = true }
				hl.TelescopePromptTitle = { fg = p.bg_dark, bg = p.cyan, bold = true }
				hl.TelescopePreviewTitle = { fg = p.bg_dark, bg = p.yellow, bold = true }
				hl.TelescopeResultsTitle = { fg = p.bg_dark, bg = p.purple, bold = true }
				hl.TelescopeBorder = { fg = p.border, bg = p.bg_float }
				hl.TelescopePromptBorder = { fg = p.cyan, bg = p.bg_float }
				hl.TelescopePromptNormal = { fg = p.fg, bg = p.bg_float }
				hl.TelescopePromptPrefix = { fg = p.magenta, bg = p.bg_float }
				hl.TelescopeMatching = { fg = p.yellow, bold = true }
				hl.DiffAdd = { bg = p.diff_add }
				hl.DiffDelete = { bg = p.diff_delete }
				hl.DiffChange = { bg = p.diff_change }
				hl.DiffText = { bg = p.panel_alt }
				hl.SnacksIndent = { fg = p.panel_alt }
				hl.SnacksIndentScope = { fg = p.cyan, bold = true }
				hl.NoiceCmdlinePopupBorder = { fg = p.cyan, bg = p.bg_float }
				hl.NoiceConfirmBorder = { fg = p.yellow, bg = p.bg_float }
				hl.NoicePopupBorder = { fg = p.border, bg = p.bg_float }
				hl.NoicePopupmenuBorder = { fg = p.magenta, bg = p.bg_float }
				hl.NotifyINFOBorder = { fg = p.cyan, bg = p.bg_float }
				hl.NotifyWARNBorder = { fg = p.yellow, bg = p.bg_float }
				hl.NotifyERRORBorder = { fg = p.red, bg = p.bg_float }
				hl.MiniStarterHeader = { fg = p.magenta, bold = true }
				hl.MiniStarterSection = { fg = p.cyan, bold = true }
				hl.MiniStarterItem = { fg = p.fg, bg = "NONE" }
				hl.MiniStarterFooter = { fg = colors.comment, italic = true }
			end,
		},
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight",
			show_end_of_buffer = true,
		},
	},
}

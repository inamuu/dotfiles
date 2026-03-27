local p = require("config.palette")

local function segment(bg, fg)
	return { bg = bg, fg = fg or p.bg_dark, gui = "bold" }
end

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

			opts.options = {
				theme = {
					normal = {
						a = segment(p.magenta),
						b = segment(p.cyan),
						c = { bg = "NONE", fg = p.fg },
					},
					insert = {
						a = segment(p.cyan),
						b = segment(p.blue),
						c = { bg = "NONE", fg = p.fg },
					},
					visual = {
						a = segment(p.yellow),
						b = segment(p.magenta),
						c = { bg = "NONE", fg = p.fg },
					},
					replace = {
						a = segment(p.orange),
						b = segment(p.red),
						c = { bg = "NONE", fg = p.fg },
					},
					command = {
						a = segment(p.green),
						b = segment(p.cyan),
						c = { bg = "NONE", fg = p.fg },
					},
					inactive = {
						a = { bg = p.bg_dark, fg = p.comment },
						b = { bg = p.bg_dark, fg = p.comment },
						c = { bg = "NONE", fg = p.comment },
					},
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
						icon = "",
						separator = { left = "", right = "" },
						padding = { left = 1, right = 1 },
					},
				},
				lualine_b = {
					{
						"branch",
						icon = "",
						color = segment(p.cyan),
						separator = { left = "", right = "" },
					},
					{
						"diff",
						symbols = {
							added = icons.git.added,
							modified = icons.git.modified,
							removed = icons.git.removed,
						},
						source = function()
							local gitsigns = vim.b.gitsigns_status_dict
							if gitsigns then
								return {
									added = gitsigns.added,
									modified = gitsigns.changed,
									removed = gitsigns.removed,
								}
							end
						end,
						color = { bg = p.panel, fg = p.fg, gui = "bold" },
						separator = { left = "", right = "" },
					},
				},
				lualine_c = {
					{
						LazyVim.lualine.root_dir({ icon = "󰉋 " }),
						color = { bg = p.bg_alt, fg = p.yellow, gui = "bold" },
						separator = { left = "", right = "" },
					},
					{
						LazyVim.lualine.pretty_path({ length = 4, modified_hl = "Directory", directory_hl = "Comment" }),
						color = { bg = p.panel_alt, fg = p.fg, gui = "bold" },
						separator = { left = "", right = "" },
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
						color = { bg = p.bg_sidebar, fg = p.fg, gui = "bold" },
						separator = { left = "", right = "" },
					},
					{
						function()
							return require("noice").api.status.command.get()
						end,
						cond = function()
							return package.loaded["noice"] and require("noice").api.status.command.has()
						end,
						color = { bg = p.bg_sidebar, fg = p.magenta, gui = "bold" },
						separator = { left = "", right = "" },
					},
				},
				lualine_y = {
					{
						"filetype",
						icon_only = false,
						colored = true,
						color = { bg = p.green, fg = p.bg_dark, gui = "bold" },
						separator = { left = "", right = "" },
					},
					{
						"progress",
						color = { bg = p.bg_alt, fg = p.fg, gui = "bold" },
						separator = { left = "", right = "" },
					},
				},
				lualine_z = {
					{
						"location",
						color = { bg = p.orange, fg = p.bg_dark, gui = "bold" },
						separator = { left = "", right = "" },
						padding = { left = 1, right = 1 },
					},
				},
			}

			opts.inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{
						LazyVim.lualine.pretty_path({ length = 2 }),
						color = { bg = p.bg_dark, fg = p.comment },
						separator = { left = "", right = "" },
					},
				},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {
					{
						"location",
						color = { bg = p.bg_dark, fg = p.comment },
						separator = { left = "", right = "" },
					},
				},
			}

			opts.extensions = { "neo-tree", "nvim-tree", "lazy", "fzf" }
		end,
	},
}

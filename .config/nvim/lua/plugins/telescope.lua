return {
	"nvim-telescope/telescope.nvim",
	keys = {
		{
			"<leader>sg",
			function()
				require("config.grep").live_grep_cwd()
			end,
			desc = "Grep (現在階層)",
		},
		{
			"<leader>sG",
			function()
				require("config.grep").live_grep_root()
			end,
			desc = "Grep (プロジェクトルート)",
		},
	},
	opts = function(_, opts)
		opts.defaults = opts.defaults or {}
		opts.defaults.layout_strategy = "horizontal"
		opts.defaults.sorting_strategy = "ascending"
		opts.defaults.layout_config = vim.tbl_deep_extend("force", opts.defaults.layout_config or {}, {
			horizontal = {
				prompt_position = "top",
				preview_width = 0.55,
			},
			vertical = {
				prompt_position = "top",
			},
		})
		opts.defaults.vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		}

		return opts
	end,
}

return {
	"nvim-telescope/telescope.nvim",
	keys = {
		-- LazyVimのデフォルトキーマップを上書き
		{
			"<leader>sg",
			function()
				require("telescope.builtin").live_grep({
					additional_args = function()
						return { "--hidden", "--glob", "!.git/", "--glob", "!node_modules/" }
					end,
				})
			end,
			desc = "Grep (隠しファイル含む)",
		},
		{
			"<leader>sG",
			function()
				require("telescope.builtin").live_grep({
					cwd = vim.fn.getcwd(),
					additional_args = function()
						return { "--hidden", "--glob", "!.git/", "--glob", "!node_modules/" }
					end,
				})
			end,
			desc = "Grep (cwd, 隠しファイル含む)",
		},
	},
	opts = function(_, opts)
		-- デフォルト設定も一応設定しておく
		opts.defaults = opts.defaults or {}
		opts.defaults.vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",
			"--glob",
			"!.git/",
			"--glob",
			"!node_modules/",
		}

		return opts
	end,
}

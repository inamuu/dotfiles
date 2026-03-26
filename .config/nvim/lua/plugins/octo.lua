return {
	{
		"pwntester/octo.nvim",
		cmd = { "Octo" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>go", "<cmd>Octo<cr>", desc = "Octo" },
			{ "<leader>gi", "<cmd>Octo issue list<cr>", desc = "GitHub Issues" },
			{ "<leader>gp", "<cmd>Octo pr list<cr>", desc = "GitHub PRs" },
			{ "<leader>gr", "<cmd>Octo review start<cr>", desc = "GitHub Review" },
		},
		opts = {
			picker = "telescope",
		},
	},
}

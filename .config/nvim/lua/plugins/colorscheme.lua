return {
	-- add gruvbox
	{ "ellisonleao/gruvbox.nvim" },

	-- add dracula
	{ "Mofiqul/dracula.nvim" },

	-- Configure LazyVim to load dracula
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "dracula",
			show_end_of_buffer = true,
			lualine_bg_color = "#3b3052",
			transparent_bg = true,
		},
	},
}

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
			lualine_bg_color = "#44475a",
			transparent_bg = true,
		},
	},
}

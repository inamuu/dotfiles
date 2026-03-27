return {
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			opts.servers = opts.servers or {}
			opts.servers.lua_ls = vim.tbl_deep_extend("force", opts.servers.lua_ls or {}, {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})
		end,
	},
}

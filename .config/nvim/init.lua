-- netrwを無効化 (最初に設定する必要がある)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.clipboard = "unnamedplus"

vim.opt.guifont = "UDEV Gothic 35"

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.lazy")
require("config.keymaps").setup()

vim.opt.number = true

-- 設定ファイルリロードのショートカット
vim.keymap.set("n", "<leader>r", ":source ~/.config/nvim/init.lua<CR>", { desc = "設定ファイルをリロード" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.cmd("NvimTreeToggle")
		end
	end,
})

-- netrwを無効化 (最初に設定する必要がある)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.clipboard = "unnamedplus"

vim.opt.guifont = "UDEV Gothic 35"

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.lazyvim_picker = "telescope"

require("config.options")
require("config.lazy")
require("config.keymaps").setup()

vim.opt.number = true

-- 設定ファイルリロードのショートカット
vim.keymap.set("n", "<leader>r", function()
  for name in pairs(package.loaded) do
    if name:match("^config%.") then
      package.loaded[name] = nil
    end
  end
  vim.cmd("source ~/.config/nvim/init.lua")
  if vim.fn.exists(":LspRestart") == 2 then
    pcall(vim.cmd, "LspRestart")
  end
  print("設定とLSPを再起動しました")
end, { desc = "設定ファイルをリロードしてLSPを再起動" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.cmd("NvimTreeToggle")
		end
	end,
})

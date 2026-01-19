
vim.opt.clipboard = "unnamedplus"

require("config.lazy")

vim.opt.number = true

-- 設定ファイルリロードのショートカット
vim.keymap.set("n", "<leader>r", ":source ~/.config/nvim/init.lua<CR>", { desc = "設定ファイルをリロード" })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("NvimTreeOpen")
    end
  end,
})

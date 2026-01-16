
vim.opt.clipboard = "unnamedplus"

require("config.lazy")

vim.opt.number = true

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("NvimTreeOpen")
    end
  end,
})

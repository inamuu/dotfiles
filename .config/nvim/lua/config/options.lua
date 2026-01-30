vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.opt.foldlevel = 0
vim.opt.foldlevelstart = 0

--- yankしたら自動でClipboard連携
vim.opt.clipboard = "unnamedplus"

vim.opt.swapfile = false
vim.opt.spell = false

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.opt.foldlevel = 0
vim.opt.foldlevelstart = 0

--- yankしたら自動でClipboard連携
vim.opt.clipboard = "unnamedplus"

-- 分割線を見やすくする（端末上では実際の太さは変えられないので、太線文字 + 色で補強）
vim.opt.fillchars:append({
	vert = "┃",
	horiz = "━",
	horizup = "┻",
	horizdown = "┳",
	vertleft = "┫",
	vertright = "┣",
	verthoriz = "╋",
})

local function set_ui_highlights()
	vim.api.nvim_set_hl(0, "WinSeparator", {
		fg = "#BD93F9",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "CursorLine", {
		bg = "#2A2138",
	})
	vim.api.nvim_set_hl(0, "CursorLineNr", {
		fg = "#BD93F9",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "StatusLine", {
		fg = "#F8F8F2",
		bg = "#3B3052",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "StatusLineNC", {
		fg = "#B8AECF",
		bg = "#241D31",
	})

	-- Markdownのアンダーライン・赤色表示を修正
	vim.api.nvim_set_hl(0, "@markup.underline", { underline = false })
	vim.api.nvim_set_hl(0, "@markup.raw", { fg = "#F1FA8C", bg = "none" })
	vim.api.nvim_set_hl(0, "@markup.raw.block", { fg = "#F1FA8C", bg = "none" })
	vim.api.nvim_set_hl(0, "@markup.link", { fg = "#8BE9FD", underline = false })
	vim.api.nvim_set_hl(0, "@markup.link.url", { fg = "#8BE9FD", underline = false })
	vim.api.nvim_set_hl(0, "@markup.link.label", { fg = "#8BE9FD", underline = false })
	vim.api.nvim_set_hl(0, "markdownError", { fg = "none", bg = "none" })
end

set_ui_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_ui_highlights,
})

-- LazyVimがMarkdownでspellを有効にするのを無効化
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		vim.opt_local.spell = false
	end,
})

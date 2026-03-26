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
	vim.api.nvim_set_hl(0, "LeaderActiveWindow", {
		bg = "#3A2F4F",
	})
	vim.api.nvim_set_hl(0, "LeaderActiveWindowNC", {
		bg = "none",
	})
	vim.api.nvim_set_hl(0, "CursorLine", {
		bg = "#2A2138",
	})
	vim.api.nvim_set_hl(0, "LeaderActiveCursorLine", {
		bg = "#4B3D66",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "CursorLineNr", {
		fg = "#BD93F9",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "LeaderActiveCursorLineNr", {
		fg = "#FFB86C",
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

local leader_flash_ns = vim.api.nvim_create_namespace("leader-active-window-flash")

local function restore_window_highlight(winid)
	if not vim.api.nvim_win_is_valid(winid) then
		return
	end

	pcall(vim.api.nvim_win_del_var, winid, "leader_flash_timer")

	local ok_previous, previous = pcall(vim.api.nvim_win_get_var, winid, "leader_flash_previous_winhl")
	if ok_previous then
		vim.wo[winid].winhighlight = previous
		pcall(vim.api.nvim_win_del_var, winid, "leader_flash_previous_winhl")
	else
		vim.wo[winid].winhighlight = ""
	end
end

local function flash_active_window()
	if vim.fn.mode() ~= "n" then
		return
	end

	local winid = vim.api.nvim_get_current_win()
	if not vim.api.nvim_win_is_valid(winid) then
		return
	end

	local ok_previous = pcall(vim.api.nvim_win_get_var, winid, "leader_flash_previous_winhl")
	if not ok_previous then
		vim.api.nvim_win_set_var(winid, "leader_flash_previous_winhl", vim.wo[winid].winhighlight)
	end

	vim.wo[winid].winhighlight =
		"Normal:LeaderActiveWindow,NormalNC:LeaderActiveWindowNC,CursorLine:LeaderActiveCursorLine,CursorLineNr:LeaderActiveCursorLineNr"

	local ok_timer, existing_timer = pcall(vim.api.nvim_win_get_var, winid, "leader_flash_timer")
	if ok_timer then
		vim.fn.timer_stop(existing_timer)
	end

	local timer = vim.fn.timer_start(500, function()
		vim.schedule(function()
			restore_window_highlight(winid)
		end)
	end)
	vim.api.nvim_win_set_var(winid, "leader_flash_timer", timer)
end

vim.on_key(nil, leader_flash_ns)
vim.on_key(function(key)
	if key == " " then
		flash_active_window()
	end
end, leader_flash_ns)

-- LazyVimがMarkdownでspellを有効にするのを無効化
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		vim.opt_local.spell = false
	end,
})

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
	vim.api.nvim_set_hl(0, "ActiveWindowNormal", {
		bg = "#241B33",
	})
	vim.api.nvim_set_hl(0, "ActiveWindowSignColumn", {
		bg = "#241B33",
	})
	vim.api.nvim_set_hl(0, "ActiveWindowEndOfBuffer", {
		fg = "#241B33",
		bg = "#241B33",
	})
	vim.api.nvim_set_hl(0, "InactiveWindowNormal", {
		bg = "#130F1C",
		fg = "#A89FBC",
	})
	vim.api.nvim_set_hl(0, "InactiveWindowSignColumn", {
		bg = "#130F1C",
	})
	vim.api.nvim_set_hl(0, "InactiveWindowEndOfBuffer", {
		fg = "#130F1C",
		bg = "#130F1C",
	})
	vim.api.nvim_set_hl(0, "InactiveWindowSeparator", {
		fg = "#5B4C74",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "WinSeparator", {
		fg = "#BD93F9",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "LeaderActiveWindow", {
		bg = "#5A3E1B",
		fg = "#FFF4D6",
	})
	vim.api.nvim_set_hl(0, "LeaderActiveWindowNC", {
		bg = "none",
	})
	vim.api.nvim_set_hl(0, "CursorLine", {
		bg = "#2A2138",
	})
	vim.api.nvim_set_hl(0, "InactiveCursorLine", {
		bg = "#191322",
	})
	vim.api.nvim_set_hl(0, "LeaderActiveCursorLine", {
		bg = "#7A5426",
		fg = "#FFF4D6",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "CursorLineNr", {
		fg = "#BD93F9",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "InactiveCursorLineNr", {
		fg = "#6D6482",
	})
	vim.api.nvim_set_hl(0, "LeaderActiveCursorLineNr", {
		fg = "#FFD166",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "ActiveWindowStatusLine", {
		fg = "#1F1300",
		bg = "#FFB86C",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "LeaderActiveStatusLine", {
		fg = "#1F1300",
		bg = "#FFD166",
		bold = true,
	})
	vim.api.nvim_set_hl(0, "LeaderActiveWinSeparator", {
		fg = "#FFD166",
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
	vim.api.nvim_set_hl(0, "NvimTreeNormal", {
		bg = "#241B33",
	})
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", {
		bg = "#130F1C",
		fg = "#A89FBC",
	})
	vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", {
		fg = "#241B33",
		bg = "#241B33",
	})
	vim.api.nvim_set_hl(0, "NvimTreeEndOfBufferNC", {
		fg = "#130F1C",
		bg = "#130F1C",
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
local managed_winhighlight_keys = {
	Normal = true,
	NormalNC = true,
	SignColumn = true,
	EndOfBuffer = true,
	CursorLine = true,
	CursorLineNr = true,
	StatusLine = true,
	WinSeparator = true,
}

local function merge_winhighlight(base, overrides)
	local merged = {}

	for entry in string.gmatch(base or "", "[^,]+") do
		local from, to = entry:match("^([^:]+):(.+)$")
		if from and to and not managed_winhighlight_keys[from] then
			table.insert(merged, string.format("%s:%s", from, to))
		end
	end

	for from, to in pairs(overrides) do
		table.insert(merged, string.format("%s:%s", from, to))
	end

	return table.concat(merged, ",")
end

local function apply_window_focus_highlights(active_winid)
	local current = active_winid or vim.api.nvim_get_current_win()
	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_is_valid(winid) then
			local is_active = winid == current
			local overrides
			if is_active then
				overrides = {
					Normal = "ActiveWindowNormal",
					NormalNC = "InactiveWindowNormal",
					SignColumn = "ActiveWindowSignColumn",
					EndOfBuffer = "ActiveWindowEndOfBuffer",
					CursorLine = "CursorLine",
					CursorLineNr = "CursorLineNr",
					StatusLine = "ActiveWindowStatusLine",
					WinSeparator = "WinSeparator",
				}
			else
				overrides = {
					Normal = "InactiveWindowNormal",
					NormalNC = "InactiveWindowNormal",
					SignColumn = "InactiveWindowSignColumn",
					EndOfBuffer = "InactiveWindowEndOfBuffer",
					CursorLine = "InactiveCursorLine",
					CursorLineNr = "InactiveCursorLineNr",
					StatusLine = "StatusLineNC",
					WinSeparator = "InactiveWindowSeparator",
				}
			end
			vim.wo[winid].winhighlight = merge_winhighlight(vim.wo[winid].winhighlight, overrides)
		end
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

	apply_window_focus_highlights(winid)

	vim.wo[winid].winhighlight =
		merge_winhighlight(vim.wo[winid].winhighlight, {
			Normal = "LeaderActiveWindow",
			NormalNC = "LeaderActiveWindowNC",
			SignColumn = "LeaderActiveWindow",
			EndOfBuffer = "LeaderActiveWindow",
			CursorLine = "LeaderActiveCursorLine",
			CursorLineNr = "LeaderActiveCursorLineNr",
			StatusLine = "LeaderActiveStatusLine",
			WinSeparator = "LeaderActiveWinSeparator",
		})

	local ok_timer, existing_timer = pcall(vim.api.nvim_win_get_var, winid, "leader_flash_timer")
	if ok_timer then
		vim.fn.timer_stop(existing_timer)
	end

	local timer = vim.fn.timer_start(900, function()
		vim.schedule(function()
			if vim.api.nvim_win_is_valid(winid) then
				pcall(vim.api.nvim_win_del_var, winid, "leader_flash_timer")
			end
			apply_window_focus_highlights()
		end)
	end)
	vim.api.nvim_win_set_var(winid, "leader_flash_timer", timer)
end

vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
	callback = function()
		vim.schedule(function()
			apply_window_focus_highlights()
		end)
	end,
})

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

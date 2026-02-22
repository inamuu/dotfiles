local M = {}

local function resolve_grep_cwd()
	local default_cwd = vim.fn.getcwd()
	local cwd = default_cwd

	local ok_api, api = pcall(require, "nvim-tree.api")
	if ok_api then
		local node = api.tree.get_node_under_cursor()
		if node and node.absolute_path then
			if vim.fn.isdirectory(node.absolute_path) == 1 then
				cwd = node.absolute_path
			else
				cwd = vim.fn.fnamemodify(node.absolute_path, ":h")
			end
		end
	end

	if cwd == default_cwd then
		local ok_core, core = pcall(require, "nvim-tree.core")
		if ok_core then
			local tree_cwd = core.get_cwd()
			if tree_cwd and tree_cwd ~= "" then
				cwd = tree_cwd
			end
		end
	end

	return cwd
end

function M.live_grep_from_nvimtree_or_cwd()
	local ok_telescope, builtin = pcall(require, "telescope.builtin")
	if not ok_telescope then
		vim.notify("telescope.nvim が読み込めません", vim.log.levels.ERROR)
		return
	end

	local cwd = resolve_grep_cwd()
	builtin.live_grep({
		cwd = cwd,
		search_dirs = { cwd },
		additional_args = function()
			return { "--hidden", "--glob", "!.git/", "--glob", "!node_modules/" }
		end,
	})
end

function M.open_cheatsheet()
	local path = vim.fn.expand("~/.config/nvim/cheatsheet.md")
	if vim.fn.filereadable(path) == 0 then
		vim.notify("チートシートが見つかりません: " .. path, vim.log.levels.WARN)
		return
	end

	local lines = vim.fn.readfile(path)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	vim.bo[buf].readonly = true
	vim.bo[buf].filetype = "markdown"

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = width,
		height = height,
		row = row,
		col = col,
	})
end

function M.setup()
	vim.keymap.set("n", "<C-w>e", "<cmd>NvimTreeFocus<cr>", { desc = "NvimTree に移動" })
	vim.keymap.set("n", "<C-w>-", "<cmd>split<cr>", { desc = "水平分割" })
	vim.keymap.set("n", "<C-w>|", "<cmd>vsplit<cr>", { desc = "垂直分割" })
	vim.keymap.set("n", "<C-w>?", M.open_cheatsheet, { desc = "チートシート" })
	vim.keymap.set({ "n", "v" }, "<leader>w", "<cmd>update<cr>", { desc = "ファイル保存" })
	vim.keymap.set("n", "<leader>W", "<cmd>wall<cr>", { desc = "全ファイル保存" })
	vim.keymap.set("n", "<leader>sG", M.live_grep_from_nvimtree_or_cwd, { desc = "Grep (NvimTree階層 or cwd, 隠しファイル含む)" })
	vim.keymap.set({ "n", "v" }, "<D-s>", "<cmd>update<cr>", { desc = "ファイル保存 (Command+S)" })
	vim.keymap.set("i", "<D-s>", "<C-o><cmd>update<cr>", { desc = "ファイル保存 (Command+S)" })
end

return M

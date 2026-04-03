local M = {}

local function normalize_dir(path)
	if not path or path == "" then
		return vim.fn.getcwd()
	end

	if vim.fn.isdirectory(path) == 1 then
		return path
	end

	return vim.fn.fnamemodify(path, ":h")
end

local function resolve_tree_dir()
	local ok_api, api = pcall(require, "nvim-tree.api")
	if not ok_api then
		return nil
	end

	local ok_node, node = pcall(api.tree.get_node_under_cursor)
	if not ok_node or not node or not node.absolute_path then
		return nil
	end

	return normalize_dir(node.absolute_path)
end

function M.resolve_cwd()
	return resolve_tree_dir() or vim.fn.getcwd()
end

function M.resolve_root()
	return LazyVim.root()
end

local function picker_title(opts)
	local scope = vim.fn.fnamemodify(opts.cwd, ":~")
	local hidden = opts.hidden and "on" or "off"
	local ignored = opts.no_ignore and "off" or "on"
	return string.format("Live Grep [%s] hidden:%s ignore:%s", scope, hidden, ignored)
end

local function live_grep(opts)
	local builtin = require("telescope.builtin")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	opts = vim.tbl_deep_extend("force", {
		cwd = M.resolve_cwd(),
		hidden = false,
		no_ignore = false,
		default_text = nil,
	}, opts or {})

	builtin.live_grep({
		cwd = opts.cwd,
		search_dirs = { opts.cwd },
		hidden = opts.hidden,
		no_ignore = opts.no_ignore,
		default_text = opts.default_text,
		prompt_title = picker_title(opts),
		additional_args = function()
			return { "--glob", "!.git/" }
		end,
		attach_mappings = function(prompt_bufnr, map)
			local function reopen(next_opts)
				local line = action_state.get_current_line()
				actions.close(prompt_bufnr)
				vim.schedule(function()
					live_grep(vim.tbl_deep_extend("force", opts, next_opts, {
						default_text = line,
					}))
				end)
			end

			local function toggle_hidden()
				reopen({ hidden = not opts.hidden })
			end

			local function toggle_ignore()
				reopen({ no_ignore = not opts.no_ignore })
			end

			map({ "i", "n" }, "<M-h>", toggle_hidden, { desc = "Toggle hidden files" })
			map({ "i", "n" }, "<M-i>", toggle_ignore, { desc = "Toggle ignored files" })
			return true
		end,
	})
end

function M.live_grep_cwd()
	live_grep({ cwd = M.resolve_cwd() })
end

function M.live_grep_root()
	live_grep({ cwd = M.resolve_root() })
end

return M

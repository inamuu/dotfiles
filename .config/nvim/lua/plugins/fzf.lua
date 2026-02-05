return {
	"ibhagwan/fzf-lua",
	optional = true,
	opts = function(_, opts)
		local actions = require("fzf-lua.actions")

		-- grepの設定を更新
		opts.grep = opts.grep or {}
		-- デフォルトで隠しファイルも検索対象にする
		opts.grep.rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --glob '!.git/' --glob '!node_modules/' -e"

		-- アクションも保持
		opts.grep.actions = opts.grep.actions or {}
		opts.grep.actions["alt-i"] = { actions.toggle_ignore }
		opts.grep.actions["alt-h"] = { actions.toggle_hidden }

		return opts
	end,
}

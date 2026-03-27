return {
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    config = function()
      require("nvim-tree").setup({
        filters = {
          dotfiles = false,
          git_ignored = false,
        },
        actions = {
          change_dir = {
            enable = true,
            global = true,
          },
        },
        view = {
          width = 34,
          preserve_window_proportions = true,
          signcolumn = "yes",
        },
        renderer = {
          root_folder_label = false,
          group_empty = true,
          highlight_git = true,
          highlight_opened_files = "all",
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "│",
              bottom = "─",
              none = " ",
            },
          },
          icons = {
            glyphs = {
              folder = {
                arrow_closed = "▸",
                arrow_open = "▾",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
      })
    end,
    keys = {
	  {mode = "n", "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "NvimTreeをトグルする"},
    }
  },
}

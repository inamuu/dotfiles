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
          width = 30,
        },
      })
    end,
    keys = {
	  {mode = "n", "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "NvimTreeをトグルする"},
    }
  },
}

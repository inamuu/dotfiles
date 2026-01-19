return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  -- add dracula
  { "Mofiqul/dracula.nvim" },

  -- Configure LazyVim to load dracula
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  }
}

return {
  --add gruvbox
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = {
    terminal_colors = true,
  } },

  -- configure gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}

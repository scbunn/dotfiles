require("vim._core.ui2").enable{}


-- leader must be set before any mappings or plugins load
vim.g.mapleader = ","
vim.g.maplocalleader = ","


require("options")

vim.opt.termguicolors = true

vim.pack.add({
  "https://github.com/ellisonleao/gruvbox.nvim",
})

vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox")

-- ===========================================================================
-- Keymaps
-- ===========================================================================
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- arrow keys are disabled; tell me which hjkl key to use instead
local arrows = { Left = "h", Down = "j", Up = "k", Right = "l" }
for arrow, key in pairs(arrows) do
  vim.keymap.set({ "n", "v", "i" }, "<" .. arrow .. ">", function()
    vim.notify("Use " .. key, vim.log.levels.WARN)
  end, { desc = "Disabled: use " .. key })
end


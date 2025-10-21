require "nvchad.options"

-- add yours here!

-- Ensure files open in single window by default
vim.opt.splitbelow = false  -- Don't split below when opening files
vim.opt.splitright = false  -- Don't split right when opening files

-- File opening behavior
vim.opt.switchbuf = "useopen,usetab"  -- Reuse existing buffers/tabs when possible

-- Window management
vim.opt.equalalways = false  -- Don't automatically resize windows
vim.opt.winfixwidth = false  -- Allow windows to be resized
vim.opt.winfixheight = false  -- Allow windows to be resized

-- Buffer management
vim.opt.hidden = true  -- Allow hidden buffers (already set in performance.lua)
vim.opt.autowrite = false  -- Don't auto-save when switching buffers

-- Enable winbar globally
vim.opt.winbar = ""

-- Number mode switching: absolute in normal, relative in insert/visual
vim.opt.number = true
vim.opt.relativenumber = false

-- Auto-switch number modes based on current mode
local number_group = vim.api.nvim_create_augroup("NumberModeSwitch", { clear = true })

-- Switch to relative numbers when entering insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  group = number_group,
  callback = function()
    vim.opt.relativenumber = true
  end,
})

-- Switch to absolute numbers when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  group = number_group,
  callback = function()
    vim.opt.relativenumber = false
  end,
})

-- Switch to relative numbers when entering visual mode
vim.api.nvim_create_autocmd("ModeChanged", {
  group = number_group,
  pattern = "[^v]*:v",
  callback = function()
    vim.opt.relativenumber = true
  end,
})

-- Switch to absolute numbers when leaving visual mode
vim.api.nvim_create_autocmd("ModeChanged", {
  group = number_group,
  pattern = "v:[^v]*",
  callback = function()
    vim.opt.relativenumber = false
  end,
})

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
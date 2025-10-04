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

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

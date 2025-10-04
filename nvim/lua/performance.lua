-- Performance optimizations for faster Neovim

-- Disable some builtin vim plugins
local disabled_built_ins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Faster updatetime (default is 4000ms)
vim.opt.updatetime = 250

-- Reduce redraw frequency
vim.opt.lazyredraw = false -- keep false for better experience

-- Faster completion
vim.opt.completeopt = "menu,menuone,noselect"

-- Disable swap files (can cause lag)
vim.opt.swapfile = false

-- Better search performance
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Faster scrolling
vim.opt.scrolljump = 1
vim.opt.sidescrolloff = 3

-- Memory optimizations
vim.opt.hidden = true
vim.opt.history = 100

-- Disable unnecessary providers for faster startup
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

print("Performance optimizations loaded")
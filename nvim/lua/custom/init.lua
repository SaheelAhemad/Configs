-- Enable inline virtual text for diagnostics
vim.diagnostic.config({
  virtual_text = true,   -- show inline error messages
  signs = true,          -- show signs in gutter (default)
  underline = true,      -- underline problematic code
  update_in_insert = false,
})
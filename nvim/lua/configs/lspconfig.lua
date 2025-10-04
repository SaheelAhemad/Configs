require("nvchad.configs.lspconfig").defaults()

-- Diagnostic configuration (W for warnings, E for errors only)
vim.diagnostic.config({
  virtual_text = false,  -- No inline text
  signs = true,          -- Show signs in gutter (W for warnings, E for errors)
  underline = false,     -- No underlines
  update_in_insert = false,
  severity_sort = true,
  -- Show warnings and errors only (hide info and hints)
  severity = {
    min = vim.diagnostic.severity.WARN,
    max = vim.diagnostic.severity.ERROR,
  },
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    show_header = false,
  },
})

-- Explicitly hide INFO and HINT diagnostics
vim.diagnostic.config({
  signs = {
    [vim.diagnostic.severity.INFO] = { text = "", numhl = "", linehl = "", texthl = "" },
    [vim.diagnostic.severity.HINT] = { text = "", numhl = "", linehl = "", texthl = "" },
  },
})

-- Additional filter to completely hide INFO and HINT diagnostics
vim.diagnostic.handlers["INFO"] = {
  show = function() end,
  hide = function() end,
}
vim.diagnostic.handlers["HINT"] = {
  show = function() end,
  hide = function() end,
}


-- VS Code-style hover delay
vim.opt.updatetime = 300

-- Hover diagnostics (warnings and errors only)
local function show_hover_diagnostic()
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") - 1 })
  
  -- Filter to only show warnings and errors
  local filtered_diagnostics = {}
  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR or 
       diagnostic.severity == vim.diagnostic.severity.WARN then
      table.insert(filtered_diagnostics, diagnostic)
    end
  end
  
  if #filtered_diagnostics > 0 then
    -- Close any existing float
    vim.diagnostic.hide()
    
    local opts = {
      focusable = false,
      close_events = { "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" },
      border = "rounded",
      source = "always",
      prefix = function(diagnostic)
        if diagnostic.severity == vim.diagnostic.severity.ERROR then
          return "Error: "
        elseif diagnostic.severity == vim.diagnostic.severity.WARN then
          return "Warning: "
        end
        return ""
      end,
      scope = "cursor",
      max_width = 80,
      max_height = 10,
      header = "",
      style = "minimal",
      relative = "cursor",
      row = 1,
      col = 0,
    }
    vim.diagnostic.open_float(nil, opts)
  end
end

-- Show diagnostics on hover (VS Code style)
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  group = vim.api.nvim_create_augroup("vscode_hover_diagnostics", { clear = true }),
  callback = show_hover_diagnostic,
})

-- No visual diagnostic indicators - clean interface


-- Enhanced LSP servers for comprehensive error detection
local servers = { 
  "html", 
  "cssls", 
  "gopls",
  "lua_ls",        -- Lua language server for syntax errors
  "jsonls",        -- JSON language server
  "yamlls",        -- YAML language server
  "bashls",        -- Bash language server
  "pyright",       -- Python language server (better than pylsp)
  "tsserver",      -- TypeScript/JavaScript language server
  "eslint",        -- JavaScript/TypeScript linting
  "clangd",        -- C/C++ language server
  "rust_analyzer", -- Rust language server
  "jdtls",         -- Java language server
}

-- Enable all servers
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers

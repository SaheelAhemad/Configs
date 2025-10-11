require("nvchad.configs.lspconfig").defaults()

-- diagnostic configuration (w for warnings, e for errors only)
vim.diagnostic.config({
  virtual_text = false, -- no inline text
  signs = true,         -- show signs in gutter (w for warnings, e for errors)
  underline = true,     -- no underlines
  update_in_insert = false,
  severity_sort = true,
  -- show warnings and errors only (hide info and hints)
  severity = {
    -- min = vim.diagnostic.severity.warn,
    max = vim.diagnostic.severity.error,
  },
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    show_header = true,
  },
})
--
-- -- explicitly hide info and hint diagnostics
-- vim.diagnostic.config({
--   signs = {
--     [vim.diagnostic.severity.info] = { text = "", numhl = "", linehl = "", texthl = "" },
--     [vim.diagnostic.severity.hint] = { text = "", numhl = "", linehl = "", texthl = "" },
--   },
-- })
--
-- -- additional filter to completely hide info and hint diagnostics
-- vim.diagnostic.handlers["info"] = {
--   show = function() end,
--   hide = function() end,
-- }
-- vim.diagnostic.handlers["hint"] = {
--   show = function() end,
--   hide = function() end,
-- }
--

-- vs code-style hover delay vim.opt.updatetime = 300
-- hover diagnostics (warnings and errors only)
local function show_hover_diagnostic()
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") - 1 })

  -- filter to only show warnings and errors
  local filtered_diagnostics = {}
  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.error or
        diagnostic.severity == vim.diagnostic.severity.warn then
      table.insert(filtered_diagnostics, diagnostic)
    end
  end

  if #filtered_diagnostics > 0 then
    -- close any existing float
    vim.diagnostic.hide()

    local opts = {
      focusable = true,
      close_events = { "cursormoved", "cursormovedi", "insertenter", "bufleave" },
      border = "rounded",
      source = "always",
      prefix = function(diagnostic)
        if diagnostic.severity == vim.diagnostic.severity.error then
          return "error: "
        elseif diagnostic.severity == vim.diagnostic.severity.warn then
          return "warning: "
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

-- show diagnostics on hover and cursor movement (vs code style)
vim.api.nvim_create_autocmd({ "cursorhold", "cursormoved" }, {
  group = vim.api.nvim_create_augroup("vscode_hover_diagnostics", { clear = true }),
  callback = show_hover_diagnostic,
})

-- no visual diagnostic indicators - clean interface


-- enhanced lsp servers for comprehensive error detection
local servers = {
  "html",
  "cssls",
  "gopls",
  "lua_ls",        -- lua language server for syntax errors
  "jsonls",        -- json language server
  "yamlls",        -- yaml language server
  "bashls",        -- bash language server
  "pyright",       -- python language server (better than pylsp)
  "tsserver",      -- typescript/javascript language server
  "eslint",        -- javascript/typescript linting
  "clangd",        -- c/c++ language server
  "rust_analyzer", -- rust language server
  "jdtls",         -- java language server
}

-- enable all servers
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers

-- =============================
-- diagnostic line highlighting
-- =============================

local diag_linehl_enabled = true

-- define highlight groups
vim.api.nvim_set_hl(0, "diagnosticlineerror", { bg = "#3b1f22", fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "diagnosticlinewarn", { bg = "#37311b", fg = "#ffd93d" })

-- override diagnostic config to include line highlighting
local original_diag_config = vim.diagnostic.config

local function update_diag_config()
  local config = {
    virtual_text = false,
    signs = true,
    underline = false,
    update_in_insert = false,
    severity_sort = true,
    severity = {
      min = vim.diagnostic.severity.warn,
      max = vim.diagnostic.severity.error,
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
  }

  if diag_linehl_enabled then
    config.signs = {
      [vim.diagnostic.severity.error] = {
        text = "e",
        texthl = "diagnosticsignerror",
        linehl = "diagnosticlineerror",
        numhl = "diagnosticsignerror"
      },
      [vim.diagnostic.severity.warn] = {
        text = "w",
        texthl = "diagnosticsignwarn",
        linehl = "diagnosticlinewarn",
        numhl = "diagnosticsignwarn"
      },
    }
  end

  vim.diagnostic.config(config)
end

-- apply the configuration
update_diag_config()

-- force diagnostic refresh when opening files to show line highlighting immediately
vim.api.nvim_create_autocmd({ "bufreadpost", "bufenter" }, {
  group = vim.api.nvim_create_augroup("diagnostic_refresh_on_open", { clear = true }),
  callback = function(args)
    -- only for normal files
    if vim.bo[args.buf].buftype == "" and vim.api.nvim_buf_get_name(args.buf) ~= "" then
      -- small delay to ensure lsp has attached and processed the file
      vim.defer_fn(function()
        vim.diagnostic.show(args.buf)
      end, 100)
    end
  end,
})

-- re-apply after colorscheme changes
vim.api.nvim_create_autocmd("colorscheme", {
  group = vim.api.nvim_create_augroup("diagnostic_linehl_refresh", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "diagnosticlineerror", { bg = "#3b1f22", fg = "#ff6b6b" })
    vim.api.nvim_set_hl(0, "diagnosticlinewarn", { bg = "#37311b", fg = "#ffd93d" })
    update_diag_config()
  end,
})

-- toggle command
vim.api.nvim_create_user_command("diaglinehltoggle", function()
  diag_linehl_enabled = not diag_linehl_enabled
  update_diag_config()
  local state = diag_linehl_enabled and "enabled" or "disabled"
  vim.notify("diagnostic line highlight " .. state, vim.log.levels.info)
end, { desc = "toggle diagnostic line background highlight" })

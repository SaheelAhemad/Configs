require("nvchad.autocmds")

local virt_ns = vim.api.nvim_create_namespace("diagnostic_virtual_lines_aligned")

-- Display virtual text at the error region
local function render_virtual_diagnostics(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, virt_ns, 0, -1)

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local diagnostics = vim.diagnostic.get(bufnr)

  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      -- Check line validity
      if diagnostic.lnum < 0 or diagnostic.lnum >= line_count then
        -- Skip invalid line numbers
        goto continue
      end

      local hl_group = "DiagnosticVirtualTextError"
      local msg = diagnostic.message:gsub("\n", " ")
      local padding = string.rep(" ", diagnostic.col)

      local virt_line = {
        { padding .. "↳ ", "Comment" },
        { "● ", hl_group },
        { msg, hl_group },
      }

      vim.api.nvim_buf_set_extmark(bufnr, virt_ns, diagnostic.lnum, 0, {
        virt_lines = { virt_line },
        virt_lines_above = false,
        hl_mode = "combine",
      })

      ::continue::
    end
  end
end


vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "DiagnosticChanged" }, {
  group = vim.api.nvim_create_augroup("vscode_virtual_diagnostics", { clear = true }),
  callback = function(args)
    render_virtual_diagnostics(args.buf)
  end,
})

-- Floating popup on hover/move
local function show_diagnostic_popup()
  local opts = {
    focusable = false,
    close_events = { "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" },
    border = "rounded",
    source = "always",
    scope = "cursor",
    prefix = function(diagnostic)
      if diagnostic.severity == vim.diagnostic.severity.ERROR then
        return "Error: "
      end
      return ""
    end,
  }

  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if diagnostics and #diagnostics > 0 then
    vim.diagnostic.open_float(nil, opts)
  end
end

vim.api.nvim_create_autocmd({ "CursorHold", "CursorMoved" }, {
  group = vim.api.nvim_create_augroup("hover_diagnostics_popup", { clear = true }),
  callback = show_diagnostic_popup,
})

-- AutoSave
local autosave_enabled = true
local autosave_timer = nil

local function should_save(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return false end
  if vim.bo[buf].buftype ~= "" then return false end
  if not vim.bo[buf].modifiable then return false end
  if vim.bo[buf].readonly then return false end
  if vim.api.nvim_buf_get_name(buf) == "" then return false end
  if not vim.api.nvim_buf_get_option(buf, "modified") then return false end
  return true
end

local function autosave_write(buf)
  if not autosave_enabled then return end
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if should_save(buf) then
    pcall(vim.api.nvim_buf_call, buf, function()
      vim.cmd("silent noautocmd write")
    end)
  end
end

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("autosave_idle", { clear = true }),
  callback = function(args)
    if autosave_timer then
      autosave_timer:stop()
    end
    autosave_timer = vim.defer_fn(function()
      autosave_write(args.buf)
    end, 1000)
  end,
})

vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("autosave_focus", { clear = true }),
  callback = function(args)
    autosave_write(args.buf)
  end,
})

vim.api.nvim_create_user_command("AutosaveToggle", function()
  autosave_enabled = not autosave_enabled
  local state = autosave_enabled and "enabled" or "disabled"
  vim.notify("Autosave " .. state, vim.log.levels.INFO)
end, { desc = "Toggle autosave" })
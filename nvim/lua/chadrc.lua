-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig

local M = {}

M.base46 = {
  theme = "ayu_dark",
  transparency = false, -- transparency can cause lag
}

-- Custom statusline with git info
M.ui = {
  statusline = {
    theme = "minimal",
    separator_style = "round",
    order = { "mode", "git", "file", "%=", "cursor" },
    modules = {
      git = function()
        -- Prefer gitsigns' detected head for the current buffer
        local head = vim.b.gitsigns_head
        if not head or head == "" then
          -- Fallback to shell call if gitsigns not available yet
          local ok, branch = pcall(function()
            local handle = io.popen(
            "git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null")
            if handle then
              local result = handle:read("*a"):gsub("\n", "")
              handle:close()
              return result
            end
            return ""
          end)
          head = ok and branch or ""
        end

        if head ~= nil and head ~= "" then
          return "%#St_gitIcons# 󰊢 " .. head .. " "
        end

        return ""
      end,
    },
  },
}


-- Performance optimizations
M.lazy_nvim = {
  performance = {
    rtp = {
      disabled_plugins = {},
    },
  },
}

return M

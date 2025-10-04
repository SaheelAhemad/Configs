-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "aylin",
	transparency = false, -- transparency can cause lag

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- Custom statusline with git info
M.ui = {
  statusline = {
    theme = "minimal",
    separator_style = "round",
    order = { "mode", "git", "file", "%=", "cursor" },
    modules = {
      git = function()
        -- Load git branch once and keep it permanent
        if not vim.g._git_branch_permanent then
          local ok, branch = pcall(function()
            local handle = io.popen("git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null")
            if handle then
              local result = handle:read("*a"):gsub("\n", "")
              handle:close()
              return result
            end
            return "no-git"
          end)
          
          vim.g._git_branch_permanent = ok and branch or "no-git"
        end
        
        -- Always return the permanent branch
        return "%#St_gitIcons# 󰊢 " .. vim.g._git_branch_permanent .. " "
      end,
    },
  },
  
  -- Enable tabufline to show open files at top
  tabufline = {
    enabled = true,
    lazyload = true,
  },
}

return M

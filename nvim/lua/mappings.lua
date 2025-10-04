require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- VS Code-style error navigation
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })

-- Error-only navigation
map("n", "]e", function() 
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) 
end, { desc = "Next error" })
map("n", "[e", function() 
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) 
end, { desc = "Previous error" })

-- Warning-only navigation
map("n", "]w", function() 
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN }) 
end, { desc = "Next warning" })
map("n", "[w", function() 
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN }) 
end, { desc = "Previous warning" })

-- Manual diagnostic display (warnings and errors only)
map("n", "<leader>e", function()
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
    vim.diagnostic.open_float(nil, {
      focusable = false,
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
      max_width = 80,
      max_height = 10,
    })
  else
    vim.notify("No warnings or errors on current line", vim.log.levels.INFO)
  end
end, { desc = "Show diagnostic message" })
map("n", "<leader>E", vim.diagnostic.hide, { desc = "Hide diagnostic message" })

-- Go test running
map("n", "<leader>tt", function()
  if vim.bo.filetype ~= "go" then
    vim.notify("Not a Go file!", vim.log.levels.WARN)
    return
  end

  vim.cmd("w") -- Save file before test

  -- Run all tests in the entire project (from project root)
  local project_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
  if project_root == "" then
    -- Fallback to current directory if not in a git repo
    project_root = vim.fn.getcwd()
  end
  
  local cmd = string.format("cd %s && go test -v ./...", vim.fn.shellescape(project_root))
  vim.notify("Running all tests in project: " .. project_root, vim.log.levels.INFO)
  vim.cmd("!" .. cmd)
end, { desc = "Run all Go tests in entire project" })

map("n", "<leader>tf", function()
  if vim.bo.filetype ~= "go" then
    vim.notify("Not a Go file!", vim.log.levels.WARN)
    return
  end

  vim.cmd("w") -- Save file before test

  -- Run all tests in the current file only
  local file_dir = vim.fn.expand("%:p:h")
  local file_name = vim.fn.expand("%:t:r") -- Get filename without extension
  
  local cmd = string.format("cd %s && go test -v -run %s", 
    vim.fn.shellescape(file_dir), 
    vim.fn.shellescape(file_name)
  )

  vim.notify("Running all tests in file: " .. file_name, vim.log.levels.INFO)
  vim.cmd("!" .. cmd)
end, { desc = "Run all Go tests in current file" })

map("n", "<leader>ts", function()
  if vim.bo.filetype ~= "go" then
    vim.notify("Not a Go file!", vim.log.levels.WARN)
    return
  end

  vim.cmd("w") -- Save file before test

  -- Get current line
  local current_line = vim.fn.line(".")
  
  -- Find test function using a simple approach
  local test_name = nil
  
  -- Search backwards from current line
  for i = current_line, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(0, i-1, i, false)[1]
    if line then
      -- Look for any function that starts with "Test" (with or without implementation)
      local patterns = {
        "func%s+(Test%w+)%s*%(",  -- func TestSomething(
        "func%s+%(%w+%s*%*%w+%)%s+(Test%w+)%s*%(",  -- func (receiver *AnyStruct) TestSomething(
        "func%s+(Test%w+)%s*%(%w*%)%s*%w*",  -- func TestSomething() returnType (interface methods)
        "func%s+%(%w+%s*%*%w+%)%s+(Test%w+)%s*%(%w*%)%s*%w*",  -- func (receiver *AnyStruct) TestSomething() returnType
        "func%s+(Test%w+[_%w]*)%s*%(",  -- func TestSomething_WithUnderscores(
        "func%s+%(%w+%s*%*%w+%)%s+(Test%w+[_%w]*)%s*%(",  -- func (receiver *AnyStruct) TestSomething_WithUnderscores(
      }
      
      for _, pattern in ipairs(patterns) do
        local match = line:match(pattern)
        if match then
          test_name = match
          break
        end
      end
      
      if test_name then break end
    end
  end
  
  if not test_name then
    vim.notify("No test function found above cursor", vim.log.levels.ERROR)
    return
  end
  
  -- Run the specific test function
  local file_dir = vim.fn.expand("%:p:h")
  local cmd = string.format("cd %s && go test -v -run %s", vim.fn.shellescape(file_dir), vim.fn.shellescape(test_name))
  
  vim.notify("Running single test: " .. test_name, vim.log.levels.INFO)
  vim.cmd("!" .. cmd)
end, { desc = "Run single Go test function under cursor" })

-- Telescope keybindings - ensure single window opening
map("n", "<leader>ff", function()
  -- Ensure we're in single window mode before opening telescope
  local windows = vim.api.nvim_list_wins()
  if #windows > 1 then
    vim.cmd("only")  -- Close all windows except current
  end
  vim.cmd("Telescope find_files")
end, { desc = "Find files" })

map("n", "<leader>fg", function()
  local windows = vim.api.nvim_list_wins()
  if #windows > 1 then
    vim.cmd("only")
  end
  vim.cmd("Telescope live_grep")
end, { desc = "Live grep" })

map("n", "<leader>fb", function()
  local windows = vim.api.nvim_list_wins()
  if #windows > 1 then
    vim.cmd("only")
  end
  vim.cmd("Telescope buffers")
end, { desc = "Find buffers" })

map("n", "<leader>fh", function()
  local windows = vim.api.nvim_list_wins()
  if #windows > 1 then
    vim.cmd("only")
  end
  vim.cmd("Telescope help_tags")
end, { desc = "Help tags" })

map("n", "<leader>fr", function()
  local windows = vim.api.nvim_list_wins()
  if #windows > 1 then
    vim.cmd("only")
  end
  vim.cmd("Telescope oldfiles")
end, { desc = "Recent files" })

map("n", "<leader>fc", function()
  local windows = vim.api.nvim_list_wins()
  if #windows > 1 then
    vim.cmd("only")
  end
  vim.cmd("Telescope commands")
end, { desc = "Commands" })

map("n", "<leader>fk", function()
  local windows = vim.api.nvim_list_wins()
  if #windows > 1 then
    vim.cmd("only")
  end
  vim.cmd("Telescope keymaps")
end, { desc = "Keymaps" })

-- Buffer switching
map("n", "t", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "T", "<cmd>bprevious<cr>", { desc = "Previous buffer" })


-- Override default file opening to ensure single window
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    -- When NvimTree opens, ensure it doesn't create splits
    vim.keymap.set("n", "<CR>", function()
      local node = require("nvim-tree.lib").get_node_at_cursor()
      if node and node.absolute_path then
        -- Close NvimTree first, then open file in single window
        vim.cmd("NvimTreeClose")
        vim.cmd("edit " .. vim.fn.fnameescape(node.absolute_path))
      end
    end, { buffer = true, desc = "Open file in single window" })
  end,
})

-- Terminal keybindings
map("n", "<leader>ot", function()
  -- Check if NvimTree is open
  local nvim_tree_open = false
  local windows = vim.api.nvim_list_wins()
  
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    
    if filetype == "NvimTree" then
      nvim_tree_open = true
      break
    end
  end
  
  if nvim_tree_open then
    -- If NvimTree is open, open terminal in the main area (right side)
    vim.cmd("wincmd l") -- Move to right window (main area)
    vim.cmd("split | terminal")
    vim.cmd("wincmd J") -- Move terminal to bottom
    vim.cmd("resize 15") -- Set terminal height
  else
    -- If NvimTree is not open, open terminal normally
    vim.cmd("split | terminal")
    vim.cmd("wincmd J") -- Move terminal to bottom
    vim.cmd("resize 15") -- Set terminal height
  end
end, { desc = "Open terminal at bottom (after NvimTree if open)" })

-- Git diff window management with original file tracking
local original_file_path = nil

-- Store original file path before opening git diffs
local function store_original_file()
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(current_buf)
  local buftype = vim.bo.buftype
  
  -- Only store if it's a real file (not temporary buffer)
  if buf_name ~= "" and buftype ~= "nofile" and not buf_name:match("HEAD") and not buf_name:match(":%%") then
    original_file_path = buf_name
  end
end

-- Restore original file
local function restore_original_file()
  if original_file_path and vim.fn.filereadable(original_file_path) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(original_file_path))
    return true
  end
  return false
end



-- Alternative command for closing git buffers (same as gq but different key)
map("n", "<leader>gQ", function()
  -- Try to restore original file first
  if restore_original_file() then
    vim.notify("Returned to original file", vim.log.levels.INFO)
  end
  
  -- Find and close all git-related buffers
  local buffers = vim.api.nvim_list_bufs()
  local git_buffers = {}
  
  for _, buf in ipairs(buffers) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
    
    -- Check if this is a git-related buffer
    local is_git_buffer = buf_name:match("Git Diff") or 
                          buf_name:match("git diff") or 
                          buf_name:match("Git Blame") or
                          buf_name:match("Select Commit") or
                          buf_name:match("Select Branch") or
                          buf_name:match("Git Diff vs") or
                          buf_name:match("HEAD") or  -- Git revision files like HEAD~:file.go
                          buf_name:match(":%%") or   -- Git revision format (escaped %)
                          filetype == "diff" or 
                          filetype == "git" or
                          (buftype == "nofile" and buf_name:match("diff"))
    
    if is_git_buffer then
      table.insert(git_buffers, buf)
    end
  end
  
  -- Close git buffers
  for _, buf in ipairs(git_buffers) do
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  
  -- Close extra windows but keep at least one
  local windows = vim.api.nvim_list_wins()
  if #windows > 1 then
    -- Close windows that don't have valid buffers
    for i = #windows, 1, -1 do
      local win = windows[i]
      local win_buf = vim.api.nvim_win_get_buf(win)
      if not vim.api.nvim_buf_is_valid(win_buf) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end
  
  vim.notify("Closed " .. #git_buffers .. " git diff buffers", vim.log.levels.INFO)
end, { desc = "Close all git diff buffers and return to original file (alternative)" })

-- Manual command to store current file as original (useful before opening git diffs)
map("n", "<leader>gS", function()
  store_original_file()
  if original_file_path then
    vim.notify("Stored original file: " .. vim.fn.fnamemodify(original_file_path, ":t"), vim.log.levels.INFO)
  else
    vim.notify("No valid file to store as original", vim.log.levels.WARN)
  end
end, { desc = "Store current file as original (before git diff)" })

-- Force return to working file (handles git revision files)
map("n", "<leader>gR", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(current_buf)
  
  -- Check if we're in a git revision file
  if buf_name:match("HEAD") or buf_name:match(":%%") then
    -- Extract the actual filename from git revision path
    local actual_file = buf_name:match(":([^:]+)$")
    if actual_file then
      -- Try to find the working directory and construct full path
      local cwd = vim.fn.getcwd()
      local full_path = cwd .. "/" .. actual_file
      
      if vim.fn.filereadable(full_path) == 1 then
        -- Delete the git revision buffer first
        vim.api.nvim_buf_delete(current_buf, { force = true })
        -- Open the working file
        vim.cmd("edit " .. vim.fn.fnameescape(full_path))
        vim.notify("Deleted git revision and opened working file: " .. actual_file, vim.log.levels.INFO)
        return
      end
    end
  end
  
  -- If not a git revision file, try normal restoration
  if restore_original_file() then
    vim.notify("Returned to original file", vim.log.levels.INFO)
  else
    vim.notify("Could not find working file", vim.log.levels.WARN)
  end
end, { desc = "Force return to working file (handles git revisions)" })

-- Debug command to show current buffer info (DISABLED)
-- map("n", "<leader>gd", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(current_buf)
  local filetype = vim.bo.filetype
  local buftype = vim.bo.buftype
  
  vim.notify("=== DEBUG INFO ===", vim.log.levels.INFO)
  vim.notify("Buffer name: " .. buf_name, vim.log.levels.INFO)
  vim.notify("Filetype: " .. filetype, vim.log.levels.INFO)
  vim.notify("Buftype: " .. buftype, vim.log.levels.INFO)
  vim.notify("Is HEAD: " .. tostring(buf_name:match("HEAD")), vim.log.levels.INFO)
  vim.notify("Has colon: " .. tostring(buf_name:match(":%%")), vim.log.levels.INFO)
  
  -- Show all buffers
  local buffers = vim.api.nvim_list_bufs()
  vim.notify("Total buffers: " .. #buffers, vim.log.levels.INFO)
  for i, buf in ipairs(buffers) do
    local buf_name_check = vim.api.nvim_buf_get_name(buf)
    if buf_name_check ~= "" then
      vim.notify("Buffer " .. i .. ": " .. buf_name_check, vim.log.levels.INFO)
    end
  end
-- end, { desc = "Debug: Show current buffer info" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

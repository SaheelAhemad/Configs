require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- Basic navigation
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Override NvChad's default <C-n> to use Neotree instead of nvim-tree
map("n", "<C-n>", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neo-tree", noremap = true, silent = true })

-- Disable nvim-tree commands and redirect to Neotree
vim.api.nvim_create_user_command("NvimTreeToggle", function()
  vim.cmd("Neotree toggle")
end, { desc = "Redirect NvimTreeToggle to Neotree" })

vim.api.nvim_create_user_command("NvimTreeFocus", function()
  vim.cmd("Neotree focus")
end, { desc = "Redirect NvimTreeFocus to Neotree" })

-- Enhanced diagnostic navigation
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

-- Switch tabs
map("n", "t", "<cmd>bnext<cr>", { desc = "Next buffer", noremap = true, silent = true })
map("n", "T", "<cmd>bprevious<cr>", { desc = "Previous buffer", noremap = true, silent = true })

-- Terminal keybindings
map("n", "<leader>ot", function()
  -- Check if neo-tree is open
  local neo_tree_open = false
  local windows = vim.api.nvim_list_wins()
  
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    
    if filetype == "neo-tree" then
      neo_tree_open = true
      break
    end
  end
  
  if neo_tree_open then
    -- If neo-tree is open, open terminal in the main area (right side)
    vim.cmd("wincmd l") -- Move to right window (main area)
    vim.cmd("ToggleTerm direction=horizontal")
  else
    -- If neo-tree is not open, open terminal normally
    vim.cmd("ToggleTerm direction=horizontal")
  end
end, { desc = "Open terminal at bottom (after neo-tree if open)" })

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
map("n", "<leader>gq", function()
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

map("n", "<leader>ts", function()
  if vim.bo.filetype ~= "go" then
    vim.notify("Not a Go file!", vim.log.levels.WARN)
    return
  end

  vim.cmd("w") -- Save file

  local test_method = nil
  local suite_func = nil
  local normal_func = nil

  local current_line = vim.fn.line(".")

  -- Step 1: Search upward for test method or normal func
  for i = current_line, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

    if line then
      -- Match suite test method: func (suite *SuiteType) TestXxx()
      if not test_method then
        local method = line:match("^func%s+%([^%)]+%)%s+(Test%w+)%s*%(")
        if method then
          test_method = method
        end
      end

      -- Match regular test function
      if not normal_func then
        local func = line:match("^func%s+(Test%w+)%s*%(")
        if func then
          normal_func = func
        end
      end

      if test_method and normal_func then break end
    end
  end

  -- Step 2: If this is a suite method, search whole file for suite runner
  if test_method and not suite_func then
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for _, line in ipairs(lines) do
      -- look for: func TestCalculatorTestSuite(t *testing.T)
      local suite = line:match("^func%s+(Test%w+)%s*%(")
      if suite then
        suite_func = suite
        break
      end
    end
  end

  -- Step 3: Build test command
  local file_dir = vim.fn.expand("%:p:h")
  local cmd = ""

  if test_method and suite_func then
    -- Suite test method
    cmd = string.format(
      "cd %s && go test -v -run '^%s$' -testify.m '^%s$'",
      vim.fn.shellescape(file_dir),
      suite_func,
      test_method
    )
    vim.notify("Running suite method: " .. suite_func .. " -> " .. test_method, vim.log.levels.INFO)
  elseif normal_func then
    -- Regular Go test function
    cmd = string.format(
      "cd %s && go test -v -run '^%s$'",
      vim.fn.shellescape(file_dir),
      normal_func
    )
    vim.notify("Running test function: " .. normal_func, vim.log.levels.INFO)
  else
    vim.notify("Could not determine test to run.", vim.log.levels.ERROR)
    return
  end

  vim.cmd("!" .. cmd)
end, { desc = "Run Go test under cursor (regular or testify suite)" })

map("n", "<leader>tf", function()
  if vim.bo.filetype ~= "go" then
    vim.notify("Not a Go file!", vim.log.levels.WARN)
    return
  end

  vim.cmd("w")

  local current_line = vim.fn.line(".")
  local suite_func = nil

  -- Look upward for suite function
  for i = current_line, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    if line then
      local match = line:match("^func%s+(Test%w+)%s*%(")
      if match then
        suite_func = match
        break
      end
    end
  end

  if not suite_func then
    vim.notify("No suite function found above cursor!", vim.log.levels.ERROR)
    return
  end

  local file_dir = vim.fn.expand("%:p:h")
  local cmd = string.format("cd %s && go test -v -run '^%s$'", vim.fn.shellescape(file_dir), suite_func)

  vim.notify("Running ALL tests in suite: " .. suite_func, vim.log.levels.INFO)
  vim.cmd("!" .. cmd)
end, { desc = "Run entire Go test suite under cursor" })

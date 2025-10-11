return {
  -- Test function visual indicators
  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPost",
    config = function()
      -- Custom test function highlighting
      local function setup_test_indicators()
        -- Define test function highlight group with green color
        vim.api.nvim_set_hl(0, "TestFunction", { 
          fg = "#98c379",  -- Green color like VS Code
          bold = true,
          italic = true
        })
        
        -- Create autocmd to highlight test functions
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged" }, {
          pattern = "*.go",
          callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            local ns_id = vim.api.nvim_create_namespace("test_functions")
            
            -- Clear existing highlights
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
            
            -- Get all lines
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            
            for line_num, line in ipairs(lines) do
              -- Match test functions: any function that starts with "Test" (with or without implementation)
              local patterns = {
                "func%s+(Test%w+)%s*%(",  -- func TestSomething(
                "func%s+%(%w+%s*%*%w+%)%s+(Test%w+)%s*%(",  -- func (receiver *AnyStruct) TestSomething(
                "func%s+(Test%w+)%s*%(%w*%)%s*%w*",  -- func TestSomething() returnType (interface methods)
                "func%s+%(%w+%s*%*%w+%)%s+(Test%w+)%s*%(%w*%)%s*%w*",  -- func (receiver *AnyStruct) TestSomething() returnType
                "func%s+(Test%w+[_%w]*)%s*%(",  -- func TestSomething_WithUnderscores(
                "func%s+%(%w+%s*%*%w+%)%s+(Test%w+[_%w]*)%s*%(",  -- func (receiver *AnyStruct) TestSomething_WithUnderscores(
              }
              
              local is_test_function = false
              for _, pattern in ipairs(patterns) do
                local match = line:match(pattern)
                if match then
                  is_test_function = true
                  break
                end
              end
              
              if is_test_function then
                -- Highlight the entire function declaration line
                vim.api.nvim_buf_add_highlight(
                  bufnr, 
                  ns_id, 
                  "TestFunction", 
                  line_num - 1, 
                  0, 
                  -1
                )
              end
            end
          end,
        })
      end
      
      setup_test_indicators()
    end,
  },

  -- Plugin for go debug
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require('dap')

      -- Toggle breakpoint keymap
      vim.api.nvim_set_keymap('n', '<leader>ab', ":lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
      -- Continue keymap
      vim.api.nvim_set_keymap('n', '<leader>cd', ":lua require'dap'.continue()<CR>", { noremap = true, silent = true })

      -- Go adapter configuration using delve
      dap.adapters.go = {
        type = 'server',
        host = '127.0.0.1',
        port = '${port}',
        executable = {
          command = 'dlv',
          args = { 'dap', '-l', '127.0.0.1:${port}' },
        }
      }

      dap.configurations.go = {
        {
          type = 'go',
          name = 'Debug',
          request = 'launch',
          program = '${file}',
        },
        {
          type = 'go',
          name = 'Debug test',
          request = 'launch',
          mode = 'test',
          program = '${file}',
        },
        {
          type = 'go',
          name = 'Debug test (package)',
          request = 'launch',
          mode = 'test',
          program = './${relativeFileDirname}',
        }
      }

      -- Optional: Define a sign for breakpoints
      vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})

    end,
  },

}

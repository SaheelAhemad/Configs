return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPost",
    config = function()
      local function setup_test_indicators()
        vim.api.nvim_set_hl(0, "TestFunction", { fg = "#98c379", bold = true, italic = true })
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged" }, {
          pattern = "*.go",
          callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            local ns_id = vim.api.nvim_create_namespace("test_functions")
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            for line_num, line in ipairs(lines) do
              local patterns = {
                "func%s+(Test%w+)%s*%(",
                "func%s+%(%w+%s*%*%w+%)%s+(Test%w+)%s*%(",
                "func%s+(Test%w+)%s*%(%w*%)%s*%w*",
                "func%s+%(%w+%s*%*%w+%)%s+(Test%w+)%s*%(%w*%)%s*%w*",
                "func%s+(Test%w+[_%w]*)%s*%(",
                "func%s+%(%w+%s*%*%w+%)%s+(Test%w+[_%w]*)%s*%(",
              }
              local is_test_function = false
              for _, pattern in ipairs(patterns) do
                if line:match(pattern) then
                  is_test_function = true
                  break
                end
              end
              if is_test_function then
                vim.api.nvim_buf_add_highlight(bufnr, ns_id, "TestFunction", line_num - 1, 0, -1)
              end
            end
          end,
        })
      end
      setup_test_indicators()
    end,
  },
}


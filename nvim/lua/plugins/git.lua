return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require('gitsigns').setup({
        signs = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged_enable = false,
        signcolumn = true,
        numhl      = false,
        linehl     = false,
        word_diff  = false,
        watch_gitdir = { follow_files = true },
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
          end
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc="Next Git hunk"})
          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc="Previous Git hunk"})
          map('n', '<leader>ga', gs.stage_hunk, {desc="Stage hunk"})
          map('n', '<leader>gr', gs.reset_hunk, {desc="Reset hunk"})
          map('v', '<leader>ga', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc="Stage hunk (visual)"})
          map('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc="Reset hunk (visual)"})
          map('n', '<leader>gA', gs.stage_buffer, {desc="Stage buffer"})
          map('n', '<leader>gu', gs.undo_stage_hunk, {desc="Undo stage hunk"})
          -- Use <leader>gX to avoid conflict with user's <leader>gR
          map('n', '<leader>gX', gs.reset_buffer, {desc="Reset buffer"})
          map('n', '<leader>gp', gs.preview_hunk, {desc="Preview hunk"})
          map('n', '<leader>gb', function() gs.blame_line{full=true} end, {desc="Git blame line"})
          map('n', '<leader>gt', gs.toggle_current_line_blame, {desc="Toggle line blame"})
          map('n', '<leader>gd', function() gs.diffthis('~') end, {desc="Diff this (cached)"})
          map('n', '<leader>gT', gs.toggle_deleted, {desc="Toggle deleted"})
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc="Select hunk"})
        end
      })
      vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#98c379" })
      vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#e5c07b" })
      vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#e06c75" })
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitFilter" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
  },

  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
      { "<leader>gw", "<cmd>Gwrite<cr>", desc = "Git Write" },
      { "<leader>gl", "<cmd>Git log --oneline<cr>", desc = "Git Log" },
      { "<leader>gP", "<cmd>Git push<cr>", desc = "Git Push" },
      { "<leader>gL", "<cmd>Git pull<cr>", desc = "Git Pull" },
    }
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
    }
  },
}


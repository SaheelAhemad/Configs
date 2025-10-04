return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre", "BufNewFile" }, -- lazy load on write or new file
    cmd = { "ConformInfo" },
    opts = require "configs.conform",
  },

  -- Git signs in the gutter
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
        signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          follow_files = true
        },
        attach_to_untracked = true,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
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

          -- Navigation
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

          -- Actions - All moved to <leader><g> tab
          map('n', '<leader>ga', gs.stage_hunk, {desc="Stage hunk"})
          map('n', '<leader>gr', gs.reset_hunk, {desc="Reset hunk"})
          map('v', '<leader>ga', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc="Stage hunk (visual)"})
          map('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc="Reset hunk (visual)"})
          map('n', '<leader>gA', gs.stage_buffer, {desc="Stage buffer"})
          map('n', '<leader>gu', gs.undo_stage_hunk, {desc="Undo stage hunk"})
          map('n', '<leader>gR', gs.reset_buffer, {desc="Reset buffer"})
          map('n', '<leader>gp', gs.preview_hunk, {desc="Preview hunk"})
          map('n', '<leader>gb', function() gs.blame_line{full=true} end, {desc="Git blame line"})
          map('n', '<leader>gt', gs.toggle_current_line_blame, {desc="Toggle line blame"})
          map('n', '<leader>gd', gs.diffthis, {desc="Diff this"})
          map('n', '<leader>gD', function() gs.diffthis('~') end, {desc="Diff this (cached)"})
          map('n', '<leader>gT', gs.toggle_deleted, {desc="Toggle deleted"})

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc="Select hunk"})
        end
      })
      
      -- Set custom colors for git signs
      vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#98c379" })
      vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#e5c07b" })
      vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#e06c75" })
    end,
  },

  -- Disable indent-blankline to stop errors
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
  },

  -- Floating Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
        on_open = function(term)
          -- Move terminal to the bottom
          if term.direction == "horizontal" then
            vim.cmd("wincmd J") -- Move to bottom window
          end
        end,
      })
    end,
    keys = {
      { "<leader>ot", function()
        vim.cmd("split | terminal")
        vim.cmd("wincmd J") -- Move terminal to bottom
        vim.cmd("resize 15") -- Set terminal height
        vim.cmd("wincmd K") -- Move back to main window
        vim.cmd("wincmd J") -- Move main window to bottom
      end, desc = "Toggle terminal at bottom" },
      { "<leader>of", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle floating terminal" },
    }
  },

  -- Lazygit integration - Best Git UI for terminal
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitFilter",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    }
  },

  -- Fugitive - Powerful Git commands
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


  -- Diffview - Beautiful diff viewer
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
    }
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Mason for LSP server management
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },


  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc", "html", "css", "go", "gomod", "gosum", "javascript", "typescript", "python", "json", "yaml", "bash", "rust", "c", "cpp"
      },
    },
  }
  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}

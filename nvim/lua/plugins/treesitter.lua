return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = {
          "vim", "lua", "vimdoc", "html", "css", "go", "gomod", "gosum", "javascript", "typescript", "python", "json", "yaml", "bash", "rust", "c", "cpp"
        },
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      })
    end,
  }
}


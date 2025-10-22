return {
    -- Test function visual indicators
    {
        "nvim-treesitter/nvim-treesitter",
        -- event = "BufReadPost",
        config = function()
            require("nvim-treesitter.configs").setup{
                ensure_installed = {"go"},
                highlight = {
                    enable = true,
                }
            }
            -- Custom test function highlighting
            local function setup_test_indicators()
                -- Define test function highlight group with green color
                vim.api.nvim_set_hl(0, "TestFunction", {
                    fg = "#98c379", -- Green color like VS Code
                    bold = true,
                    italic = true,
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
                                "func%s+(Test%w+)%s*%(",                              -- func TestSomething(
                                "func%s+%(%w+%s*%*%w+%)%s+(Test%w+)%s*%(",            -- func (receiver *AnyStruct) TestSomething(
                                "func%s+(Test%w+)%s*%(%w*%)%s*%w*",                   -- func TestSomething() returnType (interface methods)
                                "func%s+%(%w+%s*%*%w+%)%s+(Test%w+)%s*%(%w*%)%s*%w*", -- func (receiver *AnyStruct) TestSomething() returnType
                                "func%s+(Test%w+[_%w]*)%s*%(",                        -- func TestSomething_WithUnderscores(
                                "func%s+%(%w+%s*%*%w+%)%s+(Test%w+[_%w]*)%s*%(",      -- func (receiver *AnyStruct) TestSomething_WithUnderscores(
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
                                vim.api.nvim_buf_add_highlight(bufnr, ns_id, "TestFunction", line_num - 1, 0, -1)
                            end
                        end
                    end,
                })
            end

            setup_test_indicators()
        end,
    },

    -- Minimap
    {
        "gorbit99/codewindow.nvim",
        config = function()
            local codewindow = require("codewindow")

            codewindow.setup({
                auto_enable = false, -- don't show minimap by default
                width = 10,          -- make it slightly wider for clarity

                -- Use LSP diagnostics (shows error lines in color)
                use_lsp = true,

                -- Characters for representing lines (feels more like text)
                chars = {
                    "▏",
                    "▎",
                    "▍",
                    "▌",
                    "▋",
                    "▊",
                    "▉",
                    "█",
                },

                -- Highlight the current line in the minimap
                highlight_selection = true,

                -- Use relative highlights for the cursor line
                cursor_line_highlight = {
                    enabled = true,
                    color = "#5f87ff", -- change to your taste
                },

                -- Add your own excluded filetypes
                exclude_filetypes = { "neo-tree", "TelescopePrompt", "alpha", "lazy" },
            })

            codewindow.apply_default_keybinds()

            -- Optional: keybinding here if not using mappings.lua
            vim.keymap.set("n", "<leader>mm", function()
                codewindow.toggle_minimap()
            end, { desc = "Toggle minimap" })
        end,
        event = "VeryLazy",
    },

    -- lightspeed
    {
        "ggandor/lightspeed.nvim",
        event = "VeryLazy",
        config = function()
            require("lightspeed").setup({})

            -- Explicitly map "s" to Lightspeed in normal, visual, and operator-pending modes
            vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>Lightspeed_s", {})
            vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>Lightspeed_S", {})
        end,
    },


    -- Incline for error display
    {
        "b0o/incline.nvim",
        event = "BufReadPre",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local devicons = require("nvim-web-devicons")

            require("incline").setup({
                window = {
                    padding = 1,
                    margin = { horizontal = 1, vertical = 1 },
                    placement = { horizontal = "right", vertical = "top" },
                },
                hide = {
                    cursorline = false,
                    focused_win = false,
                    only_win = false,
                },
                render = function(props)
                    -- Get file name
                    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                    if filename == "" then
                        filename = "[No Name]"
                    end

                    -- Get file icon
                    local ft_icon, ft_color = devicons.get_icon_color(filename)

                    -- Get only ERROR diagnostics
                    local diagnostics = vim.diagnostic.get(props.buf, {
                        severity = vim.diagnostic.severity.ERROR,
                    })

                    local error_count = #diagnostics
                    local error_lines = {}
                    for _, d in ipairs(diagnostics) do
                        table.insert(error_lines, d.lnum + 1) -- lnum is 0-based
                    end

                    -- Circle with error count
                    local diagnostic_circle = " " .. error_count

                    -- Display up to 5 error lines
                    local line_info = ""
                    if #error_lines > 0 then
                        local shown_lines = vim.fn.join(vim.list_slice(error_lines, 1, 5), ", ")
                        line_info = "[Ln " .. shown_lines .. (#error_lines > 5 and ",…" or "") .. "]"
                    end

                    return {
                        { (ft_icon or "") .. " ", guifg = ft_color, guibg = "none" },
                        {
                          -- Uncomment the below line to display the file name
                          -- filename .. " ",
                            "Errors: ",
                            
                            gui = vim.bo[props.buf].modified and "bold,italic" or "bold",
                        },
                        {
                            diagnostic_circle .. line_info,
                            guifg = "#f38ba8",
                            guibg = "none",
                            gui = "bold",
                        },
                    }
                end,
            })

            -- Refresh incline when diagnostics change
            vim.api.nvim_create_autocmd("DiagnosticChanged", {
                callback = function()
                    require("incline").refresh()
                end,
            })
        end,
    },

-- Trouble
{
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Trouble",
  keys = {
    {
      "<leader>ll",
      function()
        local trouble = require("trouble")

        -- Toggle diagnostics view
        if trouble.is_open() then
          trouble.close()
        else
          trouble.open("diagnostics")
        end
      end,
      desc = "Toggle Trouble - diagnostics (workspace + document)",
    },
  },
  opts = {
    -- Optional: customize settings if needed
  },
},
    -- lspsaga Diagnostics
    {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        config = function()
            local saga = require("lspsaga")

            saga.setup({
                ui = {
                    border = "rounded",
                },
                lightbulb = {
                    enable = false,
                },
            })

            -- Keybindings for Lspsaga
            local opts = { noremap = true, silent = true }
            local keymap = vim.keymap.set

            keymap("n", "<leader>dl", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
            keymap("n", "<leader>db", "<cmd>Lspsaga show_buf_diagnostics<CR>", opts)
            keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
            keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", opts)
            keymap("n", "gr", "<cmd>Lspsaga finder<CR>", opts)
            keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
            keymap("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
            keymap("n", "<leader>o", "<cmd>Lspsaga outline<CR>", opts)
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter", -- optional but recommended
            "nvim-tree/nvim-web-devicons"      -- optional but nice icons
        },
    },

    -- Disable nvim-tree (NvChad default)
    {
        "nvim-tree/nvim-tree.lua",
        enabled = false,
    },

    -- Replace with neo-tree
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        lazy = false,
        priority = 1000,
        keys = {
            { "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = true,
                window = {
                    width = 30,
                    mappings = {
                        ["<cr>"] = "open",
                        ["l"] = "open",
                        ["h"] = "close_node",
                    },
                },
                filesystem = {
                    follow_current_file = {
                        enabled = true,
                    },
                    filtered_items = {
                        hide_dotfiles = false,
                        hide_gitignored = false,
                    },
                },
            })

            -- Auto-open neo-tree on startup
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    -- Only open if no file was specified
                    if vim.fn.argc() == 0 then
                        vim.cmd("Neotree show")
                    end
                end,
            })
        end,
    },

    -- Fuzzy Finder
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("fzf-lua").setup({})
        end,
        keys = {
            { "<leader>ff", "<cmd>lua require('fzf-lua').files()<CR>",        desc = "FZF Find Files" },
            { "<leader>fg", "<cmd>lua require('fzf-lua').grep_project()<CR>", desc = "FZF Grep Project" },
            { "<leader>fb", "<cmd>lua require('fzf-lua').buffers()<CR>",      desc = "FZF Buffers" },
        },
    },

    -- Satellite scroll
    {
        "lewis6991/satellite.nvim",
        event = "BufReadPost",
        config = function()
            require("satellite").setup({
                width = 1,
                current_only = true,
                winblend = 0,
                zindex = 40,
                excluded_filetypes = {
                    "neo-tree", -- Exclude Neo-tree sidebar
                    "neo-tree-popup",
                    "alpha",
                    "lazy",
                    "dashboard",
                    "terminal",
                    "toggleterm",
                    "packer",
                },
                handlers = {
                    diagnostic = {
                        enable = true,
                        signs = { "●" }, -- You can change to "●" or "‖" if preferred
                        min_severity = vim.diagnostic.severity.ERROR,
                    },
                    cursor = { enable = true},
                    search = { enable = true},
                    gitsigns = { enable = true },
                    marks = { enable = false},
                    quickfix = { enable = false},
                },
            })

            -- 🔴 Optional: force red color for error markers
            vim.cmd([[highlight SatelliteDiagnostic guifg=#ff0000 guibg=NONE]])
            -- 🔵 Optional: Blue-ish cursor marker (you can customize this)
            vim.cmd([[highlight SatelliteCursor guifg=#00afff guibg=NONE]])
        end,
    },

-- nvim-cokeline (Bufferline)
--   {
--     "noib3/nvim-cokeline",
--     config = function()
--       require("cokeline").setup({
--         default_hl = {
--           fg = "white",  -- Text color
--           bg = "black",  -- Background color
--         },
--         buffers = {
--           insert_after = "filename",  -- After the filename in the buffer line
--           show_diagnostics = true,
--           diagnostics = {
--             error_indicator = "",  -- Error icon
--             warning_indicator = "",  -- Warning icon
--             info_indicator = "",  -- Info icon
--             max_error_count = 3,  -- Show up to 3 errors
--           },
--         },
--       })
--     end
--   },
}

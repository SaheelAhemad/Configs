require("nvchad.autocmds")
-- Auto popup diagnostics on cursor movement
local diagnostic_timer = nil

local function show_hover_diagnostic()
	-- Cancel any existing timer
	if diagnostic_timer then
		diagnostic_timer:stop()
	end

	-- Debounce the function to prevent excessive calls
	diagnostic_timer = vim.defer_fn(function()
		local bufnr = vim.api.nvim_get_current_buf()
		local diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") - 1 })

		-- Filter to only show warnings and errors
		local filtered_diagnostics = {}
		for _, diagnostic in ipairs(diagnostics) do
			if
				diagnostic.severity == vim.diagnostic.severity.ERROR
				or diagnostic.severity == vim.diagnostic.severity.WARN
			then
				table.insert(filtered_diagnostics, diagnostic)
			end
		end

		if #filtered_diagnostics > 0 then
			-- Close any existing float
			vim.diagnostic.hide()

			local opts = {
				focusable = false,
				close_events = { "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" },
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
				scope = "cursor",
				max_width = 80,
				max_height = 10,
				header = "",
				style = "minimal",
				relative = "cursor",
				row = 1,
				col = 0,
			}
			vim.diagnostic.open_float(nil, opts)
		end
	end, 50) -- 50ms debounce
end

-- Show diagnostics on hover and cursor movement (VS Code style)
vim.api.nvim_create_autocmd({ "CursorHold", "CursorMoved" }, {
	group = vim.api.nvim_create_augroup("vscode_hover_diagnostics", { clear = true }),
	callback = show_hover_diagnostic,
})

-- -- Treesitter-powered folding for Go buffers
-- vim.api.nvim_create_autocmd({ "FileType" }, {
-- 	group = vim.api.nvim_create_augroup("treesitter_go_folds", { clear = true }),
-- 	pattern = "go",
-- 	callback = function()
-- 		vim.opt_local.foldmethod = "expr"
-- 		vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
-- 		vim.opt_local.foldenable = true
-- 		vim.opt_local.foldlevel = 99
-- 	end,
-- })

-- VS Code-style autosave: after short idle and on focus change
local autosave_enabled = true
local autosave_timer = nil

local function should_save(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return false
	end
	if vim.bo[buf].buftype ~= "" then
		return false
	end -- nofile/quickfix/etc
	if not vim.bo[buf].modifiable then
		return false
	end
	if vim.bo[buf].readonly then
		return false
	end
	if vim.api.nvim_buf_get_name(buf) == "" then
		return false
	end -- unnamed
	if not vim.api.nvim_buf_get_option(buf, "modified") then
		return false
	end
	return true
end

local function autosave_write(buf)
  if not autosave_enabled then return end
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if should_save(buf) then
    pcall(vim.api.nvim_buf_call, buf, function()
      vim.cmd("silent noautocmd write")
    end)
  end
end

-- Debounced save on CursorHold (idle)
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	group = vim.api.nvim_create_augroup("autosave_idle", { clear = true }),
	callback = function(args)
		if not autosave_enabled then
			return
		end
		if autosave_timer then
			autosave_timer:stop()
		end
		autosave_timer = vim.defer_fn(function()
			autosave_write(args.buf)
		end, 1000) -- 1s idle like VS Code's default
	end,
})

-- Immediate save on focus change and buffer leave
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("autosave_focus", { clear = true }),
	callback = function(args)
		autosave_write(args.buf)
	end,
})

-- User command to toggle autosave
vim.api.nvim_create_user_command("AutosaveToggle", function()
	autosave_enabled = not autosave_enabled
	local state = autosave_enabled and "enabled" or "disabled"
	vim.notify("Autosave " .. state, vim.log.levels.INFO)
end, { desc = "Toggle autosave" })

-- Debug command to manually check diagnostics
vim.api.nvim_create_user_command("DebugDiagnostics", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local diagnostics = vim.diagnostic.get(bufnr)
	local line_diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") - 1 })

	vim.notify("=== DIAGNOSTIC DEBUG ===", vim.log.levels.INFO)
	vim.notify("Total diagnostics in buffer: " .. #diagnostics, vim.log.levels.INFO)
	vim.notify("Diagnostics on current line: " .. #line_diagnostics, vim.log.levels.INFO)

	for i, diag in ipairs(line_diagnostics) do
		vim.notify(
			"Diagnostic " .. i .. ": " .. diag.message .. " (severity: " .. diag.severity .. ")",
			vim.log.levels.INFO
		)
	end

	-- Show all diagnostics
	vim.diagnostic.open_float()
end, { desc = "Debug diagnostics" })

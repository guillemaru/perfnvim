local M = {}
local client_helpers = require("perfnvim.helpers.client_helpers")
local file_helpers = require("perfnvim.helpers.file_helpers")
local helpers = require("perfnvim.helpers.other_helpers")

-- Function to list changelists and allow selection
function M.SelectChangelistInteractively(action)
	-- Get all the different changelist numbers in current client
	-- Alternative commands (1 preferred):
	-- 1 : p4 changelists -s pending -c <clientname> | cut -d' ' -f2
	-- 2 : p4 opened -s | cut -d' ' -f5 | uniq
	local handle = io.popen("p4 changelists -s pending -c " .. client_helpers._GetClientName() .. " | cut -d' ' -f2")
	if not handle then
		print("Failed to run p4 changelists command")
		return
	end
	local result = handle:read("*a")
	handle:close()

	-- Get description for all the changelist numbers
	local changelists = {}
	for changelist in result:gmatch("%d+") do
		-- Fetch the description for each changelist
		local desc_handle = io.popen(string.format("p4 -Ztag -F %%desc%% describe -s %s", changelist))
		if desc_handle then
			local description = desc_handle:read("*a"):gsub("\n", " ")
			desc_handle:close()
			table.insert(changelists, string.format("- Change %s: %s", changelist, description))
		end
	end

	-- Also allow to create a new changelist
	table.insert(changelists, string.format("New..."))

	local filepath = vim.api.nvim_buf_get_name(0)
	if filepath == "" then
		print("Cannot add/edit file to a changelist: no file associated with the current buffer.")
		return
	end

	-- Create a new buffer and window for displaying changelists
	local newbuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(newbuf, 0, -1, false, changelists)

	-- Define window options
	local width = 100
	local height = 3 * #changelists
	local opts = {
		relative = "editor",
		width = width,
		height = math.min(height, 10), -- Limit height to avoid overly large windows
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "single",
	}

	local win = vim.api.nvim_open_win(newbuf, true, opts)

	-- Map <Enter> to select a changelist
	vim.api.nvim_buf_set_keymap(
		newbuf,
		"n",
		"<CR>",
		":lua select_changelist_entry()<CR>",
		{ noremap = true, silent = true }
	)

	-- Function to handle selection
	_G.select_changelist_entry = function()
		local line = vim.api.nvim_get_current_line()
		local changelist = line:match("Change (%d+)")
		if changelist then
			-- Run p4 add with the selected changelist
			local cmd = string.format("p4 " .. action .. " -c %s %s", changelist, filepath)
			vim.cmd("!" .. cmd)
			vim.api.nvim_win_close(win, true)
		elseif line:match("New...") then
			-- Clear the buffer
			vim.api.nvim_buf_set_lines(
				newbuf,
				0,
				-1,
				false,
				{ "Write new changelist description. Press enter in normal mode when done." }
			)
			-- Enter insert mode
			vim.api.nvim_command("startinsert")
			-- Map <Enter> to create a new changelist with the entered description
			vim.api.nvim_buf_set_keymap(
				newbuf,
				"n",
				"<CR>",
				":lua create_new_changelist()<CR>",
				{ noremap = true, silent = true }
			)
		else
			print("Error: you did not select a valid line.")
		end
	end

	-- Function to create a new changelist
	_G.create_new_changelist = function()
		-- Get the description entered by the user
		local description = table.concat(vim.api.nvim_buf_get_lines(newbuf, 0, -1, false), "\n")

		if description and description ~= "" then
			-- Create a temporary file to hold the changelist form
			local tmpfile = os.tmpname()

			local p4ChangeHandle = io.popen("p4 change -o")
			if not p4ChangeHandle then
				print("Failed to run p4 change -o command")
				return
			end
			local changelist_form = p4ChangeHandle:read("*a")
			p4ChangeHandle:close()

			-- Modify the changelist form with the desired description
			changelist_form = changelist_form:gsub("(<enter description here.-)\n", description .. "\n")

			-- Write the modified form to the temporary file
			local file = io.open(tmpfile, "w")
			if not file then
				print("Error creating new changelist")
				return
			end
			file:write(changelist_form)
			file:close()

			-- Submit the changelist using the modified form
			local submit_handle = io.popen("p4 change -i < " .. tmpfile)
			if not submit_handle then
				print("Error executing p4 change -i")
				return
			end
			local p4ChangeIResult = submit_handle:read("*a")
			submit_handle:close()

			-- Clean up the temporary file
			os.remove(tmpfile)

			-- Close the window
			vim.api.nvim_win_close(win, true)

			-- Add/edit the file to the created changelist
			local changelist = p4ChangeIResult:match("Change (%d+) created.")
			if changelist then
				local cmd = string.format("p4 " .. action .. " -c %s %s", changelist, filepath)
				vim.cmd("!" .. cmd)
			else
				print("Failed to create changelist")
			end
		else
			print("No description entered. Aborting creation of new changelist.")
		end
	end
end

-- Create a Telescope picker for the p4 opened files
function M.GetP4Opened()
	local actions = require("telescope.actions")
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local previewers = require("telescope.previewers")
	local conf = require("telescope.config").values

	local client_root = client_helpers._GetClientRoot()
	local files = file_helpers._GetP4OpenedPaths()
	-- Transform files to be relative to client_root
	local relative_files = {}
	for _, file in ipairs(files) do
		local relative_path = file:gsub("^" .. client_root .. "/", "")
		table.insert(relative_files, { full_path = file, relative_path = relative_path })
	end
	pickers
		.new({}, {
			prompt_title = "P4 Opened Files",
			finder = finders.new_table({
				results = relative_files,
				entry_maker = function(entry)
					return {
						value = entry.full_path,
						display = entry.relative_path,
						ordinal = entry.relative_path,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewers.new_termopen_previewer({
				get_command = function(entry)
					return { "batcat", "--style=numbers", "--color=always", "--line-range=:500", entry.value }
				end,
			}),
			attach_mappings = function(_, map)
				map("i", "<CR>", actions.select_default)
				map("n", "<CR>", actions.select_default)
				return true
			end,
		})
		:find()
end

function M.GoToPreviousChange()
	-- Get all signs placed in the current buffer
	local buf = vim.fn.bufnr()
	local signs = vim.fn.sign_getplaced(buf, { group = "*" })
	-- Get the current cursor line
	local current_line = vim.fn.line(".")
	-- Iterate over the signs to find the next one
	local continuous_counter = 1
	local signs_array = signs[1].signs
	helpers._ReverseArray(signs_array)
	for _, sign in ipairs(signs_array) do
		if sign.lnum < current_line then
			if sign.lnum == (current_line - continuous_counter) then
				continuous_counter = continuous_counter + 1
			else
				vim.fn.sign_jump(sign.id, sign.group, buf)
				return
			end
		end
	end
end

function M.GoToNextChange()
	-- Get all signs placed in the current buffer
	local buf = vim.fn.bufnr()
	local signs = vim.fn.sign_getplaced(buf, { group = "*" })
	-- Get the current cursor line
	local current_line = vim.fn.line(".")
	-- Iterate over the signs to find the next one
	local continuous_counter = 1
	for _, sign in ipairs(signs[1].signs) do
		if sign.lnum > current_line then
			if sign.lnum == (current_line + continuous_counter) then
				continuous_counter = continuous_counter + 1
			else
				vim.fn.sign_jump(sign.id, sign.group, buf)
				return
			end
		end
	end
end

return M

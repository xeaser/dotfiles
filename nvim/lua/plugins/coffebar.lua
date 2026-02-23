return {
	"coffebar/neovim-project",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		-- optional picker
		{ "ibhagwan/fzf-lua" },
		{ "Shatur/neovim-session-manager" },
	},
	lazy = false,
	priority = 100,
	keys = {
		{ "<leader>p", group = "project" },
		{ "<leader>pp", "<cmd>NeovimProjectDiscover<cr>", desc = "Browse projects" },
		{ "<leader>pr", "<cmd>NeovimProjectLoadRecent<cr>", desc = "Recent project" },
		{ "<leader>ph", "<cmd>NeovimProjectHistory<cr>", desc = "Project history (picker)" },
		{
			"<leader>pl",
			function()
				vim.ui.input({ prompt = "Project path: ", completion = "dir" }, function(path)
					if path and path ~= "" then
						local expanded = vim.fn.expand(path)
						if vim.fn.isdirectory(expanded) == 1 then
							require("neovim-project.project").switch_project(expanded)
						else
							vim.notify("Directory does not exist: " .. expanded, vim.log.levels.ERROR)
						end
					end
				end)
			end,
			desc = "Load project by path",
		},
	},
	opts = function()
		local projects_file = vim.fn.stdpath("config") .. "/lua/local/projects.lua"
		local ok, projects = pcall(dofile, projects_file)
		if not ok then
			projects = {}
			vim.notify("No local projects file found at: " .. projects_file, vim.log.levels.WARN)
		end

		return {
			projects = projects,
			picker = {
				type = "fzf-lua",
				opts = {
					winopts = {
						width = 0.4,
						height = 0.5,
					},
				},
			},
			session_manager_opts = {
				autosave_last_session = true,
			},
		}
	end,
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "SessionSavePre",
			callback = function()
				pcall(vim.cmd, "Neotree close")
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			pattern = "SessionLoadPost",
			callback = function()
				vim.defer_fn(function()
					pcall(vim.cmd, "Neotree filesystem show")
				end, 100)
			end,
		})
	end,
}

return {
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.35 },
            { id = "breakpoints", size = 0.15 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          position = "left",
          size = 40,
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          position = "bottom",
          size = 12,
        },
      },
    },
    config = function(_, opts)
      local dapui = require("dapui")
      dapui.setup(opts)

      local dap = require("dap")
      local neotree_was_open = false

      local function close_neotree()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "neo-tree" then
            neotree_was_open = true
            vim.cmd("Neotree close")
            return
          end
        end
        neotree_was_open = false
      end

      local function restore_neotree()
        if neotree_was_open then
          vim.defer_fn(function()
            vim.cmd("Neotree show")
          end, 300)
        end
      end

      dap.listeners.before.attach["dapui_config"] = function()
        close_neotree()
        dapui.open({ reset = true })
      end
      dap.listeners.before.launch["dapui_config"] = function()
        close_neotree()
        dapui.open({ reset = true })
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({ reset = true })
        restore_neotree()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({ reset = true })
        restore_neotree()
      end
    end,
  },
}

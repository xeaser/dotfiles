return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "fredrikaverpil/neotest-golang",
    "nvim-neotest/neotest-jest",
    "nvim-neotest/neotest-python",
    "MisanthropicBit/neotest-busted",
  },
  keys = {
    { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
    { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
    { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show test output" },
    { "<leader>tp", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
    { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-golang"),
        require("neotest-jest"),
        require("neotest-python"),
        require("neotest-busted"),
      },
    })
  end,
}

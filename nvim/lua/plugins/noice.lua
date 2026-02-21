-- Use classic bottom cmdline instead of centered popup.
-- The "cmdline" view renders full-width at the bottom of the screen.
return {
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline",
      },
    },
  },
}

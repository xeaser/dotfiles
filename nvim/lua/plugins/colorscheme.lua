return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      integrations = {
        neotree = true,
        dap = true,
        dap_ui = true,
        flash = true,
        gitsigns = true,
        treesitter = true,
        which_key = true,
        noice = true,
        mini = { enabled = true },
        lsp_trouble = true,
        mason = true,
        native_lsp = { enabled = true },
      },
      custom_highlights = function(colors)
        return {
          NeoTreeNormal = { bg = colors.mantle },
          NeoTreeNormalNC = { bg = colors.mantle },
          NeoTreeEndOfBuffer = { bg = colors.mantle },
          NeoTreeWinSeparator = { fg = colors.mantle, bg = colors.mantle },
          NormalFloat = { bg = colors.mantle },
          CursorLine = { bg = colors.surface0 },
        }
      end,
    },
  },

  {
    "sainnhe/gruvbox-material",
    lazy = true,
    config = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_foreground = "material"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "gruvbox-material",
        callback = function()
          local sidebar = "#141617"
          local bg = "#1d2021"
          local bg_dim = "#191b1c"
          local surface = "#282828"
          local border = "#3c3836"
          local fg_dim = "#928374"
          local fg = "#d4be98"
          local accent = "#d8a657"

          -- NeoTree sidebar: darker than editor
          vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = sidebar, fg = fg })
          vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = sidebar, fg = fg_dim })
          vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = sidebar, fg = sidebar })
          vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { fg = sidebar, bg = sidebar })
          vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = surface })
          vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = accent })
          vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = accent })
          vim.api.nvim_set_hl(0, "NeoTreeRootName", { fg = accent, bold = true })
          vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#a9b665" })
          vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#7daea3" })

          -- Win separators: visible thin line
          vim.api.nvim_set_hl(0, "WinSeparator", { fg = border, bg = "NONE" })
          vim.api.nvim_set_hl(0, "VertSplit", { fg = border, bg = "NONE" })

          -- Floats and popups
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = bg_dim, fg = fg })
          vim.api.nvim_set_hl(0, "FloatBorder", { fg = border, bg = bg_dim })
          vim.api.nvim_set_hl(0, "FloatTitle", { fg = accent, bg = bg_dim, bold = true })
          vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = bg_dim })

          -- Cursor line
          vim.api.nvim_set_hl(0, "CursorLine", { bg = surface })
          vim.api.nvim_set_hl(0, "CursorLineNr", { fg = accent, bg = surface, bold = true })
          vim.api.nvim_set_hl(0, "LineNr", { fg = "#504945" })

          -- Statusline
          vim.api.nvim_set_hl(0, "StatusLine", { bg = sidebar, fg = fg })
          vim.api.nvim_set_hl(0, "StatusLineNC", { bg = sidebar, fg = fg_dim })

          -- Pmenu (completion)
          vim.api.nvim_set_hl(0, "Pmenu", { bg = bg_dim, fg = fg })
          vim.api.nvim_set_hl(0, "PmenuSel", { bg = surface, fg = fg, bold = true })
          vim.api.nvim_set_hl(0, "PmenuThumb", { bg = border })
          vim.api.nvim_set_hl(0, "PmenuSbar", { bg = bg_dim })

          -- Bufferline area: darker than NeoTree sidebar
          local bufbar = "#101112"
          vim.api.nvim_set_hl(0, "TabLine", { bg = bufbar, fg = fg_dim })
          vim.api.nvim_set_hl(0, "TabLineFill", { bg = bufbar })
          vim.api.nvim_set_hl(0, "TabLineSel", { bg = bg, fg = fg, bold = true })
          vim.api.nvim_set_hl(0, "BufferLineFill", { bg = bufbar })
          vim.api.nvim_set_hl(0, "BufferLineBackground", { bg = bufbar, fg = fg_dim })
          vim.api.nvim_set_hl(0, "BufferLineBuffer", { bg = bufbar, fg = fg_dim })
          vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { bg = sidebar, fg = fg_dim })
          vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { bg = bg, fg = fg, bold = true })
          vim.api.nvim_set_hl(0, "BufferLineTab", { bg = bufbar, fg = fg_dim })
          vim.api.nvim_set_hl(0, "BufferLineTabSelected", { bg = bg, fg = fg, bold = true })
          vim.api.nvim_set_hl(0, "BufferLineTabClose", { bg = bufbar, fg = fg_dim })
          vim.api.nvim_set_hl(0, "BufferLineSeparator", { bg = bufbar, fg = bufbar })
          vim.api.nvim_set_hl(0, "BufferLineSeparatorVisible", { bg = sidebar, fg = sidebar })
          vim.api.nvim_set_hl(0, "BufferLineSeparatorSelected", { bg = bg, fg = bufbar })
          vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = accent, bg = bg })
          vim.api.nvim_set_hl(0, "BufferLineModified", { fg = accent, bg = bufbar })
          vim.api.nvim_set_hl(0, "BufferLineModifiedSelected", { fg = accent, bg = bg })

          -- Which-key
          vim.api.nvim_set_hl(0, "WhichKey", { fg = accent })
          vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = fg })
          vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = "#7daea3" })
          vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = fg_dim })

          -- Trouble
          vim.api.nvim_set_hl(0, "TroubleNormal", { bg = bg_dim })

          -- Inlay hints and virtual text: subdued but readable
          vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#7c6f64", bg = "#1a1c1d", italic = true })
          vim.api.nvim_set_hl(0, "LspCodeLens", { fg = "#7c6f64", italic = true })
          vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#6e6763", bg = "#1a1c1d" })
          vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#689d6a", bg = "#1a1c1d" })
          vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#b47109", bg = "#1c1a17" })
          vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#c14a4a", bg = "#1c1717" })

          -- Noice cmdline
          vim.api.nvim_set_hl(0, "NoiceCmdline", { bg = bg })

          -- indent-blankline: subtle guide lines that don't distract
          vim.api.nvim_set_hl(0, "IblIndent", { fg = "#2a2a2a" })
          vim.api.nvim_set_hl(0, "IblScope", { fg = "#504945" })
          vim.api.nvim_set_hl(0, "@ibl.indent.char.1", { fg = "#2a2a2a" })
          vim.api.nvim_set_hl(0, "@ibl.scope.char.1", { fg = "#504945" })
          vim.api.nvim_set_hl(0, "@ibl.scope.underline.1", { sp = "#504945", underline = true })

          -- illuminate: soft highlight for word under cursor
          vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#2a2c2e" })
          vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#2a2c2e" })
          vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#2e2a28" })

          -- aerial: symbol browser sidebar (matches NeoTree sidebar feel)
          vim.api.nvim_set_hl(0, "AerialLine", { bg = surface })
          vim.api.nvim_set_hl(0, "AerialGuide", { fg = "#2a2a2a" })

          -- navic: breadcrumb bar in winbar (subdued, readable)
          vim.api.nvim_set_hl(0, "NavicText", { fg = fg_dim })
          vim.api.nvim_set_hl(0, "NavicSeparator", { fg = "#504945" })
          vim.api.nvim_set_hl(0, "NavicIconsFile", { fg = fg_dim })
          vim.api.nvim_set_hl(0, "NavicIconsModule", { fg = "#d8a657" })
          vim.api.nvim_set_hl(0, "NavicIconsNamespace", { fg = "#d8a657" })
          vim.api.nvim_set_hl(0, "NavicIconsPackage", { fg = "#7daea3" })
          vim.api.nvim_set_hl(0, "NavicIconsClass", { fg = "#d8a657" })
          vim.api.nvim_set_hl(0, "NavicIconsMethod", { fg = "#a9b665" })
          vim.api.nvim_set_hl(0, "NavicIconsFunction", { fg = "#a9b665" })
          vim.api.nvim_set_hl(0, "NavicIconsVariable", { fg = "#7daea3" })
          vim.api.nvim_set_hl(0, "NavicIconsConstant", { fg = "#d3869b" })
          vim.api.nvim_set_hl(0, "NavicIconsString", { fg = "#a9b665" })
          vim.api.nvim_set_hl(0, "NavicIconsStruct", { fg = "#d8a657" })
        end,
      })
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {
      theme = "dragon",
      background = { dark = "dragon" },
      dimInactive = false,
      colors = {
        theme = {
          dragon = {
            ui = {
              bg_sidebar = "#16161D",
              bg_gutter = "none",
            },
          },
        },
      },
      overrides = function(colors)
        return {
          NeoTreeNormal = { bg = "#16161D" },
          NeoTreeNormalNC = { bg = "#16161D" },
          NeoTreeEndOfBuffer = { bg = "#16161D" },
          NeoTreeWinSeparator = { fg = "#16161D", bg = "#16161D" },
          NormalFloat = { bg = "#16161D" },
        }
      end,
    },
  },

  {
    "neanias/everforest-nvim",
    lazy = true,
    config = function()
      require("everforest").setup({
        background = "hard",
        italics = true,
        disable_italic_comments = false,
        on_highlights = function(hl, palette)
          hl.NeoTreeNormal = { bg = palette.bg0 }
          hl.NeoTreeNormalNC = { bg = palette.bg0 }
          hl.NeoTreeEndOfBuffer = { bg = palette.bg0 }
          hl.NeoTreeWinSeparator = { fg = palette.bg0, bg = palette.bg0 }
          hl.NormalFloat = { bg = palette.bg0 }
        end,
      })
    end,
  },

  {
    "navarasu/onedark.nvim",
    lazy = true,
    opts = {
      style = "darker",
      transparent = false,
      lualine = { transparent = false },
      highlights = {
        NeoTreeNormal = { bg = "#1a1a1a" },
        NeoTreeNormalNC = { bg = "#1a1a1a" },
        NeoTreeEndOfBuffer = { bg = "#1a1a1a" },
        NeoTreeWinSeparator = { fg = "#1a1a1a", bg = "#1a1a1a" },
        NormalFloat = { bg = "#1a1a1a" },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },
}

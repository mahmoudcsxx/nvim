return {
  -- Icons (required by many plugins)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- UI component library
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
    -- Patch Tree:get_node at runtime so no source file is modified (survives updates).
    -- nui deprecated o.winid in favour of o.bufnr; neo-tree still passes the old API,
    -- so win_findbuf() can return {} during the rename callback → nil window crash.
    config = function()
      local Tree = require("nui.tree")
      local orig = Tree.get_node
      Tree.get_node = function(self, node_id_or_linenr)
        -- Only the no-arg cursor-based path needs a valid window.
        if node_id_or_linenr == nil and not vim.fn.win_findbuf(self.bufnr or -1)[1] then
          return nil
        end
        return orig(self, node_id_or_linenr)
      end
    end,
  },

  -- Notifications backend
  {
    "rcarriga/nvim-notify",
    lazy = true,
    opts = {
      timeout = 3000,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
      render = "wrapped-compact",
      stages = "fade_in_slide_out",
    },
    init = function()
      local default_notify = vim.notify
      vim.notify = function(...)
        require("lazy").load({ plugins = { "nvim-notify" } })
        local ok, notify = pcall(require, "nvim-notify")
        if ok then
          return notify(...)
        end
        return default_notify(...)
      end
    end,
  },

  -- Better vim.ui.select / vim.ui.input
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- Beautiful cmdline, messages and popups
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        signature = { enabled = false }, -- using cmp for signature
      },
      routes = {
        { filter = { event = "msg_show", find = "%d+L, %d+B" }, view = "mini" },
        { filter = { event = "msg_show", find = "; after #%d+" }, view = "mini" },
        { filter = { event = "msg_show", find = "; before #%d+" }, view = "mini" },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
    keys = {
      { "<leader>sn", "", desc = "+noice" },
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "catppuccin" },
    opts = {
      options = {
        theme = "catppuccin-mocha",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = {
          { "mode", fmt = function(s) return s:sub(1, 1) end },
        },
        lualine_b = {
          { "branch", icon = "" },
          { "diff", symbols = { added = " ", modified = " ", removed = " " } },
          { "diagnostics", symbols = { error = " ", warn = " ", hint = " ", info = " " } },
        },
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = "●", readonly = "󰌾", unnamed = "󰡯" } },
        },
        lualine_x = {
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then return "" end
              local names = {}
              for _, c in ipairs(clients) do
                if c.name ~= "null-ls" and c.name ~= "copilot" then
                  names[#names + 1] = c.name
                end
              end
              return #names > 0 and (" " .. table.concat(names, " · ")) or ""
            end,
            color = { fg = "#a6e3a1" },
          },
          { "filetype", color = { fg = "#cdd6f4" } },
        },
        lualine_y = {
          { "progress", color = { fg = "#7f849c" } },
        },
        lualine_z = { "location" },
      },
    },
  },

  -- Buffer tabs
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle pin buffer" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Delete unpinned buffers" },
    },
    opts = {
      options = {
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = { error = " ", warning = " " }
          return (diag.error and icons.error .. diag.error .. " " or "")
            .. (diag.warning and icons.warning .. diag.warning or "")
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal file in explorer" },
    },
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = (vim.uv or vim.loop).fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
      window = {
        width = 35,
        mappings = { ["<space>"] = "none" },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
        git_status = {
          symbols = { unstaged = "󰄱", staged = "󰱒" },
        },
      },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = true, show_start = true },
      exclude = {
        filetypes = { "help", "dashboard", "neo-tree", "Trouble", "lazy", "mason", "notify", "toggleterm" },
      },
    },
  },

  -- Keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>o", group = "outline" },
        { "<leader>q", group = "quit/session" },
        { "<leader>r", group = "run/build" },
        { "<leader>s", group = "search/noice" },
        { "<leader>t", group = "terminal" },
        { "<leader>u", group = "toggle/ui" },
        { "<leader>w", group = "window" },
        { "<leader>x", group = "diagnostics" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer keymaps" },
    },
  },

  -- Session persistence
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end,               desc = "Restore session (cwd)" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end,               desc = "Disable session save" },
    },
  },

  -- Startup screen
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons", "folke/persistence.nvim" },
    config = function()
      -- Catppuccin Mocha palette for dashboard highlights
      vim.api.nvim_set_hl(0, "DashboardHeader",   { fg = "#cba6f7", bold = true })
      vim.api.nvim_set_hl(0, "DashboardFooter",   { fg = "#585b70", italic = true })
      vim.api.nvim_set_hl(0, "DashboardCenter",   { fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "DashboardShortCut", { fg = "#a6e3a1", bold = true })
      vim.api.nvim_set_hl(0, "DashboardDesc",     { fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "DashboardKey",      { fg = "#f38ba8", bold = true })

      -- Re-apply on colorscheme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.api.nvim_set_hl(0, "DashboardHeader",   { fg = "#cba6f7", bold = true })
          vim.api.nvim_set_hl(0, "DashboardFooter",   { fg = "#585b70", italic = true })
          vim.api.nvim_set_hl(0, "DashboardCenter",   { fg = "#cdd6f4" })
          vim.api.nvim_set_hl(0, "DashboardShortCut", { fg = "#a6e3a1", bold = true })
          vim.api.nvim_set_hl(0, "DashboardDesc",     { fg = "#89b4fa" })
          vim.api.nvim_set_hl(0, "DashboardKey",      { fg = "#f38ba8", bold = true })
        end,
      })

      local logo = table.concat({
        "",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "",
        "           precision  ·  performance  ·  pleasure          ",
        "",
      }, "\n")

      local header = string.rep("\n", 3) .. logo .. "\n"

      require("dashboard").setup({
        theme = "doom",
        hide = { statusline = true, tabline = true },
        config = {
          header = vim.split(header, "\n"),
          center = {
            {
              action  = "Telescope find_files",
              desc    = " Find file",
              icon    = "󰱼 ",
              key     = "f",
              padding = 2,
            },
            {
              action  = "ene | startinsert",
              desc    = " New file",
              icon    = " ",
              key     = "n",
              padding = 2,
            },
            {
              action  = "Telescope oldfiles",
              desc    = " Recent files",
              icon    = "󰋚 ",
              key     = "r",
              padding = 2,
            },
            {
              action  = "lua require('persistence').load()",
              desc    = " Restore session",
              icon    = "󰁯 ",
              key     = "s",
              padding = 2,
            },
            {
              action  = "Telescope live_grep",
              desc    = " Find text",
              icon    = "󰊄 ",
              key     = "g",
              padding = 2,
            },
            {
              action  = "Telescope git_status",
              desc    = " Git status",
              icon    = " ",
              key     = "G",
              padding = 2,
            },
            {
              action  = "e $MYVIMRC",
              desc    = " Open config",
              icon    = " ",
              key     = "c",
              padding = 2,
            },
            {
              action  = "Lazy",
              desc    = " Lazy",
              icon    = "󰒲 ",
              key     = "l",
              padding = 2,
            },
            {
              action  = "Mason",
              desc    = " Mason",
              icon    = " ",
              key     = "m",
              padding = 2,
            },
            {
              action  = "qa",
              desc    = " Quit",
              icon    = "󰅚 ",
              key     = "q",
              padding = 2,
            },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms    = math.floor(stats.startuptime * 100 + 0.5) / 100
            local ver   = vim.version()
            local nvim  = string.format("NVIM v%d.%d.%d", ver.major, ver.minor, ver.patch)
            local plugins = string.format("⚡ %d/%d plugins · %sms", stats.loaded, stats.count, ms)
            local date    = os.date("  %A, %B %d %Y   ·    %I:%M %p")
            return { "", plugins .. "   ·   " .. nvim, date }
          end,
        },
      })
    end,
  },

  -- Winbar with clickable path + current symbol (like VS Code breadcrumbs)
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      bar = {
        update_debounce = 100,
        enable = function(buf, win)
          local ft = vim.bo[buf].filetype
          local skip = { "dashboard", "neo-tree", "Trouble", "lazy", "mason", "help", "toggleterm" }
          for _, s in ipairs(skip) do if ft == s then return false end end
          return vim.bo[buf].buftype == "" and vim.api.nvim_win_get_config(win).relative == ""
        end,
        sources = function(_, _)
          local sources = require("dropbar.sources")
          return {
            sources.path,
            {
              get_symbols = function(buf, win, cursor)
                local lsp = sources.lsp.get_symbols(buf, win, cursor)
                if #lsp > 0 then return lsp end
                return sources.treesitter.get_symbols(buf, win, cursor)
              end,
            },
          }
        end,
        padding = { left = 1, right = 1 },
        pick = { pivots = "abcdefghijklmnopqrstuvwxyz" },
      },
      icons = {
        ui = { bar = { separator = "  " } },
      },
    },
    keys = {
      { "<leader>cp", function() require("dropbar.api").pick() end, desc = "Pick symbol (dropbar)" },
    },
  },

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      mappings         = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
      hide_cursor      = false,
      stop_eof         = true,
      cursor_scrolls_alone = true,
      duration_multiplier  = 0.8,
      easing           = "sine",
    },
  },

  -- Sidebar scrollbar with diagnostic + git markers
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "lewis6991/gitsigns.nvim" },
    opts = {
      handle = {
        text = " ",
        blend = 30,
        color = "#45475a",
      },
      marks = {
        Search  = { text = { "─", "━" }, color = "#f9e2af" },
        Error   = { text = { "─", "━" }, color = "#f38ba8" },
        Warn    = { text = { "─", "━" }, color = "#fab387" },
        Info    = { text = { "─", "━" }, color = "#89b4fa" },
        Hint    = { text = { "─", "━" }, color = "#a6e3a1" },
        GitAdd    = { color = "#a6e3a1" },
        GitChange = { color = "#89b4fa" },
        GitDelete = { color = "#f38ba8" },
      },
      excluded_filetypes = {
        "dashboard", "neo-tree", "Trouble", "lazy", "mason", "toggleterm",
        "help", "notify", "aerial",
      },
      handlers = {
        cursor      = false,
        diagnostic  = true,
        gitsigns    = true,
        search      = false,
      },
    },
    config = function(_, opts)
      require("scrollbar").setup(opts)
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },
}

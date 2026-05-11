return {
  -- Mason: tool installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>m", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },

  -- Bridge between Mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
    opts = {},
  },

  -- Auto-install LSPs, formatters, linters, DAPs
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- LSP servers
        "clangd",
        "pyright",
        "omnisharp",
        "jdtls",
        "lua-language-server",
        "bash-language-server",
        "json-lsp",
        "yaml-language-server",
        "cmake-language-server",
        "marksman",
        -- Formatters
        "clang-format",
        "black",
        "isort",
        "csharpier",
        "google-java-format",
        "stylua",
        "shfmt",
        -- DAP adapters
        "codelldb",
        "debugpy",
        "netcoredbg",
        "java-debug-adapter",
        "java-test",
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  -- JSON/YAML schema catalog
  { "b0o/SchemaStore.nvim", lazy = true },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "nvim-telescope/telescope.nvim",
      "b0o/SchemaStore.nvim",
    },
    config = function()
      local lsputil = require("util.lsp")
      local lspconfig = require("lspconfig")
      local capabilities = lsputil.capabilities()
      local on_attach = lsputil.on_attach

      -- Diagnostic signs and config
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = false, -- replaced by tiny-inline-diagnostic
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Rounded borders for LSP windows
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "pyright", "omnisharp", "lua_ls", "bashls", "jsonls", "yamlls", "marksman" },
        handlers = {
          -- Default handler
          function(server_name)
            lspconfig[server_name].setup({ on_attach = on_attach, capabilities = capabilities })
          end,

          -- clangd is handled by clangd_extensions plugin below
          clangd = function() end,

          -- Pyright: Python LSP
          pyright = function()
            lspconfig.pyright.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                python = {
                  analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                    useLibraryCodeForTypes = true,
                    typeCheckingMode = "basic",
                  },
                },
              },
            })
          end,

          -- OmniSharp: C# LSP
          omnisharp = function()
            lspconfig.omnisharp.setup({
              on_attach = function(client, bufnr)
                client.server_capabilities.semanticTokensProvider = nil
                on_attach(client, bufnr)
              end,
              capabilities = capabilities,
              settings = {
                FormattingOptions = { EnableEditorConfigSupport = true },
                RoslynExtensionsOptions = { EnableImportCompletion = true },
              },
            })
          end,

          -- Lua LSP: great for Neovim config editing
          lua_ls = function()
            lspconfig.lua_ls.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  workspace = {
                    checkThirdParty = false,
                    library = vim.api.nvim_get_runtime_file("", true),
                  },
                  diagnostics = { globals = { "vim" } },
                  telemetry = { enable = false },
                  hint = { enable = true },
                  format = { enable = false }, -- use stylua via conform
                },
              },
            })
          end,

          -- Bash LSP
          bashls = function()
            lspconfig.bashls.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              filetypes = { "sh", "bash", "zsh" },
            })
          end,

          -- JSON LSP with schema validation
          jsonls = function()
            lspconfig.jsonls.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                json = {
                  schemas = require("schemastore").json.schemas(),
                  validate = { enable = true },
                },
              },
            })
          end,

          -- YAML LSP with schema validation
          yamlls = function()
            lspconfig.yamlls.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                yaml = {
                  schemaStore = { enable = false, url = "" },
                  schemas = require("schemastore").yaml.schemas(),
                  hover = true,
                  completion = true,
                  validate = true,
                },
              },
            })
          end,

          -- CMake LSP
          cmake = function()
            lspconfig.cmake.setup({
              on_attach = on_attach,
              capabilities = capabilities,
            })
          end,

          -- Markdown LSP
          marksman = function()
            lspconfig.marksman.setup({
              on_attach = on_attach,
              capabilities = capabilities,
            })
          end,
        },
      })
    end,
  },

  -- Enhanced clangd features for C++
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local lsputil = require("util.lsp")
      require("clangd_extensions").setup({
        server = {
          on_attach = function(client, bufnr)
            lsputil.on_attach(client, bufnr)
            -- C++ specific: switch header/source
            vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>",
              { buffer = bufnr, desc = "Switch header/source" })
          end,
          capabilities = lsputil.capabilities(),
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--cross-file-rename",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
        inlay_hints = {
          inline = vim.fn.has("nvim-0.10") == 1,
          only_current_line = false,
          other_hints_prefix = "=> ",
          max_len_align = false,
          right_align = false,
        },
        ast = {
          role_icons = {
            type = "",
            declaration = "",
            expression = "",
            specifier = "",
            statement = "",
            ["template argument"] = "",
          },
          kind_icons = {
            Compound = "",
            Recovery = "",
            TranslationUnit = "",
            PackExpansion = "",
            TemplateTypeParm = "",
            TemplateTemplateParm = "",
            TemplateParamObject = "",
          },
        },
        memory_usage = { border = "rounded" },
        symbol_info = { border = "rounded" },
      })
    end,
  },

  -- Diagnostics panel
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics (Trouble)" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location list" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix list" },
      {
        "[t", function()
          if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
          else vim.cmd.cprev() end
        end,
        desc = "Prev trouble item",
      },
      {
        "]t", function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else vim.cmd.cnext() end
        end,
        desc = "Next trouble item",
      },
    },
  },

  -- Java LSP (configured in ftplugin/java.lua)
  { "mfussenegger/nvim-jdtls", ft = "java" },

  -- Error Lens: inline diagnostic messages next to code (replaces virtual_text)
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = {
      preset = "powerline",
      hi = {
        error = "DiagnosticError",
        warn  = "DiagnosticWarn",
        info  = "DiagnosticInfo",
        hint  = "DiagnosticHint",
        arrow = "NonText",
        background = "CursorLine",
        mixing_color = "None",
      },
      blend = { factor = 0.27 },
      options = {
        show_source         = true,
        throttle            = 20,
        softwrap            = 30,
        multiple_diag_under_cursor = true,
        multilines          = false,
        show_all_diags_on_cursorline = true,
        enable_on_insert    = false,
        overflow            = { mode = "wrap" },
        virt_texts          = { priority = 2048 },
        severity = {
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
          vim.diagnostic.severity.INFO,
          vim.diagnostic.severity.HINT,
        },
      },
    },
  },
}

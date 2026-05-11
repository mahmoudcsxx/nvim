return {
  -- DAP core
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- DAP UI
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        keys = {
          { "<leader>du", function() require("dapui").toggle() end,  desc = "DAP UI toggle" },
          { "<leader>de", function() require("dapui").eval() end,    desc = "DAP eval expression", mode = { "n", "v" } },
        },
        opts = {
          icons = { expanded = "", collapsed = "", current_frame = "" },
          layouts = {
            {
              elements = {
                { id = "scopes",      size = 0.40 },
                { id = "breakpoints", size = 0.20 },
                { id = "stacks",      size = 0.20 },
                { id = "watches",     size = 0.20 },
              },
              size = 40,
              position = "left",
            },
            {
              elements = {
                { id = "repl",    size = 0.5 },
                { id = "console", size = 0.5 },
              },
              size = 12,
              position = "bottom",
            },
          },
        },
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
          -- Auto open/close UI
          dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
          dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
          dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
        end,
      },

      -- Virtual text for variable values while debugging
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          highlight_changed_variables = true,
          show_stop_reason = true,
          virt_text_pos = "eol",
        },
      },

      -- Python debug adapter
      {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        config = function()
          local debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
          require("dap-python").setup(debugpy)
        end,
      },

      -- Mason DAP installer
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim" },
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          ensure_installed = { "codelldb", "python", "coreclr" },
          automatic_installation = true,
          handlers = {
            function(config)
              require("mason-nvim-dap").default_setup(config)
            end,
          },
        },
      },
    },

    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,           desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,                                             desc = "Continue / Start" },
      { "<leader>ds", function() require("dap").step_over() end,                                            desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step into" },
      { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step out" },
      { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
      { "<leader>dr", function() require("dap").restart() end,                                              desc = "Restart" },
      { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run last" },
      { "<leader>dp", function() require("dap").pause() end,                                                desc = "Pause" },
      { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to cursor" },
      { "<leader>dL", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: ")) end, desc = "Log point" },
    },

    config = function()
      local dap = require("dap")
      local data = vim.fn.stdpath("data")

      -- C / C++ with codelldb
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = data .. "/mason/bin/codelldb",
          args = { "--port", "${port}" },
        },
      }
      dap.configurations.cpp = {
        {
          name = "Launch executable",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Launch with args",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = function()
            local args_str = vim.fn.input("Args: ")
            return vim.split(args_str, " ")
          end,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          args = {},
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- C# with netcoredbg
      dap.adapters.coreclr = {
        type = "executable",
        command = data .. "/mason/bin/netcoredbg",
        args = { "--interpreter=vscode" },
      }
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch .NET app",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
        {
          type = "coreclr",
          name = "Attach to process",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      -- DAP sign icons
      vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "󰛿 ", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "󰁕 ", texthl = "DiagnosticSignWarn", linehl = "DapStoppedLine", numhl = "" })
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
    end,
  },
}

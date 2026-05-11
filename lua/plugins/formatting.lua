return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format buffer",
        mode = { "n", "v" },
      },
    },
    opts = {
      formatters_by_ft = {
        -- C / C++
        c   = { "clang_format" },
        cpp = { "clang_format" },
        -- Python
        python = { "isort", "black" },
        -- C#
        cs = { "csharpier" },
        -- Java (fallback to LSP which uses google-java-format via jdtls)
        java = { "google_java_format" },
        -- Misc
        lua        = { "stylua" },
        json       = { "prettier" },
        jsonc      = { "prettier" },
        yaml       = { "prettier" },
        markdown   = { "prettier" },
        sh         = { "shfmt" },
      },
      format_on_save = function(bufnr)
        -- Disable format on save for certain filetypes
        local disable_fts = { "sql", "java" } -- java handled by lsp
        if vim.tbl_contains(disable_fts, vim.bo[bufnr].filetype) then
          return
        end
        return { timeout_ms = 2000, lsp_fallback = true }
      end,
      formatters = {
        clang_format = {
          prepend_args = { "--style=file,{BasedOnStyle: LLVM, IndentWidth: 4, ColumnLimit: 120}" },
        },
        black = {
          prepend_args = { "--line-length", "120" },
        },
        isort = {
          prepend_args = { "--profile", "black" },
        },
        google_java_format = {
          command = vim.fn.stdpath("data") .. "/mason/bin/google-java-format",
        },
      },
    },
  },
}

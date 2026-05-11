return {
  -- Git signs in gutter + hunk operations
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Git: " .. desc })
        end

        -- Navigation
        map("n", "]g", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, "Next hunk")
        map("n", "[g", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, "Prev hunk")

        -- Hunk actions
        map({ "n", "v" }, "<leader>ghs", function() gs.stage_hunk() end, "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", function() gs.reset_hunk() end, "Reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>ghd", gs.diffthis, "Diff this")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff this ~")
        map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")

        -- Text objects
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- Full git TUI via lazygit
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>",            desc = "LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit current file" },
      { "<leader>gl", "<cmd>LazyGitFilter<cr>",      desc = "LazyGit log" },
    },
  },

  -- GitHub-style diff viewer and file history
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffviewToggleFiles" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gdv", "<cmd>DiffviewOpen<cr>",           desc = "Diff view (HEAD)" },
      { "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>",  desc = "File history" },
      { "<leader>gdH", "<cmd>DiffviewFileHistory<cr>",    desc = "Branch history" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>",          desc = "Close diff view" },
    },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true,
      view = {
        default     = { layout = "diff2_horizontal", winbar_info = true },
        merge_tool  = { layout = "diff3_horizontal", disable_diagnostics = true },
        file_history = { layout = "diff2_horizontal" },
      },
      hooks = {
        -- Close Neovim if diffview is the last window
        view_closed = function()
          if #vim.api.nvim_list_wins() == 0 then vim.cmd("qa") end
        end,
      },
    },
  },

  -- GitHub: issues, PRs, and code reviews inside Neovim (requires `gh` CLI authed)
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>goi", "<cmd>Octo issue list<cr>",        desc = "GitHub issues" },
      { "<leader>gop", "<cmd>Octo pr list<cr>",           desc = "GitHub PRs" },
      { "<leader>goc", "<cmd>Octo pr create<cr>",         desc = "Create PR" },
      { "<leader>gor", "<cmd>Octo review start<cr>",      desc = "Start PR review" },
      { "<leader>goa", "<cmd>Octo actions<cr>",           desc = "Octo actions" },
    },
    opts = {
      enable_builtin = true,
      default_remote = { "upstream", "origin" },
      ui = { use_signcolumn = true },
      issues = {
        order_by = { field = "CREATED_AT", direction = "DESC" },
      },
      pull_requests = {
        order_by = { field = "CREATED_AT", direction = "DESC" },
        always_select_remote_on_create = false,
      },
      file_panel = { size = 10, use_icons = true },
    },
  },
}

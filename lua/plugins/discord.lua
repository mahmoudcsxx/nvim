return {
  {
    "vyfor/cord.nvim",
    build = ":Cord update",
    lazy = false,
    opts = {
      advanced = {
        discord = {
          pipe_paths = {
            vim.env.XDG_RUNTIME_DIR .. "/app/com.discordapp.Discord/discord-ipc-0",
            vim.env.XDG_RUNTIME_DIR .. "/discord-ipc-0",
          },
          reconnect = {
            enabled = true,
            interval = 5000,
            initial = true,
          },
        },
      },
    },
  },
}

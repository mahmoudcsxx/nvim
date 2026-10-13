# Neovim Config

Personal Neovim configuration built around `lazy.nvim`, LSP, completion, debugging,
formatting, Git tooling, snippets, and a small build/run workflow for programming.

![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-57A143?style=flat-square&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey?style=flat-square)

---

## Contents

- [Highlights](#highlights)
- [Requirements](#requirements)
- [Install](#install)
- [Structure](#structure)
- [Keymaps](#keymaps)
- [Language Support](#language-support)
- [Notes](#notes)

---

## Highlights

- Plugin management with `lazy.nvim`
- Catppuccin-based UI with statusline, bufferline, dashboard, file explorer, and notifications
- LSP setup through Mason and `nvim-lspconfig`
- Completion with `nvim-cmp` and LuaSnip snippets
- Treesitter syntax highlighting and code context
- Formatting with `conform.nvim`
- Debugging with `nvim-dap`, DAP UI, and Mason-managed adapters
- Git integration with Gitsigns, LazyGit, Diffview, and Octo
- Telescope-powered file, text, Git, symbol, and diagnostic search
- Discord Rich Presence via `cord.nvim` (`lua/plugins/discord.lua`)
- Custom runner for C, C++, Python, Java, C#, Lua, shell, JavaScript, and TypeScript

---

## Requirements

Install these first:

- Neovim 0.10+
- Git
- A C compiler / build tools
- `make`
- `ripgrep`
- `fd` or `fdfind`
- Node.js and npm
- Python 3

Optional but recommended:

- `lazygit`
- GitHub CLI, `gh`, for Octo/GitHub workflows
- Nerd Font for icons
- Language toolchains you use: `gcc`, `g++`, `clang`, `cmake`, `java`, `maven`,
  `gradle`, `.NET SDK`, `ts-node`
- A Discord client, if you want the Rich Presence integration to do anything

Most LSP servers, formatters, and debug adapters are installed automatically through
Mason on first startup.

---

## Install

Neovim's config directory is **not** the same path on every platform, so use the
one that matches your system.

### Windows

Neovim reads its config from `%LOCALAPPDATA%\nvim`:

```powershell
# Back up an existing config first, if you have one
if (Test-Path "$env:LOCALAPPDATA\nvim") {
    Move-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.bak"
}

git clone https://github.com/mahmoudcsxx/nvim.git "$env:LOCALAPPDATA\nvim"
```

### Linux / macOS

```bash
# Back up an existing config first, if you have one
mv ~/.config/nvim ~/.config/nvim.bak

git clone https://github.com/mahmoudcsxx/nvim.git ~/.config/nvim
```

### First launch

```bash
nvim
```

`lazy.nvim` will bootstrap itself, then install the configured plugins. Mason then
installs the LSP servers, formatters and debug adapters on first startup — that
takes a few minutes and needs a network connection. Run `:Lazy` and `:Mason` to
watch progress.

---

## Structure

```text
.
|-- init.lua
|-- lazy-lock.json
|-- ftplugin/
|   `-- java.lua
|-- lua/
|   |-- config/
|   |   |-- autocmds.lua
|   |   |-- keymaps.lua
|   |   `-- options.lua
|   |-- plugins/
|   |   |-- colorscheme.lua
|   |   |-- completion.lua
|   |   |-- debug.lua
|   |   |-- discord.lua
|   |   |-- editor.lua
|   |   |-- formatting.lua
|   |   |-- git.lua
|   |   |-- lsp.lua
|   |   |-- telescope.lua
|   |   |-- treesitter.lua
|   |   `-- ui.lua
|   `-- util/
|       |-- lsp.lua
|       `-- runner.lua
`-- snippets/
    |-- cpp.lua
    |-- cs.lua
    |-- java.lua
    `-- python.lua
```

`init.lua` bootstraps `lazy.nvim`, then loads `config.options`, `config.keymaps`
and `config.autocmds` before handing over to `lazy.nvim` with `plugins` as the
spec directory.

`lua/util/runner.lua` is what `<F5>` calls: it picks a build/run command from the
current filetype and any project files it finds (`pom.xml`, `build.gradle`,
`gradlew`, `Makefile`, `*.csproj`).

---

## Keymaps

Leader key: `Space`

| Key | Action |
| --- | --- |
| `jk` | Escape insert mode |
| `<C-s>` | Save file |
| `<C-h/j/k/l>` | Move between windows |
| `<leader>wv` | Vertical split |
| `<leader>wh` | Horizontal split |
| `<leader>wd` | Close window |
| `[b` / `]b` | Previous / next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>fn` | New file |
| `<A-j>` / `<A-k>` | Move line or selection down / up |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>/` | Fuzzy search current buffer |
| `<leader>e` | Toggle file explorer |
| `<leader>E` | Reveal current file in explorer |
| `<leader>cf` | Format buffer |
| `<leader>cd` | Show line diagnostics |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>xx` | Trouble diagnostics |
| `<leader>xq` | Quickfix list (Trouble) |
| `<F5>` | Build and run current file/project |
| `<leader>rr` | Build and run |
| `<leader>rb` | Build only |
| `<leader>tt` | Floating terminal |
| `<leader>gg` | LazyGit |
| `<leader>gdv` | Diffview |
| `<leader>m` | Mason |
| `<leader>l` | Lazy |

More mappings are available through which-key after pressing `<leader>`.

---

## Language Support

Configured LSP/tooling includes:

- C / C++: `clangd`, `clang-format`, `codelldb`
- Python: `pyright`, `black`, `isort`, `debugpy`
- C#: `omnisharp`, `csharpier`, `netcoredbg`
- Java: `jdtls`, `google-java-format`, Java debug/test adapters
- Lua: `lua-language-server`, `stylua`
- Bash: `bash-language-server`, `shfmt`
- JSON / YAML: schema-aware language servers
- CMake: `cmake-language-server`
- Markdown: `marksman`

---

## Notes

This is my personal setup, so it is optimized for my workflow and languages. Feel
free to fork it, copy pieces from it, or use it as a starting point for your own
Neovim configuration.

**The published config can lag behind the one I actually run.** If a plugin or
mapping here looks stale, that is usually why — check the commit dates.

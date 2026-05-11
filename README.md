# Neovim Config

Personal Neovim configuration built around `lazy.nvim`, LSP, completion, debugging,
formatting, Git tooling, snippets, and a small build/run workflow for programming.

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
- Custom runner for C, C++, Python, Java, C#, Lua, shell, JavaScript, and TypeScript

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

Most LSP servers, formatters, and debug adapters are installed automatically through
Mason on first startup.

## Install

Back up your existing config first if you already have one:

```bash
mv ~/.config/nvim ~/.config/nvim.bak
```

Clone this config:

```bash
git clone https://github.com/mahmoudcsxx/nvim.git ~/.config/nvim
```

Start Neovim:

```bash
nvim
```

`lazy.nvim` will bootstrap itself, then install the configured plugins.

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

## Keymaps

Leader key: `Space`

| Key | Action |
| --- | --- |
| `jk` | Escape insert mode |
| `<C-s>` | Save file |
| `<C-h/j/k/l>` | Move between windows |
| `<leader>wv` | Vertical split |
| `<leader>wh` | Horizontal split |
| `[b` / `]b` | Previous / next buffer |
| `<leader>bd` | Delete buffer |
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
| `<F5>` | Build and run current file/project |
| `<leader>rr` | Build and run |
| `<leader>rb` | Build only |
| `<leader>tt` | Floating terminal |
| `<leader>gg` | LazyGit |
| `<leader>gdv` | Diffview |
| `<leader>m` | Mason |
| `<leader>l` | Lazy |

More mappings are available through which-key after pressing `<leader>`.

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

## Notes

This is my personal setup, so it is optimized for my workflow and languages. Feel
free to fork it, copy pieces from it, or use it as a starting point for your own
Neovim configuration.

local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.wrap = false
opt.linebreak = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.cursorline = true
opt.colorcolumn = "120"
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.clipboard = "unnamedplus"

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.autowrite = true
opt.autowriteall = true

opt.splitbelow = true
opt.splitright = true

opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10

opt.timeoutlen = 300
opt.updatetime = 200

-- Treesitter-based folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false
opt.foldlevel = 99

opt.mouse = "a"
opt.showmode = false
opt.hidden = true
opt.fileencoding = "utf-8"
opt.cmdheight = 1
opt.pumblend = 10
opt.winblend = 0
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.virtualedit = "block"
opt.smoothscroll = true
opt.spelllang = { "en" }

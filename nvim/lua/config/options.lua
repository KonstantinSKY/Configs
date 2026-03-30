local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.showmode = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true

opt.updatetime = 250
opt.timeoutlen = 300

opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 4
opt.sidescrolloff = 8

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
opt.confirm = true

opt.expandtab = true
opt.smartindent = true
opt.shiftround = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4

opt.wrap = false
opt.breakindent = true

opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }
opt.clipboard:append("unnamedplus")

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

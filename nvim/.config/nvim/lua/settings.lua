local cmd = vim.cmd
local g = vim.g
local opt = vim.opt

g.loaded_perl_provider = 0
g.loaded_python_provider = 0
g.loaded_ruby_provider = 0

g.mapleader = ","

opt.listchars = {
    eol = '↲',
    tab = '▸ ',
    trail = '·',
}
opt.list = true

opt.sidescrolloff = 30
opt.colorcolumn = "160"
opt.updatetime = 100
opt.ttimeoutlen = 25
opt.showtabline = 2
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true

opt.hlsearch = false
opt.wrap = false
opt.showmode = false
opt.swapfile = false

opt.ignorecase = true
opt.smartcase = true
opt.fixendofline = false
opt.splitbelow = true
opt.laststatus = 3
opt.foldcolumn = "auto"

opt.termguicolors = true
opt.completeopt = "menu,menuone,noselect"

require("everforest").load()

cmd([[packadd cfilter]])
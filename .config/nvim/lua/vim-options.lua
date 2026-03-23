vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.list = true
vim.opt.listchars = { space = '·', tab = '»·', trail = '·', extends = '→', precedes = '←' }

vim.g.mapleader = " "

vim.cmd("set nowrap")
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.opt.clipboard:append { 'unnamedplus' }

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

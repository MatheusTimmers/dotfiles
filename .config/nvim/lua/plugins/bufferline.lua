return {
  'akinsho/bufferline.nvim',
  event = "VeryLazy",
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  keys = {
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[b",    "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "]b",    "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[B",    "<cmd>BufferLineMovePrev<cr>",  desc = "Move buffer prev" },
    { "]B",    "<cmd>BufferLineMoveNext<cr>",  desc = "Move buffer next" },
  },
  config = function()
    vim.opt.termguicolors = true
    require("bufferline").setup {}
  end
}

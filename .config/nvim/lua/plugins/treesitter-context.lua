return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "VeryLazy",
  opts = { mode = "cursor", max_lines = 3 },
  keys = {
    { "<leader>uc", function() require("treesitter-context").toggle() end, desc = "Toggle treesitter context" },
    { "[x", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Jump to context" },
  },
}

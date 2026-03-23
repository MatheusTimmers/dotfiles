return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      {
        "<leader>,",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Switch Buffer",
      },
      { "<leader>fg", require("telescope.builtin").live_grep, desc = "Grep (Root Dir)" },
      { "<leader>fp", require("telescope.builtin").find_files, desc = "Find Files" },
    },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set('n', '<C-p>', builtin.find_files, {})
    end
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
            }
          }
        }
      })
      require("telescope").load_extension("ui-select")
    end
  }
}

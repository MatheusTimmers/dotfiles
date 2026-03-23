return {
  "lukas-reineke/indent-blankline.nvim",
  opts = function()
    return {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { show_start = false, show_end = false },
      exclude = {
        filetypes = {
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
        },
      },
    }
  end,
  main = "ibl",
}

return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  opts = { headerMaxWidth = 80 },
  keys = {
    {
      "<leader>fR",
      function()
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        require("grug-far").open({
          prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
        })
      end,
      mode = { "n", "x" },
      desc = "Search and replace",
    },
    {
      "<leader>fW",
      function()
        require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
      end,
      desc = "Replace word under cursor",
    },
  },
}

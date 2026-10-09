return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = { providers = { "lsp" } },
    filetypes_denylist = { "neo-tree", "snacks_dashboard", "Trouble", "trouble", "lazy", "mason" },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)
  end,
  keys = {
    { "]]", function() require("illuminate").goto_next_reference(false) end, desc = "Next reference" },
    { "[[", function() require("illuminate").goto_prev_reference(false) end, desc = "Prev reference" },
  },
}

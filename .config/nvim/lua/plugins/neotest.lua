return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "fredrikaverpil/neotest-golang", version = "*" },
    "mrcjkb/rustaceanvim",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-golang")({}),
        require("rustaceanvim.neotest"),
      },
    })

    local map = function(l, r, desc)
      vim.keymap.set("n", l, r, { desc = desc })
    end

    map("<leader>tt", function() require("neotest").run.run() end,                   "Run Nearest Test")
    map("<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, "Run File Tests")
    map("<leader>ts", function() require("neotest").summary.toggle() end,            "Toggle Test Summary")
    map("<leader>to", function() require("neotest").output_panel.toggle() end,       "Toggle Test Output")
    map("<leader>tS", function() require("neotest").run.stop() end,                  "Stop Test")
    map("]T",         function() require("neotest").jump.next({ status = "failed" }) end, "Next Failed Test")
    map("[T",         function() require("neotest").jump.prev({ status = "failed" }) end, "Prev Failed Test")
  end,
}

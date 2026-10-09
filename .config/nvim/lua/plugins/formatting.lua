return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "x" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        objc = { "clang-format" },
        objcpp = { "clang-format" },
        cuda = { "clang-format" },
        proto = { "clang-format" },
        go = { "goimports", "gofumpt" },
        cs = { "csharpier" },
        verilog = { "verible" },
        systemverilog = { "verible" },
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    ft = "go",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.code_actions.gomodifytags,
          null_ls.builtins.code_actions.impl,
        },
      })
    end,
  },
}

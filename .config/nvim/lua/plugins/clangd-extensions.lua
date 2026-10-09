return {
  "p00f/clangd_extensions.nvim",
  ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  opts = {
    memory_usage = { border = "rounded" },
    symbol_info = { border = "rounded" },
  },
  keys = {
    { "<leader>cA", "<cmd>ClangdAST<cr>", desc = "Clangd AST", ft = { "c", "cpp" } },
    { "<leader>cT", "<cmd>ClangdTypeHierarchy<cr>", desc = "Type hierarchy", ft = { "c", "cpp" } },
    { "<leader>cI", "<cmd>ClangdSymbolInfo<cr>", desc = "Symbol info", ft = { "c", "cpp" } },
    { "<leader>cM", "<cmd>ClangdMemoryUsage<cr>", desc = "Clangd memory usage", ft = { "c", "cpp" } },
  },
}

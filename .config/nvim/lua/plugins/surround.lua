return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup()
  end,
}
-- Uso:
--   ys iw"   → envolve palavra com aspas
--   ys s(    → envolve linha com parênteses
--   ds"      → remove aspas ao redor
--   cs"'     → troca " por '

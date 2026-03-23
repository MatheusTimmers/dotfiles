return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    local flavor_file = vim.fn.stdpath("config") .. "/flavor"
    local f = io.open(flavor_file, "r")
    local flavor = f and f:read("*l") or "frappe"
    if f then f:close() end

    require("catppuccin").setup({ flavour = flavor })
    vim.cmd.colorscheme("catppuccin")
  end
}

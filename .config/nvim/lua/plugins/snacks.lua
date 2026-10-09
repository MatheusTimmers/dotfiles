local header = table.concat({
  [[       ████ ██████           █████      ██                     ]],
  [[      ███████████             █████                             ]],
  [[      █████████ ███████████████████ ███   ███████████   ]],
  [[     █████████  ███    █████████████ █████ ██████████████   ]],
  [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
  [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
  [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
}, "\n")

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    lazygit = { enabled = true },
    rename = { enabled = true },
    scroll = {
      enabled = true,
      animate = { duration = { step = 10, total = 120 } },
    },
    words = { enabled = false },
    indent = {
      enabled = true,
      indent = { char = "│" },
      scope = { enabled = true, char = "│" },
      animate = { duration = { step = 15, total = 250 } },
    },
    dashboard = {
      enabled = true,
      preset = { header = header },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
  },
  keys = {
    { "<leader>gg", function() Snacks.lazygit() end, desc = "LazyGit" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "LazyGit Log" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "LazyGit File History" },
    { "<leader>gB", function() Snacks.gitbrowse() end, mode = { "n", "v" }, desc = "Open in browser" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss Notifications" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.scroll():map("<leader>uS")
      end,
    })
  end,
}

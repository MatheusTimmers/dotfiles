return {
  "christoomey/vim-tmux-navigator",
  -- Os comandos so existem depois que o plugin carrega, entao as teclas ficam
  -- em `keys` (lazy carrega sob demanda) em vez de vim.keymap.set solto no spec.
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
  },
  keys = {
    { "<c-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Window/pane left" },
    { "<c-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Window/pane down" },
    { "<c-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Window/pane up" },
    { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
  },
}

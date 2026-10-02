return {
  'nvim-telescope/telescope.nvim',
  -- master, e nao tag: a 0.1.8 (mai/2024) chama nvim-treesitter.parsers.ft_to_lang,
  -- que sumiu na reescrita do branch main -- toda preview com treesitter estoura
  -- com "attempt to call field 'ft_to_lang' (a nil value)". O master ja usa o
  -- vim.treesitter.start nativo, e a correcao nao entrou em nenhuma tag ainda.
  -- O lazy-lock.json continua fixando o commit exato.
  branch = 'master',
  -- VeryLazy em vez de so `keys`: o ui-select precisa rodar load_extension para
  -- assumir o vim.ui.select (code actions, mason...), entao o telescope tem que
  -- carregar de qualquer jeito -- mas depois da UI aparecer, nao durante o startup.
  event = "VeryLazy",
  cmd = "Telescope",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
  },
  keys = {
    {
      "<leader>,",
      "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
      desc = "Switch Buffer",
    },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "Grep (Root Dir)" },
    { "<leader>fp", function() require("telescope.builtin").find_files() end, desc = "Find Files" },
    { "<leader>fw", function() require("telescope.builtin").grep_string() end, desc = "Grep word under cursor" },
    { "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Document symbols" },
    { "<leader>fS", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, desc = "Workspace symbols" },
    { "<leader>fd", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics" },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end,  desc = "Help" },
    { "<leader>fk", function() require("telescope.builtin").keymaps() end,    desc = "Keymaps" },
    { "<leader>fr", function() require("telescope.builtin").resume() end,     desc = "Resume last search" },
  },
  config = function()
    local telescope = require("telescope")
    -- Um setup so: antes o spec do ui-select chamava telescope.setup() por conta
    -- propria, sobrescrevendo o que estivesse configurado aqui.
    telescope.setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
      },
    })
    telescope.load_extension("ui-select")

    vim.keymap.set('n', '<C-p>', require("telescope.builtin").find_files, { desc = "Find Files" })
  end,
}

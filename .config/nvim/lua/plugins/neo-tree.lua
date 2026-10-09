return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-mini/mini.icons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local function on_move(data)
      Snacks.rename.on_rename_file(data.source, data.destination)
    end
    local events = require("neo-tree.events")
    require("neo-tree").setup({
      event_handlers = {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      },
    })
    vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<cr>', { desc = "File explorer" })
  end
}

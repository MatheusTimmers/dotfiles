local function jump(direction)
  return function()
    local trouble = require("trouble")
    if trouble.is_open() then
      trouble[direction]({ skip_groups = true, jump = true })
      return
    end
    local ok, err = pcall(direction == "next" and vim.cmd.cnext or vim.cmd.cprev)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end

return {
  "folke/trouble.nvim",
  cmd = { "Trouble" },
  opts = {
    modes = {
      lsp = { win = { position = "right" } },
      lsp_base = { win = { position = "right" } },
    },
  },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location List (Trouble)" },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List (Trouble)" },

    { "<leader>cs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)" },
    { "<leader>cS", "<cmd>Trouble lsp toggle<cr>",                      desc = "LSP references/definitions/... (Trouble)" },
    { "<leader>ci", "<cmd>Trouble lsp_incoming_calls toggle<cr>",       desc = "Incoming calls (Trouble)" },
    { "<leader>co", "<cmd>Trouble lsp_outgoing_calls toggle<cr>",       desc = "Outgoing calls (Trouble)" },

    { "[q", jump("prev"), desc = "Previous Trouble/Quickfix Item" },
    { "]q", jump("next"), desc = "Next Trouble/Quickfix Item" },
  },
}

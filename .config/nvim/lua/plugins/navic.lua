return {
  "SmiteshP/nvim-navic",
  lazy = true,
  init = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("navic_attach", { clear = true }),
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method("textDocument/documentSymbol", ev.buf) then
          require("nvim-navic").attach(client, ev.buf)
        end
      end,
    })
  end,
  opts = {
    separator = " > ",
    highlight = true,
    depth_limit = 5,
    lazy_update_context = true,
  },
}

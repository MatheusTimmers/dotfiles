-- Fechar o que voce abriu.
--
-- O :bdelete puro fecha junto a janela que segura o buffer, entao ler um arquivo
-- num split e dispensa-lo desmonta o layout. Estes helpers tiram cada janela de
-- cima do buffer primeiro, e so depois o deletam.

local M = {}

--- Deleta um buffer sem desmontar o layout de janelas.
--- @param opts? { buf?: integer, force?: boolean }
function M.remove(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()

  if vim.bo[buf].modified and not opts.force then
    local choice = vim.fn.confirm(("Salvar alteracoes em %q?"):format(vim.fn.bufname(buf)), "&Sim\n&Nao\n&Cancelar")
    if choice == 0 or choice == 3 then -- cancelado
      return
    end
    if choice == 1 then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd.write()
      end)
    end
  end

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
        return
      end
      -- Prefere o arquivo alternado, depois o anterior na lista de buffers, e
      -- so cai num buffer vazio quando nao ha mais nada listado.
      local alt = vim.fn.bufnr("#")
      if alt ~= buf and vim.fn.buflisted(alt) == 1 then
        vim.api.nvim_win_set_buf(win, alt)
        return
      end
      local ok = pcall(vim.cmd, "bprevious")
      if ok and buf ~= vim.api.nvim_win_get_buf(win) then
        return
      end
      vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
    end)
  end

  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.cmd, (opts.force and "bdelete! " or "bdelete ") .. buf)
  end
end

--- Deleta todos os buffers listados menos o atual.
function M.remove_others()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted and not vim.bo[buf].modified then
      M.remove({ buf = buf })
    end
  end
end

function M.setup()
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = desc })
  end

  map("<leader>bd", function() M.remove() end, "Close buffer (keep window)")
  map("<leader>bD", function() M.remove({ force = true }) end, "Close buffer (discard changes)")
  map("<leader>bo", M.remove_others, "Close other buffers")
  map("<leader>bq", "<cmd>close<cr>", "Close window (keep buffer)")

  -- Janelas descartaveis (help, quickfix, :man, logs do LSP) sao as que voce
  -- abre so para olhar e ja quer fechar -- q e a convencao para elas.
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
    pattern = {
      "help",
      "man",
      "qf",
      "checkhealth",
      "lspinfo",
      "startuptime",
      "notify",
      "query",
      "netrw",
      "gitsigns-blame",
    },
    callback = function(ev)
      vim.bo[ev.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", {
        buffer = ev.buf,
        silent = true,
        desc = "Close window",
      })
    end,
  })
end

return M

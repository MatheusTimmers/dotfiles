-- Mantem o compile_commands.json de projetos PlatformIO em dia para o clangd.
--
-- O clangd descobre includes e defines lendo compile_commands.json, mas o
-- PlatformIO so o gera sob demanda (`pio run -t compiledb`); o que ele escreve
-- sozinho e .vscode/c_cpp_properties.json, formato da extensao da Microsoft,
-- que o clangd ignora. Sem o banco, o clangd parseia o codigo sem nenhum -I e
-- marca Arduino.h, String, millis... como inexistentes.

local M = {}

local FILETYPES = { "c", "cpp", "arduino", "objc", "objcpp" }

-- O instalador do PlatformIO nao poe o pio no PATH; o venv dele e o fallback.
local function pio_exe()
  if vim.fn.executable("pio") == 1 then
    return "pio"
  end
  local venv = vim.env.HOME .. "/.platformio/penv/bin/pio"
  return vim.fn.executable(venv) == 1 and venv or nil
end

local function project_root(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return nil
  end
  local ini = vim.fs.find("platformio.ini", {
    path = vim.fs.dirname(name),
    upward = true,
    type = "file",
  })[1]
  return ini and vim.fs.dirname(ini) or nil
end

-- Regenera quando o banco nao existe ou quando o platformio.ini mudou depois
-- dele (troca de board, lib_deps nova, build_flags...).
local function stale(root)
  local db = vim.uv.fs_stat(root .. "/compile_commands.json")
  if not db then
    return true
  end
  local ini = vim.uv.fs_stat(root .. "/platformio.ini")
  return ini ~= nil and ini.mtime.sec > db.mtime.sec
end

-- O clangd le o banco uma vez, no startup: sem reiniciar, ele segue mostrando
-- os erros antigos mesmo com o arquivo ja no disco.
local function restart_clangd(root)
  local buffers = {}
  for _, client in ipairs(vim.lsp.get_clients({ name = "clangd" })) do
    if client.root_dir == nil or client.root_dir == root then
      for buf in pairs(client.attached_buffers) do
        buffers[#buffers + 1] = buf
      end
      client:stop()
    end
  end
  if #buffers == 0 then
    return
  end
  -- vim.lsp.enable engancha o autostart no FileType, entao reemitir o evento
  -- reata o cliente novo -- sem depender do :LspRestart do nvim-lspconfig.
  vim.defer_fn(function()
    for _, buf in ipairs(buffers) do
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
      end
    end
  end, 300)
end

local in_flight = {}

--- @param opts? { root?: string, silent?: boolean }
function M.compiledb(opts)
  opts = opts or {}
  local root = opts.root or project_root(0)
  if not root then
    if not opts.silent then
      vim.notify("platformio.ini nao encontrado a partir deste buffer", vim.log.levels.WARN)
    end
    return
  end
  if in_flight[root] then
    return
  end
  local exe = pio_exe()
  if not exe then
    vim.notify("pio nao encontrado (nem no PATH nem em ~/.platformio/penv/bin)", vim.log.levels.ERROR)
    return
  end

  in_flight[root] = true
  vim.system(
    { exe, "run", "-t", "compiledb" },
    { cwd = root, text = true },
    vim.schedule_wrap(function(res)
      in_flight[root] = nil
      if res.code ~= 0 then
        local err = res.stderr ~= "" and res.stderr or res.stdout
        vim.notify("pio run -t compiledb falhou:\n" .. err, vim.log.levels.ERROR)
        return
      end
      restart_clangd(root)
      if not opts.silent then
        vim.notify("compile_commands.json atualizado", vim.log.levels.INFO)
      end
    end)
  )
end

function M.setup()
  vim.api.nvim_create_user_command("PioCompileDB", function()
    M.compiledb({})
  end, { desc = "PlatformIO: regenerate compile_commands.json and restart clangd" })

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("platformio_compiledb", { clear = true }),
    pattern = FILETYPES,
    callback = function(ev)
      local root = project_root(ev.buf)
      if not root then
        return
      end
      vim.keymap.set("n", "<leader>cp", function()
        M.compiledb({ root = root })
      end, { buffer = ev.buf, desc = "PlatformIO compiledb" })

      if stale(root) then
        M.compiledb({ root = root })
      end
    end,
  })
end

return M

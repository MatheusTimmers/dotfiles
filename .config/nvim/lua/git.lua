local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "git" })
end

local function git(args, cwd)
  local result = vim.system(vim.list_extend({ "git" }, args), { cwd = cwd, text = true }):wait()
  return result.code == 0, vim.trim(result.stdout or ""), vim.trim(result.stderr or "")
end

local function file_of(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" or vim.bo[buf].buftype ~= "" then
    return nil
  end
  return name
end

local function root()
  local file = file_of(vim.api.nvim_get_current_buf())
  local dir = file and vim.fs.dirname(file) or vim.uv.cwd()
  if not vim.uv.fs_stat(dir) then
    dir = vim.uv.cwd()
  end
  local ok, out = git({ "rev-parse", "--show-toplevel" }, dir)
  if not ok then
    notify("Nao e um repositorio git", vim.log.levels.WARN)
    return nil
  end
  return out
end

local function inside(path, dir)
  local real = vim.uv.fs_realpath(path) or path
  return vim.startswith(real, dir .. "/")
end

local function reload_buffers(dir, discard)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local file = vim.api.nvim_buf_is_loaded(buf) and file_of(buf)
    if file and inside(file, dir) then
      local modified = vim.bo[buf].modified
      if vim.uv.fs_stat(file) then
        if discard or not modified then
          vim.api.nvim_buf_call(buf, function()
            vim.cmd("edit!")
          end)
        end
      elseif discard or not modified then
        require("buffers").remove({ buf = buf, force = true })
      end
    end
  end
end

local function run(args, cwd, success)
  local ok, out, err = git(args, cwd)
  reload_buffers(cwd, false)
  if not ok then
    notify(err ~= "" and err or out, vim.log.levels.ERROR)
    return false
  end
  notify(success)
  return true
end

function M.discard_file()
  local buf = vim.api.nvim_get_current_buf()
  local file = file_of(buf)
  if not file then
    notify("Buffer sem arquivo", vim.log.levels.WARN)
    return
  end
  local cwd = root()
  if not cwd then
    return
  end
  local name = vim.fn.fnamemodify(file, ":.")

  if not git({ "ls-files", "--error-unmatch", "--", file }, cwd) then
    if vim.fn.confirm(("%q nao esta versionado. Apagar o arquivo?"):format(name), "&Apagar\n&Cancelar", 2) ~= 1 then
      return
    end
    require("buffers").remove({ buf = buf, force = true })
    local ok, err = os.remove(file)
    if not ok then
      notify(err, vim.log.levels.ERROR)
      return
    end
    notify(("%s apagado"):format(name))
    return
  end

  if vim.fn.confirm(("Descartar todas as alteracoes em %q?"):format(name), "&Descartar\n&Cancelar", 2) ~= 1 then
    return
  end
  local ok, _, err = git({ "restore", "--source=HEAD", "--staged", "--worktree", "--", file }, cwd)
  if not ok then
    notify(err, vim.log.levels.ERROR)
    return
  end
  if vim.uv.fs_stat(file) then
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("edit!")
    end)
  else
    require("buffers").remove({ buf = buf, force = true })
  end
  notify(("Alteracoes descartadas em %s"):format(name))
end

function M.discard_all()
  local cwd = root()
  if not cwd then
    return
  end
  local choice = vim.fn.confirm(
    ("Descartar TODAS as alteracoes em %s?"):format(vim.fn.fnamemodify(cwd, ":~")),
    "&Versionados\n&Tudo (inclui untracked)\n&Cancelar",
    3
  )
  if choice ~= 1 and choice ~= 2 then
    return
  end

  local ok, _, err = git({ "reset", "--hard", "HEAD" }, cwd)
  if ok and choice == 2 then
    ok, _, err = git({ "clean", "-fd" }, cwd)
  end
  reload_buffers(cwd, true)
  if not ok then
    notify(err, vim.log.levels.ERROR)
    return
  end
  notify("Alteracoes descartadas")
end

function M.stash()
  local cwd = root()
  if not cwd then
    return
  end
  vim.ui.input({ prompt = "Stash message: " }, function(msg)
    if msg == nil then
      return
    end
    local args = { "stash", "push", "--include-untracked" }
    if vim.trim(msg) ~= "" then
      vim.list_extend(args, { "-m", msg })
    end
    run(args, cwd, "Alteracoes guardadas no stash")
  end)
end

function M.stash_pop()
  local cwd = root()
  if cwd then
    run({ "stash", "pop" }, cwd, "Stash aplicado e removido")
  end
end

function M.stash_list()
  local cwd = root()
  if not cwd then
    return
  end
  local actions = require("telescope.actions")
  local state = require("telescope.actions.state")

  local function on_selected(fn)
    return function(prompt_bufnr)
      local entry = state.get_selected_entry()
      actions.close(prompt_bufnr)
      if entry then
        fn(entry.value)
      end
    end
  end

  require("telescope.builtin").git_stash({
    cwd = cwd,
    prompt_title = "Git Stash (<CR> apply, <C-p> pop, <C-x> drop)",
    attach_mappings = function(_, map)
      actions.select_default:replace(on_selected(function(ref)
        run({ "stash", "apply", ref }, cwd, ("%s aplicado"):format(ref))
      end))
      map({ "i", "n" }, "<C-p>", on_selected(function(ref)
        run({ "stash", "pop", ref }, cwd, ("%s aplicado e removido"):format(ref))
      end))
      map({ "i", "n" }, "<C-x>", on_selected(function(ref)
        if vim.fn.confirm(("Apagar %s?"):format(ref), "&Apagar\n&Cancelar", 2) == 1 then
          run({ "stash", "drop", ref }, cwd, ("%s apagado"):format(ref))
        end
      end))
      return true
    end,
  })
end

function M.setup()
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = desc })
  end

  map("<leader>gx", M.discard_file, "Discard File Changes")
  map("<leader>gX", M.discard_all, "Discard All Changes")
  map("<leader>gzz", M.stash, "Stash Changes")
  map("<leader>gzp", M.stash_pop, "Stash Pop")
  map("<leader>gzl", M.stash_list, "Stash List")
end

return M

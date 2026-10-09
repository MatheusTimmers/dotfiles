local M = {}

local IS_WINDOWS = vim.fn.has("win32") == 1
local SOURCE_PATTERNS = { "*.pas", "*.dpr", "*.dpk", "*.inc" }
local STUDIO_GLOBS = {
  "C:/Program Files (x86)/Embarcadero/Studio/*/bin",
  "C:/Program Files/Embarcadero/Studio/*/bin",
}
local BUILD_EFM = table.concat({
  "%f(%l\\,%c): %trror %m",
  "%f(%l\\,%c): %tarning %m",
  "%f(%l): %trror %m",
  "%f(%l): %tarning %m",
  "%f(%l): %tatal %m",
  "%f(%l): h%tnt %m",
  "%-G%.%#",
}, ",")

local function find_dir(markers, depth)
  for _, pattern in ipairs(markers) do
    local hits = vim.fn.glob(pattern, false, true)
    if #hits > 0 then
      local dir = hits[#hits]
      for _ = 1, depth do
        dir = vim.fs.dirname(dir)
      end
      return dir
    end
  end
end

local function project_root(bufnr, on_dir)
  local root = vim.fs.root(bufnr, function(name)
    return name:match("%.delphilsp%.json$") or name:match("%.groupproj$") or name:match("%.dproj$") or name:match("%.lpi$")
  end) or vim.fs.root(bufnr, ".git")
  on_dir(root or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
end

local function studio_bin()
  if vim.env.BDS and vim.uv.fs_stat(vim.env.BDS .. "/bin/DelphiLSP.exe") then
    return vim.fs.normalize(vim.env.BDS .. "/bin")
  end
  local exe = vim.fn.exepath("DelphiLSP.exe")
  if exe ~= "" then
    return vim.fs.dirname(vim.fs.normalize(exe))
  end
  local found = {}
  for _, pattern in ipairs(STUDIO_GLOBS) do
    for _, dir in ipairs(vim.fn.glob(pattern, false, true)) do
      if vim.uv.fs_stat(dir .. "/DelphiLSP.exe") then
        table.insert(found, vim.fs.normalize(dir))
      end
    end
  end
  table.sort(found, function(a, b)
    return (tonumber(a:match("Studio/([%d%.]+)/")) or 0) < (tonumber(b:match("Studio/([%d%.]+)/")) or 0)
  end)
  return found[#found]
end

local function find_in(root, suffix, limit)
  return vim.fs.find(function(name)
    return name:sub(-#suffix) == suffix
  end, { path = root, type = "file", limit = limit or math.huge, upward = false })
end

local function setup_delphilsp()
  local bin = studio_bin()
  if not bin then
    return
  end
  vim.lsp.config("delphi_ls", {
    cmd = { bin .. "/DelphiLSP.exe" },
    filetypes = { "pascal" },
    root_dir = project_root,
    on_init = function(client)
      local settings = find_in(client.root_dir, ".delphilsp.json", 1)[1]
      if not settings then
        vim.notify_once(
          "DelphiLSP: nenhum *.delphilsp.json em " .. client.root_dir
            .. "\nGere na IDE: Tools > Options > Editor > Language > Code Insight > Generate LSP Config",
          vim.log.levels.WARN
        )
        return
      end
      client.config.settings = { settingsFile = settings }
      client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end,
  })
  vim.lsp.enable("delphi_ls")
end

local function pasls_exe()
  if vim.fn.executable("pasls") == 1 then
    return "pasls"
  end
  local local_bin = vim.env.HOME .. "/.local/bin/pasls"
  return vim.fn.executable(local_bin) == 1 and local_bin or nil
end

local function pasls_env()
  return {
    FPCDIR = vim.env.FPCDIR or find_dir({
      "/usr/share/fpcsrc/rtl",
      "/usr/share/fpcsrc/*/rtl",
      "/usr/lib*/fpc/src/rtl",
      "/usr/lib*/fpc/*/source/rtl",
    }, 1),
    PP = vim.env.PP or find_dir({ "/usr/lib*/fpc/*/ppcx64" }, 0),
    LAZARUSDIR = vim.env.LAZARUSDIR or find_dir({
      "/usr/lib*/lazarus/components/codetools",
      "/usr/share/lazarus/components/codetools",
    }, 2),
    FPCTARGETCPU = "x86_64",
  }
end

local function setup_pasls()
  local exe = pasls_exe()
  if not exe then
    return
  end
  vim.lsp.config("pasls", {
    cmd = { exe },
    cmd_env = pasls_env(),
    root_dir = project_root,
    init_options = {
      fpcOptions = { "-Mdelphiunicode" },
      includeWorkspaceFoldersAsUnitPaths = true,
      includeWorkspaceFoldersAsIncludePaths = true,
      insertCompletionsAsSnippets = true,
      insertCompletionProcedureBrackets = true,
      maximumCompletions = 200,
      documentSymbols = true,
      checkSyntax = false,
      publishDiagnostics = false,
      showSyntaxErrors = false,
    },
  })
  vim.lsp.enable("pasls")
end

local function build_lines(output)
  local lines = {}
  for line in output:gmatch("[^\r\n]+") do
    line = line:gsub("^%s+", ""):gsub("%s+%[[^%]]+%.dproj%]$", "")
    table.insert(lines, line)
  end
  return lines
end

local function run_build(project, config, platform)
  local bin = studio_bin()
  if not bin then
    vim.notify("Delphi: RAD Studio não encontrado (DelphiLSP.exe/rsvars.bat)", vim.log.levels.ERROR)
    return
  end
  local script = ('chcp 65001 >nul && call "%s" && msbuild "%s" /t:Build /p:Config=%s /p:Platform=%s /nologo /v:minimal'):format(
    vim.fs.joinpath(bin, "rsvars.bat"):gsub("/", "\\"),
    project:gsub("/", "\\"),
    config,
    platform
  )
  local name = vim.fs.basename(project)
  vim.notify(("Delphi: compilando %s (%s|%s)..."):format(name, config, platform))
  vim.system({ "cmd.exe", "/d", "/s", "/c", script }, { text = true, cwd = vim.fs.dirname(project) }, function(res)
    vim.schedule(function()
      vim.fn.setqflist({}, " ", {
        title = "msbuild " .. name,
        lines = build_lines((res.stdout or "") .. "\n" .. (res.stderr or "")),
        efm = BUILD_EFM,
      })
      local errors = #vim.tbl_filter(function(item)
        return item.valid == 1 and (item.type == "e" or item.type == "f")
      end, vim.fn.getqflist())
      if res.code == 0 and errors == 0 then
        vim.cmd("cclose")
        vim.notify(("Delphi: %s compilado"):format(name))
      else
        vim.cmd("copen")
        vim.notify(("Delphi: %s falhou (%d erro(s))"):format(name, errors), vim.log.levels.ERROR)
      end
    end)
  end)
end

local function build(opts)
  local config = opts.fargs[1] or "Debug"
  local platform = opts.fargs[2] or "Win32"
  local root
  project_root(0, function(dir)
    root = dir
  end)
  local projects = find_in(root, ".dproj")
  if #projects == 0 then
    vim.notify("Delphi: nenhum .dproj em " .. root, vim.log.levels.WARN)
  elseif #projects == 1 then
    run_build(projects[1], config, platform)
  else
    vim.ui.select(projects, {
      prompt = "Projeto",
      format_item = function(path)
        return vim.fs.basename(path)
      end,
    }, function(choice)
      if choice then
        run_build(choice, config, platform)
      end
    end)
  end
end

function M.setup()
  vim.filetype.add({ extension = { dpk = "pascal" } })
  vim.opt.fileencodings = "ucs-bom,utf-8,cp1252,latin1"

  local group = vim.api.nvim_create_augroup("delphi", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "pascal",
    callback = function(ev)
      local bo = vim.bo[ev.buf]
      bo.expandtab = true
      bo.shiftwidth = 2
      bo.tabstop = 2
      bo.softtabstop = 2
      bo.commentstring = "// %s"
      if IS_WINDOWS then
        vim.keymap.set("n", "<leader>cb", "<cmd>DelphiBuild<cr>", { buffer = ev.buf, desc = "Delphi build (Debug)" })
        vim.keymap.set("n", "<leader>cB", "<cmd>DelphiBuild Release<cr>", { buffer = ev.buf, desc = "Delphi build (Release)" })
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufNewFile", {
    group = group,
    pattern = SOURCE_PATTERNS,
    callback = function(ev)
      vim.bo[ev.buf].fileencoding = "cp1252"
      vim.bo[ev.buf].fileformat = "dos"
    end,
  })

  if IS_WINDOWS then
    vim.api.nvim_create_user_command("DelphiBuild", build, {
      nargs = "*",
      complete = function(_, line)
        local n = #vim.split(line, "%s+")
        return n <= 2 and { "Debug", "Release" } or { "Win32", "Win64" }
      end,
      desc = "Delphi: msbuild [Config] [Platform]",
    })
    setup_delphilsp()
  else
    setup_pasls()
  end
end

return M

local M = {}

local SOURCE_PATTERNS = { "*.pas", "*.dpr", "*.dpk", "*.inc" }

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

local function project_root(bufnr, on_dir)
  local root = vim.fs.root(bufnr, ".git")
    or vim.fs.root(bufnr, function(name)
      return name:match("%.groupproj$") or name:match("%.dproj$") or name:match("%.lpi$")
    end)
  on_dir(root or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
end

local function setup_lsp()
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

  setup_lsp()
end

return M

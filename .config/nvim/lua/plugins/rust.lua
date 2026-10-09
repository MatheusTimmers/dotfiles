local function bare_metal_target(root)
  if not root then
    return nil
  end
  for _, name in ipairs({ "/.cargo/config.toml", "/.cargo/config" }) do
    local path = root .. name
    if vim.uv.fs_stat(path) then
      for line in io.lines(path) do
        local triple = line:match('^%s*target%s*=%s*"([^"]+)"')
        if triple and triple:match("%-none") then
          return triple
        end
      end
    end
  end
  return nil
end

local function settings(project_root, default_settings)
  local result = vim.tbl_deep_extend("force", {}, default_settings or {}, {
    ["rust-analyzer"] = {
      checkOnSave = true,
      check = { command = "clippy", extraArgs = { "--no-deps" } },
      cargo = { features = "all" },
    },
  })
  if bare_metal_target(project_root) then
    result["rust-analyzer"].check.allTargets = false
  end
  return result
end

local function on_attach(_, bufnr)
  local map = function(lhs, cmd, desc)
    vim.keymap.set("n", lhs, function()
      vim.cmd.RustLsp(cmd)
    end, { buffer = bufnr, desc = desc })
  end

  map("K", { "hover", "actions" }, "Hover (actions)")
  map("<leader>ca", "codeAction", "Code Action")
  map("<leader>re", "expandMacro", "Expand Macro")
  map("<leader>rc", "openCargo", "Open Cargo.toml")
  map("<leader>rp", "parentModule", "Parent Module")
  map("<leader>rd", "renderDiagnostic", "Render Diagnostic")
  map("<leader>rE", "explainError", "Explain Error")
  map("<leader>rr", "runnables", "Runnables")
  map("<leader>rt", "testables", "Testables")
  map("<leader>rD", "debuggables", "Debuggables")
end

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = function()
        return {
          server = {
            on_attach = on_attach,
            settings = settings,
            capabilities = require("blink.cmp").get_lsp_capabilities(),
          },
        }
      end
    end,
  },
}

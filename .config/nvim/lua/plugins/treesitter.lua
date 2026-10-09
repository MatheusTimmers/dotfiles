return {
  "nvim-treesitter/nvim-treesitter",
  -- O branch master esta congelado no Neovim 0.11; main e a reescrita para 0.12+.
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
    ts.setup()

    -- No main nao existe auto_install: os parsers sao pedidos explicitamente.
    -- E no-op para os que ja estao instalados.
    ts.install({
      "arduino", "asm", "bash", "c", "c_sharp", "cmake", "cpp", "css", "desktop",
      "disassembly",
      "git_config", "gitcommit", "gitignore", "go", "gomod", "gosum", "html",
      "hyprlang", "java", "json", "latex", "linkerscript", "lua", "make",
      "markdown", "markdown_inline", "po", "python", "ruby", "rust",
      "systemverilog", "tcl", "toml", "tsx", "typescript", "vim", "vimdoc",
      "xml", "yaml",
    })

    -- So existe parser de systemverilog (a gramatica cobre IEEE 1800 inteiro),
    -- e o filetype de .v e "verilog": sem o alias, arquivos .v ficam sem realce.
    vim.treesitter.language.register("systemverilog", "verilog")

    -- Substitui os antigos modulos highlight/indent, que sumiram no main.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        -- get_lang devolve o proprio filetype quando nao conhece o mapeamento,
        -- e language.add devolve nil (nao false) quando nao ha parser -- por isso
        -- o teste e de veracidade, e nao == false.
        local ok, added = pcall(vim.treesitter.language.add, lang)
        if not ok or not added then
          return
        end
        vim.treesitter.start(ev.buf, lang)
        -- Indentacao por treesitter e marcada como experimental pelo plugin.
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}

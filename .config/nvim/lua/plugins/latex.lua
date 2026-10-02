return {
  {
    "lervag/vimtex",
    lazy = false,
    ft = { "tex", "latex" },
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-pdf",
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      -- Desativa mapeamentos padrão do vimtex para evitar conflitos
      vim.g.vimtex_mappings_prefix = "<localleader>l"
    end,
  },
}
-- Instalar: sudo dnf install texlive-scheme-full zathura zathura-pdf-mupdf
-- Keymaps (dentro de .tex):
--   <localleader>ll  → compilar
--   <localleader>lv  → visualizar PDF (zathura)
--   <localleader>lc  → limpar arquivos auxiliares
--   <localleader>le  → erros de compilação
--   <localleader>lk  → parar compilação

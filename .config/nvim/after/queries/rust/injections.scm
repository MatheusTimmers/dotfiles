;; extends

; Assembly dentro dos macros de asm inline.
;
; O nvim-treesitter nao injeta nada neles por padrao: num kernel isso deixa todo
; o boot (naked_asm!, global_asm!) como uma string cinza sem realce nenhum.
(macro_invocation
  macro: (identifier) @_macro
  (token_tree
    (string_literal
      (string_content) @injection.content))
  (#any-of? @_macro "asm" "naked_asm" "global_asm")
  (#set! injection.language "asm"))

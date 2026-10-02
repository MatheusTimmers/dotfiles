#!/usr/bin/env bash
# Layout genérico de desenvolvimento.
# Uso: dev /caminho/do/projeto
# Ou:  PROJECT=/caminho/do/projeto tmuxifier load-session dev

PROJECT_DIR="${PROJECT:-$PWD}"
SESSION_NAME=$(basename "$PROJECT_DIR")

session_root "$PROJECT_DIR"

if initialize_session "$SESSION_NAME"; then

  # 1. Terminal — shell limpo no projeto
  new_window "  terminal"

  # 2. Neovim — editor abrindo o projeto inteiro
  new_window "  nvim"
  run_cmd "nvim ."

  # 3. Claude Code — conecta no nvim da janela 2 via --ide
  #    O sleep dá tempo do nvim subir o servidor e escrever ~/.claude/ide/*.lock
  new_window "  claude"
  run_cmd "sleep 3 && claude --ide"

  # Foca no nvim ao iniciar
  select_window 2

fi

finalize_and_go_to_session

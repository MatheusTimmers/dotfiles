fastfetch

HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
bindkey -e

# Atualização do PATH consolidada
export PATH=$PATH:/home/timmers/.local/bin:/home/timmers/.config/tmux/plugins/tmuxifier/bin

# Inicialização do tmuxifier
export TMUXIFIER_LAYOUT_PATH="$HOME/.config/tmux/layouts"
eval "$(tmuxifier init -)"

# Inicialização do Starship como prompt
eval "$(starship init zsh)"

command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fzf >/dev/null && source <(fzf --zsh)

# Aliases
alias ls='eza --icons --group-directories-first'
alias cat="bat --style=auto"
alias tmuxa="tmux attach -f ~/.config/tmux/tmux.conf"
alias tmux="tmux -f ~/.config/tmux/tmux.conf"
alias icat="kitty +kitten icat"
[[ "$TERM" == "xterm-kitty" ]] && alias ssh="kitten ssh"

# Configuração do editor
export VISUAL=nvim
export EDITOR=nvim

# Variáveis e funções ZSH
export LINUX_OVERRIDE_SRCDIR=~/Projects/Pucrs/LabOS/linuxdistro/linux-4.13.9/
fpath+=${ZDOTDIR:-~}/.zsh_functions

# Autocompletar (compinit)
zstyle :compinstall filename '/home/timmers/.zshrc'
autoload -Uz compinit
compinit

source ~/.config/ohmyposh/fzf-tab/fzf-tab.plugin.zsh
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:*' fzf-flags --height=60% --border
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --icons --color=always $realpath'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

# Syntax highlighting e autossugestões
source $HOME/.config/ohmyposh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/ohmyposh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Ativação do ambiente mise
eval "$(~/.local/bin/mise activate zsh)"

# Saudoso oh-my-posh
# eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/catppuccin_frappe.json)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

fastfetch() {
    if [[ $# -eq 0 && "$TERM" == xterm-kitty && -z "$HERDR_ENV" && $COLUMNS -ge 100 ]]; then
        clear
        kitten icat -n --place 40x20@1x2 --scale-up --align left ~/.config/fastfetch/patch-"$(cat ~/.config/quickshell/flavor 2>/dev/null || echo mocha)".png \
            | command fastfetch --logo-type raw --logo - --logo-width 42 --logo-height 20
    else
        command fastfetch "$@"
    fi
}
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

export PATH=$PATH:/home/timmers/.local/bin

# Inicialização do Starship como prompt
eval "$(starship init zsh)"

command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fzf >/dev/null && source <(fzf --zsh)

# Aliases
alias ls='eza --icons --group-directories-first'
alias cat="bat --style=auto"
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

if [[ -n "$HERDR_ENV" && -f "${XDG_CACHE_HOME:-$HOME/.cache}/herdr-layout-pending" ]]; then
    () {
        local pending="${XDG_CACHE_HOME:-$HOME/.cache}/herdr-layout-pending"
        mv "$pending" "$pending.$$" 2>/dev/null || return
        local args=$(<"$pending.$$")
        rm -f "$pending.$$"
        eval "herdr-layout $args"
    }
fi

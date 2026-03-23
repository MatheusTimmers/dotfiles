fastfetch

# Configurações do histórico
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e

# Atualização do PATH consolidada
export PATH=$PATH:/home/timmers/.local/bin:/home/timmers/.config/tmux/plugins/tmuxifier/bin

# Inicialização do tmuxifier
eval "$(tmuxifier init -)"

# Inicialização do Starship como prompt
eval "$(starship init zsh)"

# Aliases
alias ls="exa --icons"
alias cat="bat --style=auto"
alias tmuxa="tmux attach -f ~/.config/tmux/tmux.conf"
alias tmux="tmux -f ~/.config/tmux/tmux.conf"

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

# Syntax highlighting e autossugestões
source $HOME/.config/ohmyposh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/ohmyposh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Ativação do ambiente mise
eval "$(~/.local/bin/mise activate zsh)"

# Saudoso oh-my-posh
# eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/catppuccin_frappe.json)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

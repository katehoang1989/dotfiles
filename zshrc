fpath=(/usr/local/share/zsh-completions $fpath)

#############################################################################
# Options
#############################################################################
setopt COMPLETE_IN_WORD
setopt PROMPT_SUBST
setopt HIST_IGNORE_SPACE
setopt extended_glob
setopt histignoredups
setopt interactivecomments
setopt autocd

#############################################################################
# Autoloads
#############################################################################
autoload -U colors
colors

autoload -U bashcompinit
bashcompinit

#############################################################################
# Prompt
#############################################################################
local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ %s)"

# Indicate with red <<< on the right when in normal mode.
function zle-key-map-init zle-keymap-select {
    zle reset-prompt
    zle -R
}

zle -N zle-keymap-init
zle -N zle-keymap-select

MODE_INDICATOR="%{$fg_bold[red]%}<<<%{$reset_color%}"
function vi_mode_indicator() {
    echo "${${KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
}
RPS1='$(vi_mode_indicator)'

function cabal_sandbox_info() {
    if [ -f cabal.sandbox.config ]; then
        echo "%{$fg[green]%}sandboxed%{$reset_color%}"
    else
        if [ -d .stack-work ]; then
            echo "%{$fg[green]%}stack%{$reset_color%}"
        else
        cabal_files=(*.cabal(N))
            if [ $#cabal_files -gt 0 ]; then
                echo "%{$fg[red]%}not sandboxed%{$reset_color%}"
            fi
        fi
    fi
}

source ~/.dotfiles/zsh/git_prompt.sh

PROMPT='%{$fg_bold[white]%}%M%{$reset_color%} ${ret_status}%{$fg_bold[green]%}%p %{$fg[cyan]%}%~ %{$fg_bold[blue]%}$(git_super_status)%{$reset_color%} $(cabal_sandbox_info)
%{$fg[blue]%} $ %{$reset_color%}'

#############################################################################
# Key bindings
#############################################################################
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '\eb' backward-word
bindkey '\ef' forward-word
bindkey '\ed' kill-word

# Bind v in Normal mode to edit the current command in vim.
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

#############################################################################
# Aliases
#############################################################################
alias l=ls
alias ll="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias serve_this="python -mSimpleHTTPServer"

#############################################################################
# Environment variables
#############################################################################
export EDITOR=vim
if (which nvim &> /dev/null); then
    # Prefer nvim over vim.
    alias vi=nvim
    alias vim=nvim
    export EDITOR=nvim
fi

export LANG=en_US.UTF-8
export TERM=xterm-256color
export HISTSIZE=9999
export SAVEHIST=9999
export HISTFILE=~/.zsh_history
export HOMEBREW_EDITOR="$EDITOR"
export HOMEBREW_NO_ANALYTICS=1
export GITHUB_USER=abhinav
export KEYTIMEOUT=1  # no lag when switching to vi normal mode
export CLICOLOR=1
export FZF_DEFAULT_OPTS="--cycle"
export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export PATH="\
$HOME/.bin:\
$HOME/.local/bin:\
$HOME/.cabal/bin:\
$HOME/.cargo/bin:\
/usr/local/bin:\
/usr/local/sbin:\
/usr/local/share/npm/bin:\
$PATH:\
/usr/local/opt/go/libexec/bin"

#############################################################################
# FASD
#############################################################################
fasd_cache="$HOME/.fasd-init-zsh"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
    fasd --init auto >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache


#############################################################################
# Completion configuration
#############################################################################

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' file-sort name
zstyle ':completion:*' ignore-parents parent pwd directory
zstyle ':completion:*:*:-command-:*:*' ignored-patterns '_*'
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle :compinstall filename '/Users/abg/.dotfiles/zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
#

#############################################################################
# End setup
#############################################################################

. ~/.zsh/plugins/syntax-highlighting/zsh-syntax-highlighting.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#############################################################################
# Source the local zshrc if present
#############################################################################

if [[ -f "$HOME/.dotfiles/local/zshrc" ]]; then
    . ~/.dotfiles/local/zshrc
fi

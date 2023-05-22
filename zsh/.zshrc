[[ ! -f $HOME/.zsh/dracula/dracula.zsh-theme ]] || source $HOME/.zsh/dracula/dracula.zsh-theme

autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
    compinit -i
else
    compinit -C -i
fi
zmodload -i zsh/complist
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $HOME/.zsh/cache

# Language
export TERM="xterm-256color"
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"

# Config
setopt auto_cd               # simply type dir name to cd
setopt auto_pushd            # make cd behave like pushd
setopt pushd_ignore_dups     # don't pushd duplicates
setopt pushd_minus           # exchange the meanings of `+` and `-` in pushd
setopt interactive_comments  # comments in interactive shells
setopt multios               # multiple redirections
setopt ksh_option_print      # make setopt output all options
setopt extended_glob         # extended globbing
setopt no_bare_glob_qual     # disable `PATTERN(QUALIFIERS)`, extended_glob has `PATTERN(#qQUALIFIERS)`
setopt glob_dots             # match hidden files (affect completion)

setopt hist_ignore_all_dups  # no duplicates
setopt hist_save_no_dups     # don't save duplicates
setopt hist_ignore_space     # no commands starting with space
setopt hist_reduce_blanks    # remove all unneccesary spaces
setopt share_history         # share history between sessions
HISTFILE=$HOME/.zsh/.zsh_history
HISTSIZE=1000000  # number of commands that are loaded into memory
SAVEHIST=1000000  # number of commands that are stored

# Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias la="ls -la"
alias ll="ls -ll"

# sources
source $HOME/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $HOME/.zsh/zsh-completions/zsh-completions.plugin.zsh
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source $HOME/.zsh/history.zsh
source $HOME/.zsh/key-bindings.zsh

# fast-syntax-highlighting
unset 'FAST_HIGHLIGHT[chroma-man]'  # chroma-man will stuck history browsing

# zsh-autosuggestions
ZSH_AUTOSUGGEST_MANUAL_REBIND='1'

# zsh-history-substring-search
HISTORY_SUBSTRING_SEARCH_FUZZY='1'

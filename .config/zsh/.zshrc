## FAST TRAVEL
## $XDG_CONFIG_HOME/shell/aliasrc
## $XDG_CONFIG_HOME/shell/aliasrc-extra
if [ $SSH_TTY ]; then # Needs to be above p10k for colored output
	fastfetch 2>/dev/null || neofetch 2>/dev/null
	w
fi
## Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
## Initialization code that may require console input (password prompts, [y/n]
## confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi
## To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f "$XDG_CONFIG_HOME/zsh/p10k.zsh" ]] || source "$XDG_CONFIG_HOME/zsh/p10k.zsh"


HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$XDG_CACHE_HOME/zsh/zsh_history"
ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"

## source aliases
source "$XDG_CONFIG_HOME/shell/aliasrc"
[ -f "$XDG_CONFIG_HOME/shell/aliasrc-extra" ] && source "$XDG_CONFIG_HOME/shell/aliasrc-extra"

## source bookmarks
[ -f "$XDG_CONFIG_HOME/shell/shortcutrc" ] && source "$XDG_CONFIG_HOME/shell/shortcutrc"
[ -f "$XDG_CONFIG_HOME/zsh/zshnameddirrc" ] && source "$XDG_CONFIG_HOME/zsh/zshnameddirrc"

## source zsh plugins
source "$XDG_CONFIG_HOME/zsh/p10k/powerlevel10k.zsh-theme"
source "$XDG_CONFIG_HOME/zsh/autosuggestions/zsh-autosuggestions.zsh"
source "$XDG_CONFIG_HOME/zsh/histsearch/zsh-history-substring-search.zsh"
source "$XDG_CONFIG_HOME/zsh/syntaxhl/zsh-syntax-highlighting.zsh"
## vim mode plugin
#bindkey -e
source "$XDG_CONFIG_HOME/zsh/vimode/zsh-vi-mode.plugin.zsh"
## vim mode cursor style
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

[ $(which fzf) 2>/dev/null ] && source <(fzf --zsh)


zmodload zsh/complist
zmodload zsh/terminfo

## Theming section
autoload -U compinit colors zcalc
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$HOST"
colors

## Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R

## Options section
setopt autocd												# If only directory path is entered, cd there.
setopt autonamedirs											# Show full path for bookmarked dirs
setopt nobeep												# No beep
setopt nocaseglob											# Case insensitive globbing
setopt nocheckjobs											# Don't warn about running processes when exiting
setopt correct												# Auto correct mistakes
setopt extendedglob											# Extended globbing. Allows using regular expressions with *
setopt globcomplete
#setopt extendedhistory										# Add timestamps to history ‘: <beginning time>:<elapsed seconds>;<command>'
setopt globdots												# Include hidden files
setopt histignorealldups									# Don't save command if it's a duplicate of an older one, even if it's not previous command
setopt histignoredups										# Don't save command if it's a duplicate of the previous one
setopt histignorespace                                      # Don't save commands that start with space
setopt incappendhistory										# Commands are added to the history immediately, thus shared with parallel session. use unsetopt to disable
setopt numericglobsort										# Sort filenames numerically when it makes sense
setopt rcexpandparam										# Array expension with parameters

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'	# Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"		# Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true							# Automatically find new executables in path
zstyle ':completion:*' menu select							# Menu-like tabbing 
## Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
WORDCHARS='*?[]~&;!#$%^(){}<>|'                             # Consider certain characters part of the word

## Keybindings section
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[7~' beginning-of-line                           # Home - move to beginning of line
bindkey '^[[H' beginning-of-line                            # Home - move to beginning of line
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line            # Home - move to beginning of line
fi
bindkey '^[[8~' end-of-line                                 # End - move to end of line
bindkey '^[[F' end-of-line                                  # End - move to end of line
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                   # End - move to end of line
fi
bindkey '^[[2~' overwrite-mode                              # Ins - insert mode
bindkey '^[[3~' delete-char                                 # Del - delete char ->
bindkey '^[[C'  forward-char                                # -> - move by char ->
bindkey '^[[D'  backward-char                               # <- - move by char <-
bindkey '^[[5~' history-beginning-search-backward           # Page up - search history up
bindkey '^[[6~' history-beginning-search-forward            # Page down - search history down
bindkey '^[Oc' forward-word                                 # Ctrl+-> - move by word ->
bindkey '^[Od' backward-word                                # Ctrl+<- - move by word <-
bindkey '^[[1;5D' backward-word                             # Ctrl+<- - move by word <-
bindkey '^[[1;5C' forward-word                              # Ctrl+-> - move by word ->
bindkey '^[[3;5~' kill-word                                 # Ctrl+Del - delete word -> (conflicting bind in ~/.config/zsh/vimode/zsh-vi-mode.zsh on line 3425 & 3426 had to be disabled)
bindkey '^H' backward-kill-word                             # Ctrl+Backspace - delete word <-
bindkey '^[[3;6~' kill-whole-line                           # Ctrl+Shift+Del - delete whole line
bindkey '^[[Z' undo                                         # Shift+tab - undo last action
bindkey -s '^L' '^u clear\n'                                # Actual clear on Ctrl+L

## Use vim keys in tab complete menu:   
bindkey -M menuselect 'h' vi-backward-char   
bindkey -M menuselect 'k' vi-up-line-or-history   
bindkey -M menuselect 'l' vi-forward-char   
bindkey -M menuselect 'j' vi-down-line-or-history   



bindkey -s '^O' '^ulfcd\n'						# Ctrl+O - lfcd
#bindkey -s '^O' '^urcd\n'						# Ctrl+O - rcd
bindkey -s '^G' '^urfv\n'						# Ctrl+G - live ripgrep
bindkey -s '^F' '^ufzf_jump\n'					# Ctrl+F (conflicting bind in ~/.config/zsh/vimode/zsh-vi-mode.zsh on line 3413 had to be disabled)

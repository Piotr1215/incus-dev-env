# Suffix aliases
alias -s md=nvim
alias -s txt=nvim
alias -s yaml=nvim
alias ls='ls --color=auto -lah'

ZSH_THEME="simple" #Best theme ever

# Initialize direnv
eval "$(direnv hook zsh)"

# Enable basic syntax highlighting
autoload -Uz colors && colors

# Enable tab completion
autoload -Uz compinit && compinit

fpath=(${HOME}/.oh-my-zsh/completions/ $fpath)
# Set ZSH_CUSTOM dir if env var not present
if [[ -z "$ZSH_CUSTOM" ]]; then
    ZSH_CUSTOM="$ZSH/custom"
fi
export CLICOLOR=YES
export LSCOLORS="Gxfxcxdxbxegedabagacad"
# This prevents the 'too many files error' when running PackerSync
ulimit -n 10240

alias mdit='nvim ~/.zsh_minimal/.zshrc'
function ddg() {
    open "https://duckduckgo.com/?q=$*"
}

parse_git_dirty() {
  git_status="$(git status 2> /dev/null)"
  [[ "$git_status" =~ "Changes to be committed:" ]] && echo -n "%F{green}●%f"
  [[ "$git_status" =~ "Changes not staged for commit:" ]] && echo -n "%F{yellow}●%f"
  [[ "$git_status" =~ "Untracked files:" ]] && echo -n "%F{red}●%f"
}

setopt prompt_subst

NEWLINE=$'\n'

autoload -Uz vcs_info # enable vcs_info
precmd () { vcs_info } # always load before displaying the prompt
zstyle ':vcs_info:git*' formats ' ⇒ (%F{cyan}%b%F{245})' # format $vcs_info_msg_0_

# Improved Prompt with Hostname
PS1='%F{245}%n@%m%f:%F{153}%(5~|%-1~/⋯/%3~|%4~)%F{245}${vcs_info_msg_0_} $(parse_git_dirty)$NEWLINE%F{254}$%f '

# Explanation of Prompt
# %n: Username
# %m: Hostname (short version)
# %F{color}: Start coloring text
# %f: Reset color
# %~: Current directory, with truncation for deep paths
# $(parse_git_dirty): Displays git status with colored dots
# $NEWLINE: Forces the prompt onto a new line

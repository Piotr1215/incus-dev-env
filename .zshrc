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
export PATH=$PATH:$HOME/.arkade/bin/
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
#
# Aliases
# Global aliases
alias -g C='| sed -r "s/\x1b\[[0-9;]*m//g" | tmux load-buffer -'
alias -g G='| grep -i --color=always'
alias -g H=' --help'
alias -g L='| less'
alias -g NUL="> /dev/null 2>&1"
alias -g R="2>&1 | tee output.txt"
alias -g T="| tail -n +2"
alias -g V=' --version'
alias -g W='| nvim -c "setlocal buftype=nofile bufhidden=wipe" -c "nnoremap <buffer> q :q!<CR>" -'

# Suffix aliases
alias -s md=nvim
alias -s txt=nvim
alias -s yaml=nvim

# Directories and files
alias la='/usr/bin/ls'
alias ls='exa --color=always --long --all --header --icons'
alias lsa='exa --color=always --long --all --sort=age --reverse --header --icons'
alias lsf='fd --max-depth=1 --type=file'
alias tr2='tree -LC 2 --si --sort name | less'
alias lt='exa --tree --level=2 --icons --color=always'
alias lsdir='ls -ld *(/om[1])'

# Commands shadow
alias zedit='vim ~/.zshrc'
alias vm="nvim -c ':lua MiniFiles.open()'"
alias aider='aider --model gpt-4o --dark-mode --no-auto-commits'
alias aider-commit='aider --model gpt-4o --dark-mode'
alias cat='bat'
alias diff=colordiff
alias fd='fd --hidden'
alias ra=ranger
alias rg='rg --hidden'
alias vim=nvim
alias v=nvim
alias watch=viddy
alias ugu='ug -Q -.'

## Kubernetes aliases
alias k=kubectl
alias kconf='__create_separate_kubeconfig.sh'
alias kdump='kubectl get all --all-namespaces'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kstart='~/dev/dotfiles/scripts/__kind_manager.sh --start'
alias kstop='~/dev/dotfiles/scripts/__kind_manager.sh --stop'

# Other
alias dls="docker container ls -a"
alias dpsa="docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}'" #docker ps -a with only id name and image
alias dps="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}'" #docker ps -a with only id name and image
alias gcc='git diff --stat --cached origin/master' # Git Check Commit before pushing
alias ghc='__gh_cli.sh'
alias ghcurrentbranch='gh repo view --branch $(git rev-parse --abbrev-ref HEAD) --web'
alias gs='git show'
alias lg='lazygit'
alias lvim='nvim -c "normal '\''0"'
alias sr='omz reload'

# shellcheck disable=SC1090
# ~ works ok here

function gpt() {
    local input

    # Check if input is piped
    if [ -t 0 ]; then
        input="$1"
    else
        input=$(cat | sed -r "s/\x1b\[[0-9;]*m//g")
    fi

    # Use a temporary file for the processed content
    local tmpfile=$(mktemp /tmp/nvim_buffer_cleaned.XXXXXX)
    # Save the input to the temporary file
    echo "$input" > $tmpfile

    # Process the input and open Neovim directly, ensuring it doesn't suspend
    nvim -c "GpChatNew" \
         -c "call append(line('$')-1, readfile('$tmpfile'))" \
         -c "normal! Gdd" \
         -c "startinsert"

    # Remove the temporary file after usage
    rm $tmpfile
}

function cds() {
  session=$(tmux display-message -p '#{session_path}')
  cd "$session"
}

function short() {
  if [[ -z "$1" ]]; then
    echo "Folder name is required."
    return 1
  else
    take "$1"
  fi
  cp ~/dev/shorts/templates/demo.sh .
  clear
}

function cfp() {
    local file_path="$1"
    local full_path=$(realpath "$file_path")
    echo -n "$full_path" | xclip -selection clipboard
}

function record() {
  # run noisetorch to reduce noise
  noisetorch &
}

function pkill() {
  ps aux | 
  fzf --height 40% \
      --layout=reverse \
      --header-lines=1 \
      --prompt="Select process to kill: " \
      --preview 'echo {}' \
      --preview-window up:3:hidden:wrap \
      --bind 'F2:toggle-preview' |
  awk '{print $2}' |
  xargs -r bash -c '
      if ! kill "$1" 2>/dev/null; then
          echo "Regular kill failed. Attempting with sudo..."
          sudo kill "$1" || echo "Failed to kill process $1" >&2
      fi
  ' --
}

# Function to create and activate a Python virtual environment
function mkvenv() {    # Set the environment directory name, default to 'venv' if no name provided
    local env_dir=${1:-venv}
    local requirements_path="captured-requirements.txt"
    # Check if the environment already exists
        # Create the virtual environment
        echo "Creating new virtual environment '$env_dir'..."
        python3 -m venv $env_dir
        
        # Activate the virtual environment
        source $env_dir/bin/activate
        
        # Optional: Install any default packages
        pip3 install --upgrade pip
        pip3 install wheel

        if [ -f "$requirements_path" ]; then
            echo "Installing packages from '$requirements_path'..."
            pip3 install -r "$requirements_path"
        fi
        
        echo "Virtual environment '$env_dir' created and activated!"
  }

function rmvenv() {
    # Check if the environment is active
    local requirements_path="captured-requirements.txt"
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        if [[ ! -f "requirements.txt" ]]; then
            pip3 freeze > "$requirements_path"
        fi
        # Deactivate the environment
        deactivate
        
        echo "Virtual environment deactivated and all installed packages captured"
    else
        echo "No virtual environment is active."
    fi
}

# PROJECT: git-log
function logg() {
    git lg | fzf --ansi --no-sort \
        --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % git show % --color=always' \
        --preview-window=right:50%:wrap --height 100% \
        --bind 'enter:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "git show % | nvim -c \"setlocal buftype=nofile bufhidden=wipe noswapfile nowrap\" -c \"nnoremap <buffer> q :q!<CR>\" -")' \
        --bind 'ctrl-e:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "gh browse %")' \
}

function saver() {
  if [[ -z $1 ]]; then
    echo "Provide hidden text to save"
    return 1
  fi
  tmatrix --mode=default --fall-speed=0,1 --title="$1" --color=green --background=black 
}

function crypt() {
  ENCRYPTED_DIR="$HOME/dev/encrypted"
  # Check if the current directory is the mount point or a subdirectory of it
  if pwd | grep -q "^$MOUNT_POINT"; then
    echo "You are currently in the encrypted directory. Changing to home directory."
    cd ~/dev || return 1
  fi
  if findmnt -M "$ENCRYPTED_DIR" > /dev/null; then
    fusermount -u "$ENCRYPTED_DIR" && echo "Encrypted directory unmounted successfully." || echo "Failed to unmount encrypted directory."
    echo "Logged out from bitwarden."
  else
    echo "Encrypted directory is not mounted."
  fi
}

function uncrypt() {
  if [ -n "$(\ls -A ~/dev/encrypted)" ]; then
    echo "Directory is not empty, assuming already uncrypted, switching to directory."
  elif encfs ~/.encrypted ~/dev/encrypted; then
    echo "Encrypted directory mounted successfully."
  else
    echo "Failed to mount encrypted directory."
    return
  fi
  
  cd ~/dev/encrypted && ls
}

# Define custom copy function
function copy_and_create_folders() {
    echo "Debug: Function copy_and_create_folders called"  # Debug line
    last_arg="${!#}"  # This will get the last argument
    echo "Debug: last_arg=$last_arg"
    echo "Debug: dirname of last_arg=$(dirname "$last_arg")"
    if [[ ! -d "$last_arg" && ! -d "$(dirname "$last_arg")" ]]; then
      echo "Debug: Inside if condition"
        target_dir="$(dirname "${@[-1]}")"
        mkdir -p "$target_dir"
        echo "Created directory structure: $target_dir"
    fi
    
    # Now use the regular cp command
    command cp "$@"
}

function apply_pattern() {
    awk "NR == 1 || /$1/"
}

function play_song() {
    # Check if a song name is provided
    if [[ -z $1 ]]; then
        echo "Provide song name"
        return 1
    fi

    # Determine the song URL based on the input
    case $1 in
        "bek")
            song_url="https://www.youtube.com/watch?v=K3SLQiTC4tM"
            ;;
        "lustmord")
            song_url="https://youtu.be/nj_DqmRac78"
            ;;
        *)
            echo "Song not found"
            return 1
            ;;
    esac

    echo "Playing $song_url"

    # Start mpv in the background without video and redirect its output
    echo "Starting mpv..."
    mpv --loop-file --ytdl --no-video "$song_url" >/dev/null 2>&1 &

    echo "mpv process ID: $!"
}

# xev wrapper for ascii keycodes
function char2hex() {
  xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf "%-3s %s\n", $5, $8 }'
}

# Paste link form clipboard and create a new pet snippet
function plink ()
{
  link=$(xclip -o -sel clipboard)
  desc="$*"
  if [[ -z $desc ]]; then
   echo "Provide description for link" 
   return 1
  fi

  if [[ -z $link ]]; then
   echo "Provide url to link" 
   return 1
  fi

  if [[ $link =~ ^https?:// ]]; then
    echo "Linking $link"
    command_name="xdg-open \\\"$link\\\""
    description="Link to $desc"
    tag="link"

    # Use expect to interact with pet new
    /usr/bin/expect <<EOF
      spawn pet new -t
      expect "Command>"
      send "${command_name}\r"
      expect "Description>"
      send "${description}\r"
      expect "Tag>"
      send "${tag}\r"
      expect eof
EOF
  else
    echo "Not a valid url"
    return 1
  fi
}

# Creates a folder named with the current or prefixed date, using the format "prefix-YYYY-MM-DD" if a prefix is provided.
function mkdd ()
{
 mkdir -p ${1:+$1$prefix_separator}"$(date +%F)"; }

# Creates a real-time countdown with alert sound, useful for bash scripts and terminal.
function timer ()
{
  total=$1 
  for ((i=total; i>0; i--)); do sleep 1; printf "Time remaining %s secs \r" "$i"; done
  echo -e "\a" 
}

# Display calendar with day highlighted
function cal ()
{
  if [ -t 1 ] ; then alias cal="ncal -b" ; else alias cal="/usr/bin/cal" ; fi
}

# Simplifies font installation, making font customization easier and improving visual experience in the shell
function install_font ()
{
  if [[ -z $1 ]]; then
   echo provide path to zipped font file 
   return 1
  fi
  
  font_zip=$(realpath "$1")

  unzip "$font_zip" "*.ttf" "*.otf" -d ~/.local/share/fonts/
  fc-cache -vf
}

# Common function to search for a string in files using rga and fzf, and opens the file with nvim.
function _fif_common() {
  local ignore_case_flag="$1"
  shift

  local files
  local preview_cmd=$(printf "rga %s --pretty --context 10 '%s' {}" "$ignore_case_flag" "$*")
  local rga_output=$(rga --max-count=1 $ignore_case_flag --files-with-matches --no-messages "$*")
  # PROJECT: project
  # This is used to copy file names so that they can be used a project documentaiton
  echo "$rga_output" | xsel --clipboard --input
  IFS=$'\n' files=($(echo "$rga_output" | fzf-tmux +m --preview="$preview_cmd" --multi --select-1 --exit-0)) || return 1

  if [ ${#files[@]} -eq 0 ]; then
    echo "No files selected."
    return 0
  fi

  typeset -a temp_files
  for i in {1..${#files[@]}}; do
    if [[ -n "${files[i]}" ]]; then
      temp_files[i]=$(realpath "${files[i]}")
    fi
  done
  files=("${temp_files[@]}")
  local nvim_cmd=""
  case "${#files[@]}" in
    2)
      nvim -O "${files[1]}" "${files[2]}"
      ;;
    3)
      nvim_cmd="nvim -O \"${files[1]}\" -c 'wincmd j' -c \"vsplit ${files[2]}\" -c \"split ${files[3]}\""
      ;;
    4)
      nvim_cmd="nvim -O \"${files[1]}\" -c \"vsplit ${files[2]}\" -c \"split ${files[3]}\" -c 'wincmd h' -c \"split ${files[4]}\""
      ;;
    *)
      nvim_cmd="nvim \"${files[@]}\""
      ;;
  esac

  eval "$nvim_cmd"
}

# Wrapper function for case-sensitive search
function fifs() {
    _fif_common "" "$@"
}

# Wrapper function for case-insensitive search
function fif() {
    _fif_common "--ignore-case" "$@"
}

# Dedicated function to list all files associated with a given project tag
function list_project_files() {
    local project_tag="PROJECT: $1"
    local ignore_case_flag=""  # Adjust as necessary for case sensitivity

    cd ~/dev
    # Use rga to find files containing the project tag, listing filenames only
    local rga_output=$(rga --max-count=1 $ignore_case_flag --files-with-matches --no-messages "$project_tag")

    # Check if any files were found
    if [[ -z "$rga_output" ]]; then
        echo "No files found for project $1."
        return 0
    fi

    # Print each file path
    echo "$rga_output"
}
# Wrapper function for project tags search with optional listing
function fifp() {
    local mode="$1"  # Check for the '-l' flag
    if [[ "$mode" == "-l" ]]; then
        shift  # Remove the first argument (the '-l' flag)
        list_project_files "$*"
    else
        _fif_common "" "PROJECT: $*"
    fi
}

# Uploads content to clbin and copies URL to clipboard, opens in browser
function share ()
{
    local image_path="/tmp/screenshot.png"

    # Save the clipboard content to a file
    # Adjust this command based on your system and the clipboard content
    xclip -selection clipboard -t image/png -o > "$image_path"

    # Upload the image file and parse the JSON response to get the link
    local response=$(curl -sF "file=@$image_path" https://file.io)
    local url=$(echo $response | jq -r '.link')

    # Check if the URL is valid
    if [[ $url != "https://file.io/"* ]]; then
        echo "Error: Invalid URL received"
        return 1
    fi

    # Handle the URL (copy to clipboard, open in browser, etc.)
    echo $url | tee >(xsel -ib)
    nohup xdg-open $url >/dev/null 2>&1 &
}

# Copy file name to clipboard
function cname() {
    file="$1"
    stat -t "$1" | cut -d ' ' -f1 | xargs echo -n | xsel -ib
}

# Copy the current working directory path to the clipboard
function cpa() {
    if command -v xclip > /dev/null; then
        printf "%s" "$PWD" | xclip -selection clipboard
        printf "%s\n" "Current working directory ('$(basename "$PWD")') path copied to clipboard."
    else
        printf "%s\n" "Error: 'xclip' command not found. Please install 'xclip' to use this function."
    fi
}

# Change the directory to the path stored in the clipboard
function dpa() {
    if command -v xclip > /dev/null; then
        local target_dir
        target_dir="$(xclip -o -sel clipboard)"
        if [[ -d "${target_dir}" ]]; then
            cd "${target_dir}" && printf "%s\n" "Changed directory to: ${target_dir}"
        else
            printf "%s\n" "Error: Invalid directory path or directory does not exist."
        fi
    else
        printf "%s\n" "Error: 'xclip' command not found. Please install 'xclip' to use this function."
    fi
}

# Add all changes to git, commit with given message, and push
function gac() {
  git add .
  git commit -m "$1"
  git push
}

# Add all changes to git, commit with given message and signed-off-by line, and push
function gacs() {
  git add .
  git commit -m "$1" -s
  git push
}

# Find a repo for authenticated user with gh CLI and cd into it, clone and cd if not found on disk
function repo() {
  export repo=$(fd . ${HOME}/dev --type=directory --max-depth=1 --color always| awk -F "/" '{print $5}' | fzf --ansi --preview 'onefetch /home/decoder/dev/{1}' --preview-window up)
    if [[ -z "$repo" ]]; then
        echo "Repository not found"
      else
        echo "Repository found locally, entering"
        cd ${HOME}/dev/$repo
        if [[ -d .git ]]; then
          echo "Fetching origin"
          git fetch origin
          onefetch
        fi
          create_tmux_session "${HOME}/dev/$repo"
    fi
}

function create_tmux_session() {
    local RESULT="$1"
    zoxide add "$RESULT" &>/dev/null
    local FOLDER=$(basename "$RESULT")
    local SESSION_NAME=$(echo "$FOLDER" | tr ' .:' '_')
    
    if [ -d "$RESULT/.git" ]; then
        SESSION_NAME+="_$(git -C "$RESULT" symbolic-ref --short HEAD 2>/dev/null)"
    fi
    
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux new-session -d -s "$SESSION_NAME" -c "$RESULT"
    fi
    
    if [ -z "$TMUX" ]; then
        tmux attach -t "$SESSION_NAME"
    else
        tmux switch-client -t "$SESSION_NAME"
    fi
}

# Adjust system volume to given percentage or display current volume
function vol() {
    echo "Usage: provide volume in intiger, e.g. 50 will adjust vol to 50%"
    if [[ -z "$1" ]]; then
      echo "Current volume on Masteris $(amixer get Master | grep '%' | awk -F'[][]' '{ print $2 }' | head -n 1)"
        return
    fi
    amixer set Master "$1"% > /dev/null
    echo "Volume set to $1%"
}

# Switch primary monitor between HDMI and DVI-D-0
function mon()
{
  active_mon=$(xrandr | grep primary)

  if [[ "$active_mon" =~ "HDMI" ]]; then
    xrandr --output DVI-D-0 --primary
  else
    xrandr --output HDMI-0 --primary
  fi
}

# Toggle audio output between main monitor and headset
function sout() {
  echo "Usage: sout toggles between\n - hdmi: plays sound via main monitor or\n - head: plays sound via main headset\n"

  # Do some grep magic to retrieve id of output devices, * indicates active device
  local local_output=$(wpctl status | grep Sinks: -A2 | head -3 | grep \* | grep "\d+" -Po | head -1)
  local new_output=$(wpctl status | grep Sinks: -A2 | head -3 | grep -v \* | grep "\d+" -Po | head -1)

  # Swap the the device with no star making it active and adding the star
  wpctl set-default "$new_output"
  local sink_name=$(wpctl status | grep Sinks: -A2 | head -3 | grep \*)

  vol=50%

  if [[ $(echo "$sink_name" |  grep "GP106 High Definition") ]]; then
    wpctl set-mute $(wpctl status | grep --after-context=3 " ├─ Sources:" | grep "Microphone Mono" | grep "\d+" -Po | head -n 1) 1
    amixer set Master "$vol"
    local_output='hdmi'
    echo "Sound local_output set to '$=monitor, mic muted\nVolume $vol"
  else
    vol=75%
    amixer set Master "$vol"
    local_output='head'
    echo "Sound local_output set to 31=headset\nVolume $vol"
  fi
} 

function ms () {
    if [[ -z $1 ]]
    then
        echo "Provide one or more tmuxinator sessions to start"
        return 1
    fi
    
    # Special case for 'cluster' which takes an additional argument
    if [[ $1 == "cluster" && ! -z $2 ]]; then
        tmuxinator start cluster $2
        return 0
    fi

    for session in "$@"
    do
        tmuxinator start "$session"
    done
}

# Close multiple tmuxinator sessions
function mst ()
{
  if [[ -z $1 ]]; then
    echo "Provide one or more tmuxinator sessions to start"
    return 1  # Exit early with error status
  fi

  # Split the arguments into an array, zsh populates this by default
  for session in "$@"; do
    tmuxinator stop "$session"
  done
}

# Check system info using onefetch and output in terminal
function checkfetch() {
    local res=$(onefetch) &> /dev/null
    if [[ "$res" =~ "Error" ]]; then
        echo ""
    else echo $(onefetch)
    fi
}


# Open a debugging shell within a Kubernetes pod
function kcdebug() {
  kubectl run -i --rm --tty debug --image=busybox --restart=Never -- sh
}

# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'

# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'pc'

# Don't start tmux.
zstyle ':z4h:' start-tmux     no 

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace

z4h bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4h bindkey redo Alt+/             # redo the last undone command line change

z4h bindkey z4h-cd-back    Alt+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Alt+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Alt+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Alt+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Define aliases.
# alias tree='tree -a -I .git'

# Add flags to existing aliases.
# alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

eval "$(zoxide init --cmd cd zsh)"

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

# easier to read disk
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB
export PATH="$PATH:~/.local/bin/"

alias ls="exa --icons --group-directories-first"
alias tree="exa --tree --dirsfirst --group"
alias cat="batcat"
alias fs="exa --icons --group-directories-first --tree"
alias pkill='ps -ef | fzf | awk "{print \$2}" | xargs kill -9'
alias ll="exa --icons --group-directories-first -l"

# Some useful functions
# Some useful functions
copyLine () {
  rg --line-number "${1:-.}" | sk --delimiter ':' --preview 'batcat --color=always --highlight-line {2} {1}' | awk -F ':' '{print $3}' | sed 's/^\s+//' | xclip -selection clipboard 
}

fw () { 
  nvim $(rg --line-number "${1:-.}" | sk --delimiter ':' --preview 'batcat --color=always --highlight-line {2} {1}' | awk -F ':' '{print "+"$2" "$1}')
}

ff() {
  local file
  file=$(fzf --preview="batcat --color=always --style=numbers {}")
  [ -n "$file" ] && nvim "$file"
}

fa() {
  local file
  file=$(find . -type f | fzf --preview="batcat --color=always --style=numbers {}")
  [ -n "$file" ] && nvim "$file"
}

fd() {
  local dir
  dir=$(find . -type d | fzf --preview "exa --icons --tree --color=always {}")
  if [ -n "$dir" ]; then
    cd "$dir" && echo "Changed directory to $dir"
  fi
}

copyPathToAFile () {
  local file=$(find ${1:-.} -type f | sk --preview "batcat --color=always {}")
  if [ -n "$file" ]; then
    # Convert relative path to absolute path
    local abs_path=$(realpath "$file")
    echo -n "$abs_path" | xclip -selection clipboard
    echo "Copied '$abs_path' to clipboard"
  else
    echo "No file selected or found"
  fi
}

extract () {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"    ;;
      *.tar.gz)    tar xzf "$1"    ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.rar)       unrar x "$1"    ;;
      *.gz)        gunzip "$1"     ;;
      *.tar)       tar xf "$1"     ;;
      *.tbz2)      tar xjf "$1"    ;;
      *.tgz)       tar xzf "$1"    ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"       ;;
      *)           echo "'$1' cannot be extracted via extractArchive()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

diffFiles () {
  local file1=$(find ${1:-.} -type f | sk --preview "batcat --color=always {}")
  local file2=$(find ${1:-.} -type f | sk --preview "batcat --color=always {}")
  [ -n "$file1" ] && [ -n "$file2" ] && nvim -d "$file1" "$file2"
} 

ruf() {
  local file
  file=$(find . -type f \( ! -regex '.*/\..*' \) -print0 | \
    xargs -0 stat -c "%Y:%n" | \
    sort -n | \
    tail -n 20 | \
    cut -d ':' -f2- | \
    fzf --preview="batcat --style=numbers --color=always --line-range=:500 {}")
  [ -n "$file" ] && nvim "$file"
}

cdu() {
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}

cpwd() {
    local current_dir="$PWD"
    echo -n "$current_dir" | xclip -selection clipboard
    echo "Copied '$current_dir' to clipboard"
}

ctif() {
  if [ -z "$1" ]; then
    echo "Usage: copyfile filename"
    return 1
  fi

  if [ ! -f "$1" ]; then
    echo "File not found: $1"
    return 1
  fi

  if xsel --clipboard < "$1"; then
    echo "Copied all the text inside the file $1 to clipboard"
  else
    echo "Failed to copy $1 to clipboard"
  fi
}

ptif () {
  local file="${1}"
  
  if [ -z "$file" ]; then
    echo "Please provide a file name or path."
    return 1
  fi

  # Convert relative path to absolute path
  local abs_path=$(realpath "$file")
  
  # Check if the file exists
  if [ -f "$abs_path" ]; then
    echo "Do you want to overwrite '$abs_path'? (y/n)"
    read confirm
    if [ "$confirm" != "y" ]; then
      echo "Aborted."
      return
    fi
  fi

  # Get clipboard content with the explicit clipboard target
  clipboard_content=$(xclip -o -selection clipboard 2>/dev/null)

  if [ -z "$clipboard_content" ]; then
    echo "Error: Unable to retrieve clipboard content."
    return 1
  fi

  # Paste clipboard content into the file
  echo -n "$clipboard_content" > "$abs_path"
  echo "Pasted clipboard content into '$abs_path'"
}

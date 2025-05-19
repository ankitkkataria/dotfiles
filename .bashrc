# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anythk
case $- in
  *i*) ;;
  *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
PS1="\w\n$ "
else
PS1="\w\n$ "
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Colored GCC warnings and errors
# Export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

eval "$(zoxide init bash)"
eval "$(zoxide init --cmd cd bash)"

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
alias fs="exa --icons --group-directories-first --tree"
alias pkill='ps -ef | fzf | awk "{print \$2}" | xargs kill -9'
alias ll="exa --icons --group-directories-first -l"

# Some useful functions
copyLine() {
  rg --line-number "${1:-.}" | sk --delimiter ':' --preview 'batcat --color=always --highlight-line {2} {1}' | awk -F ':' '{print $3}' | sed 's/^\s+//' | xclip -selection clipboard 
}

# Search with ripgrep and sk (skim), then cd and open in neovim
fw() {
  local selected
  local file
  local line
  local dir
  local search_pattern="${1:-.}"
  
  # Handle spaces in search pattern by properly quoting
  selected=$(rg --line-number --ignore-case "$search_pattern" | sk --delimiter ':' --preview 'batcat --color=always --highlight-line {2} {1}')
  
  if [ -n "$selected" ]; then
    file=$(echo "$selected" | awk -F ':' '{print $1}')
    line=$(echo "$selected" | awk -F ':' '{print $2}')
    dir=$(dirname "$file")
    cd "$dir" && nvim +"$line" "$file"
  fi
}

# Search with fzf and preview with bat, then cd and open in neovim
ff() {
  local file
  local dir
  file=$(fzf --preview="batcat --color=always --style=numbers {}")
  if [ -n "$file" ]; then
    file=$(realpath "$file")  # Convert to absolute path
    dir=$(dirname "$file")
    cd "$dir" && nvim "$file"
  fi
}

# Search all files with find and fzf, then cd and open in neovim
fa() {
  local file
  local dir
  file=$(find . -type f | fzf --preview="batcat --color=always --style=numbers {}")
  if [ -n "$file" ]; then
    file=$(realpath "$file")  # Convert to absolute path
    dir=$(dirname "$file")
    cd "$dir" && nvim "$file"
  fi
}

# Show recently opened files in neovim with fzf preview, then cd and open
fo() {
  local file
  local dir
  
  # Create a temporary file for the list
  local tmpfile=$(mktemp)
  
  # Extract recent files from Neovim
  nvim --headless -c "rshada" -c "call writefile(v:oldfiles, '$tmpfile')" -c "qall" > /dev/null 2>&1
  
  # Use fzf to select from files that actually exist, removing any quotes
  file=$(cat "$tmpfile" | sed 's/^"//; s/"$//' | xargs -I{} bash -c 'if [ -f "{}" ]; then echo "{}"; fi' | 
         head -n 50 | 
         fzf --preview="batcat --color=always --style=numbers {}")
  
  # Clean up
  rm -f "$tmpfile"
  
  if [ -n "$file" ]; then
    # Remove any remaining quotes
    file=$(echo "$file" | sed 's/^"//; s/"$//')
    
    # Check if file exists before trying to open
    if [ -f "$file" ]; then
      file=$(realpath "$file")  # Convert to absolute path
      dir=$(dirname "$file")
      cd "$dir" && nvim "$file"
    else
      echo "File no longer exists: $file"
    fi
  fi
}

fd() {
  local dir
  dir=$(find . -type d | fzf --preview "exa --icons --tree --color=always {}")
  if [ -n "$dir" ]; then
    cd "$dir" && echo "Changed directory to $dir"
  fi
}

captf() {
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

crptf() {
  # Prompt the user to select a file
  local file=$(find ${1:-.} -type f | sk --preview "batcat --color=always {}")
  
  if [ -n "$file" ]; then
    # Convert the selected file path to a relative path
    local rel_path=$(realpath --relative-to="." "$file")
    
    # Copy the relative path to the clipboard
    echo -n "$rel_path" | xclip -selection clipboard
    echo "Copied relative path '$rel_path' to clipboard."
  else
    echo "No file selected or found"
  fi
}

ex() {
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

diffFiles() {
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
    echo "Copied '$current_dir' to clipboard."
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
    echo "Copied all the text inside the file $1 to clipboard."
  else
    echo "Failed to copy $1 to clipboard."
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

# Create a new directory and enter it
mkdircd() {
        mkdir -p "$@"
        cd "$@" || exit
}

backupFolder () {
    local source_dir="$1"
    local backup_name="${2:-backup-$(date +%Y%m%d-%H%M%S)}"
    local backup_dir="$HOME/.backups"
    local backup_file="$backup_dir/$backup_name.tar.gz"
    
    # Validate input
    if [ -z "$source_dir" ]; then
        echo "Usage: quickbackup <source_dir> [backup_name]"
        return 1
    fi
    
    if [ ! -d "$source_dir" ]; then
        echo "Error: Source directory '$source_dir' doesn't exist!"
        return 1
    fi
    
    # Ensure backup directory exists
    mkdir -p "$backup_dir"
    
    echo "Creating backup of '$source_dir'..."
    
    # Create tar archive with optimized settings
    tar --create \
        --gzip \
        --file="$backup_file" \
        --exclude="node_modules" \
        --exclude="*.log" \
        --exclude="*.pyc" \
        --exclude="__pycache__" \
        --exclude=".git" \
        --exclude="build" \
        --exclude="dist" \
        --exclude=".env" \
        --exclude="venv" \
        --exclude=".venv" \
        "$source_dir" 2>/dev/null || {
            echo "Backup failed!"
            return 1
        }
    
    # Show backup size and location
    local size=$(du -h "$backup_file" | cut -f1)
    echo "Backup created: $backup_file (Size: $size)"
}

listBackups() { 
    local backup_dir="$HOME/.backups"
    ls -lh "$backup_dir" | head -n 10
}

# Sourcing paths
source /opt/ros/humble/setup.bash
source /home/ankit/ws/install/setup.bash
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

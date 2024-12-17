eval "$(zoxide init bash)"
eval "$(zoxide init --cmd cd bash)"
# alias cd="z"
# alias cdi="zi"
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
copyLine() {
  rg --line-number "${1:-.}" | sk --delimiter ':' --preview 'batcat --color=always --highlight-line {2} {1}' | awk -F ':' '{print $3}' | sed 's/^\s+//' | xclip -selection clipboard 
}

# Search with ripgrep and sk (skim), then cd and open in neovim
fw() {
  local selected
  local file
  local line
  local dir
  selected=$(rg --line-number "${1:-.}" | sk --delimiter ':' --preview 'batcat --color=always --highlight-line {2} {1}')
  if [ -n "$selected" ]; then
    file=$(echo "$selected" | awk -F ':' '{print $1}')
    line=$(echo "$selected" | awk -F ':' '{print $2}')
    dir=$(dirname "$file")
    cd "$dir" && nvim +"$line" "$file"
  fi
}

# Search with ripgrep and sk (skim), then cd and open in neovim
fw() {
  local selected
  local file
  local line
  local dir
  selected=$(rg --line-number "${1:-.}" | sk --delimiter ':' --preview 'batcat --color=always --highlight-line {2} {1}')
  if [ -n "$selected" ]; then
    file=$(echo "$selected" | awk -F ':' '{print $1}')
    line=$(echo "$selected" | awk -F ':' '{print $2}')
    file=$(realpath "$file")  # Convert to absolute path
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

# Advanced clipboard manager
clip() {
  # Clipboard history manager with preview
  local clip_dir="$HOME/.clipboard_history"
  mkdir -p "$clip_dir"
  
  # Save current clipboard
  xclip -selection clipboard -o > "$clip_dir/$(date +%Y%m%d-%H%M%S)"
  
  # Browse and restore old clipboards
  local selected=$(find "$clip_dir" -type f | \
    sort -r | \
    fzf --preview 'cat {}' \
    --bind 'ctrl-d:execute(rm {})' \
    --header 'CTRL-D: delete entry')
    
  [ -n "$selected" ] && cat "$selected" | xclip -selection clipboard

}

createBackupForFolder () {
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

# Optional: Add a function to list recent backups
listBackups() {
    local backup_dir="$HOME/.backups"
    ls -lh "$backup_dir" | head -n 10
}

# Sourcing paths
# source /home/ankit/apriltag_ros/install/apriltag_ros/share/apriltag_ros/local_setup.bash
source /opt/ros/humble/setup.bash
#export GZ_VERSION=garden
source /home/ankit/ws/install/setup.bash
# source ~/ws_sensor_combined/install/setup.bash
# source /home/ankit/apriltag_ros2_ws/install/setup.bash
#. "$HOME/.cargo/env"
#export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

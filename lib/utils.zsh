#!/usr/bin/env zsh

# Gitmon CLI Utilities
# Platform detection, color setup, and common helper functions

# Platform detection
gitmon_detect_platform() {
  case "$OSTYPE" in
    darwin*)
      export GITMON_PLATFORM="macos"
      ;;
    linux*)
      export GITMON_PLATFORM="linux"
      ;;
    msys*|cygwin*|win32)
      export GITMON_PLATFORM="windows"
      ;;
    *)
      export GITMON_PLATFORM="unknown"
      ;;
  esac
}

# Color setup for cross-platform compatibility
gitmon_setup_colors() {
  # Enable colors if supported
  autoload -U colors && colors

  # Define Gitmon color palette
  export GITMON_COLOR_RESET="%{$reset_color%}"
  export GITMON_COLOR_BOLD="%{$fg_bold[white]%}"

  # Primary theme colors
  export GITMON_COLOR_PRIMARY="%{$fg[cyan]%}"
  export GITMON_COLOR_SECONDARY="%{$fg[blue]%}"
  export GITMON_COLOR_ACCENT="%{$fg[magenta]%}"

  # Status colors
  export GITMON_COLOR_SUCCESS="%{$fg[green]%}"
  export GITMON_COLOR_WARNING="%{$fg[yellow]%}"
  export GITMON_COLOR_ERROR="%{$fg[red]%}"

  # Git colors
  export GITMON_COLOR_GIT_CLEAN="%{$fg[green]%}"
  export GITMON_COLOR_GIT_DIRTY="%{$fg[red]%}"
  export GITMON_COLOR_GIT_STAGED="%{$fg[yellow]%}"
  export GITMON_COLOR_GIT_BRANCH="%{$fg[cyan]%}"

  # Directory colors
  export GITMON_COLOR_DIR="%{$fg[blue]%}"
  export GITMON_COLOR_DIR_REPO="%{$fg[magenta]%}"

  # Time colors
  export GITMON_COLOR_TIME="%{$fg[white]%}"
  export GITMON_COLOR_USER="%{$fg[green]%}"
  export GITMON_COLOR_HOST="%{$fg[yellow]%}"
}

# String utilities
gitmon_str_length() {
  local str="$1"
  echo "${#${(S%%)str//(\%([KF1]|)\{*\}|\%[Bbkf])}}}"
}

gitmon_str_truncate() {
  local str="$1"
  local max_length="$2"
  local suffix="${3:-...}"

  if [[ $(gitmon_str_length "$str") -gt $max_length ]]; then
    local truncated_length=$((max_length - ${#suffix}))
    echo "${str[1,$truncated_length]}$suffix"
  else
    echo "$str"
  fi
}

# Path utilities
gitmon_path_shorten() {
  local path="$1"
  local max_length="${2:-30}"

  if [[ ${#path} -le $max_length ]]; then
    echo "$path"
    return
  fi

  # Replace home directory with ~
  path="${path/#$HOME/~}"

  # If still too long, show only the last few directories
  if [[ ${#path} -gt $max_length ]]; then
    local dirs=(${(s:/:)path})
    local result=""
    local i=${#dirs}

    while [[ $i -gt 0 && ${#result} -lt $max_length ]]; do
      if [[ -z "$result" ]]; then
        result="$dirs[$i]"
      else
        result="$dirs[$i]/$result"
      fi
      ((i--))
    done

    if [[ $i -gt 0 ]]; then
      result=".../$result"
    fi

    echo "$result"
  else
    echo "$path"
  fi
}

# Timer utilities
_gitmon_timer_start=0

gitmon_timer_start() {
  _gitmon_timer_start=$SECONDS
}

gitmon_timer_stop() {
  if [[ $_gitmon_timer_start -gt 0 ]]; then
    local elapsed=$(($SECONDS - $_gitmon_timer_start))
    _gitmon_timer_start=0
    echo $elapsed
  else
    echo 0
  fi
}

# Format timer output
gitmon_format_timer() {
  local elapsed="$1"

  if [[ $elapsed -lt 1 ]]; then
    echo ""
  elif [[ $elapsed -lt 60 ]]; then
    echo "${elapsed}s"
  elif [[ $elapsed -lt 3600 ]]; then
    echo "$((elapsed / 60))m$((elapsed % 60))s"
  else
    echo "$((elapsed / 3600))h$(((elapsed % 3600) / 60))m"
  fi
}

# Check if command exists
gitmon_command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Safe directory checking
gitmon_is_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Initialize utilities
gitmon_setup_colors
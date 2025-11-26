#!/usr/bin/env zsh

# Crystalix Theme for Gitmon CLI
# A minimalist theme with subtle gitmon elements and clean aesthetics

# Theme configuration
CRYSTALIX_SHOW_USER="${CRYSTALIX_SHOW_USER:-minimal}"  # minimal, full, never
CRYSTALIX_SHOW_PATH_TYPE="${CRYSTALIX_SHOW_PATH_TYPE:-short}"  # short, full, relative
CRYSTALIX_GIT_ICONS="${CRYSTALIX_GIT_ICONS:-true}"
CRYSTALIX_SUBTLE_COLORS="${CRYSTALIX_SUBTLE_COLORS:-true}"

# Minimal symbols
CRYSTALIX_PROMPT_CHAR="❯"
CRYSTALIX_GIT_CHAR="±"
CRYSTALIX_DIRTY_CHAR="●"
CRYSTALIX_STAGED_CHAR="✓"
CRYSTALIX_UNTRACKED_CHAR="?"
CRYSTALIX_STASH_CHAR="⚑"
CRYSTALIX_AHEAD_CHAR="↑"
CRYSTALIX_BEHIND_CHAR="↓"

# Color scheme - subtle and modern
if [[ "$CRYSTALIX_SUBTLE_COLORS" == "true" ]]; then
  CRYSTALIX_USER_COLOR="%F{246}"      # light gray
  CRYSTALIX_HOST_COLOR="%F{246}"      # light gray
  CRYSTALIX_DIR_COLOR="%F{4}"         # blue
  CRYSTALIX_DIR_REPO_COLOR="%F{5}"    # magenta
  CRYSTALIX_GIT_CLEAN_COLOR="%F{2}"   # green
  CRYSTALIX_GIT_DIRTY_COLOR="%F{1}"   # red
  CRYSTALIX_GIT_STAGED_COLOR="%F{3}"  # yellow
  CRYSTALIX_PROMPT_COLOR="%F{6}"      # cyan
  CRYSTALIX_TIME_COLOR="%F{240}"      # dark gray
  CRYSTALIX_GITMON_COLOR="%F{5}"      # magenta
else
  CRYSTALIX_USER_COLOR="$GITMON_COLOR_USER"
  CRYSTALIX_HOST_COLOR="$GITMON_COLOR_HOST"
  CRYSTALIX_DIR_COLOR="$GITMON_COLOR_DIR"
  CRYSTALIX_DIR_REPO_COLOR="$GITMON_COLOR_DIR_REPO"
  CRYSTALIX_GIT_CLEAN_COLOR="$GITMON_COLOR_GIT_CLEAN"
  CRYSTALIX_GIT_DIRTY_COLOR="$GITMON_COLOR_GIT_DIRTY"
  CRYSTALIX_GIT_STAGED_COLOR="$GITMON_COLOR_GIT_STAGED"
  CRYSTALIX_PROMPT_COLOR="$GITMON_COLOR_PRIMARY"
  CRYSTALIX_TIME_COLOR="$GITMON_COLOR_TIME"
  CRYSTALIX_GITMON_COLOR="$GITMON_COLOR_ACCENT"
fi

# Build user info (minimal approach)
crystalix_user_info() {
  case "$CRYSTALIX_SHOW_USER" in
    "full")
      echo "${CRYSTALIX_USER_COLOR}%n@%m${GITMON_COLOR_RESET}"
      ;;
    "minimal")
      if [[ -n "$SSH_CONNECTION" ]]; then
        echo "${CRYSTALIX_USER_COLOR}%n@%m${GITMON_COLOR_RESET}"
      elif [[ "$USER" != "$(whoami)" ]]; then
        echo "${CRYSTALIX_USER_COLOR}%n${GITMON_COLOR_RESET}"
      fi
      ;;
    "never"|*)
      return
      ;;
  esac
}

# Build directory info
crystalix_directory() {
  local current_dir="$(pwd)"
  local display_dir=""

  case "$CRYSTALIX_SHOW_PATH_TYPE" in
    "full")
      display_dir="$current_dir"
      ;;
    "relative")
      display_dir="${current_dir/#$HOME/~}"
      ;;
    "short"|*)
      display_dir="$(gitmon_path_shorten "$current_dir" 35)"
      display_dir="${display_dir/#$HOME/~}"
      ;;
  esac

  # Choose color based on git repo status
  if gitmon_is_git_repo; then
    echo "${CRYSTALIX_DIR_REPO_COLOR}$display_dir${GITMON_COLOR_RESET}"
  else
    echo "${CRYSTALIX_DIR_COLOR}$display_dir${GITMON_COLOR_RESET}"
  fi
}

# Build git info with minimal, clean styling
crystalix_git_info() {
  if ! gitmon_is_git_repo; then
    return
  fi

  local branch="$(gitmon_git_branch)"
  local status="$(gitmon_git_status)"
  local ahead_behind="$(gitmon_git_ahead_behind)"
  local stash="$(gitmon_git_stash_count)"

  if [[ -z "$branch" ]]; then
    return
  fi

  local git_color="$CRYSTALIX_GIT_CLEAN_COLOR"
  local git_info=""

  # Set color and add status indicators based on repo state
  case "$status" in
    "clean")
      git_color="$CRYSTALIX_GIT_CLEAN_COLOR"
      git_info="$branch"
      ;;
    "staged")
      git_color="$CRYSTALIX_GIT_STAGED_COLOR"
      git_info="$branch"
      if [[ "$CRYSTALIX_GIT_ICONS" == "true" ]]; then
        git_info="$git_info $CRYSTALIX_STAGED_CHAR"
      fi
      ;;
    "dirty")
      git_color="$CRYSTALIX_GIT_DIRTY_COLOR"
      git_info="$branch"
      if [[ "$CRYSTALIX_GIT_ICONS" == "true" ]]; then
        git_info="$git_info $CRYSTALIX_DIRTY_CHAR"
      fi
      ;;
    "mixed")
      git_color="$CRYSTALIX_GIT_DIRTY_COLOR"
      git_info="$branch"
      if [[ "$CRYSTALIX_GIT_ICONS" == "true" ]]; then
        git_info="$git_info $CRYSTALIX_STAGED_CHAR$CRYSTALIX_DIRTY_CHAR"
      fi
      ;;
    "untracked")
      git_color="$CRYSTALIX_GIT_STAGED_COLOR"
      git_info="$branch"
      if [[ "$CRYSTALIX_GIT_ICONS" == "true" ]]; then
        git_info="$git_info $CRYSTALIX_UNTRACKED_CHAR"
      fi
      ;;
    *)
      git_color="$CRYSTALIX_GIT_CLEAN_COLOR"
      git_info="$branch"
      ;;
  esac

  # Add ahead/behind info (minimal style)
  if [[ -n "$ahead_behind" && "$CRYSTALIX_GIT_ICONS" == "true" ]]; then
    git_info="$git_info $ahead_behind"
  fi

  # Add stash info
  if [[ -n "$stash" && "$CRYSTALIX_GIT_ICONS" == "true" ]]; then
    git_info="$git_info $stash"
  fi

  echo "${git_color}${CRYSTALIX_GIT_CHAR} $git_info${GITMON_COLOR_RESET}"
}

# Build gitmon display (subtle integration)
crystalix_gitmon_display() {
  if [[ "$GITMON_SHOW_GITMON" != "true" || -z "$GITMON_CURRENT_GITMON" ]]; then
    return
  fi

  echo "${CRYSTALIX_GITMON_COLOR}$GITMON_CURRENT_GITMON${GITMON_COLOR_RESET}"
}

# Main prompt function - clean and minimal
gitmon_theme_prompt() {
  local prompt_parts=()

  # Add user info if needed
  local user_info="$(crystalix_user_info)"
  if [[ -n "$user_info" ]]; then
    prompt_parts+=("$user_info")
  fi

  # Add directory (always shown)
  local dir_info="$(crystalix_directory)"
  prompt_parts+=("$dir_info")

  # Add git info if in repo
  local git_info="$(crystalix_git_info)"
  if [[ -n "$git_info" ]]; then
    prompt_parts+=("$git_info")
  fi

  # Add gitmon if enabled
  local gitmon_info="$(crystalix_gitmon_display)"

  # Build the final prompt
  local prompt=""

  # Join prompt parts with space
  local IFS=" "
  prompt="${prompt_parts[*]}"

  # Add gitmon with slight separation
  if [[ -n "$gitmon_info" ]]; then
    prompt="$prompt $gitmon_info"
  fi

  # Add final prompt character
  prompt="$prompt ${CRYSTALIX_PROMPT_COLOR}$CRYSTALIX_PROMPT_CHAR${GITMON_COLOR_RESET} "

  echo "$prompt"
}

# Right prompt - minimal time and timer info
gitmon_theme_rprompt() {
  local rprompt_parts=()

  # Add command timer if significant
  if [[ "$GITMON_SHOW_TIMER" == "true" && $GITMON_LAST_COMMAND_TIME -gt 2 ]]; then
    local timer_display="$(gitmon_format_timer $GITMON_LAST_COMMAND_TIME)"
    if [[ -n "$timer_display" ]]; then
      rprompt_parts+=("${GITMON_COLOR_WARNING}$timer_display${GITMON_COLOR_RESET}")
    fi
  fi

  # Add time if enabled
  if [[ "$GITMON_SHOW_TIME" == "true" ]]; then
    rprompt_parts+=("${CRYSTALIX_TIME_COLOR}%D{%H:%M}${GITMON_COLOR_RESET}")
  fi

  # Join with space and return
  local IFS=" "
  echo "${rprompt_parts[*]}"
}

# Theme setup function
gitmon_theme_setup() {
  # Initialize core functionality
  gitmon_core_init

  # Set a clean window title for supported terminals
  case "$TERM" in
    xterm*|rxvt*|screen*|tmux*)
      echo -n "\033]0;Terminal - Crystalix\007"
      ;;
  esac

  # Crystalix-specific configurations
  # Optimize for minimal latency
  export GITMON_GIT_CACHE_TTL=3  # Slightly shorter cache for responsiveness

  # Set up any crystalix-specific key bindings or aliases
  # (none for now, keeping it minimal)
}
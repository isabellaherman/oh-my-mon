#!/usr/bin/env zsh

# Shadrix Theme for Gitmon CLI
# A modern powerline-style theme with git integration and dynamic gitmons

# Theme configuration
SHADRIX_SHOW_USER="${SHADRIX_SHOW_USER:-auto}"  # auto, always, never
SHADRIX_SHOW_HOST="${SHADRIX_SHOW_HOST:-auto}"  # auto, always, never
SHADRIX_POWERLINE_STYLE="${SHADRIX_POWERLINE_STYLE:-true}"
SHADRIX_COMPACT_MODE="${SHADRIX_COMPACT_MODE:-false}"

# Powerline characters
if [[ "$SHADRIX_POWERLINE_STYLE" == "true" ]]; then
  SHADRIX_SEP_RIGHT=""
  SHADRIX_SEP_LEFT=""
  SHADRIX_SEP_THIN="❯"
else
  SHADRIX_SEP_RIGHT=">"
  SHADRIX_SEP_LEFT="<"
  SHADRIX_SEP_THIN=">"
fi

# Theme colors (can be overridden)
SHADRIX_USER_BG="${SHADRIX_USER_BG:-blue}"
SHADRIX_USER_FG="${SHADRIX_USER_FG:-white}"
SHADRIX_HOST_BG="${SHADRIX_HOST_BG:-cyan}"
SHADRIX_HOST_FG="${SHADRIX_HOST_FG:-black}"
SHADRIX_DIR_BG="${SHADRIX_DIR_BG:-magenta}"
SHADRIX_DIR_FG="${SHADRIX_DIR_FG:-white}"
SHADRIX_GIT_CLEAN_BG="${SHADRIX_GIT_CLEAN_BG:-green}"
SHADRIX_GIT_DIRTY_BG="${SHADRIX_GIT_DIRTY_BG:-red}"
SHADRIX_GIT_FG="${SHADRIX_GIT_FG:-white}"

# Build powerline segment
shadrix_segment() {
  local bg="$1"
  local fg="$2"
  local content="$3"
  local next_bg="$4"

  if [[ -n "$content" ]]; then
    echo -n "%K{$bg}%F{$fg} $content %k%f"
    if [[ -n "$next_bg" && "$next_bg" != "$bg" ]]; then
      echo -n "%K{$next_bg}%F{$bg}$SHADRIX_SEP_RIGHT%k%f"
    elif [[ -z "$next_bg" ]]; then
      echo -n "%F{$bg}$SHADRIX_SEP_RIGHT%f"
    fi
  fi
}

# Build user segment
shadrix_user_segment() {
  local show_user="$SHADRIX_SHOW_USER"
  local show_host="$SHADRIX_SHOW_HOST"

  # Auto-detect if we should show user/host
  if [[ "$show_user" == "auto" ]]; then
    if [[ -n "$SSH_CONNECTION" ]] || [[ "$USER" != "$(whoami)" ]]; then
      show_user="always"
    else
      show_user="never"
    fi
  fi

  if [[ "$show_host" == "auto" ]]; then
    if [[ -n "$SSH_CONNECTION" ]]; then
      show_host="always"
    else
      show_host="never"
    fi
  fi

  local user_content=""
  if [[ "$show_user" == "always" ]]; then
    user_content="%n"
  fi

  if [[ "$show_host" == "always" ]]; then
    if [[ -n "$user_content" ]]; then
      user_content="$user_content@%m"
    else
      user_content="%m"
    fi
  fi

  echo "$user_content"
}

# Build directory segment
shadrix_dir_segment() {
  local current_dir="$(pwd)"
  local short_dir="$(gitmon_path_shorten "$current_dir" 25)"

  # Replace home with ~
  short_dir="${short_dir/#$HOME/~}"

  echo "$short_dir"
}

# Build git segment with status-based colors
shadrix_git_segment() {
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

  local git_bg="$SHADRIX_GIT_CLEAN_BG"
  local git_content="$branch"

  # Set background based on status
  case "$status" in
    "dirty"|"staged"|"mixed")
      git_bg="$SHADRIX_GIT_DIRTY_BG"
      ;;
    "untracked")
      git_bg="yellow"
      ;;
  esac

  # Add status indicators
  case "$status" in
    "staged")
      git_content="$git_content ●"
      ;;
    "dirty")
      git_content="$git_content ●"
      ;;
    "untracked")
      git_content="$git_content ?"
      ;;
    "mixed")
      git_content="$git_content ●?"
      ;;
  esac

  # Add ahead/behind
  if [[ -n "$ahead_behind" ]]; then
    git_content="$git_content $ahead_behind"
  fi

  # Add stash
  if [[ -n "$stash" ]]; then
    git_content="$git_content $stash"
  fi

  echo "$git_bg:$git_content"
}

# Build gitmon segment
shadrix_gitmon_segment() {
  if [[ "$GITMON_SHOW_GITMON" == "true" && -n "$GITMON_CURRENT_GITMON" ]]; then
    echo "$GITMON_CURRENT_GITMON"
  fi
}

# Main prompt function
gitmon_theme_prompt() {
  local segments=()
  local next_bg=""

  # User segment
  local user_content="$(shadrix_user_segment)"
  if [[ -n "$user_content" ]]; then
    segments+=("$SHADRIX_USER_BG:$SHADRIX_USER_FG:$user_content")
  fi

  # Directory segment
  local dir_content="$(shadrix_dir_segment)"
  segments+=("$SHADRIX_DIR_BG:$SHADRIX_DIR_FG:$dir_content")

  # Git segment
  local git_info="$(shadrix_git_segment)"
  if [[ -n "$git_info" ]]; then
    local git_bg="${git_info%%:*}"
    local git_content="${git_info#*:}"
    segments+=("$git_bg:$SHADRIX_GIT_FG:$git_content")
  fi

  # Build the prompt
  local prompt=""
  local segment_count=${#segments[@]}

  for (( i=1; i<=segment_count; i++ )); do
    local segment="${segments[$i]}"
    local seg_parts=(${(s.:.)segment})
    local bg="$seg_parts[1]"
    local fg="$seg_parts[2]"
    local content="${seg_parts[3]}"

    # Determine next background
    if [[ $i -lt $segment_count ]]; then
      local next_segment="${segments[$((i+1))]}"
      next_bg="${next_segment%%:*}"
    else
      next_bg=""
    fi

    prompt="$prompt$(shadrix_segment "$bg" "$fg" "$content" "$next_bg")"
  done

  # Add gitmon and final separator
  local gitmon="$(shadrix_gitmon_segment)"
  if [[ -n "$gitmon" ]]; then
    prompt="$prompt ${GITMON_COLOR_ACCENT}$gitmon${GITMON_COLOR_RESET}"
  fi

  prompt="$prompt ${GITMON_COLOR_PRIMARY}$SHADRIX_SEP_THIN${GITMON_COLOR_RESET} "

  echo "$prompt"
}

# Right prompt with time and command status
gitmon_theme_rprompt() {
  local rprompt=""

  # Command timer
  if [[ "$GITMON_SHOW_TIMER" == "true" && $GITMON_LAST_COMMAND_TIME -gt 0 ]]; then
    local timer_display="$(gitmon_format_timer $GITMON_LAST_COMMAND_TIME)"
    if [[ -n "$timer_display" ]]; then
      rprompt="$rprompt${GITMON_COLOR_WARNING}⏱ $timer_display${GITMON_COLOR_RESET} "
    fi
  fi

  # Time
  if [[ "$GITMON_SHOW_TIME" == "true" ]]; then
    rprompt="$rprompt${GITMON_COLOR_TIME}%D{%H:%M:%S}${GITMON_COLOR_RESET}"
  fi

  echo "$rprompt"
}

# Theme setup
gitmon_theme_setup() {
  # Initialize any theme-specific settings
  gitmon_core_init

  # Set window title if supported
  case "$TERM" in
    xterm*|rxvt*|screen*|tmux*)
      echo -n "\033]0;Gitmon CLI - Shadrix Theme\007"
      ;;
  esac
}
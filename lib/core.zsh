#!/usr/bin/env zsh

# Gitmon CLI Core Functionality
# Main framework features and hooks

# Core configuration variables
export GITMON_SHOW_TIME="${GITMON_SHOW_TIME:-true}"
export GITMON_SHOW_TIMER="${GITMON_SHOW_TIMER:-true}"
export GITMON_SHOW_GIT="${GITMON_SHOW_GIT:-true}"
export GITMON_SHOW_GITMON="${GITMON_SHOW_GITMON:-true}"
export GITMON_MAX_PATH_LENGTH="${GITMON_MAX_PATH_LENGTH:-30}"

# Current session variables
export GITMON_CURRENT_GITMON=""
export GITMON_LAST_COMMAND_TIME=0

# Hook system for themes
typeset -g -A gitmon_hooks

# Register a hook
gitmon_add_hook() {
  local hook_name="$1"
  local hook_function="$2"

  if [[ -z "$gitmon_hooks[$hook_name]" ]]; then
    gitmon_hooks[$hook_name]="$hook_function"
  else
    gitmon_hooks[$hook_name]="${gitmon_hooks[$hook_name]} $hook_function"
  fi
}

# Execute hooks
gitmon_run_hook() {
  local hook_name="$1"
  shift

  if [[ -n "$gitmon_hooks[$hook_name]" ]]; then
    local hook_functions=(${(z)gitmon_hooks[$hook_name]})
    for func in $hook_functions; do
      if declare -f "$func" >/dev/null; then
        "$func" "$@"
      fi
    done
  fi
}

# Core prompt building functions
gitmon_build_user_info() {
  if [[ -n "$SSH_CONNECTION" ]] || [[ "$USER" != "$LOGNAME" ]]; then
    echo "${GITMON_COLOR_USER}%n${GITMON_COLOR_RESET}@${GITMON_COLOR_HOST}%m${GITMON_COLOR_RESET}"
  else
    echo "${GITMON_COLOR_USER}%n${GITMON_COLOR_RESET}"
  fi
}

gitmon_build_directory() {
  local current_dir="$(pwd)"
  local short_dir="$(gitmon_path_shorten "$current_dir" "$GITMON_MAX_PATH_LENGTH")"

  if gitmon_is_git_repo; then
    echo "${GITMON_COLOR_DIR_REPO}$short_dir${GITMON_COLOR_RESET}"
  else
    echo "${GITMON_COLOR_DIR}$short_dir${GITMON_COLOR_RESET}"
  fi
}

gitmon_build_time() {
  if [[ "$GITMON_SHOW_TIME" == "true" ]]; then
    echo "${GITMON_COLOR_TIME}%D{%H:%M:%S}${GITMON_COLOR_RESET}"
  fi
}

gitmon_build_timer() {
  if [[ "$GITMON_SHOW_TIMER" == "true" && $GITMON_LAST_COMMAND_TIME -gt 0 ]]; then
    local timer_display="$(gitmon_format_timer $GITMON_LAST_COMMAND_TIME)"
    if [[ -n "$timer_display" ]]; then
      echo "${GITMON_COLOR_WARNING}⏱ $timer_display${GITMON_COLOR_RESET}"
    fi
  fi
}

gitmon_build_status() {
  echo "%(?:${GITMON_COLOR_SUCCESS}:${GITMON_COLOR_ERROR})%?${GITMON_COLOR_RESET}"
}

# Gitmon character management
gitmon_get_random_gitmon() {
  local gitmon_type="${1:-emoji}"
  local gitmons_dir="$GITMON_CLI/gitmons/$gitmon_type"

  if [[ -d "$gitmons_dir" ]]; then
    local gitmon_files=($gitmons_dir/*)
    if [[ ${#gitmon_files[@]} -gt 0 ]]; then
      local random_file="$gitmon_files[$RANDOM % ${#gitmon_files[@]} + 1]"
      if [[ -f "$random_file" ]]; then
        cat "$random_file" | head -1
      fi
    fi
  fi

  # Fallback gitmons
  case $gitmon_type in
    emoji)
      local fallback_gitmons=("🐾" "🎮" "⚡" "🌟" "🔥" "💎" "🚀" "⭐")
      echo "$fallback_gitmons[$RANDOM % ${#fallback_gitmons[@]} + 1]"
      ;;
    ascii)
      echo ">"
      ;;
    *)
      echo ">"
      ;;
  esac
}

gitmon_select_gitmon() {
  if [[ "$GITMON_SHOW_GITMON" != "true" ]]; then
    return
  fi

  # Change gitmon based on various conditions
  if gitmon_is_git_repo; then
    if [[ "$(gitmon_git_status)" == "dirty" ]]; then
      GITMON_CURRENT_GITMON="$(gitmon_get_random_gitmon emoji)"
    else
      GITMON_CURRENT_GITMON="$(gitmon_get_random_gitmon ascii)"
    fi
  else
    GITMON_CURRENT_GITMON="$(gitmon_get_random_gitmon emoji)"
  fi
}

# Command timing
gitmon_preexec() {
  gitmon_timer_start
  gitmon_run_hook "preexec" "$@"
}

gitmon_precmd() {
  GITMON_LAST_COMMAND_TIME=$(gitmon_timer_stop)
  gitmon_select_gitmon
  gitmon_run_hook "precmd" "$@"
}

# Setup key bindings
gitmon_setup_keybindings() {
  # Add any custom key bindings here
  # For now, we'll keep it minimal
}

# Initialize core hooks
gitmon_core_init() {
  # Set up command timing hooks
  autoload -U add-zsh-hook
  add-zsh-hook preexec gitmon_preexec
  add-zsh-hook precmd gitmon_precmd

  # Initialize gitmon selection
  gitmon_select_gitmon

  # Run initialization hook for themes
  gitmon_run_hook "core_init"
}
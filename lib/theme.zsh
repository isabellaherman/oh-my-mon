#!/usr/bin/env zsh

# Gitmon CLI Theme Management
# Theme loading, switching, and prompt building

# Theme configuration
export GITMON_THEME_DIR="$GITMON_CLI/themes"
typeset -g -A gitmon_theme_info

# Theme registry for available themes
gitmon_register_theme() {
  local theme_name="$1"
  local theme_description="$2"
  local theme_file="$3"

  gitmon_theme_info[$theme_name]="$theme_description:$theme_file"
}

# List available themes
gitmon_list_themes() {
  echo "Available Gitmon CLI themes:"
  echo ""

  for theme_name in ${(ko)gitmon_theme_info}; do
    local theme_data=(${(s.:.)gitmon_theme_info[$theme_name]})
    local theme_description="$theme_data[1]"
    echo "  ${GITMON_COLOR_PRIMARY}$theme_name${GITMON_COLOR_RESET} - $theme_description"
  done
}

# Load a theme
gitmon_theme_load() {
  local theme_name="$1"

  if [[ -z "$theme_name" ]]; then
    echo "❌ No theme specified"
    return 1
  fi

  local theme_file="$GITMON_THEME_DIR/$theme_name.zsh-theme"

  if [[ ! -f "$theme_file" ]]; then
    echo "❌ Theme '$theme_name' not found at $theme_file"
    echo "Available themes:"
    gitmon_list_available_theme_files
    return 1
  fi

  # Clear any existing prompt functions
  unset -f gitmon_theme_prompt 2>/dev/null
  unset -f gitmon_theme_rprompt 2>/dev/null
  unset -f gitmon_theme_setup 2>/dev/null

  # Source the theme file
  source "$theme_file"

  # Verify theme loaded correctly
  if ! declare -f gitmon_theme_prompt >/dev/null; then
    echo "❌ Theme '$theme_name' did not define gitmon_theme_prompt function"
    return 1
  fi

  # Run theme setup if available
  if declare -f gitmon_theme_setup >/dev/null; then
    gitmon_theme_setup
  fi

  # Set the prompt
  setopt PROMPT_SUBST
  PROMPT='$(gitmon_theme_prompt)'

  # Set right prompt if theme provides it
  if declare -f gitmon_theme_rprompt >/dev/null; then
    RPROMPT='$(gitmon_theme_rprompt)'
  else
    RPROMPT=""
  fi

  export GITMON_THEME="$theme_name"

  echo "✅ Theme '$theme_name' loaded successfully"
}

# List available theme files
gitmon_list_available_theme_files() {
  echo "Theme files in $GITMON_THEME_DIR:"
  if [[ -d "$GITMON_THEME_DIR" ]]; then
    for theme_file in "$GITMON_THEME_DIR"/*.zsh-theme; do
      if [[ -f "$theme_file" ]]; then
        local theme_name="${theme_file:t:r}"
        echo "  - $theme_name"
      fi
    done
  else
    echo "  No theme directory found"
  fi
}

# Switch theme command
gitmon_theme_switch() {
  local theme_name="$1"

  if [[ -z "$theme_name" ]]; then
    echo "Usage: gitmon_theme_switch <theme_name>"
    echo ""
    gitmon_list_available_theme_files
    return 1
  fi

  gitmon_theme_load "$theme_name"
}

# Reload current theme
gitmon_theme_reload() {
  local current_theme="$GITMON_THEME"
  if [[ -n "$current_theme" ]]; then
    echo "Reloading theme: $current_theme"
    gitmon_theme_load "$current_theme"
  else
    echo "No theme currently loaded"
  fi
}

# Theme development helpers
gitmon_theme_test() {
  echo "Testing current theme prompt components:"
  echo ""
  echo "User info: $(gitmon_build_user_info)"
  echo "Directory: $(gitmon_build_directory)"
  echo "Git info: $(gitmon_build_git_info 2>/dev/null || echo 'Not in git repo')"
  echo "Time: $(gitmon_build_time)"
  echo "Timer: $(gitmon_build_timer)"
  echo "Status: $(gitmon_build_status)"
  echo "Gitmon: $GITMON_CURRENT_GITMON"
  echo ""
  echo "Full prompt:"
  if declare -f gitmon_theme_prompt >/dev/null; then
    gitmon_theme_prompt
  else
    echo "No theme loaded"
  fi
  echo ""
}

# Initialize default themes
gitmon_theme_init() {
  # Register built-in themes (will be populated when themes are created)
  gitmon_register_theme "shadrix" "Modern powerline-style theme with git integration" "shadrix.zsh-theme"
  gitmon_register_theme "crystalix" "Minimalist theme with subtle gitmon elements" "crystalix.zsh-theme"

  # Run theme initialization hook
  gitmon_run_hook "theme_init"
}

# Commands for theme management
gitmon() {
  local command="$1"
  shift

  case "$command" in
    "theme")
      local subcommand="$1"
      shift
      case "$subcommand" in
        "list")
          gitmon_list_available_theme_files
          ;;
        "switch")
          gitmon_theme_switch "$1"
          ;;
        "reload")
          gitmon_theme_reload
          ;;
        "test")
          gitmon_theme_test
          ;;
        *)
          echo "Usage: gitmon theme [list|switch|reload|test]"
          ;;
      esac
      ;;
    "version")
      echo "Gitmon CLI 1.0.0"
      echo "Platform: $GITMON_PLATFORM"
      echo "Theme: $GITMON_THEME"
      ;;
    "help")
      echo "Gitmon CLI - A delightful zsh configuration framework"
      echo ""
      echo "Commands:"
      echo "  gitmon theme list     - List available themes"
      echo "  gitmon theme switch   - Switch to a different theme"
      echo "  gitmon theme reload   - Reload current theme"
      echo "  gitmon theme test     - Test prompt components"
      echo "  gitmon version        - Show version information"
      echo "  gitmon help           - Show this help"
      ;;
    *)
      echo "Unknown command: $command"
      echo "Run 'gitmon help' for available commands"
      ;;
  esac
}
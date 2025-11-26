#!/usr/bin/env zsh

# Gitmon CLI - A delightful zsh configuration framework
# Version: 1.0.0

# Prevent sourcing this file more than once
if [[ "${GITMON_LOADED}" == "true" ]]; then
  return 0
fi

# Set Gitmon CLI installation path
if [[ -z "$GITMON_CLI" ]]; then
  export GITMON_CLI="${0:a:h}"
fi

# Set default theme if not specified
if [[ -z "$GITMON_THEME" ]]; then
  export GITMON_THEME="shadrix"
fi

# Core library loading function
gitmon_load() {
  local lib_file="$1"
  if [[ -f "$GITMON_CLI/lib/$lib_file.zsh" ]]; then
    source "$GITMON_CLI/lib/$lib_file.zsh"
  else
    echo "⚠️  Gitmon CLI: Could not load lib/$lib_file.zsh"
  fi
}

# Load core libraries in order
gitmon_load "utils"
gitmon_load "core"
gitmon_load "git"
gitmon_load "theme"

# Initialize Gitmon CLI
gitmon_init() {
  # Detect platform
  gitmon_detect_platform

  # Initialize git utilities
  gitmon_git_init

  # Load and apply theme
  gitmon_theme_load "$GITMON_THEME"

  # Set up key bindings if needed
  gitmon_setup_keybindings

  # Mark as loaded
  export GITMON_LOADED="true"

  # Show welcome message on first load
  if [[ -z "$GITMON_SILENT" ]]; then
    gitmon_show_welcome
  fi
}

# Show welcome message
gitmon_show_welcome() {
  echo ""
  echo "🎮 Gitmon CLI loaded successfully!"
  echo "   Theme: $GITMON_THEME"
  echo "   Platform: $GITMON_PLATFORM"
  echo ""
}

# Main initialization
gitmon_init

# Cleanup function namespace
unfunction gitmon_load gitmon_init gitmon_show_welcome 2>/dev/null

# Export useful functions for theme development
export GITMON_CLI GITMON_THEME GITMON_PLATFORM GITMON_LOADED
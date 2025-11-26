#!/usr/bin/env zsh

# Gitmon CLI Git Integration
# Git status, branch info, and repository utilities

# Git configuration
export GITMON_GIT_SHOW_STASH="${GITMON_GIT_SHOW_STASH:-true}"
export GITMON_GIT_SHOW_AHEAD_BEHIND="${GITMON_GIT_SHOW_AHEAD_BEHIND:-true}"
export GITMON_GIT_SHOW_UNTRACKED="${GITMON_GIT_SHOW_UNTRACKED:-true}"

# Cache for git status to improve performance
typeset -g -A gitmon_git_cache
export GITMON_GIT_CACHE_TTL=5  # seconds

# Get current git branch
gitmon_git_branch() {
  if ! gitmon_is_git_repo; then
    return 1
  fi

  git symbolic-ref --short HEAD 2>/dev/null || \
  git describe --tags --exact-match HEAD 2>/dev/null || \
  git rev-parse --short HEAD 2>/dev/null
}

# Get git repository status
gitmon_git_status() {
  if ! gitmon_is_git_repo; then
    echo "none"
    return 1
  fi

  local repo_path="$(git rev-parse --show-toplevel 2>/dev/null)"
  local cache_key="$repo_path"
  local current_time="$(date +%s)"

  # Check cache
  if [[ -n "$gitmon_git_cache[$cache_key]" ]]; then
    local cache_data=(${(s:|:)gitmon_git_cache[$cache_key]})
    local cache_time="$cache_data[1]"
    local cache_status="$cache_data[2]"

    if [[ $((current_time - cache_time)) -lt $GITMON_GIT_CACHE_TTL ]]; then
      echo "$cache_status"
      return 0
    fi
  fi

  # Check for changes
  local status="clean"

  # Check for staged changes
  if ! git diff --cached --quiet 2>/dev/null; then
    status="staged"
  fi

  # Check for unstaged changes
  if ! git diff --quiet 2>/dev/null; then
    status="dirty"
  fi

  # Check for untracked files
  if [[ "$GITMON_GIT_SHOW_UNTRACKED" == "true" ]]; then
    if [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
      if [[ "$status" == "clean" ]]; then
        status="untracked"
      else
        status="mixed"
      fi
    fi
  fi

  # Cache the result
  gitmon_git_cache[$cache_key]="$current_time:$status"

  echo "$status"
}

# Get ahead/behind information
gitmon_git_ahead_behind() {
  if ! gitmon_is_git_repo || [[ "$GITMON_GIT_SHOW_AHEAD_BEHIND" != "true" ]]; then
    return 1
  fi

  local branch="$(gitmon_git_branch)"
  if [[ -z "$branch" ]]; then
    return 1
  fi

  local upstream="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"
  if [[ -z "$upstream" ]]; then
    return 1
  fi

  local ahead_behind="$(git rev-list --count --left-right HEAD...@{u} 2>/dev/null)"
  if [[ -z "$ahead_behind" ]]; then
    return 1
  fi

  local ahead="${ahead_behind%	*}"
  local behind="${ahead_behind#*	}"

  local result=""
  if [[ "$ahead" -gt 0 ]]; then
    result="↑$ahead"
  fi
  if [[ "$behind" -gt 0 ]]; then
    result="${result}↓$behind"
  fi

  echo "$result"
}

# Get stash count
gitmon_git_stash_count() {
  if ! gitmon_is_git_repo || [[ "$GITMON_GIT_SHOW_STASH" != "true" ]]; then
    return 1
  fi

  local stash_count="$(git stash list 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$stash_count" -gt 0 ]]; then
    echo "⚑$stash_count"
  fi
}

# Build git prompt segment
gitmon_build_git_info() {
  if [[ "$GITMON_SHOW_GIT" != "true" ]] || ! gitmon_is_git_repo; then
    return 1
  fi

  local branch="$(gitmon_git_branch)"
  local status="$(gitmon_git_status)"
  local ahead_behind="$(gitmon_git_ahead_behind)"
  local stash="$(gitmon_git_stash_count)"

  if [[ -z "$branch" ]]; then
    return 1
  fi

  local git_info=""

  # Branch name with appropriate color
  case "$status" in
    "clean")
      git_info="${GITMON_COLOR_GIT_CLEAN}$branch${GITMON_COLOR_RESET}"
      ;;
    "staged")
      git_info="${GITMON_COLOR_GIT_STAGED}$branch${GITMON_COLOR_RESET}"
      ;;
    "dirty"|"mixed")
      git_info="${GITMON_COLOR_GIT_DIRTY}$branch${GITMON_COLOR_RESET}"
      ;;
    "untracked")
      git_info="${GITMON_COLOR_GIT_BRANCH}$branch${GITMON_COLOR_RESET}"
      ;;
    *)
      git_info="${GITMON_COLOR_GIT_BRANCH}$branch${GITMON_COLOR_RESET}"
      ;;
  esac

  # Add status indicators
  case "$status" in
    "staged")
      git_info="${git_info} ${GITMON_COLOR_GIT_STAGED}●${GITMON_COLOR_RESET}"
      ;;
    "dirty")
      git_info="${git_info} ${GITMON_COLOR_GIT_DIRTY}●${GITMON_COLOR_RESET}"
      ;;
    "untracked")
      git_info="${git_info} ${GITMON_COLOR_WARNING}?${GITMON_COLOR_RESET}"
      ;;
    "mixed")
      git_info="${git_info} ${GITMON_COLOR_GIT_STAGED}●${GITMON_COLOR_GIT_DIRTY}●${GITMON_COLOR_WARNING}?${GITMON_COLOR_RESET}"
      ;;
  esac

  # Add ahead/behind info
  if [[ -n "$ahead_behind" ]]; then
    git_info="${git_info} ${GITMON_COLOR_ACCENT}$ahead_behind${GITMON_COLOR_RESET}"
  fi

  # Add stash info
  if [[ -n "$stash" ]]; then
    git_info="${git_info} ${GITMON_COLOR_WARNING}$stash${GITMON_COLOR_RESET}"
  fi

  echo "$git_info"
}

# Clear git cache (useful for theme switching or debugging)
gitmon_git_clear_cache() {
  gitmon_git_cache=()
}

# Initialize git functionality
gitmon_git_init() {
  # Set up any git-specific configuration
  gitmon_git_clear_cache

  # Add hook to clear cache on directory change
  gitmon_add_hook "precmd" "gitmon_git_clear_cache_on_cd"
}

# Hook to clear cache when changing directories
gitmon_git_clear_cache_on_cd() {
  # Only clear if we've actually changed directories
  if [[ "$PWD" != "$GITMON_LAST_PWD" ]]; then
    gitmon_git_clear_cache
    export GITMON_LAST_PWD="$PWD"
  fi
}
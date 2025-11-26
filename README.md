# 🎮 Gitmon CLI

A delightful zsh configuration framework with themes, git integration, and dynamic gitmon characters.

[![Platform Support](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)](#installation)
[![Shell Support](https://img.shields.io/badge/shell-zsh%20%7C%20bash%20%7C%20PowerShell-green)](#installation)
[![License](https://img.shields.io/badge/license-MIT-brightgreen)](#license)

## ✨ Features

- **🎨 Beautiful Themes**: Modern powerline-style and minimalist themes
- **🔧 Git Integration**: Branch info, status indicators, ahead/behind tracking
- **🎮 Dynamic Gitmons**: ASCII and emoji characters that change based on context
- **⏱️ Command Timing**: Track how long commands take to execute
- **🖥️ Cross-Platform**: Works on macOS, Linux, and Windows (with PowerShell adapter)
- **🚀 Performance**: Optimized git status caching for fast prompts
- **🔌 Extensible**: Easy to create custom themes and extend functionality

## 🖼️ Screenshots

### Shadrix Theme (Powerline Style)
```
isabellaherman@MacBook gitmon-cli ± main ● ⚡ ❯
```

### Crystalix Theme (Minimalist)
```
~/Projects/gitmon-cli ± main ● 🎮 ❯
```

## 🚀 Quick Start

### One-Line Installation

**Unix/Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/gitmon-cli/main/install.sh | bash
```

**Windows PowerShell:**
```powershell
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yourusername/gitmon-cli/main/install.ps1" -UseBasicParsing).Content
```

### Manual Installation

1. **Download Gitmon CLI:**
   ```bash
   git clone https://github.com/yourusername/gitmon-cli.git ~/.gitmon-cli
   ```

2. **Add to your shell config:**
   ```bash
   # For zsh (add to ~/.zshrc)
   source ~/.gitmon-cli/gitmon-cli.zsh

   # For bash (add to ~/.bashrc)
   source ~/.gitmon-cli/gitmon-cli.zsh
   ```

3. **Restart your terminal or reload config:**
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

## 🎨 Themes

Gitmon CLI comes with two built-in themes:

### 🌟 Shadrix
Modern powerline-style theme with:
- Colored segments for user, directory, and git info
- Status-based backgrounds (clean=green, dirty=red)
- Powerline separators with proper font support
- Right-side time and command duration display

### 💎 Crystalix
Minimalist theme featuring:
- Clean, subtle color scheme
- Minimal status indicators
- Reduced visual noise
- Focused on essential information

### Theme Switching
```bash
# List available themes
gitmon theme list

# Switch themes
gitmon theme switch crystalix

# Reload current theme
gitmon theme reload

# Test theme components
gitmon theme test
```

## 🔧 Configuration

### Environment Variables

```bash
# Theme selection
export GITMON_THEME="shadrix"        # or "crystalix"

# Feature toggles
export GITMON_SHOW_TIME="true"       # Show time in prompt
export GITMON_SHOW_TIMER="true"      # Show command duration
export GITMON_SHOW_GIT="true"        # Show git information
export GITMON_SHOW_GITMON="true"     # Show gitmon characters

# Display options
export GITMON_MAX_PATH_LENGTH="30"   # Max directory path length
export GITMON_SILENT="false"         # Hide welcome message

# Git options
export GITMON_GIT_SHOW_STASH="true"         # Show stash count
export GITMON_GIT_SHOW_AHEAD_BEHIND="true"  # Show ahead/behind
export GITMON_GIT_SHOW_UNTRACKED="true"     # Show untracked files
export GITMON_GIT_CACHE_TTL="5"             # Cache timeout (seconds)
```

### Per-Theme Configuration

**Shadrix Theme:**
```bash
export SHADRIX_SHOW_USER="auto"          # auto, always, never
export SHADRIX_SHOW_HOST="auto"          # auto, always, never
export SHADRIX_POWERLINE_STYLE="true"    # Use powerline characters
export SHADRIX_COMPACT_MODE="false"      # Compact display mode
```

**Crystalix Theme:**
```bash
export CRYSTALIX_SHOW_USER="minimal"     # minimal, full, never
export CRYSTALIX_SHOW_PATH_TYPE="short"  # short, full, relative
export CRYSTALIX_GIT_ICONS="true"        # Show git status icons
export CRYSTALIX_SUBTLE_COLORS="true"    # Use subtle color palette
```

## 🎮 Gitmon Characters

Gitmon CLI includes various ASCII and emoji characters that appear in your prompt:

### Emoji Gitmons
- 😊 Happy
- 🚀 Excited
- ✨ Sparkle
- 🔥 Fire
- 💎 Gem
- ⭐ Star
- ⚡ Lightning
- 🎮 Game

### ASCII Gitmons
- `>` Arrow
- `λ` Lambda
- `▶` Triangle
- `$` Dollar
- `◆` Diamond
- `#` Hash

Characters change dynamically based on:
- Git repository status (clean vs dirty)
- Current directory context
- Random selection for variety

## 📊 Git Integration

### Git Status Indicators
- `●` Staged changes
- `●` Unstaged changes
- `?` Untracked files
- `↑n` Commits ahead
- `↓n` Commits behind
- `⚑n` Stashed changes

### Git Status Colors
- **Green**: Clean repository
- **Yellow**: Staged changes
- **Red**: Unstaged changes
- **Blue**: Untracked files

### Performance
- Git status is cached for 5 seconds by default
- Cache automatically cleared on directory changes
- Minimal git commands used for fast prompts

## 🛠️ Commands

```bash
# Theme management
gitmon theme list              # List available themes
gitmon theme switch <name>     # Switch to theme
gitmon theme reload            # Reload current theme
gitmon theme test              # Test prompt components

# Information
gitmon version                 # Show version info
gitmon help                    # Show help

# Development
gitmon theme test              # Test all prompt components
```

## 🔌 Creating Custom Themes

Create a new theme file in `~/.gitmon-cli/themes/mytheme.zsh-theme`:

```bash
#!/usr/bin/env zsh

# MyTheme for Gitmon CLI

# Required: Main prompt function
gitmon_theme_prompt() {
    local prompt=""

    # Add user info
    prompt+="$(gitmon_build_user_info)"

    # Add directory
    prompt+=" $(gitmon_build_directory)"

    # Add git info
    local git_info="$(gitmon_build_git_info)"
    if [[ -n "$git_info" ]]; then
        prompt+=" $git_info"
    fi

    # Add gitmon
    if [[ -n "$GITMON_CURRENT_GITMON" ]]; then
        prompt+=" $GITMON_CURRENT_GITMON"
    fi

    prompt+=" $ "
    echo "$prompt"
}

# Optional: Right prompt function
gitmon_theme_rprompt() {
    echo "$(gitmon_build_time)"
}

# Optional: Theme setup function
gitmon_theme_setup() {
    # Theme-specific initialization
    gitmon_core_init
}
```

Then switch to your theme:
```bash
gitmon theme switch mytheme
```

### Available Helper Functions

| Function | Description |
|----------|-------------|
| `gitmon_build_user_info()` | User and hostname info |
| `gitmon_build_directory()` | Current directory path |
| `gitmon_build_git_info()` | Git status and branch |
| `gitmon_build_time()` | Current time |
| `gitmon_build_timer()` | Command execution time |
| `gitmon_build_status()` | Last command exit status |

### Available Variables

| Variable | Description |
|----------|-------------|
| `$GITMON_CURRENT_GITMON` | Current gitmon character |
| `$GITMON_PLATFORM` | Current platform (macos/linux/windows) |
| `$GITMON_LAST_COMMAND_TIME` | Last command duration in seconds |
| `$GITMON_COLOR_*` | Predefined colors |

## 🌍 Platform Support

### macOS & Linux (Full Support)
- ✅ All themes and features
- ✅ Git integration
- ✅ Command timing
- ✅ Dynamic gitmons
- ✅ Powerline fonts supported

### Windows (PowerShell Adapter)
- ✅ Basic prompt functionality
- ✅ Simple git integration
- ✅ Basic gitmon display
- ⚠️ Limited theming (no powerline)
- 💡 For full features, use WSL with zsh

## 🔧 Troubleshooting

### Powerline Characters Not Displaying
Install a powerline-compatible font:
- **Fira Code**
- **Source Code Pro**
- **Hack**
- **JetBrains Mono**

### Git Status Not Updating
```bash
# Clear git cache
gitmon_git_clear_cache

# Or restart shell
exec $SHELL
```

### Theme Not Loading
```bash
# Check theme exists
gitmon theme list

# Reload theme
gitmon theme reload

# Check for errors
gitmon theme test
```

### Slow Prompt
```bash
# Reduce git cache timeout
export GITMON_GIT_CACHE_TTL=3

# Disable features
export GITMON_SHOW_TIMER="false"
export GITMON_GIT_SHOW_AHEAD_BEHIND="false"
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup
```bash
# Clone repository
git clone https://github.com/yourusername/gitmon-cli.git
cd gitmon-cli

# Test changes
source ./gitmon-cli.zsh

# Test themes
gitmon theme test
```

### Adding New Themes
1. Create theme file in `themes/`
2. Implement required functions
3. Test with `gitmon theme test`
4. Submit pull request

### Adding Gitmons
1. Add files to `gitmons/emoji/` or `gitmons/ascii/`
2. One character per file
3. Test with different themes

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Inspired by [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- Powerline fonts from [powerline/fonts](https://github.com/powerline/fonts)
- Git integration inspired by various zsh themes

## 📞 Support

- 🐛 [Report bugs](https://github.com/yourusername/gitmon-cli/issues)
- 💡 [Request features](https://github.com/yourusername/gitmon-cli/issues)
- 📖 [Documentation](https://github.com/yourusername/gitmon-cli/wiki)
- 💬 [Discussions](https://github.com/yourusername/gitmon-cli/discussions)

---

Made with ❤️ by the Gitmon CLI team
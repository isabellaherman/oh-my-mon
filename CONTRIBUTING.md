# Contributing to Gitmon CLI

Thank you for your interest in contributing to Gitmon CLI! This document provides guidelines and information for contributors.

## 🎯 Ways to Contribute

- **🐛 Bug Reports**: Report issues you encounter
- **✨ Feature Requests**: Suggest new features or improvements
- **🎨 New Themes**: Create and share custom themes
- **🎮 Gitmon Characters**: Add new ASCII art and emoji gitmons
- **📖 Documentation**: Improve guides, tutorials, and examples
- **🔧 Code**: Fix bugs, implement features, optimize performance

## 🚀 Getting Started

### Prerequisites

- **zsh** (primary target shell)
- **git** (for version control and git integration features)
- Basic knowledge of shell scripting
- For theme development: understanding of ANSI color codes and prompt variables

### Development Setup

1. **Fork and clone the repository:**
   ```bash
   git clone https://github.com/yourusername/gitmon-cli.git
   cd gitmon-cli
   ```

2. **Test the current setup:**
   ```bash
   # Source the main file
   source ./gitmon-cli.zsh

   # Test themes
   gitmon theme list
   gitmon theme test
   ```

3. **Create a new branch for your changes:**
   ```bash
   git checkout -b feature/my-new-feature
   # or
   git checkout -b fix/bug-description
   ```

## 📁 Project Structure

```
gitmon-cli/
├── gitmon-cli.zsh          # Main entry point
├── lib/                    # Core library files
│   ├── core.zsh           # Framework core functionality
│   ├── git.zsh            # Git integration utilities
│   ├── theme.zsh          # Theme management system
│   └── utils.zsh          # Utility functions
├── themes/                 # Theme files
│   ├── shadrix.zsh-theme  # Powerline-style theme
│   └── crystalix.zsh-theme # Minimalist theme
├── gitmons/               # Gitmon character collections
│   ├── ascii/             # ASCII art characters
│   └── emoji/             # Emoji characters
├── install.sh             # Unix installation script
├── install.ps1            # PowerShell installation script
└── docs/                  # Additional documentation
```

## 🎨 Creating Themes

### Theme File Structure

Themes should be placed in `themes/` with the `.zsh-theme` extension:

```bash
themes/mytheme.zsh-theme
```

### Required Functions

Every theme must implement:

```bash
# Required: Main prompt function
gitmon_theme_prompt() {
    # Build and return the main prompt
    echo "my prompt > "
}
```

### Optional Functions

```bash
# Optional: Right-side prompt
gitmon_theme_rprompt() {
    echo "$(gitmon_build_time)"
}

# Optional: Theme initialization
gitmon_theme_setup() {
    gitmon_core_init
    # Theme-specific setup here
}
```

### Available Helper Functions

| Function | Purpose | Example Output |
|----------|---------|----------------|
| `gitmon_build_user_info()` | User@hostname info | `user@host` |
| `gitmon_build_directory()` | Current directory | `~/projects/gitmon-cli` |
| `gitmon_build_git_info()` | Git status and branch | `main ● ↑2` |
| `gitmon_build_time()` | Current time | `14:30:25` |
| `gitmon_build_timer()` | Command duration | `⏱ 2s` |
| `gitmon_build_status()` | Exit status | `0` or `1` |

### Color Variables

Use predefined color variables for consistency:

```bash
# Primary colors
$GITMON_COLOR_PRIMARY      # Cyan
$GITMON_COLOR_SECONDARY    # Blue
$GITMON_COLOR_ACCENT       # Magenta

# Status colors
$GITMON_COLOR_SUCCESS      # Green
$GITMON_COLOR_WARNING      # Yellow
$GITMON_COLOR_ERROR        # Red

# Git colors
$GITMON_COLOR_GIT_CLEAN    # Green
$GITMON_COLOR_GIT_DIRTY    # Red
$GITMON_COLOR_GIT_STAGED   # Yellow
$GITMON_COLOR_GIT_BRANCH   # Cyan

# Reset
$GITMON_COLOR_RESET        # Reset all formatting
```

### Theme Example

```bash
#!/usr/bin/env zsh

# MyTheme for Gitmon CLI - A simple example theme

# Theme configuration
MYTHEME_SHOW_FULL_PATH="${MYTHEME_SHOW_FULL_PATH:-false}"

gitmon_theme_prompt() {
    local prompt=""

    # User info (only if SSH or different user)
    local user_info="$(gitmon_build_user_info)"
    if [[ -n "$user_info" ]]; then
        prompt+="${GITMON_COLOR_SUCCESS}$user_info${GITMON_COLOR_RESET} "
    fi

    # Directory
    prompt+="${GITMON_COLOR_PRIMARY}$(gitmon_build_directory)${GITMON_COLOR_RESET}"

    # Git info
    local git_info="$(gitmon_build_git_info)"
    if [[ -n "$git_info" ]]; then
        prompt+=" $git_info"
    fi

    # Gitmon character
    if [[ -n "$GITMON_CURRENT_GITMON" ]]; then
        prompt+=" ${GITMON_COLOR_ACCENT}$GITMON_CURRENT_GITMON${GITMON_COLOR_RESET}"
    fi

    # Final prompt character
    prompt+=" ${GITMON_COLOR_PRIMARY}$${GITMON_COLOR_RESET} "

    echo "$prompt"
}

gitmon_theme_setup() {
    gitmon_core_init
    echo "MyTheme loaded!"
}
```

### Testing Themes

```bash
# Load your theme
gitmon theme switch mytheme

# Test in different contexts
cd ~/                           # Home directory
cd /tmp                         # Non-git directory
cd /path/to/git/repo           # Git repository
git status                     # Check git integration

# Test prompt components
gitmon theme test
```

## 🎮 Adding Gitmon Characters

### ASCII Characters

Add files to `gitmons/ascii/` with one character per file:

```bash
# gitmons/ascii/arrow.txt
>

# gitmons/ascii/lambda.txt
λ

# gitmons/ascii/star.txt
★
```

### Emoji Characters

Add files to `gitmons/emoji/` with one emoji per file:

```bash
# gitmons/emoji/rocket.txt
🚀

# gitmons/emoji/gem.txt
💎

# gitmons/emoji/fire.txt
🔥
```

### Guidelines

- **One character per file**
- **Descriptive filenames**
- **Test in different terminals**
- **Consider color contrast**
- **Keep ASCII simple** (single character)

## 🐛 Bug Reports

### Before Reporting

1. **Search existing issues** for duplicates
2. **Test with minimal config** to isolate the problem
3. **Try different themes** to see if it's theme-specific

### Bug Report Template

```markdown
## Bug Description
Brief description of the issue

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: macOS 12.0 / Ubuntu 20.04 / Windows 11
- Shell: zsh 5.8 / bash 5.1
- Terminal: iTerm2 / gnome-terminal / Windows Terminal
- Gitmon CLI Version: 1.0.0
- Theme: shadrix / crystalix / custom

## Additional Context
- Configuration files
- Screenshots (if visual issue)
- Error messages
```

## ✨ Feature Requests

### Feature Request Template

```markdown
## Feature Description
Clear description of the proposed feature

## Use Case
Why is this feature useful? What problem does it solve?

## Proposed Implementation
Ideas for how this could be implemented

## Alternatives Considered
Other approaches you've thought about

## Examples
Screenshots, mockups, or examples from other tools
```

## 🔧 Code Contributions

### Code Style

- **Follow existing patterns** in the codebase
- **Use consistent indentation** (2 spaces)
- **Add comments** for complex logic
- **Use descriptive variable names**
- **Keep functions focused** (single responsibility)

### Shell Scripting Guidelines

```bash
# Good: Clear variable names
local git_branch="$(gitmon_git_branch)"
local user_info="$(gitmon_build_user_info)"

# Good: Proper error handling
if ! gitmon_is_git_repo; then
    return 1
fi

# Good: Consistent formatting
gitmon_my_function() {
    local param="$1"
    local result=""

    # Function logic here

    echo "$result"
}

# Good: Use existing utilities
local short_path="$(gitmon_path_shorten "$current_path" 30)"
```

### Testing Your Changes

1. **Test with both themes:**
   ```bash
   gitmon theme switch shadrix
   gitmon theme switch crystalix
   ```

2. **Test in different contexts:**
   - Clean git repository
   - Dirty git repository
   - Non-git directory
   - SSH session
   - Different terminal sizes

3. **Test performance:**
   ```bash
   time source ./gitmon-cli.zsh
   ```

4. **Test error conditions:**
   - Missing git binary
   - Corrupted git repository
   - Very long paths

### Commit Guidelines

Use conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (no logic changes)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(themes): add new minimal theme
fix(git): resolve branch detection issue
docs(readme): update installation instructions
style(core): improve code formatting
```

## 📚 Documentation

### Documentation Types

- **README.md**: Main project documentation
- **Code comments**: Inline documentation
- **Theme documentation**: Theme-specific guides
- **Wiki articles**: Detailed tutorials and guides

### Writing Guidelines

- **Clear and concise** language
- **Include examples** for complex concepts
- **Test all code examples**
- **Use screenshots** for visual features
- **Keep documentation up-to-date**

## 🚀 Pull Request Process

1. **Create feature branch** from `main`
2. **Make your changes** following the guidelines above
3. **Test thoroughly** in different environments
4. **Update documentation** if needed
5. **Create pull request** with clear description

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Theme addition

## Testing
- [ ] Tested with shadrix theme
- [ ] Tested with crystalix theme
- [ ] Tested in git repository
- [ ] Tested in non-git directory
- [ ] Tested performance impact

## Screenshots
Include screenshots for visual changes

## Additional Notes
Any additional information for reviewers
```

## 📋 Review Process

### For Contributors

- **Respond promptly** to review comments
- **Make requested changes** in additional commits
- **Keep discussions constructive** and focused on code

### For Reviewers

- **Be constructive** and helpful
- **Test the changes** if possible
- **Check for consistency** with existing code
- **Verify documentation** is updated

## 🏆 Recognition

Contributors will be recognized in:

- **README.md** contributors section
- **Release notes** for significant contributions
- **GitHub contributors** page

## ❓ Questions?

- **General questions**: Open a [Discussion](https://github.com/yourusername/gitmon-cli/discussions)
- **Bug reports**: Create an [Issue](https://github.com/yourusername/gitmon-cli/issues)
- **Feature requests**: Create an [Issue](https://github.com/yourusername/gitmon-cli/issues)

Thank you for contributing to Gitmon CLI! 🎮
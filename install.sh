#!/usr/bin/env bash

# Gitmon CLI Installation Script
# Cross-platform installer for Unix-like systems (macOS, Linux, WSL)

set -euo pipefail

# Constants
readonly GITMON_CLI_REPO="https://github.com/yourusername/gitmon-cli"
readonly GITMON_CLI_DIR="$HOME/.gitmon-cli"
readonly BACKUP_SUFFIX=".gitmon-backup-$(date +%Y%m%d_%H%M%S)"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_header() {
    echo -e "${CYAN}${BOLD}$1${NC}"
}

# Detect shell and configuration file
detect_shell() {
    local shell_name
    shell_name="$(basename "$SHELL")"

    case "$shell_name" in
        zsh)
            echo "zsh"
            ;;
        bash)
            echo "bash"
            ;;
        fish)
            echo "fish"
            ;;
        *)
            log_warning "Unsupported shell: $shell_name. Gitmon CLI is designed for zsh."
            echo "zsh"
            ;;
    esac
}

get_config_file() {
    local shell="$1"

    case "$shell" in
        zsh)
            if [[ -f "$HOME/.zshrc" ]]; then
                echo "$HOME/.zshrc"
            else
                echo "$HOME/.zshrc"
            fi
            ;;
        bash)
            if [[ -f "$HOME/.bashrc" ]]; then
                echo "$HOME/.bashrc"
            elif [[ -f "$HOME/.bash_profile" ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "$HOME/.zshrc"
            ;;
    esac
}

# Backup existing configuration
backup_config() {
    local config_file="$1"

    if [[ -f "$config_file" ]]; then
        local backup_file="${config_file}${BACKUP_SUFFIX}"
        log_info "Backing up existing configuration to $backup_file"
        cp "$config_file" "$backup_file"
        log_success "Configuration backed up successfully"
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check for required commands
    local required_commands=("git" "zsh")
    local missing_commands=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done

    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing_commands[*]}"
        log_error "Please install the missing commands and try again."
        exit 1
    fi

    log_success "Prerequisites check passed"
}

# Install Gitmon CLI
install_gitmon_cli() {
    log_info "Installing Gitmon CLI to $GITMON_CLI_DIR"

    # Remove existing installation if present
    if [[ -d "$GITMON_CLI_DIR" ]]; then
        log_warning "Existing Gitmon CLI installation found. Removing..."
        rm -rf "$GITMON_CLI_DIR"
    fi

    # Create installation directory
    mkdir -p "$GITMON_CLI_DIR"

    # If we're in a gitmon-cli directory already, copy files directly
    if [[ -f "./gitmon-cli.zsh" && -d "./lib" && -d "./themes" ]]; then
        log_info "Installing from local directory..."
        cp -r . "$GITMON_CLI_DIR/"

        # Remove planning directory and other non-essential files
        [[ -d "$GITMON_CLI_DIR/planning" ]] && rm -rf "$GITMON_CLI_DIR/planning"
        [[ -f "$GITMON_CLI_DIR/.git" ]] && rm -rf "$GITMON_CLI_DIR/.git"
    else
        # Clone from repository (when available)
        log_info "Cloning Gitmon CLI repository..."
        if git clone "$GITMON_CLI_REPO" "$GITMON_CLI_DIR" 2>/dev/null; then
            log_success "Repository cloned successfully"
            # Remove .git directory
            rm -rf "$GITMON_CLI_DIR/.git"
        else
            log_error "Failed to clone repository. Please check your internet connection."
            log_info "You can manually download Gitmon CLI from $GITMON_CLI_REPO"
            exit 1
        fi
    fi

    log_success "Gitmon CLI installed successfully"
}

# Configure shell integration
configure_shell() {
    local shell="$1"
    local config_file="$2"

    log_info "Configuring $shell integration in $config_file"

    # Create config file if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        mkdir -p "$(dirname "$config_file")"
        touch "$config_file"
    fi

    # Check if Gitmon CLI is already configured
    if grep -q "gitmon-cli" "$config_file" 2>/dev/null; then
        log_warning "Gitmon CLI appears to already be configured in $config_file"
        echo -n "Do you want to reconfigure? [y/N]: "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Skipping configuration"
            return
        fi

        # Remove existing configuration
        log_info "Removing existing Gitmon CLI configuration..."
        sed -i.tmp '/# Gitmon CLI/,/# End Gitmon CLI/d' "$config_file" 2>/dev/null || true
        rm -f "${config_file}.tmp" 2>/dev/null || true
    fi

    # Add Gitmon CLI configuration
    cat >> "$config_file" << 'EOF'

# Gitmon CLI
if [[ -f "$HOME/.gitmon-cli/gitmon-cli.zsh" ]]; then
    source "$HOME/.gitmon-cli/gitmon-cli.zsh"
fi
# End Gitmon CLI
EOF

    log_success "Shell configuration updated"
}

# Post-installation setup
post_install() {
    log_header "🎮 Gitmon CLI Installation Complete!"
    echo ""
    log_success "Gitmon CLI has been installed to: $GITMON_CLI_DIR"
    echo ""
    echo "To get started:"
    echo "  1. Restart your terminal or run: source $config_file"
    echo "  2. Your shell will now use the 'shadrix' theme by default"
    echo "  3. Try these commands:"
    echo "     • gitmon help           - Show help"
    echo "     • gitmon theme list     - List available themes"
    echo "     • gitmon theme switch   - Switch themes"
    echo ""
    echo "Available themes:"
    echo "  • shadrix   - Modern powerline-style theme"
    echo "  • crystalix - Minimalist theme with clean aesthetics"
    echo ""
    echo "To customize your theme, set GITMON_THEME in your shell config:"
    echo "  export GITMON_THEME=\"crystalix\""
    echo ""
    log_info "Enjoy your enhanced terminal experience!"
}

# Main installation function
main() {
    log_header "🎮 Welcome to Gitmon CLI Installer"
    echo ""

    # Detect shell and config file
    local detected_shell
    detected_shell="$(detect_shell)"
    local config_file
    config_file="$(get_config_file "$detected_shell")"

    log_info "Detected shell: $detected_shell"
    log_info "Configuration file: $config_file"
    echo ""

    # Ask for confirmation
    echo "This installer will:"
    echo "  • Install Gitmon CLI to $GITMON_CLI_DIR"
    echo "  • Backup your existing configuration (if any)"
    echo "  • Add Gitmon CLI to your $config_file"
    echo ""
    echo -n "Do you want to continue? [Y/n]: "
    read -r response

    if [[ "$response" =~ ^[Nn]$ ]]; then
        log_info "Installation cancelled by user"
        exit 0
    fi

    echo ""

    # Run installation steps
    check_prerequisites
    backup_config "$config_file"
    install_gitmon_cli
    configure_shell "$detected_shell" "$config_file"
    post_install
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Gitmon CLI Installer"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --version, -v  Show version information"
        echo ""
        echo "This script will install Gitmon CLI to ~/.gitmon-cli and configure"
        echo "your shell to use it automatically."
        exit 0
        ;;
    --version|-v)
        echo "Gitmon CLI Installer v1.0.0"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information."
        exit 1
        ;;
esac
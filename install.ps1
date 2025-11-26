# Gitmon CLI Installation Script for Windows PowerShell
# Installs and configures Gitmon CLI for PowerShell environments

param(
    [switch]$Help,
    [switch]$Version,
    [switch]$Force,
    [string]$InstallPath = "$env:USERPROFILE\.gitmon-cli"
)

# Script information
$SCRIPT_VERSION = "1.0.0"
$GITMON_REPO = "https://github.com/yourusername/gitmon-cli"

# Functions
function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [string]$Prefix = ""
    )

    if ($Prefix) {
        Write-Host "[$Prefix] " -ForegroundColor $Color -NoNewline
    }
    Write-Host $Message -ForegroundColor White
}

function Write-Info { param([string]$Message) Write-ColoredOutput $Message "Cyan" "INFO" }
function Write-Success { param([string]$Message) Write-ColoredOutput $Message "Green" "SUCCESS" }
function Write-Warning { param([string]$Message) Write-ColoredOutput $Message "Yellow" "WARNING" }
function Write-Error { param([string]$Message) Write-ColoredOutput $Message "Red" "ERROR" }
function Write-Header { param([string]$Message) Write-Host $Message -ForegroundColor "Magenta" -BackgroundColor "Black" }

function Show-Help {
    @"
Gitmon CLI Installer for Windows

USAGE:
    .\install.ps1 [OPTIONS]

OPTIONS:
    -Help           Show this help message
    -Version        Show version information
    -Force          Force reinstallation even if already installed
    -InstallPath    Custom installation path (default: $env:USERPROFILE\.gitmon-cli)

DESCRIPTION:
    This script installs Gitmon CLI for PowerShell environments.
    It will configure PowerShell to load Gitmon CLI automatically.

EXAMPLES:
    .\install.ps1                           # Standard installation
    .\install.ps1 -Force                    # Force reinstallation
    .\install.ps1 -InstallPath "C:\Tools"   # Custom install path

"@ | Write-Host
}

function Show-Version {
    Write-Host "Gitmon CLI Installer v$SCRIPT_VERSION" -ForegroundColor "Cyan"
    Write-Host "For Windows PowerShell environments" -ForegroundColor "Gray"
}

function Test-Prerequisites {
    Write-Info "Checking prerequisites..."

    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Error "PowerShell 5.0 or later is required. Current version: $($PSVersionTable.PSVersion)"
        return $false
    }

    # Check for Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Warning "Git is not installed or not in PATH. Some features may not work."
    }

    Write-Success "Prerequisites check passed"
    return $true
}

function Backup-Profile {
    $profilePath = $PROFILE.CurrentUserCurrentHost

    if (Test-Path $profilePath) {
        $backupPath = "${profilePath}.gitmon-backup-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Info "Backing up existing PowerShell profile to $backupPath"
        Copy-Item $profilePath $backupPath
        Write-Success "Profile backed up successfully"
    }
}

function Install-GitmonCli {
    Write-Info "Installing Gitmon CLI to $InstallPath"

    # Remove existing installation if present
    if (Test-Path $InstallPath) {
        if (-not $Force) {
            Write-Warning "Existing Gitmon CLI installation found at $InstallPath"
            $response = Read-Host "Do you want to remove it and continue? [Y/n]"
            if ($response -match '^[Nn]') {
                Write-Info "Installation cancelled by user"
                exit 0
            }
        }

        Write-Info "Removing existing installation..."
        Remove-Item $InstallPath -Recurse -Force
    }

    # Create installation directory
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null

    # Check if we're in a gitmon-cli directory
    if ((Test-Path ".\gitmon-cli.zsh") -and (Test-Path ".\lib") -and (Test-Path ".\themes")) {
        Write-Info "Installing from local directory..."
        Copy-Item -Path "." -Destination $InstallPath -Recurse -Force

        # Clean up non-essential files
        @("planning", ".git") | ForEach-Object {
            $path = Join-Path $InstallPath $_
            if (Test-Path $path) { Remove-Item $path -Recurse -Force }
        }
    }
    else {
        Write-Info "Cloning Gitmon CLI repository..."
        try {
            git clone $GITMON_REPO $InstallPath 2>$null
            Remove-Item (Join-Path $InstallPath ".git") -Recurse -Force -ErrorAction SilentlyContinue
            Write-Success "Repository cloned successfully"
        }
        catch {
            Write-Error "Failed to clone repository. Please check your internet connection."
            Write-Info "You can manually download Gitmon CLI from $GITMON_REPO"
            exit 1
        }
    }

    Write-Success "Gitmon CLI installed successfully"
}

function Configure-PowerShell {
    Write-Info "Configuring PowerShell integration"

    $profilePath = $PROFILE.CurrentUserCurrentHost
    $profileDir = Split-Path $profilePath

    # Create profile directory if it doesn't exist
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    # Create profile file if it doesn't exist
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    # Check if Gitmon CLI is already configured
    $profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue
    if ($profileContent -match "Gitmon CLI") {
        Write-Warning "Gitmon CLI appears to already be configured in $profilePath"
        $response = Read-Host "Do you want to reconfigure? [y/N]"
        if ($response -notmatch '^[Yy]') {
            Write-Info "Skipping configuration"
            return
        }

        # Remove existing configuration
        Write-Info "Removing existing Gitmon CLI configuration..."
        $newContent = $profileContent | Where-Object { $_ -notmatch "Gitmon CLI" }
        $newContent | Set-Content $profilePath
    }

    # Add Gitmon CLI configuration
    $gitmonConfig = @"

# Gitmon CLI for PowerShell
if (Test-Path "$InstallPath\gitmon-cli.ps1") {
    . "$InstallPath\gitmon-cli.ps1"
}
# End Gitmon CLI

"@

    Add-Content -Path $profilePath -Value $gitmonConfig
    Write-Success "PowerShell profile updated"
}

function New-PowerShellAdapter {
    # Create a PowerShell adapter for the zsh-based Gitmon CLI
    $adapterContent = @"
# Gitmon CLI PowerShell Adapter
# This script provides basic Gitmon CLI functionality for PowerShell

# Note: This is a basic adapter. Full functionality requires zsh.
Write-Host "🎮 Gitmon CLI (PowerShell Mode) - Limited functionality" -ForegroundColor Magenta
Write-Host "For full features, use zsh with Windows Subsystem for Linux (WSL)" -ForegroundColor Yellow

function gitmon {
    param([string]`$command, [string]`$subcommand, [string]`$arg)

    switch (`$command) {
        "help" {
            Write-Host "Gitmon CLI PowerShell Adapter" -ForegroundColor Cyan
            Write-Host "Available commands:" -ForegroundColor White
            Write-Host "  gitmon help     - Show this help" -ForegroundColor Gray
            Write-Host "  gitmon version  - Show version" -ForegroundColor Gray
            Write-Host "" -ForegroundColor Gray
            Write-Host "Note: For full theming and git integration, use zsh in WSL." -ForegroundColor Yellow
        }
        "version" {
            Write-Host "Gitmon CLI v1.0.0 (PowerShell Adapter)" -ForegroundColor Cyan
        }
        default {
            Write-Host "Unknown command: `$command" -ForegroundColor Red
            Write-Host "Run 'gitmon help' for available commands" -ForegroundColor Gray
        }
    }
}

# Basic git-aware prompt (simple version)
function prompt {
    `$path = (Get-Location).Path.Replace(`$HOME, "~")

    # Basic git status
    if (Get-Command git -ErrorAction SilentlyContinue) {
        `$gitBranch = git branch --show-current 2>`$null
        if (`$gitBranch) {
            `$gitStatus = git status --porcelain 2>`$null
            `$gitIndicator = if (`$gitStatus) { " ±" } else { " ✓" }
            Write-Host `$path -NoNewline -ForegroundColor Blue
            Write-Host " git:" -NoNewline -ForegroundColor Gray
            Write-Host `$gitBranch -NoNewline -ForegroundColor Green
            Write-Host `$gitIndicator -NoNewline -ForegroundColor Yellow
            Write-Host " 🎮" -NoNewline -ForegroundColor Magenta
            Write-Host " > " -NoNewline -ForegroundColor Cyan
            return " "
        }
    }

    Write-Host `$path -NoNewline -ForegroundColor Blue
    Write-Host " 🎮" -NoNewline -ForegroundColor Magenta
    Write-Host " > " -NoNewline -ForegroundColor Cyan
    return " "
}
"@

    $adapterPath = Join-Path $InstallPath "gitmon-cli.ps1"
    Set-Content -Path $adapterPath -Value $adapterContent
    Write-Success "PowerShell adapter created"
}

function Show-PostInstall {
    Write-Header "🎮 Gitmon CLI Installation Complete!"
    Write-Host ""
    Write-Success "Gitmon CLI has been installed to: $InstallPath"
    Write-Host ""
    Write-Host "To get started:" -ForegroundColor White
    Write-Host "  1. Restart PowerShell or reload your profile: . `$PROFILE" -ForegroundColor Gray
    Write-Host "  2. Try: gitmon help" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Note: This is a PowerShell adapter with basic functionality." -ForegroundColor Yellow
    Write-Host "For full Gitmon CLI features, consider using zsh in WSL:" -ForegroundColor Yellow
    Write-Host "  • Rich themes with powerline support" -ForegroundColor Gray
    Write-Host "  • Advanced git integration" -ForegroundColor Gray
    Write-Host "  • Dynamic gitmon characters" -ForegroundColor Gray
    Write-Host "  • Command timing and more" -ForegroundColor Gray
    Write-Host ""
    Write-Info "Enjoy your enhanced PowerShell experience!"
}

# Main execution
function Main {
    Write-Header "🎮 Welcome to Gitmon CLI Installer (Windows)"
    Write-Host ""

    Write-Info "Installation path: $InstallPath"
    Write-Host ""

    # Confirmation
    if (-not $Force) {
        Write-Host "This installer will:" -ForegroundColor White
        Write-Host "  • Install Gitmon CLI to $InstallPath" -ForegroundColor Gray
        Write-Host "  • Backup your existing PowerShell profile (if any)" -ForegroundColor Gray
        Write-Host "  • Add Gitmon CLI to your PowerShell profile" -ForegroundColor Gray
        Write-Host ""
        $response = Read-Host "Do you want to continue? [Y/n]"

        if ($response -match '^[Nn]') {
            Write-Info "Installation cancelled by user"
            exit 0
        }
        Write-Host ""
    }

    # Installation steps
    if (-not (Test-Prerequisites)) { exit 1 }
    Backup-Profile
    Install-GitmonCli
    New-PowerShellAdapter
    Configure-PowerShell
    Show-PostInstall
}

# Handle script arguments
if ($Help) {
    Show-Help
    exit 0
}

if ($Version) {
    Show-Version
    exit 0
}

# Run main installation
try {
    Main
}
catch {
    Write-Error "Installation failed: $_"
    exit 1
}
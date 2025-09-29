# Installation Guide - High-Efficiency Programmer System

## 🚀 Quick Start

The High-Efficiency Programmer System is designed to be self-contained and easy to install. Follow these steps to get up and running quickly.

## 📋 Prerequisites

### Required Tools
- **Bash** (4.0 or higher) - For running the system scripts
- **Git** (2.0 or higher) - For version control integration
- **curl** - For web requests and API calls
- **jq** - For JSON processing (used by metrics and tracking)

### Recommended Tools
- **Node.js** (14+ or LTS) - For JavaScript project analysis
- **Python 3** (3.7+) - For Python project analysis
- **Visual Studio Code** - Primary supported editor
- **Docker** - For containerized development workflows

### Platform Support
- ✅ **Linux** (Ubuntu, Debian, CentOS, Arch, etc.)
- ✅ **macOS** (10.14+)
- ✅ **Windows** (WSL2 recommended)
- ⚠️ **Windows Native** (Limited support, some features may not work)

## 📥 Installation Methods

### Method 1: Git Clone (Recommended)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/high-efficiency-programmer-system.git
   cd high-efficiency-programmer-system
   ```

2. **Make the main script executable:**
   ```bash
   chmod +x high-efficiency-programmer.sh
   chmod +x scripts/*.sh
   ```

3. **Run the interactive setup:**
   ```bash
   ./scripts/setup-reminders.sh init
   ```

4. **Start the system:**
   ```bash
   ./high-efficiency-programmer.sh start
   ```

### Method 2: Download ZIP

1. **Download the latest release:**
   - Go to the [releases page](https://github.com/yourusername/high-efficiency-programmer-system/releases)
   - Download the latest ZIP file
   - Extract to your desired location

2. **Make scripts executable:**
   ```bash
   cd high-efficiency-programmer-system
   chmod +x high-efficiency-programmer.sh
   chmod +x scripts/*.sh
   ```

3. **Continue with setup:**
   ```bash
   ./scripts/setup-reminders.sh init
   ```

### Method 3: Package Managers

#### Homebrew (macOS/Linux)
```bash
# Coming soon
brew install high-efficiency-programmer
```

#### npm (Cross-platform)
```bash
# Coming soon
npm install -g high-efficiency-programmer
```

## 🔧 Detailed Installation Steps

### Step 1: System Requirements Check

Run the requirements check to ensure your system has all necessary tools:

```bash
./scripts/setup-reminders.sh tools
```

If any required tools are missing, install them:

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install git curl jq nodejs npm python3 python3-pip
```

#### CentOS/RHEL/Fedora:
```bash
sudo yum install git curl jq nodejs npm python3 python3-pip
# or for newer versions:
sudo dnf install git curl jq nodejs npm python3 python3-pip
```

#### macOS (with Homebrew):
```bash
brew install git curl jq node python3
```

#### Arch Linux:
```bash
sudo pacman -S git curl jq nodejs npm python python-pip
```

### Step 2: Git Configuration

The system integrates with Git for productivity tracking. Configure Git if not already done:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Step 3: Interactive Setup

Run the comprehensive setup process:

```bash
./scripts/setup-reminders.sh init
```

This will guide you through:
- ✅ Tool verification
- ⚙️ Git configuration
- 👤 Developer profile creation
- 🔗 Shell integration (aliases)
- 📁 Directory structure setup

### Step 4: Verify Installation

Test the installation by running:

```bash
./high-efficiency-programmer.sh help
```

You should see the main help menu with all available commands.

## 📁 Directory Structure

After installation, your directory structure will look like this:

```
high-efficiency-programmer-system/
├── high-efficiency-programmer.sh    # Main entry point
├── scripts/                         # All system scripts
│   ├── ai-helper.sh
│   ├── auto-improvements.sh
│   ├── auto-review.sh
│   ├── create-dashboard.sh
│   ├── debug-assistant.sh
│   ├── evening-retrospective.sh
│   ├── focus-mode.sh
│   ├── morning-routine.sh
│   ├── personal-ai-assistant.sh
│   ├── productivity-metrics.sh
│   ├── project-setup.sh
│   ├── setup-reminders.sh
│   ├── tdd-ai-cycle.sh
│   └── time-tracker.sh
├── config/                          # Configuration files
│   └── developer-profile.md
├── planning/                        # Planning templates
│   ├── daily-template.md
│   └── weeks-2-4-plan.md
├── dashboard/                       # Dashboard files
│   └── index.html
├── docs/                           # Documentation
│   ├── installation.md (this file)
│   ├── daily-usage.md
│   └── troubleshooting.md
└── README.md                       # Project overview
```

## 🔧 Configuration Options

### Shell Integration

The setup process will add aliases to your shell configuration:

```bash
# Added to ~/.bashrc or ~/.zshrc
alias hep='./high-efficiency-programmer.sh'
alias hep-start='./high-efficiency-programmer.sh start'
alias hep-focus='./high-efficiency-programmer.sh focus'
alias hep-ai='./high-efficiency-programmer.sh ai'
```

### PATH Integration (Optional)

To use the system from anywhere, add it to your PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/high-efficiency-programmer-system"

# Then you can use:
high-efficiency-programmer.sh start
# or
hep start  # if aliases are installed
```

### Data Storage

The system stores data in `~/.hep-data/`:
- `time-tracking.json` - Time tracking data
- `focus-sessions.json` - Focus session history
- `productivity-metrics.json` - Productivity metrics
- `setup-status.json` - Setup completion status

## ✅ Post-Installation Verification

### Basic Functionality Test

Run these commands to verify everything works:

```bash
# Test main script
./high-efficiency-programmer.sh help

# Test morning routine
./high-efficiency-programmer.sh morning --quiet

# Test focus mode (short session)
./high-efficiency-programmer.sh focus 1

# Test AI assistant
./high-efficiency-programmer.sh ai "Hello, test message"

# Test dashboard generation
./scripts/create-dashboard.sh text
```

### Feature Test Checklist

- [ ] Main script executes without errors
- [ ] Morning routine runs successfully
- [ ] Focus mode starts and completes
- [ ] Time tracking functions work
- [ ] Dashboard generates properly
- [ ] Git integration detects repositories
- [ ] AI assistant responds to queries

## 🔄 Upgrading

### From Git Repository

```bash
cd high-efficiency-programmer-system
git pull origin main
chmod +x scripts/*.sh  # Ensure permissions are preserved
./scripts/setup-reminders.sh status  # Check if re-setup is needed
```

### Manual Upgrade

1. Download the new version
2. Back up your configuration: `cp -r config/ config-backup/`
3. Replace system files (keep config/ and data/)
4. Run setup check: `./scripts/setup-reminders.sh status`

## 🗑️ Uninstallation

If you need to remove the system:

```bash
# Remove data directory (optional, contains your tracking data)
rm -rf ~/.hep-data/

# Remove shell aliases (edit ~/.bashrc or ~/.zshrc manually)
# Remove the line: # High-Efficiency Programmer System aliases

# Remove the main directory
rm -rf /path/to/high-efficiency-programmer-system
```

## 🐛 Installation Troubleshooting

### Common Issues

#### "Permission denied" errors
```bash
chmod +x high-efficiency-programmer.sh
chmod +x scripts/*.sh
```

#### "jq: command not found"
Install jq using your package manager:
- Ubuntu/Debian: `sudo apt install jq`
- macOS: `brew install jq`
- CentOS: `sudo yum install jq`

#### Git not configured
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

#### "No such file or directory" for scripts
Ensure you're in the correct directory:
```bash
cd high-efficiency-programmer-system
ls -la scripts/  # Should show all .sh files
```

### Platform-Specific Issues

#### Windows WSL2
- Ensure WSL2 is properly installed
- Use Ubuntu or Debian distribution in WSL2
- Install Linux versions of required tools

#### macOS
- Install Xcode Command Line Tools: `xcode-select --install`
- Use Homebrew for package management
- Some tools may require different installation methods

#### Linux
- Ensure you have sudo access for package installation
- Some distributions may have different package names
- Check your shell (bash/zsh) configuration

### Getting Help

If you encounter issues not covered here:

1. Check the [troubleshooting guide](troubleshooting.md)
2. Review the [daily usage guide](daily-usage.md)
3. Open an issue on the GitHub repository
4. Join our community discussions

## 🎯 Next Steps

After successful installation:

1. **Read the [daily usage guide](daily-usage.md)**
2. **Complete your developer profile** in `config/developer-profile.md`
3. **Start your first morning routine:** `./high-efficiency-programmer.sh start`
4. **Try a focus session:** `./high-efficiency-programmer.sh focus`
5. **Explore the AI assistant:** `./high-efficiency-programmer.sh ai`

Welcome to your high-efficiency programming journey! 🚀
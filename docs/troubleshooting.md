# Troubleshooting Guide - High-Efficiency Programmer System

## 🔧 Quick Fixes

### Most Common Issues

#### 1. Permission Denied Errors
```bash
# Fix script permissions
chmod +x high-efficiency-programmer.sh
chmod +x scripts/*.sh

# If still having issues:
find . -name "*.sh" -exec chmod +x {} \;
```

#### 2. "jq: command not found"
```bash
# Ubuntu/Debian
sudo apt install jq

# CentOS/RHEL/Fedora
sudo yum install jq
# or for newer versions:
sudo dnf install jq

# macOS with Homebrew
brew install jq

# Check installation
jq --version
```

#### 3. Git Not Configured
```bash
# Configure Git globally
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify configuration
git config --global --list
```

#### 4. Scripts Don't Execute
```bash
# Check if you're in the right directory
pwd
ls -la high-efficiency-programmer.sh

# Run with bash explicitly if needed
bash high-efficiency-programmer.sh help
```

## 🐛 Detailed Troubleshooting

### Installation Issues

#### Problem: Setup Script Fails
**Symptoms:**
- Setup process stops unexpectedly
- Error messages during `./scripts/setup-reminders.sh init`

**Solutions:**
```bash
# Check system requirements
./scripts/setup-reminders.sh tools

# Run individual setup steps
./scripts/setup-reminders.sh git
./scripts/setup-reminders.sh profile
./scripts/setup-reminders.sh shell

# Check setup status
./scripts/setup-reminders.sh status
```

#### Problem: Missing Dependencies
**Symptoms:**
- Commands fail with "command not found"
- Features don't work properly

**Solutions:**
```bash
# Check which tools are missing
for tool in git curl jq node python3; do
    if command -v $tool >/dev/null 2>&1; then
        echo "✅ $tool is installed"
    else
        echo "❌ $tool is missing"
    fi
done

# Install missing tools based on your OS
# See installation.md for platform-specific instructions
```

### Runtime Issues

#### Problem: Focus Mode Won't Start
**Symptoms:**
- Timer doesn't display properly
- Session doesn't track correctly

**Solutions:**
```bash
# Test focus mode with short session
./scripts/focus-mode.sh focus 1

# Check if data directory exists
ls -la ~/.hep-data/

# Create data directory if missing
mkdir -p ~/.hep-data

# Test with verbose output
bash -x ./scripts/focus-mode.sh focus 5
```

#### Problem: Time Tracking Not Working
**Symptoms:**
- Sessions don't start/stop
- Data not saved
- Summary shows no data

**Solutions:**
```bash
# Check data file
cat ~/.hep-data/time-tracking.json

# Manually initialize if corrupted
echo '{"sessions": [], "projects": {}, "categories": {}}' > ~/.hep-data/time-tracking.json

# Test basic tracking
./scripts/time-tracker.sh start "test" "development" "testing tracking"
sleep 5
./scripts/time-tracker.sh stop
./scripts/time-tracker.sh status
```

#### Problem: Dashboard Doesn't Load
**Symptoms:**
- HTML dashboard is blank
- Browser shows errors
- No data displayed

**Solutions:**
```bash
# Generate fresh dashboard
./scripts/create-dashboard.sh both

# Check if data exists
ls -la ~/.hep-data/

# Test with text dashboard first
./scripts/create-dashboard.sh text

# Check browser console for JavaScript errors
# Open browser developer tools (F12)
```

#### Problem: AI Assistant Not Responding
**Symptoms:**
- AI commands hang
- No responses from assistant
- Error messages in AI interactions

**Solutions:**
```bash
# Test basic AI functionality
./scripts/ai-helper.sh help

# Check if context file is valid JSON
cat ~/.hep-data/ai-context.json | jq .

# Reinitialize AI data if needed
rm ~/.hep-data/ai-context.json
rm ~/.hep-data/ai-conversations.json
./scripts/personal-ai-assistant.sh context

# Test simple query
./scripts/ai-helper.sh analyze --help
```

### Git Integration Issues

#### Problem: Git Status Not Detected
**Symptoms:**
- Morning routine shows no Git repositories
- Productivity metrics show no commits

**Solutions:**
```bash
# Check if you're in a Git repository
git status

# If not in a repo, initialize one
git init
git add .
git commit -m "Initial commit"

# Check Git configuration
git config --list

# Test Git integration
./scripts/auto-review.sh changed
```

#### Problem: Code Review Fails
**Symptoms:**
- Auto-review shows no files
- Analysis doesn't run on code

**Solutions:**
```bash
# Check if there are changed files
git status
git diff --name-only HEAD~1

# Test with specific file
./scripts/auto-review.sh file path/to/your/file.js

# Check file permissions
ls -la path/to/your/file.js

# Run review with verbose output
bash -x ./scripts/auto-review.sh changed
```

### Data and Configuration Issues

#### Problem: Productivity Metrics Missing
**Symptoms:**
- Dashboard shows no data
- Metrics commands return empty results

**Solutions:**
```bash
# Check data directory
ls -la ~/.hep-data/

# Initialize metrics if needed
./scripts/productivity-metrics.sh record

# Check data file structure
cat ~/.hep-data/productivity-metrics.json | jq .

# Reset metrics if corrupted
rm ~/.hep-data/productivity-metrics.json
./scripts/productivity-metrics.sh record
```

#### Problem: Configuration Lost
**Symptoms:**
- Settings don't persist
- Profile data missing
- System asks for setup again

**Solutions:**
```bash
# Check setup status
./scripts/setup-reminders.sh status

# Verify config files
ls -la config/
cat config/developer-profile.md

# Re-run setup if needed
./scripts/setup-reminders.sh init

# Check data directory permissions
ls -la ~/.hep-data/
# Should show files owned by your user
```

## 💻 Platform-Specific Issues

### Linux Issues

#### Problem: Package Installation Fails
```bash
# Update package lists first
sudo apt update  # Ubuntu/Debian
sudo yum update   # CentOS/RHEL

# Try alternative installation methods
# For jq on older systems:
wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x jq-linux64
sudo mv jq-linux64 /usr/local/bin/jq
```

#### Problem: Shell Integration Issues
```bash
# Check which shell you're using
echo $SHELL

# For bash users
echo 'source ~/.bashrc' >> ~/.bash_profile

# For zsh users
echo 'source ~/.zshrc' >> ~/.zprofile

# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc
```

### macOS Issues

#### Problem: Command Line Tools Missing
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcode-select -p
```

#### Problem: Homebrew Not Working
```bash
# Install Homebrew if missing
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update Homebrew
brew update
brew doctor
```

### Windows (WSL2) Issues

#### Problem: WSL2 Not Working Properly
```bash
# Update WSL2
wsl --update

# Check WSL version
wsl --list --verbose

# Ensure using WSL2
wsl --set-version Ubuntu 2
```

#### Problem: File Permissions in WSL2
```bash
# Fix Windows-Linux file permission issues
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000,umask=22,fmask=111
```

## 🔍 Debugging Commands

### System Diagnostics
```bash
# Check overall system health
./scripts/debug-assistant.sh test

# Verify all components
./scripts/setup-reminders.sh status
./scripts/debug-assistant.sh status

# Check data integrity
for file in ~/.hep-data/*.json; do
    echo "Checking $file:"
    cat "$file" | jq . > /dev/null && echo "✅ Valid JSON" || echo "❌ Invalid JSON"
done
```

### Verbose Execution
```bash
# Run commands with debug output
bash -x ./high-efficiency-programmer.sh start
bash -x ./scripts/focus-mode.sh focus 5
bash -x ./scripts/time-tracker.sh start "test"
```

### Log Analysis
```bash
# Check system logs for errors (Linux)
sudo tail -f /var/log/syslog | grep -i error

# Check application logs
ls -la ~/.hep-data/
tail -f ~/.hep-data/*.log 2>/dev/null
```

## 📊 Performance Issues

### Problem: Slow Performance
**Symptoms:**
- Scripts take a long time to run
- Dashboard generation is slow
- System feels sluggish

**Solutions:**
```bash
# Check available memory
free -h

# Check disk space
df -h

# Clean up large data files
find ~/.hep-data -name "*.json" -exec du -h {} \; | sort -rh

# Reduce data retention if needed
# Edit scripts to limit historical data
```

### Problem: High CPU Usage
**Solutions:**
```bash
# Check running processes
top | grep bash

# Kill hanging processes if needed
pkill -f "high-efficiency-programmer"

# Restart with clean state
./high-efficiency-programmer.sh help
```

## 🔒 Security Issues

### Problem: Permission Errors
```bash
# Fix data directory permissions
chmod -R 755 ~/.hep-data
chown -R $(whoami):$(whoami) ~/.hep-data

# Fix script permissions
chmod +x scripts/*.sh
chmod +x high-efficiency-programmer.sh
```

### Problem: Git Credential Issues
```bash
# Check Git credential configuration
git config --list | grep credential

# Set up credential helper
git config --global credential.helper store
# or for better security:
git config --global credential.helper cache --timeout=3600
```

## 📞 Getting Additional Help

### Self-Help Resources
1. **Check the logs:** Look in `~/.hep-data/` for any log files
2. **Run diagnostics:** Use `./scripts/debug-assistant.sh test`
3. **Verify setup:** Run `./scripts/setup-reminders.sh status`
4. **Test components:** Try individual scripts to isolate issues

### Documentation
- [Installation Guide](installation.md) - Setup and requirements
- [Daily Usage Guide](daily-usage.md) - How to use features
- [README.md](../README.md) - Project overview

### Community Support
- **GitHub Issues**: Report bugs and request features
- **Discussions**: Ask questions and share tips
- **Wiki**: Community-maintained troubleshooting tips

### Creating a Bug Report

When reporting issues, include:

```bash
# System information
uname -a
echo $SHELL
git --version
jq --version

# HEP system status
./scripts/setup-reminders.sh status
ls -la ~/.hep-data/

# Error reproduction steps
# Include the exact commands that cause the issue
# Include the complete error output
```

### Recovery Commands

If all else fails, try a clean reset:

```bash
# Backup your configuration
cp -r config/ config-backup/
cp -r ~/.hep-data ~/.hep-data-backup

# Clean reset
rm -rf ~/.hep-data/
./scripts/setup-reminders.sh init

# Restore configuration if needed
cp -r config-backup/* config/
```

---

*Remember: Most issues can be resolved by ensuring all dependencies are installed and scripts have proper execution permissions. When in doubt, start with the basic fixes and work your way up to more complex solutions.*
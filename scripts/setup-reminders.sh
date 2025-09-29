#!/bin/bash

# Setup Reminders Script
# Initial setup and configuration reminders

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
DATA_DIR="$HOME/.hep-data"
SETUP_FILE="$DATA_DIR/setup-status.json"

# Create directories
mkdir -p "$CONFIG_DIR" "$DATA_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[SETUP] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

highlight() {
    echo -e "${PURPLE}$1${NC}"
}

reminder() {
    echo -e "${CYAN}💡 $1${NC}"
}

# Initialize setup status
init_setup_status() {
    if [ ! -f "$SETUP_FILE" ]; then
        cat > "$SETUP_FILE" << EOF
{
    "setup_completed": false,
    "steps_completed": {},
    "git_configured": false,
    "profile_created": false,
    "tools_verified": false,
    "first_run": true,
    "last_updated": "$(date -Iseconds)"
}
EOF
    fi
}

# Mark setup step as completed
mark_step_completed() {
    local step="$1"
    local updated_status=$(jq ".steps_completed[\"$step\"] = true | .last_updated = \"$(date -Iseconds)\"" "$SETUP_FILE")
    echo "$updated_status" > "$SETUP_FILE"
}

# Check if step is completed
is_step_completed() {
    local step="$1"
    jq -r ".steps_completed[\"$step\"] // false" "$SETUP_FILE" 2>/dev/null | grep -q "true"
}

# Welcome message and system overview
show_welcome() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║          🚀 High-Efficiency Programmer System Setup 🚀          ║"
    echo "║                                                                  ║"
    echo "║               Welcome to your productivity journey!              ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""

    if jq -r '.first_run' "$SETUP_FILE" | grep -q "true"; then
        echo "This appears to be your first time running the High-Efficiency Programmer System."
        echo "Let's get you set up for maximum productivity!"
    else
        echo "Welcome back! Let's make sure your setup is complete."
    fi

    echo ""
    sleep 2
}

# Check and verify development tools
verify_tools() {
    log "🔧 Verifying development tools..."

    local essential_tools=("git" "curl" "jq")
    local recommended_tools=("node" "python3" "code" "docker")
    local missing_essential=()
    local missing_recommended=()

    # Check essential tools
    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" > /dev/null 2>&1; then
            info "✅ $tool is installed"
        else
            missing_essential+=("$tool")
            error "❌ $tool is missing (REQUIRED)"
        fi
    done

    # Check recommended tools
    for tool in "${recommended_tools[@]}"; do
        if command -v "$tool" > /dev/null 2>&1; then
            info "✅ $tool is installed"
        else
            missing_recommended+=("$tool")
            warn "⚠️  $tool is not installed (RECOMMENDED)"
        fi
    done

    echo ""

    if [ ${#missing_essential[@]} -gt 0 ]; then
        error "Essential tools missing: ${missing_essential[*]}"
        echo ""
        echo "Please install the missing essential tools:"
        for tool in "${missing_essential[@]}"; do
            case "$tool" in
                "git")
                    echo "• Git: https://git-scm.com/downloads"
                    ;;
                "curl")
                    echo "• curl: Usually pre-installed, or use your package manager"
                    ;;
                "jq")
                    echo "• jq: https://stedolan.github.io/jq/download/"
                    ;;
            esac
        done
        echo ""
        return 1
    fi

    if [ ${#missing_recommended[@]} -gt 0 ]; then
        warn "Recommended tools missing: ${missing_recommended[*]}"
        echo ""
        echo "Consider installing these tools for enhanced functionality:"
        for tool in "${missing_recommended[@]}"; do
            case "$tool" in
                "node")
                    echo "• Node.js: https://nodejs.org/en/download/"
                    ;;
                "python3")
                    echo "• Python 3: https://www.python.org/downloads/"
                    ;;
                "code")
                    echo "• Visual Studio Code: https://code.visualstudio.com/download"
                    ;;
                "docker")
                    echo "• Docker: https://docs.docker.com/get-docker/"
                    ;;
            esac
        done
        echo ""
    fi

    mark_step_completed "tools_verified"
    return 0
}

# Configure Git if needed
setup_git() {
    log "🔧 Configuring Git..."

    local git_user=$(git config --global user.name 2>/dev/null || echo "")
    local git_email=$(git config --global user.email 2>/dev/null || echo "")

    if [ -z "$git_user" ] || [ -z "$git_email" ]; then
        highlight "Git configuration needed"
        echo ""

        if [ -z "$git_user" ]; then
            echo -n "Enter your full name: "
            read -r user_name
            git config --global user.name "$user_name"
            info "Set Git user name: $user_name"
        fi

        if [ -z "$git_email" ]; then
            echo -n "Enter your email address: "
            read -r user_email
            git config --global user.email "$user_email"
            info "Set Git email: $user_email"
        fi

        # Set some useful Git defaults
        git config --global init.defaultBranch main
        git config --global pull.rebase true
        git config --global core.autocrlf input

        info "✅ Git configuration complete"
    else
        info "✅ Git already configured ($git_user <$git_email>)"
    fi

    # Update setup status
    local updated_status=$(jq '.git_configured = true' "$SETUP_FILE")
    echo "$updated_status" > "$SETUP_FILE"

    mark_step_completed "git_setup"
}

# Create developer profile
create_developer_profile() {
    local profile_file="$CONFIG_DIR/developer-profile.md"

    if [ -f "$profile_file" ]; then
        info "✅ Developer profile already exists"
        return
    fi

    log "📝 Creating your developer profile..."

    echo ""
    echo "Let's create your developer profile to personalize the system:"
    echo ""

    echo -n "Preferred programming languages (comma-separated): "
    read -r languages

    echo -n "Current role/title: "
    read -r role

    echo -n "Years of experience: "
    read -r experience

    echo -n "Favorite development tools: "
    read -r tools

    echo -n "Primary focus areas (e.g., web dev, mobile, ML): "
    read -r focus_areas

    cat > "$profile_file" << EOF
# Developer Profile

**Created:** $(date)

## Personal Information

- **Name:** $(git config --global user.name 2>/dev/null || echo "Not set")
- **Email:** $(git config --global user.email 2>/dev/null || echo "Not set")
- **Role:** $role
- **Experience:** $experience years

## Technical Preferences

### Programming Languages
$languages

### Development Tools
$tools

### Focus Areas
$focus_areas

## Productivity Settings

### Work Preferences
- **Pomodoro Duration:** 25 minutes (default)
- **Break Duration:** 5 minutes (default)
- **Deep Work Duration:** 90 minutes (default)

### AI Assistant Preferences
- **Verbosity:** Balanced
- **Code Style:** Clean and readable
- **Testing Preference:** TDD when possible

## Goals

### Short-term Goals (Next Month)
- [ ] Complete system setup
- [ ] Establish daily routine
- [ ]

### Long-term Goals (Next Quarter)
- [ ] Improve productivity metrics
- [ ] Learn new technology/skill
- [ ]

## Notes

Add any additional preferences or notes here...

---
*Generated by High-Efficiency Programmer System*
EOF

    info "✅ Developer profile created: $profile_file"
    echo ""
    reminder "You can edit this profile anytime to update your preferences"

    # Update setup status
    local updated_status=$(jq '.profile_created = true' "$SETUP_FILE")
    echo "$updated_status" > "$SETUP_FILE"

    mark_step_completed "profile_created"
}

# Set up shell aliases and shortcuts
setup_shell_shortcuts() {
    log "⚡ Setting up shell shortcuts..."

    local shell_rc=""
    if [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    else
        warn "Unknown shell, skipping alias setup"
        return
    fi

    local hep_dir="$(dirname "$SCRIPT_DIR")"
    local aliases_added=false

    # Check if aliases already exist
    if ! grep -q "# High-Efficiency Programmer System" "$shell_rc" 2>/dev/null; then
        echo "" >> "$shell_rc"
        echo "# High-Efficiency Programmer System aliases" >> "$shell_rc"
        echo "alias hep='$hep_dir/high-efficiency-programmer.sh'" >> "$shell_rc"
        echo "alias hep-start='$hep_dir/high-efficiency-programmer.sh start'" >> "$shell_rc"
        echo "alias hep-focus='$hep_dir/high-efficiency-programmer.sh focus'" >> "$shell_rc"
        echo "alias hep-review='$hep_dir/high-efficiency-programmer.sh review'" >> "$shell_rc"
        echo "alias hep-ai='$hep_dir/high-efficiency-programmer.sh ai'" >> "$shell_rc"
        echo "alias hep-track='$hep_dir/high-efficiency-programmer.sh track'" >> "$shell_rc"

        info "✅ Added shell aliases to $shell_rc"
        aliases_added=true
    else
        info "✅ Shell aliases already configured"
    fi

    if $aliases_added; then
        echo ""
        highlight "🎉 Shell shortcuts added!"
        echo "After restarting your shell (or running 'source $shell_rc'), you can use:"
        echo "  • hep            - Main command"
        echo "  • hep-start      - Start morning routine"
        echo "  • hep-focus      - Enter focus mode"
        echo "  • hep-review     - Code review"
        echo "  • hep-ai         - AI assistant"
        echo "  • hep-track      - Time tracking"
    fi

    mark_step_completed "shell_setup"
}

# Create initial project structure
setup_initial_structure() {
    log "📁 Setting up project structure..."

    local base_dir="$(dirname "$SCRIPT_DIR")"

    # Ensure all directories exist
    mkdir -p "$base_dir"/{scripts,config,planning,dashboard,docs}

    # Create initial planning template if it doesn't exist
    if [ ! -f "$base_dir/planning/daily-template.md" ]; then
        cat > "$base_dir/planning/daily-template.md" << EOF
# Daily Plan - {{DATE}} ({{DAY}})

## 🎯 Priority Goals
- [ ]
- [ ]
- [ ]

## 📋 Tasks

### High Priority
- [ ]

### Medium Priority
- [ ]

### Low Priority
- [ ]

## 🧠 Learning Goals
- [ ]

## 📝 Notes
<!-- Add notes throughout the day -->

## 🔄 Retrospective (End of Day)

### What went well:


### What could be improved:


### Tomorrow's focus:


---
*Template created by High-Efficiency Programmer System*
EOF
        info "✅ Created daily planning template"
    fi

    # Create weeks planning template
    if [ ! -f "$base_dir/planning/weeks-2-4-plan.md" ]; then
        cat > "$base_dir/planning/weeks-2-4-plan.md" << EOF
# Weeks 2-4 Development Plan

## Overview
This plan outlines your development journey for weeks 2-4 of using the High-Efficiency Programmer System.

## Week 2: Establishing Routines

### Goals
- [ ] Complete morning routine daily
- [ ] Use focus mode for at least 2 sessions daily
- [ ] Track time consistently
- [ ] Perform evening retrospectives

### Focus Areas
- Building consistent habits
- Understanding personal productivity patterns
- Optimizing workflow

## Week 3: Advanced Features

### Goals
- [ ] Use AI assistant for code review
- [ ] Implement TDD cycle in projects
- [ ] Set and track productivity goals
- [ ] Use auto-improvements scanner

### Focus Areas
- Code quality improvement
- AI-assisted development
- Productivity measurement

## Week 4: Optimization & Mastery

### Goals
- [ ] Customize system to personal preferences
- [ ] Achieve productivity targets
- [ ] Contribute improvements to the system
- [ ] Plan next month's objectives

### Focus Areas
- System customization
- Performance optimization
- Knowledge sharing

## Weekly Milestones

### Week 2 Milestone
- [ ] 7-day streak of morning routines
- [ ] 20+ focus sessions completed
- [ ] Daily retrospectives completed

### Week 3 Milestone
- [ ] Code quality improvements implemented
- [ ] AI assistant used for major features
- [ ] Productivity metrics showing improvement

### Week 4 Milestone
- [ ] Personal productivity system optimized
- [ ] Measurable improvement in output quality
- [ ] System customizations implemented

## Success Metrics
- Consistent daily usage
- Improved code quality scores
- Increased focus time
- Better work-life balance
- Higher job satisfaction

---
*Generated by High-Efficiency Programmer System*
EOF
        info "✅ Created weeks 2-4 planning template"
    fi

    mark_step_completed "structure_setup")
}

# Show completion summary
show_completion_summary() {
    highlight "🎉 Setup Complete!"
    echo ""

    local setup_status=$(cat "$SETUP_FILE")
    local completed_steps=$(echo "$setup_status" | jq -r '.steps_completed | keys[]')

    echo "Completed setup steps:"
    while IFS= read -r step; do
        info "✅ $step"
    done <<< "$completed_steps"

    echo ""
    highlight "🚀 You're ready to boost your productivity!"
    echo ""

    echo "Next steps:"
    echo "1. Run the morning routine: ./high-efficiency-programmer.sh start"
    echo "2. Try a focus session: ./high-efficiency-programmer.sh focus"
    echo "3. Ask the AI assistant: ./high-efficiency-programmer.sh ai"
    echo "4. Review the documentation in the docs/ folder"
    echo ""

    reminder "Consider bookmarking the main script or adding it to your PATH"
    reminder "Check out the planning templates in the planning/ directory"

    # Mark setup as completed
    local updated_status=$(jq '.setup_completed = true | .first_run = false' "$SETUP_FILE")
    echo "$updated_status" > "$SETUP_FILE"
}

# Check setup status
check_setup_status() {
    init_setup_status

    local setup_status=$(cat "$SETUP_FILE")
    local is_completed=$(echo "$setup_status" | jq -r '.setup_completed')

    highlight "📊 Setup Status"
    echo ""

    if [ "$is_completed" = "true" ]; then
        info "✅ Setup is complete!"
    else
        warn "⚠️  Setup is incomplete"
    fi

    echo ""
    echo "Step Status:"

    local steps=("tools_verified" "git_setup" "profile_created" "shell_setup" "structure_setup")
    for step in "${steps[@]}"; do
        if is_step_completed "$step"; then
            info "✅ $step"
        else
            warn "❌ $step"
        fi
    done

    echo ""
    if [ "$is_completed" != "true" ]; then
        echo "Run './scripts/setup-reminders.sh init' to complete setup"
    fi
}

# Interactive setup process
interactive_setup() {
    init_setup_status
    show_welcome

    echo ""
    echo "Let's complete your setup step by step:"
    echo ""

    # Step 1: Verify tools
    if ! is_step_completed "tools_verified"; then
        highlight "Step 1: Verifying development tools"
        if ! verify_tools; then
            error "Please install required tools and run setup again"
            exit 1
        fi
        echo ""
    fi

    # Step 2: Configure Git
    if ! is_step_completed "git_setup"; then
        highlight "Step 2: Git configuration"
        setup_git
        echo ""
    fi

    # Step 3: Create profile
    if ! is_step_completed "profile_created"; then
        highlight "Step 3: Developer profile"
        create_developer_profile
        echo ""
    fi

    # Step 4: Shell shortcuts
    if ! is_step_completed "shell_setup"; then
        highlight "Step 4: Shell shortcuts"
        setup_shell_shortcuts
        echo ""
    fi

    # Step 5: Project structure
    if ! is_step_completed "structure_setup"; then
        highlight "Step 5: Project structure"
        setup_initial_structure
        echo ""
    fi

    show_completion_summary
}

# Main function
main() {
    case "${1:-status}" in
        "init"|"i")
            interactive_setup
            ;;

        "status"|"s")
            check_setup_status
            ;;

        "tools"|"t")
            verify_tools
            ;;

        "git"|"g")
            setup_git
            ;;

        "profile"|"p")
            create_developer_profile
            ;;

        "shell"|"sh")
            setup_shell_shortcuts
            ;;

        "structure"|"str")
            setup_initial_structure
            ;;

        "help"|"-h"|"--help")
            echo "Setup Reminders - Initial setup and configuration"
            echo ""
            echo "Usage: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  init, i        Interactive setup process"
            echo "  status, s      Check setup status (default)"
            echo "  tools, t       Verify development tools"
            echo "  git, g         Configure Git"
            echo "  profile, p     Create developer profile"
            echo "  shell, sh      Setup shell shortcuts"
            echo "  structure, str Setup project structure"
            echo "  help           Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 init        # Complete interactive setup"
            echo "  $0 status      # Check current setup status"
            ;;

        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

# Initialize setup status file
init_setup_status

main "$@"
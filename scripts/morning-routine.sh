#!/bin/bash

# Morning Routine Script
# Sets up the perfect development environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
PLANNING_DIR="$(dirname "$SCRIPT_DIR")/planning"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[MORNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

highlight() {
    echo -e "${PURPLE}$1${NC}"
}

# Welcome message
show_welcome() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║         🌅 High-Efficiency Programmer Morning Routine 🌅         ║"
    echo "║                                                                  ║"
    echo "║              Starting your optimized development day             ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    sleep 2
}

# System health check
check_system_health() {
    log "🔍 Performing system health check..."

    # Check essential tools
    local tools=("git" "node" "python3" "code" "docker")
    local missing_tools=()

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        else
            info "✅ $tool is available"
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Missing tools: ${missing_tools[*]}${NC}"
    fi

    # Check disk space
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 80 ]; then
        echo -e "${YELLOW}⚠️  Disk usage high: ${disk_usage}%${NC}"
    else
        info "✅ Disk usage: ${disk_usage}%"
    fi

    # Check memory
    if command -v free &> /dev/null; then
        local mem_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
        info "💾 Memory usage: ${mem_usage}%"
    fi

    echo ""
}

# Git status overview
check_git_status() {
    log "📊 Checking Git repositories..."

    # Find git repositories in common locations
    local git_dirs=("." "~/projects" "~/dev" "~/code")
    local found_repos=()

    for dir in "${git_dirs[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r -d '' repo; do
                found_repos+=("$repo")
            done < <(find "$dir" -maxdepth 2 -name ".git" -type d -print0 2>/dev/null | head -20)
        fi
    done

    if [ ${#found_repos[@]} -gt 0 ]; then
        info "Found ${#found_repos[@]} Git repositories:"

        for repo in "${found_repos[@]:0:5}"; do
            local repo_dir=$(dirname "$repo")
            local repo_name=$(basename "$repo_dir")

            cd "$repo_dir"
            local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
            local status=$(git status --porcelain 2>/dev/null | wc -l)
            local ahead=$(git rev-list --count HEAD@{upstream}..HEAD 2>/dev/null || echo "0")

            local status_icon="✅"
            if [ "$status" -gt 0 ]; then
                status_icon="🔄"
            fi
            if [ "$ahead" -gt 0 ]; then
                status_icon="⬆️"
            fi

            info "  $status_icon $repo_name ($branch) - $status changes, $ahead ahead"
        done

        cd "$SCRIPT_DIR"
    else
        info "No Git repositories found in common locations"
    fi

    echo ""
}

# Create/update daily plan
setup_daily_plan() {
    log "📅 Setting up today's plan..."

    local today=$(date +%Y-%m-%d)
    local daily_file="$PLANNING_DIR/daily-$today.md"

    # Create daily plan from template if it doesn't exist
    if [ ! -f "$daily_file" ]; then
        if [ -f "$PLANNING_DIR/daily-template.md" ]; then
            cp "$PLANNING_DIR/daily-template.md" "$daily_file"
            # Replace placeholders
            sed -i "s/{{DATE}}/$today/g" "$daily_file" 2>/dev/null || true
            sed -i "s/{{DAY}}/$(date +%A)/g" "$daily_file" 2>/dev/null || true
            info "Created daily plan: $daily_file"
        else
            # Create basic daily plan
            cat > "$daily_file" << EOF
# Daily Plan - $today ($(date +%A))

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

EOF
            info "Created basic daily plan: $daily_file"
        fi
    else
        info "Daily plan already exists: $daily_file"
    fi

    # Show plan summary
    if [ -f "$daily_file" ]; then
        highlight "📋 Today's priorities:"
        grep "^- \[ \]" "$daily_file" | head -5 | sed 's/^- \[ \]/  •/'
    fi

    echo ""
}

# Environment optimization
optimize_environment() {
    log "⚡ Optimizing development environment..."

    # Clear caches if they're large
    if [ -d "$HOME/.npm" ]; then
        local npm_size=$(du -sh "$HOME/.npm" 2>/dev/null | cut -f1)
        info "NPM cache size: $npm_size"
    fi

    # Check for large log files
    local large_logs=$(find /tmp -name "*.log" -size +100M 2>/dev/null | head -3)
    if [ -n "$large_logs" ]; then
        echo -e "${YELLOW}Large log files found in /tmp${NC}"
    fi

    # Set up shell environment
    export EDITOR=${EDITOR:-code}
    export PAGER=${PAGER:-less}

    # Optimize git
    if git config --global --get user.name >/dev/null 2>&1; then
        git config --global pull.rebase true 2>/dev/null || true
        git config --global init.defaultBranch main 2>/dev/null || true
        info "✅ Git configuration optimized"
    fi

    echo ""
}

# Development server check
check_dev_servers() {
    log "🌐 Checking development servers..."

    # Common development ports
    local ports=(3000 3001 8000 8080 5000 4200 9000)
    local active_servers=()

    for port in "${ports[@]}"; do
        if netstat -ln 2>/dev/null | grep ":$port " >/dev/null; then
            active_servers+=("$port")
        fi
    done

    if [ ${#active_servers[@]} -gt 0 ]; then
        info "🟢 Active servers on ports: ${active_servers[*]}"
    else
        info "No development servers detected"
    fi

    echo ""
}

# Productivity tips
show_productivity_tips() {
    local tips=(
        "💡 Use Pomodoro Technique: 25min focused work + 5min break"
        "🎯 Limit WIP: Focus on 1-3 tasks at a time"
        "📝 Write commit messages that explain WHY, not just what"
        "🧪 Write tests first to clarify requirements"
        "🔄 Take breaks every hour to maintain focus"
        "📚 Learn one small thing each day"
        "🧹 Refactor code when you touch it"
        "💬 Rubber duck debugging: explain problems out loud"
        "⏰ Time-box tasks to avoid perfectionism"
        "🎨 Keep your workspace clean and organized"
    )

    local random_tip=${tips[$RANDOM % ${#tips[@]}]}
    highlight "💡 Today's productivity tip:"
    echo "   $random_tip"
    echo ""
}

# Start time tracking
start_time_tracking() {
    log "⏱️  Starting time tracking..."

    local tracking_file="/tmp/dev-session-$(date +%Y%m%d).log"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Development session started" >> "$tracking_file"

    info "Time tracking logged to: $tracking_file"
    echo ""
}

# Weather and motivation
show_motivation() {
    local motivational_quotes=(
        "🚀 \"Code is like humor. When you have to explain it, it's bad.\" - Cory House"
        "💪 \"The best time to plant a tree was 20 years ago. The second best time is now.\""
        "🎯 \"Make it work, make it right, make it fast.\" - Kent Beck"
        "🧠 \"Debugging is twice as hard as writing code. Write simple code.\" - Brian Kernighan"
        "⚡ \"Premature optimization is the root of all evil.\" - Donald Knuth"
        "🔧 \"Any fool can write code that a computer can understand. Good programmers write code that humans can understand.\" - Martin Fowler"
        "🌟 \"The only way to learn a new programming language is by writing programs in it.\" - Dennis Ritchie"
        "🎨 \"Simplicity is the ultimate sophistication.\" - Leonardo da Vinci"
    )

    local quote=${motivational_quotes[$RANDOM % ${#motivational_quotes[@]}]}
    highlight "🌟 Daily motivation:"
    echo "   $quote"
    echo ""
}

# Summary and next steps
show_summary() {
    log "✅ Morning routine completed!"
    echo ""
    highlight "🎯 You're ready to start coding! Next steps:"
    echo "   1. Review your daily plan"
    echo "   2. Start with your highest priority task"
    echo "   3. Use 'focus' command for concentrated work sessions"
    echo "   4. Take regular breaks and track your progress"
    echo ""
    echo "Available commands:"
    echo "   • ./high-efficiency-programmer.sh focus    - Start focus session"
    echo "   • ./high-efficiency-programmer.sh ai       - Ask AI assistant"
    echo "   • ./high-efficiency-programmer.sh track    - Track time"
    echo "   • ./high-efficiency-programmer.sh review   - Review code"
    echo ""
}

# Main execution
main() {
    show_welcome
    check_system_health
    check_git_status
    setup_daily_plan
    optimize_environment
    check_dev_servers
    show_productivity_tips
    start_time_tracking
    show_motivation
    show_summary
}

# Handle options
case "${1:-}" in
    "--quiet"|"-q")
        # Quiet mode - minimal output
        log "🌅 Morning routine (quiet mode)"
        setup_daily_plan
        start_time_tracking
        log "✅ Ready to code!"
        ;;
    "--check-only")
        # Only perform checks
        check_system_health
        check_git_status
        check_dev_servers
        ;;
    *)
        main
        ;;
esac
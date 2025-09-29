#!/bin/bash

# High-Efficiency Programmer System
# Master script for AI-powered development workflow
# Version: 1.0

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
PLANNING_DIR="$SCRIPT_DIR/planning"
DASHBOARD_DIR="$SCRIPT_DIR/dashboard"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Check dependencies
check_dependencies() {
    local deps=("git" "curl" "jq" "node" "python3")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error "Required dependency '$dep' is not installed"
            exit 1
        fi
    done
}

# Show help
show_help() {
    echo "High-Efficiency Programmer System v1.0"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start                    Start the complete morning routine"
    echo "  morning                  Run morning setup routine"
    echo "  focus [duration]         Enter focus mode (default: 25 minutes)"
    echo "  break                    Take a structured break"
    echo "  review                   Run code review with AI"
    echo "  debug                    Start AI-assisted debugging session"
    echo "  test                     Run TDD cycle with AI"
    echo "  track                    Track time and productivity"
    echo "  metrics                  Show productivity metrics"
    echo "  evening                  Run evening retrospective"
    echo "  dashboard                Open productivity dashboard"
    echo "  setup [project]          Setup new project structure"
    echo "  ai [query]               Ask AI assistant"
    echo "  improve                  Analyze and suggest improvements"
    echo "  reminders                Check setup reminders"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -v, --verbose           Verbose output"
    echo "  --config [file]         Use custom config file"
    echo ""
    echo "Examples:"
    echo "  $0 start                # Complete morning routine"
    echo "  $0 focus 45             # 45-minute focus session"
    echo "  $0 ai 'explain this function'"
    echo "  $0 setup myproject      # Setup new project"
}

# Main command dispatcher
main() {
    # Check if no arguments provided
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    # Parse global options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            --config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            start)
                log "🚀 Starting High-Efficiency Programmer System..."
                check_dependencies
                "$SCRIPTS_DIR/morning-routine.sh"
                "$SCRIPTS_DIR/create-dashboard.sh"
                log "✅ System started successfully!"
                exit 0
                ;;
            morning)
                "$SCRIPTS_DIR/morning-routine.sh"
                exit 0
                ;;
            focus)
                DURATION=${2:-25}
                "$SCRIPTS_DIR/focus-mode.sh" "$DURATION"
                exit 0
                ;;
            break)
                "$SCRIPTS_DIR/focus-mode.sh" break
                exit 0
                ;;
            review)
                "$SCRIPTS_DIR/auto-review.sh"
                exit 0
                ;;
            debug)
                "$SCRIPTS_DIR/debug-assistant.sh" "${@:2}"
                exit 0
                ;;
            test)
                "$SCRIPTS_DIR/tdd-ai-cycle.sh"
                exit 0
                ;;
            track)
                "$SCRIPTS_DIR/time-tracker.sh"
                exit 0
                ;;
            metrics)
                "$SCRIPTS_DIR/productivity-metrics.sh"
                exit 0
                ;;
            evening)
                "$SCRIPTS_DIR/evening-retrospective.sh"
                exit 0
                ;;
            dashboard)
                "$SCRIPTS_DIR/create-dashboard.sh"
                if command -v xdg-open &> /dev/null; then
                    xdg-open "$DASHBOARD_DIR/index.html"
                elif command -v open &> /dev/null; then
                    open "$DASHBOARD_DIR/index.html"
                else
                    log "Dashboard created at: $DASHBOARD_DIR/index.html"
                fi
                exit 0
                ;;
            setup)
                PROJECT_NAME=${2:-""}
                "$SCRIPTS_DIR/project-setup.sh" "$PROJECT_NAME"
                exit 0
                ;;
            ai)
                shift
                "$SCRIPTS_DIR/ai-helper.sh" "$@"
                exit 0
                ;;
            improve)
                "$SCRIPTS_DIR/auto-improvements.sh"
                exit 0
                ;;
            reminders)
                "$SCRIPTS_DIR/setup-reminders.sh"
                exit 0
                ;;
            *)
                error "Unknown command: $1"
                echo ""
                show_help
                exit 1
                ;;
        esac
    done
}

# Initialize if needed
if [ ! -f "$CONFIG_DIR/developer-profile.md" ]; then
    warn "Configuration not found. Running initial setup..."
    "$SCRIPTS_DIR/setup-reminders.sh" --init
fi

# Run main function
main "$@"
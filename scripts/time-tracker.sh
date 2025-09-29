#!/bin/bash

# Time Tracker Script
# Advanced time tracking with productivity analysis

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
DATA_DIR="$HOME/.hep-data"
TRACKING_FILE="$DATA_DIR/time-tracking.json"
SESSION_FILE="/tmp/hep-current-session.json"

# Create data directory
mkdir -p "$DATA_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[TRACKER] $1${NC}"
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

# Initialize tracking file if it doesn't exist
init_tracking() {
    if [ ! -f "$TRACKING_FILE" ]; then
        echo '{"sessions": [], "projects": {}, "categories": {}}' > "$TRACKING_FILE"
        log "Initialized time tracking database"
    fi
}

# Get current timestamp
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Get Unix timestamp
unix_timestamp() {
    date +%s
}

# Start tracking session
start_session() {
    local project="${1:-general}"
    local category="${2:-development}"
    local description="${3:-Coding session}"

    # Check if session already active
    if [ -f "$SESSION_FILE" ]; then
        local active_project=$(jq -r '.project' "$SESSION_FILE" 2>/dev/null || echo "")
        if [ -n "$active_project" ]; then
            warn "Session already active for project: $active_project"
            echo "Use 'stop' to end current session first"
            return 1
        fi
    fi

    # Create session data
    local session_data=$(cat << EOF
{
    "project": "$project",
    "category": "$category",
    "description": "$description",
    "start_time": "$(timestamp)",
    "start_timestamp": $(unix_timestamp),
    "status": "active"
}
EOF
    )

    echo "$session_data" > "$SESSION_FILE"
    log "🚀 Started tracking: $project ($category)"
    info "Description: $description"
    info "Started at: $(timestamp)"
}

# Stop tracking session
stop_session() {
    if [ ! -f "$SESSION_FILE" ]; then
        error "No active session found"
        return 1
    fi

    local session_data=$(cat "$SESSION_FILE")
    local project=$(echo "$session_data" | jq -r '.project')
    local category=$(echo "$session_data" | jq -r '.category')
    local description=$(echo "$session_data" | jq -r '.description')
    local start_time=$(echo "$session_data" | jq -r '.start_time')
    local start_timestamp=$(echo "$session_data" | jq -r '.start_timestamp')
    local end_timestamp=$(unix_timestamp)
    local duration=$((end_timestamp - start_timestamp))

    # Create completed session
    local completed_session=$(cat << EOF
{
    "id": "$(date +%s)_$(echo $project | tr '[:upper:]' '[:lower:]' | tr ' ' '_')",
    "project": "$project",
    "category": "$category",
    "description": "$description",
    "start_time": "$start_time",
    "end_time": "$(timestamp)",
    "start_timestamp": $start_timestamp,
    "end_timestamp": $end_timestamp,
    "duration": $duration,
    "duration_human": "$(format_duration $duration)",
    "date": "$(date +%Y-%m-%d)"
}
EOF
    )

    # Add to tracking file
    init_tracking
    local updated_data=$(jq ".sessions += [$completed_session]" "$TRACKING_FILE")
    echo "$updated_data" > "$TRACKING_FILE"

    # Remove session file
    rm -f "$SESSION_FILE"

    log "⏹️  Stopped tracking: $project"
    info "Duration: $(format_duration $duration)"
    info "Total sessions today: $(get_today_sessions_count)"
}

# Pause/Resume session
pause_session() {
    if [ ! -f "$SESSION_FILE" ]; then
        error "No active session found"
        return 1
    fi

    local session_data=$(cat "$SESSION_FILE")
    local status=$(echo "$session_data" | jq -r '.status')
    local project=$(echo "$session_data" | jq -r '.project')

    if [ "$status" = "active" ]; then
        # Pause
        local updated_session=$(echo "$session_data" | jq '.status = "paused" | .pause_time = "'$(timestamp)'" | .pause_timestamp = '$(unix_timestamp)'')
        echo "$updated_session" > "$SESSION_FILE"
        log "⏸️  Paused session: $project"
    elif [ "$status" = "paused" ]; then
        # Resume
        local pause_timestamp=$(echo "$session_data" | jq -r '.pause_timestamp')
        local pause_duration=$(($(unix_timestamp) - pause_timestamp))
        local updated_session=$(echo "$session_data" | jq '.status = "active" | del(.pause_time, .pause_timestamp) | .total_pause_time = (.total_pause_time // 0) + '$pause_duration'')
        echo "$updated_session" > "$SESSION_FILE"
        log "▶️  Resumed session: $project"
    fi
}

# Format duration in human readable format
format_duration() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))

    if [ $hours -gt 0 ]; then
        printf "%dh %02dm %02ds" $hours $minutes $seconds
    elif [ $minutes -gt 0 ]; then
        printf "%dm %02ds" $minutes $seconds
    else
        printf "%ds" $seconds
    fi
}

# Show current session status
show_status() {
    if [ ! -f "$SESSION_FILE" ]; then
        info "No active session"
        return 0
    fi

    local session_data=$(cat "$SESSION_FILE")
    local project=$(echo "$session_data" | jq -r '.project')
    local category=$(echo "$session_data" | jq -r '.category')
    local description=$(echo "$session_data" | jq -r '.description')
    local start_time=$(echo "$session_data" | jq -r '.start_time')
    local start_timestamp=$(echo "$session_data" | jq -r '.start_timestamp')
    local status=$(echo "$session_data" | jq -r '.status')
    local current_duration=$(($(unix_timestamp) - start_timestamp))

    echo -e "${PURPLE}📊 Current Session Status${NC}"
    echo "Project: $project"
    echo "Category: $category"
    echo "Description: $description"
    echo "Started: $start_time"
    echo "Status: $status"
    echo "Duration: $(format_duration $current_duration)"

    if [ "$status" = "paused" ]; then
        local pause_time=$(echo "$session_data" | jq -r '.pause_time')
        echo "Paused since: $pause_time"
    fi
}

# Get today's sessions count
get_today_sessions_count() {
    if [ ! -f "$TRACKING_FILE" ]; then
        echo "0"
        return
    fi

    local today=$(date +%Y-%m-%d)
    jq -r ".sessions | map(select(.date == \"$today\")) | length" "$TRACKING_FILE" 2>/dev/null || echo "0"
}

# Get today's total time
get_today_total() {
    if [ ! -f "$TRACKING_FILE" ]; then
        echo "0"
        return
    fi

    local today=$(date +%Y-%m-%d)
    jq -r ".sessions | map(select(.date == \"$today\")) | map(.duration) | add // 0" "$TRACKING_FILE" 2>/dev/null || echo "0"
}

# Show daily summary
show_daily_summary() {
    local date="${1:-$(date +%Y-%m-%d)}"

    if [ ! -f "$TRACKING_FILE" ]; then
        info "No tracking data found"
        return
    fi

    echo -e "${PURPLE}📈 Daily Summary - $date${NC}"

    # Get sessions for the date
    local sessions=$(jq -r ".sessions | map(select(.date == \"$date\"))" "$TRACKING_FILE")
    local session_count=$(echo "$sessions" | jq 'length')

    if [ "$session_count" = "0" ]; then
        info "No sessions recorded for $date"
        return
    fi

    # Total time
    local total_duration=$(echo "$sessions" | jq 'map(.duration) | add')
    echo "Total time: $(format_duration $total_duration)"
    echo "Sessions: $session_count"
    echo ""

    # By project
    echo "By Project:"
    echo "$sessions" | jq -r 'group_by(.project) | .[] | "\(.length) sessions - \(.[0].project): \((map(.duration) | add) / 60 | floor)m"' | sort -nr

    echo ""

    # By category
    echo "By Category:"
    echo "$sessions" | jq -r 'group_by(.category) | .[] | "\(.length) sessions - \(.[0].category): \((map(.duration) | add) / 60 | floor)m"' | sort -nr
}

# Show weekly summary
show_weekly_summary() {
    if [ ! -f "$TRACKING_FILE" ]; then
        info "No tracking data found"
        return
    fi

    echo -e "${PURPLE}📊 Weekly Summary${NC}"

    # Get last 7 days
    local dates=()
    for i in {6..0}; do
        dates+=($(date -d "$i days ago" +%Y-%m-%d))
    done

    echo "Date       Sessions  Duration"
    echo "--------------------------------"

    local total_week_duration=0
    for date in "${dates[@]}"; do
        local sessions=$(jq -r ".sessions | map(select(.date == \"$date\"))" "$TRACKING_FILE")
        local session_count=$(echo "$sessions" | jq 'length')
        local day_duration=$(echo "$sessions" | jq 'map(.duration) | add // 0')
        total_week_duration=$((total_week_duration + day_duration))

        printf "%-10s %8d  %s\n" "$date" "$session_count" "$(format_duration $day_duration)"
    done

    echo "--------------------------------"
    printf "%-10s %8s  %s\n" "TOTAL" "-" "$(format_duration $total_week_duration)"
}

# Export data
export_data() {
    local format="${1:-json}"
    local output_file="${2:-time-tracking-export-$(date +%Y%m%d).json}"

    if [ ! -f "$TRACKING_FILE" ]; then
        error "No tracking data found"
        return 1
    fi

    case "$format" in
        "json")
            cp "$TRACKING_FILE" "$output_file"
            log "Exported data to: $output_file"
            ;;
        "csv")
            local csv_file="${output_file%.json}.csv"
            echo "Date,Project,Category,Description,Duration_Minutes,Start_Time,End_Time" > "$csv_file"
            jq -r '.sessions[] | [.date, .project, .category, .description, (.duration/60|floor), .start_time, .end_time] | @csv' "$TRACKING_FILE" >> "$csv_file"
            log "Exported CSV to: $csv_file"
            ;;
        *)
            error "Unsupported format: $format (supported: json, csv)"
            return 1
            ;;
    esac
}

# Main menu
show_menu() {
    echo -e "${PURPLE}⏱️  Time Tracker Menu${NC}"
    echo ""
    echo "1. Start session"
    echo "2. Stop session"
    echo "3. Pause/Resume"
    echo "4. Show status"
    echo "5. Daily summary"
    echo "6. Weekly summary"
    echo "7. Export data"
    echo "8. Exit"
    echo ""
    echo -n "Choose option (1-8): "
}

# Interactive mode
interactive_mode() {
    while true; do
        show_menu
        read -r choice

        case $choice in
            1)
                echo -n "Project name: "
                read -r project
                echo -n "Category (development/meeting/learning/break): "
                read -r category
                echo -n "Description: "
                read -r description
                start_session "$project" "$category" "$description"
                ;;
            2)
                stop_session
                ;;
            3)
                pause_session
                ;;
            4)
                show_status
                ;;
            5)
                echo -n "Date (YYYY-MM-DD, or press Enter for today): "
                read -r date
                show_daily_summary "$date"
                ;;
            6)
                show_weekly_summary
                ;;
            7)
                echo -n "Format (json/csv): "
                read -r format
                export_data "$format"
                ;;
            8)
                log "Goodbye! 👋"
                exit 0
                ;;
            *)
                error "Invalid choice"
                ;;
        esac
        echo ""
        echo "Press Enter to continue..."
        read -r
        clear
    done
}

# Main function
main() {
    init_tracking

    case "${1:-menu}" in
        "start"|"s")
            start_session "$2" "$3" "$4"
            ;;
        "stop")
            stop_session
            ;;
        "pause"|"p")
            pause_session
            ;;
        "status"|"st")
            show_status
            ;;
        "today"|"t")
            show_daily_summary
            ;;
        "week"|"w")
            show_weekly_summary
            ;;
        "export"|"e")
            export_data "$2" "$3"
            ;;
        "menu"|"m")
            interactive_mode
            ;;
        "help"|"-h"|"--help")
            echo "Time Tracker - Advanced productivity tracking"
            echo ""
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  start [project] [category] [description]  Start tracking session"
            echo "  stop                                      Stop current session"
            echo "  pause, p                                  Pause/resume session"
            echo "  status, st                                Show current status"
            echo "  today, t                                  Show today's summary"
            echo "  week, w                                   Show weekly summary"
            echo "  export [format] [file]                    Export data (json/csv)"
            echo "  menu, m                                   Interactive menu"
            echo "  help                                      Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 start myproject development 'Working on API'"
            echo "  $0 pause"
            echo "  $0 export csv my-data.csv"
            ;;
        *)
            show_status
            echo ""
            echo "Use '$0 help' for available commands or '$0 menu' for interactive mode"
            ;;
    esac
}

main "$@"
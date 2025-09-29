#!/bin/bash

# Productivity Metrics Script
# Comprehensive productivity tracking and analysis

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
DATA_DIR="$HOME/.hep-data"
METRICS_FILE="$DATA_DIR/productivity-metrics.json"
TIME_TRACKING_FILE="$DATA_DIR/time-tracking.json"

# Create data directory
mkdir -p "$DATA_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[METRICS] $1${NC}"
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

metric() {
    echo -e "${CYAN}$1${NC}"
}

# Initialize metrics file
init_metrics() {
    if [ ! -f "$METRICS_FILE" ]; then
        cat > "$METRICS_FILE" << EOF
{
    "daily_metrics": {},
    "weekly_summaries": {},
    "goals": {},
    "achievements": [],
    "last_updated": "$(date -Iseconds)"
}
EOF
        log "Initialized productivity metrics database"
    fi
}

# Record daily metrics
record_daily_metrics() {
    local date="${1:-$(date +%Y-%m-%d)}"

    init_metrics

    log "📊 Recording metrics for $date"

    # Get git activity
    local git_commits=0
    local git_lines_added=0
    local git_lines_removed=0

    if git rev-parse --git-dir > /dev/null 2>&1; then
        git_commits=$(git log --oneline --since="$date 00:00" --until="$date 23:59" --author="$(git config user.email)" 2>/dev/null | wc -l)

        local git_stats=$(git diff --stat --since="$date 00:00" --until="$date 23:59" 2>/dev/null | tail -1 || echo "")
        if [[ "$git_stats" =~ ([0-9]+)\ insertions.*([0-9]+)\ deletions ]]; then
            git_lines_added=${BASH_REMATCH[1]:-0}
            git_lines_removed=${BASH_REMATCH[2]:-0}
        fi
    fi

    # Get time tracking data
    local total_work_time=0
    local sessions_count=0
    local focus_sessions=0

    if [ -f "$TIME_TRACKING_FILE" ]; then
        local today_sessions=$(jq -r ".sessions | map(select(.date == \"$date\"))" "$TIME_TRACKING_FILE" 2>/dev/null || echo "[]")
        sessions_count=$(echo "$today_sessions" | jq 'length' 2>/dev/null || echo "0")
        total_work_time=$(echo "$today_sessions" | jq 'map(.duration // 0) | add // 0' 2>/dev/null || echo "0")
        focus_sessions=$(echo "$today_sessions" | jq 'map(select(.category == "focus")) | length' 2>/dev/null || echo "0")
    fi

    # Calculate productivity score (0-100)
    local productivity_score=0

    # Base score components
    if [ "$git_commits" -gt 0 ]; then
        productivity_score=$((productivity_score + 20))
    fi

    if [ "$sessions_count" -gt 0 ]; then
        productivity_score=$((productivity_score + 15))
    fi

    if [ "$focus_sessions" -gt 0 ]; then
        productivity_score=$((productivity_score + 25))
    fi

    # Time-based scoring
    local hours_worked=$((total_work_time / 3600))
    if [ "$hours_worked" -ge 4 ]; then
        productivity_score=$((productivity_score + 20))
    elif [ "$hours_worked" -ge 2 ]; then
        productivity_score=$((productivity_score + 10))
    fi

    # Code contribution scoring
    if [ "$git_lines_added" -gt 100 ]; then
        productivity_score=$((productivity_score + 20))
    elif [ "$git_lines_added" -gt 50 ]; then
        productivity_score=$((productivity_score + 10))
    fi

    # Cap at 100
    if [ "$productivity_score" -gt 100 ]; then
        productivity_score=100
    fi

    # Create daily metrics object
    local daily_metrics=$(cat << EOF
{
    "date": "$date",
    "git_commits": $git_commits,
    "git_lines_added": $git_lines_added,
    "git_lines_removed": $git_lines_removed,
    "total_work_time": $total_work_time,
    "sessions_count": $sessions_count,
    "focus_sessions": $focus_sessions,
    "productivity_score": $productivity_score,
    "recorded_at": "$(date -Iseconds)"
}
EOF
    )

    # Update metrics file
    local updated_metrics=$(jq ".daily_metrics[\"$date\"] = $daily_metrics | .last_updated = \"$(date -Iseconds)\"" "$METRICS_FILE")
    echo "$updated_metrics" > "$METRICS_FILE"

    info "✅ Metrics recorded for $date"
    info "   Productivity Score: $productivity_score/100"
    info "   Commits: $git_commits"
    info "   Work Sessions: $sessions_count"
    info "   Total Time: $(format_duration $total_work_time)"
}

# Format duration
format_duration() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))

    if [ $hours -gt 0 ]; then
        printf "%dh %02dm" $hours $minutes
    elif [ $minutes -gt 0 ]; then
        printf "%dm" $minutes
    else
        printf "%ds" $total_seconds
    fi
}

# Show daily dashboard
show_daily_dashboard() {
    local date="${1:-$(date +%Y-%m-%d)}"

    init_metrics

    highlight "📊 Daily Productivity Dashboard - $date"
    echo ""

    # Get metrics for the date
    local daily_data=$(jq -r ".daily_metrics[\"$date\"] // empty" "$METRICS_FILE" 2>/dev/null)

    if [ -z "$daily_data" ]; then
        warn "No metrics recorded for $date"
        echo "Run 'record' command to capture today's metrics"
        return
    fi

    # Extract data
    local productivity_score=$(echo "$daily_data" | jq -r '.productivity_score // 0')
    local git_commits=$(echo "$daily_data" | jq -r '.git_commits // 0')
    local git_lines_added=$(echo "$daily_data" | jq -r '.git_lines_added // 0')
    local git_lines_removed=$(echo "$daily_data" | jq -r '.git_lines_removed // 0')
    local total_work_time=$(echo "$daily_data" | jq -r '.total_work_time // 0')
    local sessions_count=$(echo "$daily_data" | jq -r '.sessions_count // 0')
    local focus_sessions=$(echo "$daily_data" | jq -r '.focus_sessions // 0')

    # Productivity score visualization
    local score_bar=""
    local filled_blocks=$((productivity_score / 5))
    for ((i=0; i<20; i++)); do
        if [ $i -lt $filled_blocks ]; then
            score_bar+="█"
        else
            score_bar+="░"
        fi
    done

    # Color the score based on value
    local score_color="${RED}"
    if [ "$productivity_score" -ge 80 ]; then
        score_color="${GREEN}"
    elif [ "$productivity_score" -ge 60 ]; then
        score_color="${YELLOW}"
    fi

    echo -e "${score_color}Productivity Score: $productivity_score/100${NC}"
    echo -e "${score_color}$score_bar${NC}"
    echo ""

    # Metrics display
    metric "📈 Key Metrics:"
    echo "  Git Commits: $git_commits"
    echo "  Lines Added: +$git_lines_added"
    echo "  Lines Removed: -$git_lines_removed"
    echo "  Work Sessions: $sessions_count"
    echo "  Focus Sessions: $focus_sessions"
    echo "  Total Work Time: $(format_duration $total_work_time)"
    echo ""

    # Goals progress (if any)
    local goals=$(jq -r '.goals // {}' "$METRICS_FILE" 2>/dev/null)
    if [ "$goals" != "{}" ]; then
        metric "🎯 Goals Progress:"
        echo "$goals" | jq -r 'to_entries[] | "  \(.key): \(.value.current)/\(.value.target) (\(.value.description))"'
        echo ""
    fi

    # Recent achievements
    local recent_achievements=$(jq -r ".achievements | map(select(.date == \"$date\")) | .[]?" "$METRICS_FILE" 2>/dev/null)
    if [ -n "$recent_achievements" ]; then
        metric "🏆 Today's Achievements:"
        echo "$recent_achievements" | jq -r '.description'
        echo ""
    fi
}

# Show weekly summary
show_weekly_summary() {
    init_metrics

    highlight "📈 Weekly Productivity Summary"
    echo ""

    # Get last 7 days
    local dates=()
    local total_score=0
    local total_commits=0
    local total_work_time=0
    local total_sessions=0
    local days_with_data=0

    for i in {6..0}; do
        local date=$(date -d "$i days ago" +%Y-%m-%d)
        dates+=("$date")

        local daily_data=$(jq -r ".daily_metrics[\"$date\"] // empty" "$METRICS_FILE" 2>/dev/null)

        if [ -n "$daily_data" ]; then
            local score=$(echo "$daily_data" | jq -r '.productivity_score // 0')
            local commits=$(echo "$daily_data" | jq -r '.git_commits // 0')
            local work_time=$(echo "$daily_data" | jq -r '.total_work_time // 0')
            local sessions=$(echo "$daily_data" | jq -r '.sessions_count // 0')

            total_score=$((total_score + score))
            total_commits=$((total_commits + commits))
            total_work_time=$((total_work_time + work_time))
            total_sessions=$((total_sessions + sessions))
            days_with_data=$((days_with_data + 1))
        fi
    done

    # Calculate averages
    local avg_score=0
    if [ "$days_with_data" -gt 0 ]; then
        avg_score=$((total_score / days_with_data))
    fi

    metric "📊 Week Overview:"
    echo "  Average Productivity: $avg_score/100"
    echo "  Total Commits: $total_commits"
    echo "  Total Work Time: $(format_duration $total_work_time)"
    echo "  Total Sessions: $total_sessions"
    echo "  Active Days: $days_with_data/7"
    echo ""

    # Daily breakdown
    metric "📅 Daily Breakdown:"
    printf "%-12s %s %s %s %s\n" "Date" "Score" "Commits" "Time" "Sessions"
    echo "--------------------------------------------------------"

    for date in "${dates[@]}"; do
        local daily_data=$(jq -r ".daily_metrics[\"$date\"] // empty" "$METRICS_FILE" 2>/dev/null)

        if [ -n "$daily_data" ]; then
            local score=$(echo "$daily_data" | jq -r '.productivity_score // 0')
            local commits=$(echo "$daily_data" | jq -r '.git_commits // 0')
            local work_time=$(echo "$daily_data" | jq -r '.total_work_time // 0')
            local sessions=$(echo "$daily_data" | jq -r '.sessions_count // 0')

            printf "%-12s %5d %7d %8s %8d\n" "$date" "$score" "$commits" "$(format_duration $work_time)" "$sessions"
        else
            printf "%-12s %5s %7s %8s %8s\n" "$date" "-" "-" "-" "-"
        fi
    done
}

# Set productivity goals
set_goal() {
    local goal_type="$1"
    local target="$2"
    local description="$3"

    init_metrics

    if [ -z "$goal_type" ] || [ -z "$target" ]; then
        error "Usage: set_goal <type> <target> [description]"
        return 1
    fi

    log "🎯 Setting goal: $goal_type = $target"

    local goal_data=$(cat << EOF
{
    "target": $target,
    "current": 0,
    "description": "${description:-$goal_type goal}",
    "created_at": "$(date -Iseconds)"
}
EOF
    )

    local updated_metrics=$(jq ".goals[\"$goal_type\"] = $goal_data" "$METRICS_FILE")
    echo "$updated_metrics" > "$METRICS_FILE"

    info "✅ Goal set successfully"
}

# Add achievement
add_achievement() {
    local description="$1"
    local date="${2:-$(date +%Y-%m-%d)}"

    init_metrics

    if [ -z "$description" ]; then
        error "Usage: add_achievement <description> [date]"
        return 1
    fi

    log "🏆 Adding achievement: $description"

    local achievement_data=$(cat << EOF
{
    "description": "$description",
    "date": "$date",
    "created_at": "$(date -Iseconds)"
}
EOF
    )

    local updated_metrics=$(jq ".achievements += [$achievement_data]" "$METRICS_FILE")
    echo "$updated_metrics" > "$METRICS_FILE"

    info "✅ Achievement added successfully"
}

# Generate productivity report
generate_report() {
    local output_file="productivity-report-$(date +%Y%m%d).md"

    init_metrics

    log "📄 Generating productivity report: $output_file"

    cat > "$output_file" << EOF
# Productivity Report

**Generated:** $(date)
**Period:** Last 30 days

## Summary

EOF

    # Add weekly summary
    show_weekly_summary >> "$output_file"

    cat >> "$output_file" << EOF

## Goals Progress

EOF

    local goals=$(jq -r '.goals // {}' "$METRICS_FILE" 2>/dev/null)
    if [ "$goals" != "{}" ]; then
        echo "$goals" | jq -r 'to_entries[] | "- **\(.key):** \(.value.current)/\(.value.target) - \(.value.description)"' >> "$output_file"
    else
        echo "No goals set." >> "$output_file"
    fi

    cat >> "$output_file" << EOF

## Recent Achievements

EOF

    local recent_achievements=$(jq -r '.achievements | sort_by(.date) | reverse | .[:10]' "$METRICS_FILE" 2>/dev/null)
    if [ "$recent_achievements" != "null" ] && [ "$recent_achievements" != "[]" ]; then
        echo "$recent_achievements" | jq -r '.[] | "- **\(.date):** \(.description)"' >> "$output_file"
    else
        echo "No achievements recorded." >> "$output_file"
    fi

    cat >> "$output_file" << EOF

---
*Generated by High-Efficiency Programmer System*
EOF

    info "Report saved to: $output_file"
}

# Main function
main() {
    case "${1:-dashboard}" in
        "record"|"r")
            record_daily_metrics "$2"
            ;;

        "dashboard"|"d")
            show_daily_dashboard "$2"
            ;;

        "week"|"w")
            show_weekly_summary
            ;;

        "goal"|"g")
            if [ -z "$2" ] || [ -z "$3" ]; then
                error "Usage: $0 goal <type> <target> [description]"
                exit 1
            fi
            set_goal "$2" "$3" "$4"
            ;;

        "achieve"|"a")
            if [ -z "$2" ]; then
                error "Usage: $0 achieve <description> [date]"
                exit 1
            fi
            add_achievement "$2" "$3"
            ;;

        "report"|"rep")
            generate_report
            ;;

        "help"|"-h"|"--help")
            echo "Productivity Metrics - Comprehensive tracking and analysis"
            echo ""
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  record, r [date]             Record metrics for date (default: today)"
            echo "  dashboard, d [date]          Show daily dashboard (default: today)"
            echo "  week, w                      Show weekly summary"
            echo "  goal, g <type> <target> [desc] Set productivity goal"
            echo "  achieve, a <desc> [date]     Add achievement"
            echo "  report, rep                  Generate productivity report"
            echo "  help                         Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 record                    # Record today's metrics"
            echo "  $0 dashboard                 # Show today's dashboard"
            echo "  $0 goal commits 5 'Daily commit goal'"
            echo "  $0 achieve 'Completed feature X'"
            echo "  $0 report                    # Generate report"
            ;;

        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

main "$@"
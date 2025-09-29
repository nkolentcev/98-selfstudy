#!/bin/bash

# Evening Retrospective Script
# End-of-day reflection and planning

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
PLANNING_DIR="$(dirname "$SCRIPT_DIR")/planning"
DATA_DIR="$HOME/.hep-data"
RETROSPECTIVES_DIR="$DATA_DIR/retrospectives"

# Create directories
mkdir -p "$DATA_DIR" "$RETROSPECTIVES_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[RETROSPECTIVE] $1${NC}"
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

reflect() {
    echo -e "${CYAN}$1${NC}"
}

# Show evening banner
show_evening_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║           🌅 Evening Retrospective & Reflection 🌅              ║"
    echo "║                                                                  ║"
    echo "║              Reviewing your development journey today            ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    sleep 2
}

# Collect daily metrics
collect_daily_metrics() {
    local today=$(date +%Y-%m-%d)

    log "📊 Collecting today's metrics..."

    # Git activity
    local git_commits=0
    local git_files_changed=0
    local git_lines_added=0
    local git_lines_removed=0

    if git rev-parse --git-dir > /dev/null 2>&1; then
        git_commits=$(git log --oneline --since="$today 00:00" --until="$today 23:59" --author="$(git config user.email)" 2>/dev/null | wc -l)

        local git_stats=$(git diff --stat --since="$today 00:00" --until="$today 23:59" 2>/dev/null | tail -1 || echo "")
        if [[ "$git_stats" =~ ([0-9]+)\ files?\ changed,\ ([0-9]+)\ insertions.*([0-9]+)\ deletions ]]; then
            git_files_changed=${BASH_REMATCH[1]:-0}
            git_lines_added=${BASH_REMATCH[2]:-0}
            git_lines_removed=${BASH_REMATCH[3]:-0}
        fi
    fi

    # Time tracking data
    local time_tracking_file="$DATA_DIR/time-tracking.json"
    local total_work_time=0
    local sessions_count=0
    local focus_sessions=0

    if [ -f "$time_tracking_file" ]; then
        local today_sessions=$(jq -r ".sessions | map(select(.date == \"$today\"))" "$time_tracking_file" 2>/dev/null || echo "[]")
        sessions_count=$(echo "$today_sessions" | jq 'length' 2>/dev/null || echo "0")
        total_work_time=$(echo "$today_sessions" | jq 'map(.duration // 0) | add // 0' 2>/dev/null || echo "0")
        focus_sessions=$(echo "$today_sessions" | jq 'map(select(.category == "focus")) | length' 2>/dev/null || echo "0")
    fi

    # Focus sessions
    local focus_log="$DATA_DIR/focus-sessions.json"
    local focus_work_time=0
    local pomodoro_sessions=0

    if [ -f "$focus_log" ]; then
        local focus_today=$(jq -r ".sessions | map(select(.date == \"$today\" and (.type == \"work\" or .type == \"custom_focus\" or .type == \"deep_work\")))" "$focus_log" 2>/dev/null || echo "[]")
        focus_work_time=$(echo "$focus_today" | jq 'map(.duration_minutes // 0) | add // 0' 2>/dev/null || echo "0")
        pomodoro_sessions=$(echo "$focus_today" | jq 'length' 2>/dev/null || echo "0")
    fi

    # Display metrics
    echo ""
    highlight "📈 Today's Metrics Summary"
    echo ""
    echo "🔧 Development Activity:"
    echo "  • Git commits: $git_commits"
    echo "  • Files changed: $git_files_changed"
    echo "  • Lines added: +$git_lines_added"
    echo "  • Lines removed: -$git_lines_removed"
    echo ""
    echo "⏱️  Time & Focus:"
    echo "  • Work sessions: $sessions_count"
    echo "  • Total work time: $(format_duration $total_work_time)"
    echo "  • Focus sessions: $pomodoro_sessions"
    echo "  • Focus work time: ${focus_work_time} minutes"
    echo ""

    # Save metrics to retrospective data
    cat > "/tmp/daily_metrics.json" << EOF
{
    "date": "$today",
    "git_commits": $git_commits,
    "git_files_changed": $git_files_changed,
    "git_lines_added": $git_lines_added,
    "git_lines_removed": $git_lines_removed,
    "work_sessions": $sessions_count,
    "total_work_time_seconds": $total_work_time,
    "focus_sessions": $pomodoro_sessions,
    "focus_work_minutes": $focus_work_time
}
EOF
}

# Format duration helper
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

# Interactive reflection questions
interactive_reflection() {
    local today=$(date +%Y-%m-%d)
    local retrospective_file="$RETROSPECTIVES_DIR/retro-$today.md"

    log "🤔 Starting interactive reflection..."

    # Initialize retrospective file
    cat > "$retrospective_file" << EOF
# Daily Retrospective - $today ($(date +%A))

**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Day:** $(date +%A)

## 📊 Daily Metrics
$(cat /tmp/daily_metrics.json | jq -r '. | "- Git commits: \(.git_commits)\n- Files changed: \(.git_files_changed)\n- Lines added: +\(.git_lines_added)\n- Lines removed: -\(.git_lines_removed)\n- Work sessions: \(.work_sessions)\n- Focus sessions: \(.focus_sessions)"')

EOF

    echo ""
    highlight "📝 Reflection Questions"
    echo "Take a moment to reflect on your day. Be honest and thoughtful."
    echo ""

    # Question 1: Accomplishments
    reflect "1. What did you accomplish today? (List your key achievements)"
    echo "   Examples: completed feature, fixed bugs, learned new concept, etc."
    echo ""
    echo "Your accomplishments:"
    local accomplishments=""
    local count=1
    while true; do
        echo -n "   $count. "
        read -r achievement
        if [ -z "$achievement" ]; then
            break
        fi
        accomplishments+="- $achievement\n"
        count=$((count + 1))
    done

    echo "" >> "$retrospective_file"
    echo "## 🎯 Accomplishments" >> "$retrospective_file"
    echo -e "$accomplishments" >> "$retrospective_file"

    # Question 2: Challenges
    echo ""
    reflect "2. What challenges did you face? How did you handle them?"
    echo ""
    echo -n "Your challenges and solutions: "
    read -r challenges

    echo "" >> "$retrospective_file"
    echo "## 🚧 Challenges & Solutions" >> "$retrospective_file"
    echo "$challenges" >> "$retrospective_file"

    # Question 3: Learning
    echo ""
    reflect "3. What did you learn today? (Technical, process, or personal insights)"
    echo ""
    echo -n "Your learnings: "
    read -r learnings

    echo "" >> "$retrospective_file"
    echo "## 📚 Learning & Insights" >> "$retrospective_file"
    echo "$learnings" >> "$retrospective_file"

    # Question 4: What went well
    echo ""
    reflect "4. What went particularly well today? (Celebrate your wins!)"
    echo ""
    echo -n "What went well: "
    read -r went_well

    echo "" >> "$retrospective_file"
    echo "## ✅ What Went Well" >> "$retrospective_file"
    echo "$went_well" >> "$retrospective_file"

    # Question 5: Improvements
    echo ""
    reflect "5. What could be improved? (Process, tools, habits, etc.)"
    echo ""
    echo -n "Areas for improvement: "
    read -r improvements

    echo "" >> "$retrospective_file"
    echo "## 🔄 Areas for Improvement" >> "$retrospective_file"
    echo "$improvements" >> "$retrospective_file"

    # Question 6: Energy and mood
    echo ""
    reflect "6. How was your energy and mood today? (1-10 scale and description)"
    echo ""
    echo -n "Energy level (1-10): "
    read -r energy_level
    echo -n "Mood description: "
    read -r mood_description

    echo "" >> "$retrospective_file"
    echo "## 🔋 Energy & Mood" >> "$retrospective_file"
    echo "Energy Level: $energy_level/10" >> "$retrospective_file"
    echo "Mood: $mood_description" >> "$retrospective_file"

    # Question 7: Tomorrow's priorities
    echo ""
    reflect "7. What are your top 3 priorities for tomorrow?"
    echo ""
    echo "Tomorrow's priorities:"
    local priorities=""
    for i in {1..3}; do
        echo -n "   $i. "
        read -r priority
        if [ -n "$priority" ]; then
            priorities+="$i. $priority\n"
        fi
    done

    echo "" >> "$retrospective_file"
    echo "## 🎯 Tomorrow's Priorities" >> "$retrospective_file"
    echo -e "$priorities" >> "$retrospective_file"

    # Question 8: Gratitude
    echo ""
    reflect "8. What are you grateful for today? (Optional but recommended)"
    echo ""
    echo -n "Gratitude: "
    read -r gratitude

    if [ -n "$gratitude" ]; then
        echo "" >> "$retrospective_file"
        echo "## 🙏 Gratitude" >> "$retrospective_file"
        echo "$gratitude" >> "$retrospective_file"
    fi

    # Add action items section
    echo ""
    echo "## 📋 Action Items for Tomorrow" >> "$retrospective_file"
    echo "- [ ] Review and prioritize task list" >> "$retrospective_file"
    echo "- [ ] $improvements" >> "$retrospective_file" # From improvement question
    echo "" >> "$retrospective_file"

    # Footer
    echo "---" >> "$retrospective_file"
    echo "*Generated by High-Efficiency Programmer System - Evening Retrospective*" >> "$retrospective_file"

    info "✅ Retrospective saved to: $retrospective_file"
}

# Generate insights and trends
generate_insights() {
    log "🧠 Generating insights from recent retrospectives..."

    # Get last 7 days of retrospectives
    local insights_file="/tmp/weekly_insights.md"
    local retro_files=($(find "$RETROSPECTIVES_DIR" -name "retro-*.md" -type f | sort | tail -7))

    if [ ${#retro_files[@]} -eq 0 ]; then
        warn "No retrospective files found for analysis"
        return
    fi

    echo ""
    highlight "📊 Weekly Insights & Patterns"
    echo ""

    # Analyze patterns in retrospectives
    echo "Based on your last ${#retro_files[@]} retrospectives:"
    echo ""

    # Energy trends
    local energy_levels=()
    for file in "${retro_files[@]}"; do
        local energy=$(grep "Energy Level:" "$file" | sed 's/Energy Level: //g' | sed 's/\/10//g' || echo "")
        if [ -n "$energy" ]; then
            energy_levels+=("$energy")
        fi
    done

    if [ ${#energy_levels[@]} -gt 0 ]; then
        local total_energy=0
        for energy in "${energy_levels[@]}"; do
            total_energy=$((total_energy + energy))
        done
        local avg_energy=$((total_energy / ${#energy_levels[@]}))
        echo "⚡ Average energy level: $avg_energy/10"

        if [ "$avg_energy" -ge 8 ]; then
            echo "   🟢 High energy - keep up the great work!"
        elif [ "$avg_energy" -ge 6 ]; then
            echo "   🟡 Good energy - consider what's working well"
        else
            echo "   🔴 Low energy - look for patterns and consider rest"
        fi
    fi

    # Common themes in accomplishments
    echo ""
    echo "🎯 Recent accomplishment themes:"
    local common_words=($(grep -h "^- " "${retro_files[@]}" | sed 's/^- //g' | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | grep -v '^$' | sort | uniq -c | sort -nr | head -5 | awk '{print $2}'))

    for word in "${common_words[@]:0:3}"; do
        echo "   • $word"
    done

    # Improvement suggestions
    echo ""
    echo "🔄 Recurring improvement areas:"
    grep -h "Areas for Improvement" -A 1 "${retro_files[@]}" | grep -v "Areas for Improvement" | grep -v "^--$" | head -3 | while read -r improvement; do
        if [ -n "$improvement" ]; then
            echo "   • $improvement"
        fi
    done
}

# Show week summary
show_week_summary() {
    local end_date=$(date +%Y-%m-%d)
    local start_date=$(date -d "7 days ago" +%Y-%m-%d)

    highlight "📅 Week Summary ($start_date to $end_date)"
    echo ""

    # Collect week's retrospectives
    local retro_files=($(find "$RETROSPECTIVES_DIR" -name "retro-*.md" -type f | sort | tail -7))

    if [ ${#retro_files[@]} -eq 0 ]; then
        warn "No retrospectives found for this week"
        return
    fi

    echo "Retrospectives completed: ${#retro_files[@]}/7 days"
    echo ""

    # Extract key metrics from retrospectives
    local total_accomplishments=0
    local total_learnings=0

    for file in "${retro_files[@]}"; do
        local date=$(basename "$file" | sed 's/retro-//g' | sed 's/.md//g')
        local accomplishment_count=$(grep "^- " "$file" | wc -l || echo "0")
        local has_learning=$(grep -q "Learning & Insights" "$file" && echo "1" || echo "0")

        total_accomplishments=$((total_accomplishments + accomplishment_count))
        total_learnings=$((total_learnings + has_learning))

        printf "%-12s: %d accomplishments\n" "$date" "$accomplishment_count"
    done

    echo ""
    echo "Week totals:"
    echo "• Total accomplishments recorded: $total_accomplishments"
    echo "• Days with learnings recorded: $total_learnings/${#retro_files[@]}"
    echo ""

    # Suggest focus for next week
    echo "💡 Suggestions for next week:"
    echo "• Continue daily retrospectives for consistency"
    if [ "$total_learnings" -lt 5 ]; then
        echo "• Focus more on capturing daily learnings"
    fi
    echo "• Review this week's improvement areas for action items"
}

# Quick retrospective (shorter version)
quick_retrospective() {
    local today=$(date +%Y-%m-%d)
    local retrospective_file="$RETROSPECTIVES_DIR/quick-retro-$today.md"

    log "⚡ Starting quick retrospective..."

    cat > "$retrospective_file" << EOF
# Quick Retrospective - $today

**Date:** $(date '+%Y-%m-%d %H:%M:%S')

EOF

    echo ""
    echo -n "🎯 Main accomplishment today: "
    read -r main_accomplishment

    echo -n "🚧 Biggest challenge: "
    read -r main_challenge

    echo -n "📚 Key learning: "
    read -r key_learning

    echo -n "🔜 Tomorrow's priority: "
    read -r tomorrow_priority

    cat >> "$retrospective_file" << EOF
## Main Accomplishment
$main_accomplishment

## Biggest Challenge
$main_challenge

## Key Learning
$key_learning

## Tomorrow's Priority
$tomorrow_priority

---
*Quick retrospective generated by High-Efficiency Programmer System*
EOF

    info "✅ Quick retrospective saved to: $retrospective_file"
}

# Main function
main() {
    case "${1:-full}" in
        "full"|"f")
            show_evening_banner
            collect_daily_metrics
            interactive_reflection
            generate_insights
            show_week_summary
            ;;

        "quick"|"q")
            collect_daily_metrics
            quick_retrospective
            ;;

        "insights"|"i")
            generate_insights
            ;;

        "week"|"w")
            show_week_summary
            ;;

        "metrics"|"m")
            collect_daily_metrics
            ;;

        "help"|"-h"|"--help")
            echo "Evening Retrospective - End-of-day reflection and planning"
            echo ""
            echo "Usage: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  full, f        Complete evening retrospective (default)"
            echo "  quick, q       Quick retrospective (5 questions)"
            echo "  insights, i    Generate insights from recent retrospectives"
            echo "  week, w        Show weekly summary"
            echo "  metrics, m     Show today's metrics only"
            echo "  help           Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 full        # Complete evening routine"
            echo "  $0 quick       # Quick 5-minute retrospective"
            echo "  $0 insights    # Analyze patterns in recent retrospectives"
            ;;

        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac

    # Cleanup
    rm -f /tmp/daily_metrics.json
}

main "$@"
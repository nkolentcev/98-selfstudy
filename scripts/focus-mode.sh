#!/bin/bash

# Focus Mode Script
# Pomodoro technique and distraction-free work sessions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
DATA_DIR="$HOME/.hep-data"
FOCUS_LOG="$DATA_DIR/focus-sessions.json"

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
    echo -e "${GREEN}[FOCUS] $1${NC}"
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

focus_info() {
    echo -e "${CYAN}[FOCUS] $1${NC}"
}

# Initialize focus log
init_focus_log() {
    if [ ! -f "$FOCUS_LOG" ]; then
        echo '{"sessions": [], "settings": {"default_work": 25, "default_break": 5, "long_break": 15}}' > "$FOCUS_LOG"
        log "Initialized focus session log"
    fi
}

# Play notification sound (if available)
play_notification() {
    local type="$1"  # start, end, break

    # Try different notification methods
    if command -v paplay > /dev/null && [ -f "/usr/share/sounds/alsa/Front_Left.wav" ]; then
        paplay "/usr/share/sounds/alsa/Front_Left.wav" 2>/dev/null &
    elif command -v aplay > /dev/null && [ -f "/usr/share/sounds/alsa/Front_Left.wav" ]; then
        aplay "/usr/share/sounds/alsa/Front_Left.wav" 2>/dev/null &
    elif command -v osascript > /dev/null; then
        # macOS
        osascript -e 'display notification "Focus session notification" with title "High-Efficiency Programmer"' 2>/dev/null &
    elif command -v notify-send > /dev/null; then
        # Linux desktop notification
        notify-send "High-Efficiency Programmer" "Focus session notification" 2>/dev/null &
    else
        # Terminal bell
        echo -e "\a"
    fi
}

# Show countdown timer
show_countdown() {
    local minutes="$1"
    local message="$2"
    local total_seconds=$((minutes * 60))

    clear
    echo ""
    highlight "🎯 $message"
    echo ""

    while [ $total_seconds -gt 0 ]; do
        local mins=$((total_seconds / 60))
        local secs=$((total_seconds % 60))

        # Create progress bar
        local progress_width=50
        local elapsed=$((minutes * 60 - total_seconds))
        local filled=$((elapsed * progress_width / (minutes * 60)))
        local progress_bar=""

        for ((i=0; i<progress_width; i++)); do
            if [ $i -lt $filled ]; then
                progress_bar+="█"
            else
                progress_bar+="░"
            fi
        done

        printf "\r${CYAN}[%s] %02d:%02d remaining${NC}" "$progress_bar" "$mins" "$secs"

        sleep 1
        total_seconds=$((total_seconds - 1))
    done

    echo ""
    echo ""
}

# Record focus session
record_session() {
    local session_type="$1"
    local duration="$2"
    local task="$3"

    init_focus_log

    local session_data=$(cat << EOF
{
    "type": "$session_type",
    "duration_minutes": $duration,
    "task": "$task",
    "date": "$(date +%Y-%m-%d)",
    "start_time": "$(date '+%H:%M:%S')",
    "timestamp": "$(date -Iseconds)"
}
EOF
    )

    local updated_log=$(jq ".sessions += [$session_data]" "$FOCUS_LOG")
    echo "$updated_log" > "$FOCUS_LOG"
}

# Pomodoro session
pomodoro_session() {
    local work_minutes="${1:-25}"
    local break_minutes="${2:-5}"
    local cycles="${3:-4}"
    local long_break="${4:-15}"

    log "🍅 Starting Pomodoro session"
    echo "Work: ${work_minutes}min | Break: ${break_minutes}min | Cycles: $cycles"
    echo ""

    echo -n "What will you work on? "
    read -r task_description

    for ((cycle=1; cycle<=cycles; cycle++)); do
        echo ""
        highlight "=== CYCLE $cycle/$cycles ==="

        # Work session
        focus_info "Starting work session..."
        play_notification "start"
        show_countdown "$work_minutes" "🎯 FOCUS TIME - $task_description"

        # Work session complete
        play_notification "end"
        record_session "work" "$work_minutes" "$task_description"

        echo ""
        highlight "✅ Work session complete!"

        # Break (except after last cycle)
        if [ $cycle -lt $cycles ]; then
            local current_break=$break_minutes

            # Long break after every 4 cycles
            if [ $((cycle % 4)) -eq 0 ] && [ $cycle -gt 1 ]; then
                current_break=$long_break
                focus_info "Time for a long break!"
            else
                focus_info "Time for a short break!"
            fi

            play_notification "break"
            show_countdown "$current_break" "☕ BREAK TIME - Relax and recharge"

            play_notification "end"
            record_session "break" "$current_break" "Break"

            echo ""
            highlight "🔄 Break over! Ready for next work session?"
            echo "Press Enter to continue or Ctrl+C to stop"
            read -r
        fi
    done

    echo ""
    highlight "🎉 Pomodoro session complete!"
    show_session_summary
}

# Custom focus session
custom_focus_session() {
    local duration="$1"

    if [ -z "$duration" ]; then
        echo -n "Focus duration (minutes): "
        read -r duration
    fi

    if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
        error "Invalid duration. Please enter a number."
        return 1
    fi

    echo -n "What will you work on? "
    read -r task_description

    log "🎯 Starting custom focus session: ${duration} minutes"

    play_notification "start"
    show_countdown "$duration" "🎯 FOCUS TIME - $task_description"

    play_notification "end"
    record_session "custom_focus" "$duration" "$task_description"

    echo ""
    highlight "✅ Focus session complete!"
    show_session_summary
}

# Break session
break_session() {
    local duration="${1:-5}"

    log "☕ Starting break session: ${duration} minutes"

    play_notification "break"
    show_countdown "$duration" "☕ BREAK TIME - Relax and recharge"

    play_notification "end"
    record_session "break" "$duration" "Break"

    echo ""
    highlight "🔄 Break complete! Ready to get back to work?"
}

# Deep work session
deep_work_session() {
    local duration="${1:-90}"

    echo -n "Deep work focus (what will you work on?): "
    read -r task_description

    log "🧠 Starting deep work session: ${duration} minutes"
    warn "⚠️  This is a long session. Make sure you're prepared!"
    echo "Tips for deep work:"
    echo "• Turn off all notifications"
    echo "• Use noise-canceling headphones"
    echo "• Have water and snacks ready"
    echo "• Clear your workspace"
    echo ""

    echo "Press Enter when ready to start..."
    read -r

    play_notification "start"
    show_countdown "$duration" "🧠 DEEP WORK - $task_description"

    play_notification "end"
    record_session "deep_work" "$duration" "$task_description"

    echo ""
    highlight "🎯 Deep work session complete! Great job!"
    echo "Consider taking a longer break (15-30 minutes) after deep work."

    show_session_summary
}

# Show session summary
show_session_summary() {
    init_focus_log

    local today=$(date +%Y-%m-%d)
    local today_sessions=$(jq -r ".sessions | map(select(.date == \"$today\"))" "$FOCUS_LOG" 2>/dev/null)

    if [ "$today_sessions" = "[]" ]; then
        info "No sessions today yet"
        return
    fi

    echo ""
    highlight "📊 Today's Focus Summary"

    local total_work_time=0
    local total_break_time=0
    local work_sessions=0
    local break_sessions=0

    while IFS= read -r session; do
        local session_type=$(echo "$session" | jq -r '.type')
        local duration=$(echo "$session" | jq -r '.duration_minutes')

        case "$session_type" in
            "work"|"custom_focus"|"deep_work")
                total_work_time=$((total_work_time + duration))
                work_sessions=$((work_sessions + 1))
                ;;
            "break")
                total_break_time=$((total_break_time + duration))
                break_sessions=$((break_sessions + 1))
                ;;
        esac
    done < <(echo "$today_sessions" | jq -c '.[]')

    echo "Work sessions: $work_sessions (${total_work_time} minutes)"
    echo "Break sessions: $break_sessions (${total_break_time} minutes)"
    echo "Total productive time: ${total_work_time} minutes"

    # Calculate focus ratio
    if [ $((total_work_time + total_break_time)) -gt 0 ]; then
        local focus_ratio=$((total_work_time * 100 / (total_work_time + total_break_time)))
        echo "Focus ratio: ${focus_ratio}%"
    fi
}

# Show focus statistics
show_statistics() {
    init_focus_log

    highlight "📈 Focus Session Statistics"
    echo ""

    # Last 7 days
    local dates=()
    for i in {6..0}; do
        dates+=($(date -d "$i days ago" +%Y-%m-%d))
    done

    echo "Last 7 Days Summary:"
    printf "%-12s %s %s %s\n" "Date" "Sessions" "Work Min" "Focus %"
    echo "----------------------------------------"

    local total_work_week=0
    local total_sessions_week=0

    for date in "${dates[@]}"; do
        local day_sessions=$(jq -r ".sessions | map(select(.date == \"$date\"))" "$FOCUS_LOG" 2>/dev/null)

        local work_time=0
        local break_time=0
        local session_count=0

        if [ "$day_sessions" != "[]" ]; then
            while IFS= read -r session; do
                local session_type=$(echo "$session" | jq -r '.type')
                local duration=$(echo "$session" | jq -r '.duration_minutes')
                session_count=$((session_count + 1))

                case "$session_type" in
                    "work"|"custom_focus"|"deep_work")
                        work_time=$((work_time + duration))
                        ;;
                    "break")
                        break_time=$((break_time + duration))
                        ;;
                esac
            done < <(echo "$day_sessions" | jq -c '.[]')
        fi

        local focus_ratio=0
        if [ $((work_time + break_time)) -gt 0 ]; then
            focus_ratio=$((work_time * 100 / (work_time + break_time)))
        fi

        printf "%-12s %8d %8d %6d%%\n" "$date" "$session_count" "$work_time" "$focus_ratio"

        total_work_week=$((total_work_week + work_time))
        total_sessions_week=$((total_sessions_week + session_count))
    done

    echo "----------------------------------------"
    printf "%-12s %8d %8d\n" "TOTAL" "$total_sessions_week" "$total_work_week"

    # Session type breakdown
    echo ""
    echo "Session Type Breakdown (All Time):"
    local session_types=$(jq -r '.sessions | group_by(.type) | .[] | [.[0].type, length] | @csv' "$FOCUS_LOG" 2>/dev/null | tr -d '"')

    echo "$session_types" | while IFS=',' read -r type count; do
        printf "%-15s: %d sessions\n" "$type" "$count"
    done
}

# Configure focus settings
configure_focus() {
    init_focus_log

    highlight "⚙️  Focus Mode Configuration"
    echo ""

    local current_settings=$(jq -r '.settings' "$FOCUS_LOG")
    echo "Current settings:"
    echo "Default work duration: $(echo "$current_settings" | jq -r '.default_work') minutes"
    echo "Default break duration: $(echo "$current_settings" | jq -r '.default_break') minutes"
    echo "Long break duration: $(echo "$current_settings" | jq -r '.long_break') minutes"
    echo ""

    echo -n "New work duration (minutes, or press Enter to keep current): "
    read -r new_work
    echo -n "New break duration (minutes, or press Enter to keep current): "
    read -r new_break
    echo -n "New long break duration (minutes, or press Enter to keep current): "
    read -r new_long_break

    # Update settings
    local updated_settings="$current_settings"

    if [ -n "$new_work" ] && [[ "$new_work" =~ ^[0-9]+$ ]]; then
        updated_settings=$(echo "$updated_settings" | jq ".default_work = $new_work")
    fi

    if [ -n "$new_break" ] && [[ "$new_break" =~ ^[0-9]+$ ]]; then
        updated_settings=$(echo "$updated_settings" | jq ".default_break = $new_break")
    fi

    if [ -n "$new_long_break" ] && [[ "$new_long_break" =~ ^[0-9]+$ ]]; then
        updated_settings=$(echo "$updated_settings" | jq ".long_break = $new_long_break")
    fi

    local updated_log=$(jq ".settings = $updated_settings" "$FOCUS_LOG")
    echo "$updated_log" > "$FOCUS_LOG"

    info "✅ Settings updated"
}

# Main function
main() {
    case "${1:-menu}" in
        "pomodoro"|"p")
            local work="${2:-25}"
            local break="${3:-5}"
            local cycles="${4:-4}"
            local long_break="${5:-15}"
            pomodoro_session "$work" "$break" "$cycles" "$long_break"
            ;;

        "focus"|"f")
            custom_focus_session "$2"
            ;;

        "break"|"b")
            break_session "$2"
            ;;

        "deep"|"d")
            deep_work_session "$2"
            ;;

        "stats"|"s")
            show_statistics
            ;;

        "summary"|"sum")
            show_session_summary
            ;;

        "config"|"c")
            configure_focus
            ;;

        "menu"|"m")
            echo ""
            highlight "🎯 Focus Mode Menu"
            echo ""
            echo "1. 🍅 Pomodoro session (25min work, 5min break)"
            echo "2. 🎯 Custom focus session"
            echo "3. ☕ Take a break"
            echo "4. 🧠 Deep work session (90min)"
            echo "5. 📊 Show today's summary"
            echo "6. 📈 View statistics"
            echo "7. ⚙️  Configure settings"
            echo "8. 🚪 Exit"
            echo ""
            echo -n "Choose option (1-8): "
            read -r choice

            case $choice in
                1) pomodoro_session ;;
                2) custom_focus_session ;;
                3) break_session ;;
                4) deep_work_session ;;
                5) show_session_summary ;;
                6) show_statistics ;;
                7) configure_focus ;;
                8) log "Focus session ended. Keep up the great work! 🚀"; exit 0 ;;
                *) error "Invalid choice" ;;
            esac
            ;;

        "help"|"-h"|"--help")
            echo "Focus Mode - Pomodoro technique and distraction-free work sessions"
            echo ""
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  pomodoro, p [work] [break] [cycles] [long]  Start Pomodoro session"
            echo "  focus, f [duration]                         Custom focus session"
            echo "  break, b [duration]                         Take a break"
            echo "  deep, d [duration]                          Deep work session (90min default)"
            echo "  stats, s                                    Show focus statistics"
            echo "  summary, sum                                Show today's summary"
            echo "  config, c                                   Configure settings"
            echo "  menu, m                                     Interactive menu (default)"
            echo "  help                                        Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 pomodoro                  # Standard 25/5 Pomodoro"
            echo "  $0 focus 45                  # 45-minute focus session"
            echo "  $0 deep                      # 90-minute deep work"
            echo "  $0 break 10                  # 10-minute break"
            ;;

        *)
            # Try to parse as duration for focus mode
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                custom_focus_session "$1"
            else
                error "Unknown command: $1"
                echo "Use '$0 help' for available commands or '$0 menu' for interactive mode"
                exit 1
            fi
            ;;
    esac
}

main "$@"
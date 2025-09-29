#!/bin/bash

# Create Dashboard Script
# Generate HTML productivity dashboard

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
DASHBOARD_DIR="$(dirname "$SCRIPT_DIR")/dashboard"
DATA_DIR="$HOME/.hep-data"

# Create directories
mkdir -p "$DASHBOARD_DIR" "$DATA_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[DASHBOARD] $1${NC}"
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

# Generate dashboard data
generate_dashboard_data() {
    local today=$(date +%Y-%m-%d)
    local dashboard_data="/tmp/dashboard_data.json"

    # Initialize data structure
    cat > "$dashboard_data" << EOF
{
    "generated_at": "$(date -Iseconds)",
    "date": "$today",
    "productivity_score": 0,
    "git_activity": {},
    "time_tracking": {},
    "focus_sessions": {},
    "recent_achievements": [],
    "daily_goals": [],
    "week_summary": {}
}
EOF

    # Get Git activity
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local git_commits=$(git log --oneline --since="$today 00:00" --until="$today 23:59" --author="$(git config user.email)" 2>/dev/null | wc -l)
        local git_files=$(git diff --name-only --since="$today 00:00" --until="$today 23:59" 2>/dev/null | wc -l)

        local git_activity=$(cat << EOF
{
    "commits_today": $git_commits,
    "files_changed": $git_files,
    "current_branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
    "status": "$(git status --porcelain | wc -l) changes"
}
EOF
        )

        local updated_data=$(jq ".git_activity = $git_activity" "$dashboard_data")
        echo "$updated_data" > "$dashboard_data"
    fi

    # Get time tracking data
    if [ -f "$DATA_DIR/time-tracking.json" ]; then
        local today_sessions=$(jq -r ".sessions | map(select(.date == \"$today\"))" "$DATA_DIR/time-tracking.json" 2>/dev/null || echo "[]")
        local sessions_count=$(echo "$today_sessions" | jq 'length' 2>/dev/null || echo "0")
        local total_time=$(echo "$today_sessions" | jq 'map(.duration // 0) | add // 0' 2>/dev/null || echo "0")

        local time_tracking=$(cat << EOF
{
    "sessions_count": $sessions_count,
    "total_time_seconds": $total_time,
    "total_time_formatted": "$(format_duration $total_time)"
}
EOF
        )

        local updated_data=$(jq ".time_tracking = $time_tracking" "$dashboard_data")
        echo "$updated_data" > "$dashboard_data"
    fi

    # Get focus sessions data
    if [ -f "$DATA_DIR/focus-sessions.json" ]; then
        local focus_today=$(jq -r ".sessions | map(select(.date == \"$today\" and (.type == \"work\" or .type == \"custom_focus\" or .type == \"deep_work\")))" "$DATA_DIR/focus-sessions.json" 2>/dev/null || echo "[]")
        local focus_count=$(echo "$focus_today" | jq 'length' 2>/dev/null || echo "0")
        local focus_time=$(echo "$focus_today" | jq 'map(.duration_minutes // 0) | add // 0' 2>/dev/null || echo "0")

        local focus_sessions=$(cat << EOF
{
    "focus_count": $focus_count,
    "focus_minutes": $focus_time,
    "focus_time_formatted": "${focus_time} minutes"
}
EOF
        )

        local updated_data=$(jq ".focus_sessions = $focus_sessions" "$dashboard_data")
        echo "$updated_data" > "$dashboard_data"
    fi

    # Calculate productivity score
    local productivity_score=0
    local git_commits=$(jq -r '.git_activity.commits_today // 0' "$dashboard_data")
    local sessions_count=$(jq -r '.time_tracking.sessions_count // 0' "$dashboard_data")
    local focus_count=$(jq -r '.focus_sessions.focus_count // 0' "$dashboard_data")

    if [ "$git_commits" -gt 0 ]; then productivity_score=$((productivity_score + 30)); fi
    if [ "$sessions_count" -gt 0 ]; then productivity_score=$((productivity_score + 25)); fi
    if [ "$focus_count" -gt 0 ]; then productivity_score=$((productivity_score + 35)); fi
    if [ "$productivity_score" -gt 10 ]; then productivity_score=$((productivity_score + 10)); fi # Bonus for being active

    local updated_data=$(jq ".productivity_score = $productivity_score" "$dashboard_data")
    echo "$updated_data" > "$dashboard_data"

    echo "$dashboard_data"
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

# Generate HTML dashboard
generate_html_dashboard() {
    local data_file="$1"
    local output_file="$DASHBOARD_DIR/index.html"

    log "🎨 Generating HTML dashboard..."

    # Read data
    local dashboard_data=$(cat "$data_file")
    local today=$(echo "$dashboard_data" | jq -r '.date')
    local productivity_score=$(echo "$dashboard_data" | jq -r '.productivity_score')
    local git_commits=$(echo "$dashboard_data" | jq -r '.git_activity.commits_today // 0')
    local git_branch=$(echo "$dashboard_data" | jq -r '.git_activity.current_branch // "unknown"')
    local sessions_count=$(echo "$dashboard_data" | jq -r '.time_tracking.sessions_count // 0')
    local total_time=$(echo "$dashboard_data" | jq -r '.time_tracking.total_time_formatted // "0m"')
    local focus_count=$(echo "$dashboard_data" | jq -r '.focus_sessions.focus_count // 0')
    local focus_time=$(echo "$dashboard_data" | jq -r '.focus_sessions.focus_time_formatted // "0 minutes"')

    # Determine score color
    local score_color="#e74c3c"  # red
    if [ "$productivity_score" -ge 80 ]; then
        score_color="#27ae60"  # green
    elif [ "$productivity_score" -ge 60 ]; then
        score_color="#f39c12"  # orange
    elif [ "$productivity_score" -ge 40 ]; then
        score_color="#f1c40f"  # yellow
    fi

    cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>High-Efficiency Programmer Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            font-weight: 300;
        }

        .header .date {
            opacity: 0.9;
            font-size: 1.1em;
        }

        .dashboard-content {
            padding: 30px;
        }

        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .metric-card {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 25px;
            text-align: center;
            border-left: 5px solid #3498db;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .metric-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }

        .metric-card h3 {
            color: #2c3e50;
            margin-bottom: 15px;
            font-size: 1.1em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .metric-value {
            font-size: 2.5em;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .metric-label {
            color: #7f8c8d;
            font-size: 0.9em;
        }

        .productivity-score {
            grid-column: 1 / -1;
            background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
            border: none;
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .productivity-score::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: linear-gradient(90deg, $score_color 0%, $score_color ${productivity_score}%, #ecf0f1 ${productivity_score}%, #ecf0f1 100%);
        }

        .score-circle {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            background: conic-gradient(
                $score_color 0deg ${productivity_score}deg,
                #ecf0f1 ${productivity_score}deg 360deg
            );
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            position: relative;
        }

        .score-circle::before {
            content: '';
            width: 120px;
            height: 120px;
            background: white;
            border-radius: 50%;
            position: absolute;
        }

        .score-value {
            font-size: 2.5em;
            font-weight: bold;
            color: $score_color;
            z-index: 1;
        }

        .git-card {
            border-left-color: #e74c3c;
        }

        .time-card {
            border-left-color: #27ae60;
        }

        .focus-card {
            border-left-color: #9b59b6;
        }

        .sessions-card {
            border-left-color: #f39c12;
        }

        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 30px;
        }

        .action-btn {
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
            color: white;
            border: none;
            border-radius: 10px;
            padding: 15px 20px;
            font-size: 1em;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.3);
        }

        .footer {
            background: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
            font-size: 0.9em;
        }

        .status-indicator {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 8px;
        }

        .status-good {
            background: #27ae60;
        }

        .status-warning {
            background: #f39c12;
        }

        .status-error {
            background: #e74c3c;
        }

        @media (max-width: 768px) {
            .container {
                margin: 10px;
                border-radius: 15px;
            }

            .header {
                padding: 20px;
            }

            .header h1 {
                font-size: 2em;
            }

            .dashboard-content {
                padding: 20px;
            }

            .metrics-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 High-Efficiency Programmer</h1>
            <div class="date">Dashboard for $today</div>
        </div>

        <div class="dashboard-content">
            <div class="metrics-grid">
                <div class="metric-card productivity-score">
                    <h3>Productivity Score</h3>
                    <div class="score-circle">
                        <div class="score-value">$productivity_score</div>
                    </div>
                    <div class="metric-label">out of 100</div>
                </div>

                <div class="metric-card git-card">
                    <h3>Git Activity</h3>
                    <div class="metric-value" style="color: #e74c3c;">$git_commits</div>
                    <div class="metric-label">commits today</div>
                    <div style="margin-top: 10px; font-size: 0.9em;">
                        <span class="status-indicator status-good"></span>Branch: $git_branch
                    </div>
                </div>

                <div class="metric-card time-card">
                    <h3>Time Tracking</h3>
                    <div class="metric-value" style="color: #27ae60;">$total_time</div>
                    <div class="metric-label">total work time</div>
                </div>

                <div class="metric-card focus-card">
                    <h3>Focus Sessions</h3>
                    <div class="metric-value" style="color: #9b59b6;">$focus_count</div>
                    <div class="metric-label">focus sessions ($focus_time)</div>
                </div>

                <div class="metric-card sessions-card">
                    <h3>Work Sessions</h3>
                    <div class="metric-value" style="color: #f39c12;">$sessions_count</div>
                    <div class="metric-label">tracked sessions</div>
                </div>
            </div>

            <div class="quick-actions">
                <a href="#" onclick="executeCommand('focus')" class="action-btn">
                    🎯 Start Focus Session
                </a>
                <a href="#" onclick="executeCommand('review')" class="action-btn">
                    🔍 Code Review
                </a>
                <a href="#" onclick="executeCommand('ai')" class="action-btn">
                    🤖 AI Assistant
                </a>
                <a href="#" onclick="executeCommand('track')" class="action-btn">
                    ⏱️ Track Time
                </a>
                <a href="#" onclick="executeCommand('metrics')" class="action-btn">
                    📊 View Metrics
                </a>
                <a href="#" onclick="refreshDashboard()" class="action-btn">
                    🔄 Refresh
                </a>
            </div>
        </div>

        <div class="footer">
            Generated at $(date) | High-Efficiency Programmer System v1.0
        </div>
    </div>

    <script>
        function executeCommand(command) {
            alert('This would execute: ./high-efficiency-programmer.sh ' + command + '\\n\\nRun this command in your terminal for now.');
        }

        function refreshDashboard() {
            location.reload();
        }

        // Auto-refresh every 5 minutes
        setTimeout(() => {
            location.reload();
        }, 5 * 60 * 1000);

        // Add some interactivity
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.metric-card');
            cards.forEach(card => {
                card.addEventListener('click', function() {
                    this.style.transform = 'scale(0.95)';
                    setTimeout(() => {
                        this.style.transform = '';
                    }, 150);
                });
            });
        });
    </script>
</body>
</html>
EOF

    info "✅ HTML dashboard generated: $output_file"
}

# Generate simple text dashboard
generate_text_dashboard() {
    local data_file="$1"

    highlight "📊 Productivity Dashboard"
    echo ""

    local dashboard_data=$(cat "$data_file")
    local today=$(echo "$dashboard_data" | jq -r '.date')
    local productivity_score=$(echo "$dashboard_data" | jq -r '.productivity_score')
    local git_commits=$(echo "$dashboard_data" | jq -r '.git_activity.commits_today // 0')
    local git_branch=$(echo "$dashboard_data" | jq -r '.git_activity.current_branch // "unknown"')
    local sessions_count=$(echo "$dashboard_data" | jq -r '.time_tracking.sessions_count // 0')
    local total_time=$(echo "$dashboard_data" | jq -r '.time_tracking.total_time_formatted // "0m"')
    local focus_count=$(echo "$dashboard_data" | jq -r '.focus_sessions.focus_count // 0')
    local focus_time=$(echo "$dashboard_data" | jq -r '.focus_sessions.focus_time_formatted // "0 minutes"')

    # Productivity score with visual bar
    local score_bar=""
    local filled_blocks=$((productivity_score / 5))
    for ((i=0; i<20; i++)); do
        if [ $i -lt $filled_blocks ]; then
            score_bar+="█"
        else
            score_bar+="░"
        fi
    done

    # Color the score
    local score_color="${RED}"
    if [ "$productivity_score" -ge 80 ]; then
        score_color="${GREEN}"
    elif [ "$productivity_score" -ge 60 ]; then
        score_color="${YELLOW}"
    fi

    echo -e "${score_color}Productivity Score: $productivity_score/100${NC}"
    echo -e "${score_color}$score_bar${NC}"
    echo ""

    # Metrics
    echo "📈 Today's Metrics ($today):"
    echo "  🔧 Git Activity:"
    echo "    • Commits: $git_commits"
    echo "    • Branch: $git_branch"
    echo ""
    echo "  ⏱️  Time & Focus:"
    echo "    • Work sessions: $sessions_count"
    echo "    • Total time: $total_time"
    echo "    • Focus sessions: $focus_count"
    echo "    • Focus time: $focus_time"
    echo ""

    # Quick status
    if [ "$productivity_score" -ge 80 ]; then
        echo -e "${GREEN}🎉 Excellent productivity today!${NC}"
    elif [ "$productivity_score" -ge 60 ]; then
        echo -e "${YELLOW}👍 Good work today, keep it up!${NC}"
    elif [ "$productivity_score" -ge 40 ]; then
        echo -e "${YELLOW}📈 Decent progress, room for improvement${NC}"
    else
        echo -e "${RED}🚀 Let's boost productivity with focus sessions!${NC}"
    fi
}

# Main function
main() {
    case "${1:-both}" in
        "html"|"h")
            local data_file=$(generate_dashboard_data)
            generate_html_dashboard "$data_file"
            rm -f "$data_file"
            ;;

        "text"|"t")
            local data_file=$(generate_dashboard_data)
            generate_text_dashboard "$data_file"
            rm -f "$data_file"
            ;;

        "both"|"b")
            local data_file=$(generate_dashboard_data)
            generate_html_dashboard "$data_file"
            generate_text_dashboard "$data_file"
            rm -f "$data_file"
            ;;

        "data"|"d")
            local data_file=$(generate_dashboard_data)
            cat "$data_file"
            rm -f "$data_file"
            ;;

        "help"|"-h"|"--help")
            echo "Create Dashboard - Generate productivity dashboard"
            echo ""
            echo "Usage: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  html, h        Generate HTML dashboard only"
            echo "  text, t        Generate text dashboard only"
            echo "  both, b        Generate both HTML and text (default)"
            echo "  data, d        Show raw dashboard data (JSON)"
            echo "  help           Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 both        # Generate both dashboards"
            echo "  $0 html        # HTML dashboard only"
            echo "  $0 text        # Text dashboard only"
            ;;

        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

main "$@"
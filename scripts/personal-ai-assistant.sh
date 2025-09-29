#!/bin/bash

# Personal AI Assistant Script
# Context-aware AI helper for development tasks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
DATA_DIR="$HOME/.hep-data"
CONTEXT_FILE="$DATA_DIR/ai-context.json"
CONVERSATION_LOG="$DATA_DIR/ai-conversations.json"

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
    echo -e "${GREEN}[AI-ASSISTANT] $1${NC}"
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

ai_response() {
    echo -e "${CYAN}🤖 AI: $1${NC}"
}

# Initialize context and conversation log
init_ai_data() {
    if [ ! -f "$CONTEXT_FILE" ]; then
        cat > "$CONTEXT_FILE" << EOF
{
    "current_project": null,
    "working_directory": "$(pwd)",
    "programming_languages": [],
    "recent_files": [],
    "current_task": null,
    "preferences": {
        "code_style": "clean",
        "testing_framework": "auto-detect",
        "ai_verbosity": "balanced"
    },
    "last_updated": "$(date -Iseconds)"
}
EOF
    fi

    if [ ! -f "$CONVERSATION_LOG" ]; then
        echo '{"conversations": []}' > "$CONVERSATION_LOG"
    fi
}

# Update context with current environment
update_context() {
    init_ai_data

    local current_dir=$(pwd)
    local git_branch=""
    local git_status=""
    local project_type=""
    local recent_files=()

    # Git information
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        git_status=$(git status --porcelain | wc -l)
    fi

    # Detect project type
    if [ -f "package.json" ]; then
        project_type="javascript"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        project_type="python"
    elif [ -f "go.mod" ]; then
        project_type="go"
    elif [ -f "Cargo.toml" ]; then
        project_type="rust"
    elif [ -f "pom.xml" ]; then
        project_type="java"
    else
        project_type="general"
    fi

    # Get recent files
    while IFS= read -r -d '' file; do
        recent_files+=("$(realpath --relative-to="$current_dir" "$file")")
    done < <(find "$current_dir" -type f -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.sh" 2>/dev/null | head -10 | tr '\n' '\0')

    # Update context
    local updated_context=$(jq --arg dir "$current_dir" \
                              --arg branch "$git_branch" \
                              --arg status "$git_status" \
                              --arg type "$project_type" \
                              --argjson files "$(printf '%s\n' "${recent_files[@]}" | jq -R . | jq -s .)" \
                              '.working_directory = $dir | .git_branch = $branch | .git_status = $status | .project_type = $type | .recent_files = $files | .last_updated = now | .' \
                              "$CONTEXT_FILE")

    echo "$updated_context" > "$CONTEXT_FILE"
}

# Get relevant context for AI
get_context_for_query() {
    local query="$1"
    local context=""

    # Read current context
    local current_context=$(cat "$CONTEXT_FILE" 2>/dev/null || echo '{}')

    # Build context string
    context="Current working directory: $(echo "$current_context" | jq -r '.working_directory // "unknown"')\n"
    context+="Project type: $(echo "$current_context" | jq -r '.project_type // "unknown"')\n"

    if git rev-parse --git-dir > /dev/null 2>&1; then
        context+="Git branch: $(echo "$current_context" | jq -r '.git_branch // "unknown"')\n"
        context+="Git status: $(echo "$current_context" | jq -r '.git_status // "0"') changes\n"
    fi

    # Add recent files if relevant to query
    if [[ "$query" =~ file|code|implement|debug|review ]]; then
        local recent_files=$(echo "$current_context" | jq -r '.recent_files[]?' | head -5)
        if [ -n "$recent_files" ]; then
            context+="Recent files:\n$recent_files\n"
        fi
    fi

    echo -e "$context"
}

# Log conversation
log_conversation() {
    local query="$1"
    local response="$2"
    local context="$3"

    local conversation_entry=$(cat << EOF
{
    "timestamp": "$(date -Iseconds)",
    "query": "$query",
    "response": "$response",
    "context": "$context",
    "session_id": "$(date +%Y%m%d_%H%M%S)"
}
EOF
    )

    local updated_log=$(jq ".conversations += [$conversation_entry]" "$CONVERSATION_LOG")
    echo "$updated_log" > "$CONVERSATION_LOG"
}

# Process AI query (mock implementation - replace with actual AI service)
process_ai_query() {
    local query="$1"
    local context="$2"

    # This is a mock implementation
    # In a real implementation, you would call an actual AI service like OpenAI API, Claude API, etc.

    log "🤔 Processing query: $query"

    # Pattern matching for common queries
    case "$query" in
        *"debug"*|*"error"*|*"fix"*)
            ai_response "I'll help you debug this issue. Here's my analysis:"
            echo ""
            echo "🔍 Debugging suggestions:"
            echo "1. Check recent code changes"
            echo "2. Review error logs and stack traces"
            echo "3. Verify dependencies and imports"
            echo "4. Use debugging tools or print statements"
            echo ""
            echo "Would you like me to analyze a specific file or error message?"
            ;;

        *"implement"*|*"code"*|*"write"*)
            ai_response "I can help you implement this feature. Let me break it down:"
            echo ""
            echo "💡 Implementation approach:"
            echo "1. Define the requirements clearly"
            echo "2. Design the solution architecture"
            echo "3. Write tests first (TDD approach)"
            echo "4. Implement the functionality"
            echo "5. Refactor and optimize"
            echo ""
            echo "What specific functionality do you want to implement?"
            ;;

        *"review"*|*"improve"*|*"optimize"*)
            ai_response "I'll review your code for improvements. Here's what I look for:"
            echo ""
            echo "📋 Code review checklist:"
            echo "• Code readability and clarity"
            echo "• Performance considerations"
            echo "• Security best practices"
            echo "• Error handling"
            echo "• Test coverage"
            echo ""
            echo "Which file or function would you like me to review?"
            ;;

        *"test"*|*"testing"*)
            ai_response "Testing is crucial for reliable code. Here's my testing guidance:"
            echo ""
            echo "🧪 Testing strategy:"
            echo "• Unit tests for individual functions"
            echo "• Integration tests for components"
            echo "• End-to-end tests for user workflows"
            echo "• Edge case and error condition testing"
            echo ""
            echo "What would you like help testing?"
            ;;

        *"architecture"*|*"design"*|*"structure"*)
            ai_response "Good architecture is key to maintainable code. Consider these principles:"
            echo ""
            echo "🏗️ Architecture principles:"
            echo "• Separation of concerns"
            echo "• Single responsibility principle"
            echo "• Dependency injection"
            echo "• Modular design"
            echo "• Scalability considerations"
            echo ""
            ;;

        *"performance"*|*"optimize"*|*"slow"*)
            ai_response "Performance optimization requires systematic analysis:"
            echo ""
            echo "⚡ Performance optimization steps:"
            echo "1. Profile to identify bottlenecks"
            echo "2. Optimize data structures and algorithms"
            echo "3. Reduce unnecessary operations"
            echo "4. Consider caching strategies"
            echo "5. Minimize I/O operations"
            echo ""
            ;;

        *"git"*|*"version control"*)
            ai_response "Git best practices for better version control:"
            echo ""
            echo "📚 Git recommendations:"
            echo "• Make small, focused commits"
            echo "• Write descriptive commit messages"
            echo "• Use feature branches"
            echo "• Review code before merging"
            echo "• Keep history clean with rebase"
            echo ""
            ;;

        *"help"*|*"explain"*|*"how"*)
            ai_response "I'm here to help with your development tasks! I can assist with:"
            echo ""
            echo "🛠️ Available assistance:"
            echo "• Code debugging and troubleshooting"
            echo "• Feature implementation guidance"
            echo "• Code review and improvements"
            echo "• Testing strategies"
            echo "• Architecture and design decisions"
            echo "• Performance optimization"
            echo "• Git and version control"
            echo ""
            echo "Just ask me specific questions about your code or development challenges!"
            ;;

        *)
            ai_response "I understand you're asking about: \"$query\""
            echo ""
            echo "Based on your current context:"
            echo "$context"
            echo ""
            echo "Here's my general guidance:"
            echo "• Break down complex problems into smaller parts"
            echo "• Follow the principle of least surprise"
            echo "• Write code that's easy to read and maintain"
            echo "• Test early and test often"
            echo ""
            echo "Could you provide more specific details about what you need help with?"
            ;;
    esac

    # Return the response for logging
    echo "Processed query about: $query"
}

# Interactive AI chat
interactive_chat() {
    log "🤖 Starting interactive AI assistant session"
    echo "Type 'exit', 'quit', or 'bye' to end the session"
    echo ""

    update_context

    while true; do
        echo -n "You: "
        read -r user_query

        case "$user_query" in
            "exit"|"quit"|"bye"|"q")
                ai_response "Goodbye! Happy coding! 🚀"
                break
                ;;
            "help")
                echo ""
                echo "Available commands:"
                echo "• Ask any development question"
                echo "• 'context' - show current context"
                echo "• 'history' - show recent conversations"
                echo "• 'clear' - clear conversation history"
                echo "• 'exit' - end session"
                echo ""
                continue
                ;;
            "context")
                echo ""
                highlight "📊 Current Context:"
                get_context_for_query "$user_query"
                echo ""
                continue
                ;;
            "history")
                echo ""
                highlight "📜 Recent Conversations:"
                show_conversation_history 5
                echo ""
                continue
                ;;
            "clear")
                echo '{"conversations": []}' > "$CONVERSATION_LOG"
                ai_response "Conversation history cleared."
                echo ""
                continue
                ;;
            "")
                continue
                ;;
        esac

        echo ""
        local context=$(get_context_for_query "$user_query")
        local response=$(process_ai_query "$user_query" "$context")

        # Log the conversation
        log_conversation "$user_query" "$response" "$context"

        echo ""
    done
}

# Show conversation history
show_conversation_history() {
    local limit="${1:-10}"

    init_ai_data

    local conversations=$(jq -r ".conversations | sort_by(.timestamp) | reverse | .[:$limit]" "$CONVERSATION_LOG" 2>/dev/null)

    if [ "$conversations" = "[]" ] || [ "$conversations" = "null" ]; then
        info "No conversation history found"
        return
    fi

    echo "$conversations" | jq -r '.[] | "**\(.timestamp | split("T")[0]) \(.timestamp | split("T")[1] | split(".")[0])**\nYou: \(.query)\nAI: \(.response | split("\n")[0])...\n"'
}

# Quick AI query (non-interactive)
quick_query() {
    local query="$*"

    if [ -z "$query" ]; then
        error "Usage: quick_query <your question>"
        return 1
    fi

    update_context
    local context=$(get_context_for_query "$query")
    local response=$(process_ai_query "$query" "$context")

    # Log the conversation
    log_conversation "$query" "$response" "$context"
}

# Contextual code analysis
analyze_current_project() {
    update_context

    log "🔍 Analyzing current project..."

    local current_context=$(cat "$CONTEXT_FILE")
    local project_type=$(echo "$current_context" | jq -r '.project_type')
    local working_dir=$(echo "$current_context" | jq -r '.working_directory')

    echo ""
    highlight "📊 Project Analysis"
    echo "Directory: $working_dir"
    echo "Type: $project_type"

    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Git branch: $(git branch --show-current)"
        echo "Uncommitted changes: $(git status --porcelain | wc -l)"
    fi

    echo ""
    echo "🗂️ Project structure:"
    if command -v tree > /dev/null; then
        tree -L 2 -I 'node_modules|.git|__pycache__|target|build' | head -20
    else
        find . -maxdepth 2 -type d -not -path '*/.*' -not -path '*/node_modules*' | sort | head -10
    fi

    echo ""
    echo "📁 Recent files:"
    echo "$current_context" | jq -r '.recent_files[]?' | head -5

    echo ""
    ai_response "Based on this project structure, I can help you with:"
    case "$project_type" in
        "javascript")
            echo "• Node.js/JavaScript best practices"
            echo "• Package management with npm/yarn"
            echo "• Modern JS features and frameworks"
            echo "• Testing with Jest or similar"
            ;;
        "python")
            echo "• Python code optimization"
            echo "• Package management with pip/poetry"
            echo "• Testing with pytest"
            echo "• Virtual environment setup"
            ;;
        "go")
            echo "• Go idioms and best practices"
            echo "• Module management"
            echo "• Testing and benchmarking"
            echo "• Performance optimization"
            ;;
        "rust")
            echo "• Rust ownership and borrowing"
            echo "• Cargo package management"
            echo "• Testing and documentation"
            echo "• Performance and safety"
            ;;
        *)
            echo "• General programming best practices"
            echo "• Code organization and structure"
            echo "• Testing strategies"
            echo "• Documentation and maintenance"
            ;;
    esac
}

# Main function
main() {
    init_ai_data

    case "${1:-chat}" in
        "chat"|"c")
            interactive_chat
            ;;

        "ask"|"a")
            shift
            quick_query "$@"
            ;;

        "analyze"|"analysis")
            analyze_current_project
            ;;

        "history"|"h")
            show_conversation_history "${2:-10}"
            ;;

        "context")
            update_context
            highlight "📊 Current Context:"
            get_context_for_query "general"
            ;;

        "clear")
            echo '{"conversations": []}' > "$CONVERSATION_LOG"
            log "Conversation history cleared"
            ;;

        "help"|"-h"|"--help")
            echo "Personal AI Assistant - Context-aware AI helper"
            echo ""
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  chat, c                    Interactive AI chat (default)"
            echo "  ask, a <query>             Quick AI query"
            echo "  analyze                    Analyze current project"
            echo "  history, h [limit]         Show conversation history"
            echo "  context                    Show current context"
            echo "  clear                      Clear conversation history"
            echo "  help                       Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 chat                    # Start interactive session"
            echo "  $0 ask 'how to debug this error?'"
            echo "  $0 analyze                 # Analyze current project"
            echo "  $0 history 5               # Show last 5 conversations"
            ;;

        *)
            # Treat unknown commands as queries
            quick_query "$@"
            ;;
    esac
}

main "$@"
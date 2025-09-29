#!/bin/bash

# AI Helper Script
# Intelligent assistant for coding tasks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
AI_PROVIDER=${AI_PROVIDER:-"claude"}
MAX_CONTEXT_LINES=${MAX_CONTEXT_LINES:-50}
TEMPERATURE=${TEMPERATURE:-0.1}

log() {
    echo -e "${GREEN}[AI] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[AI-WARN] $1${NC}"
}

error() {
    echo -e "${RED}[AI-ERROR] $1${NC}"
}

# Get file context around current line
get_context() {
    local file="$1"
    local line_num="$2"
    local context_lines="$3"

    if [ -f "$file" ]; then
        local start_line=$((line_num - context_lines / 2))
        local end_line=$((line_num + context_lines / 2))

        if [ $start_line -lt 1 ]; then
            start_line=1
        fi

        sed -n "${start_line},${end_line}p" "$file" | cat -n
    fi
}

# Analyze code for issues
analyze_code() {
    local file="$1"

    if [ ! -f "$file" ]; then
        error "File not found: $file"
        return 1
    fi

    log "🔍 Analyzing code in $file..."

    # Basic static analysis
    local issues=()

    # Check for common issues
    if grep -n "TODO\|FIXME\|HACK" "$file" > /dev/null 2>&1; then
        issues+=("Found TODO/FIXME comments")
    fi

    if grep -n "console\.log\|print\|debugger" "$file" > /dev/null 2>&1; then
        issues+=("Debug statements found")
    fi

    # Language-specific checks
    case "${file##*.}" in
        js|ts)
            if grep -n "var " "$file" > /dev/null 2>&1; then
                issues+=("Using 'var' instead of 'let' or 'const'")
            fi
            ;;
        py)
            if grep -n "import \*" "$file" > /dev/null 2>&1; then
                issues+=("Using wildcard imports")
            fi
            ;;
        sh)
            if ! head -1 "$file" | grep -q "#!/bin/bash"; then
                issues+=("Missing shebang")
            fi
            ;;
    esac

    if [ ${#issues[@]} -gt 0 ]; then
        echo -e "${YELLOW}Issues found:${NC}"
        for issue in "${issues[@]}"; do
            echo "  • $issue"
        done
    else
        echo -e "${GREEN}No obvious issues found${NC}"
    fi
}

# Generate code suggestions
suggest_improvements() {
    local file="$1"

    log "💡 Generating improvement suggestions for $file..."

    # Analyze file structure and patterns
    local suggestions=()

    # Check file size
    local line_count=$(wc -l < "$file")
    if [ $line_count -gt 500 ]; then
        suggestions+=("File is large ($line_count lines) - consider splitting into modules")
    fi

    # Check function complexity
    case "${file##*.}" in
        js|ts)
            local long_functions=$(awk '/^function|^const.*=.*=>/{f++; start=NR} /^}$/{if(NR-start>30) print "Function around line " start " is long (" NR-start " lines)"}' "$file")
            if [ -n "$long_functions" ]; then
                suggestions+=("$long_functions")
            fi
            ;;
        py)
            local long_functions=$(awk '/^def |^async def /{f++; start=NR; indent=length($0)-length(ltrim($0))} /^$/{if(f && NR-start>30) print "Function around line " start " is long (" NR-start " lines)"; f=0}' "$file")
            if [ -n "$long_functions" ]; then
                suggestions+=("$long_functions")
            fi
            ;;
    esac

    if [ ${#suggestions[@]} -gt 0 ]; then
        echo -e "${BLUE}Suggestions:${NC}"
        for suggestion in "${suggestions[@]}"; do
            echo "  • $suggestion"
        done
    else
        echo -e "${GREEN}Code structure looks good${NC}"
    fi
}

# Interactive AI chat
chat_mode() {
    log "🤖 Starting AI chat mode (type 'exit' to quit)"
    echo "You can ask about code, debugging, best practices, etc."
    echo ""

    while true; do
        echo -n "You: "
        read -r query

        case "$query" in
            "exit"|"quit"|"q")
                log "Goodbye! 👋"
                break
                ;;
            "help")
                echo "Available commands:"
                echo "  analyze <file>     - Analyze code file"
                echo "  explain <file>     - Explain code file"
                echo "  suggest <file>     - Suggest improvements"
                echo "  debug <error>      - Help debug error"
                echo "  exit              - Exit chat mode"
                ;;
            analyze*)
                local file=$(echo "$query" | cut -d' ' -f2-)
                if [ -n "$file" ] && [ -f "$file" ]; then
                    analyze_code "$file"
                    suggest_improvements "$file"
                else
                    error "File not found or not specified"
                fi
                ;;
            explain*)
                local file=$(echo "$query" | cut -d' ' -f2-)
                if [ -n "$file" ] && [ -f "$file" ]; then
                    log "📖 Explaining $file structure..."
                    echo "File: $file"
                    echo "Lines: $(wc -l < "$file")"
                    echo "Type: ${file##*.}"
                    echo ""
                    echo "Structure overview:"
                    case "${file##*.}" in
                        js|ts)
                            grep -n "^function\|^const.*=\|^class\|^export" "$file" || echo "No major structures found"
                            ;;
                        py)
                            grep -n "^def\|^class\|^import" "$file" || echo "No major structures found"
                            ;;
                        sh)
                            grep -n "^function\|^[a-zA-Z_][a-zA-Z0-9_]*\(\)" "$file" || echo "No functions found"
                            ;;
                        *)
                            head -20 "$file"
                            ;;
                    esac
                else
                    error "File not found or not specified"
                fi
                ;;
            debug*)
                local error_msg=$(echo "$query" | cut -d' ' -f2-)
                log "🐛 Debug assistance for: $error_msg"
                echo ""
                echo "Common solutions:"
                case "$error_msg" in
                    *"undefined"*|*"not defined"*)
                        echo "• Check variable/function spelling"
                        echo "• Ensure proper import/require statements"
                        echo "• Verify variable is declared before use"
                        ;;
                    *"permission denied"*)
                        echo "• Check file permissions (chmod +x)"
                        echo "• Run with sudo if needed"
                        echo "• Check file ownership"
                        ;;
                    *"not found"*|*"no such file"*)
                        echo "• Check file path spelling"
                        echo "• Ensure file exists"
                        echo "• Check current working directory"
                        ;;
                    *)
                        echo "• Check syntax errors"
                        echo "• Review recent changes"
                        echo "• Check logs for more details"
                        echo "• Try reproducing with minimal example"
                        ;;
                esac
                ;;
            *)
                log "🤔 Processing: $query"
                # Here you would integrate with actual AI service
                echo "This would connect to AI service to answer: $query"
                echo "For now, try specific commands like 'analyze <file>' or 'debug <error>'"
                ;;
        esac
        echo ""
    done
}

# Quick code explanation
explain_code() {
    local file="$1"
    local line_start="$2"
    local line_end="$3"

    if [ ! -f "$file" ]; then
        error "File not found: $file"
        return 1
    fi

    log "📖 Explaining code in $file"

    if [ -n "$line_start" ]; then
        local lines_to_show="${line_start:-1},${line_end:-$line_start}"
        echo "Code section:"
        sed -n "${lines_to_show}p" "$file" | cat -n
        echo ""
    fi

    echo "Analysis:"
    analyze_code "$file"
}

# Main function
main() {
    case "${1:-help}" in
        "chat"|"c")
            chat_mode
            ;;
        "analyze"|"a")
            if [ -z "$2" ]; then
                error "Usage: $0 analyze <file>"
                exit 1
            fi
            analyze_code "$2"
            suggest_improvements "$2"
            ;;
        "explain"|"e")
            if [ -z "$2" ]; then
                error "Usage: $0 explain <file> [start_line] [end_line]"
                exit 1
            fi
            explain_code "$2" "$3" "$4"
            ;;
        "suggest"|"s")
            if [ -z "$2" ]; then
                error "Usage: $0 suggest <file>"
                exit 1
            fi
            suggest_improvements "$2"
            ;;
        "debug"|"d")
            shift
            log "🐛 Debug mode: $*"
            chat_mode
            ;;
        "help"|"-h"|"--help")
            echo "AI Helper - Intelligent coding assistant"
            echo ""
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  chat, c              Interactive AI chat"
            echo "  analyze, a <file>    Analyze code file"
            echo "  explain, e <file>    Explain code structure"
            echo "  suggest, s <file>    Suggest improvements"
            echo "  debug, d [error]     Debug assistance"
            echo "  help                 Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 chat"
            echo "  $0 analyze src/main.js"
            echo "  $0 explain utils.py 10 20"
            ;;
        *)
            # Treat as direct query
            log "🤖 AI Query: $*"
            chat_mode
            ;;
    esac
}

main "$@"
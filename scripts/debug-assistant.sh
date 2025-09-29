#!/bin/bash

# Debug Assistant Script
# AI-powered debugging companion

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
DEBUG_DIR="/tmp/hep-debug"

# Create debug directory
mkdir -p "$DEBUG_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[DEBUG] $1${NC}"
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

debug_info() {
    echo -e "${CYAN}[DEBUG-INFO] $1${NC}"
}

# Capture system information
capture_system_info() {
    local debug_session_file="$DEBUG_DIR/debug-session-$(date +%Y%m%d_%H%M%S).log"

    log "📊 Capturing system information..."

    cat > "$debug_session_file" << EOF
# Debug Session
Generated: $(date)
Working Directory: $(pwd)
User: $(whoami)
Shell: $SHELL

## System Info
OS: $(uname -a)
Memory: $(free -h | head -2 | tail -1 | awk '{print $3 "/" $2}' 2>/dev/null || echo "N/A")
Disk: $(df -h . | tail -1 | awk '{print $5}' 2>/dev/null || echo "N/A")

## Git Info
EOF

    if git rev-parse --git-dir > /dev/null 2>&1; then
        cat >> "$debug_session_file" << EOF
Repository: $(git remote get-url origin 2>/dev/null || echo "Local repository")
Branch: $(git branch --show-current)
Commit: $(git rev-parse --short HEAD)
Status: $(git status --porcelain | wc -l) changes
EOF
    else
        echo "Not in a git repository" >> "$debug_session_file"
    fi

    echo "" >> "$debug_session_file"
    echo "$debug_session_file"
}

# Analyze error message
analyze_error() {
    local error_msg="$1"
    local file_context="$2"

    log "🔍 Analyzing error: $error_msg"

    # Extract key information from error
    local error_type=""
    local suggestions=()

    # Common error patterns
    case "$error_msg" in
        *"not found"*|*"No such file"*|*"cannot find"*)
            error_type="File/Command Not Found"
            suggestions+=(
                "Check if the file/command exists"
                "Verify the path is correct"
                "Check current working directory with 'pwd'"
                "Use 'which <command>' to find command location"
            )
            ;;
        *"permission denied"*|*"Permission denied"*)
            error_type="Permission Error"
            suggestions+=(
                "Check file permissions with 'ls -la'"
                "Make file executable with 'chmod +x <file>'"
                "Run with sudo if needed (be careful!)"
                "Check file ownership"
            )
            ;;
        *"undefined"*|*"not defined"*|*"undeclared"*)
            error_type="Variable/Function Not Defined"
            suggestions+=(
                "Check variable/function spelling"
                "Ensure variable is declared before use"
                "Check import/include statements"
                "Verify scope and visibility"
            )
            ;;
        *"syntax error"*|*"SyntaxError"*|*"Parse error"*)
            error_type="Syntax Error"
            suggestions+=(
                "Check for missing brackets, parentheses, or quotes"
                "Look for typos in keywords"
                "Verify indentation (especially in Python)"
                "Check line endings and special characters"
            )
            ;;
        *"timeout"*|*"timed out"*)
            error_type="Timeout Error"
            suggestions+=(
                "Check network connectivity"
                "Increase timeout value if configurable"
                "Verify service is responding"
                "Check for blocking operations"
            )
            ;;
        *"out of memory"*|*"OutOfMemoryError"*|*"MemoryError"*)
            error_type="Memory Error"
            suggestions+=(
                "Check available memory with 'free -h'"
                "Close unnecessary applications"
                "Optimize code to use less memory"
                "Consider processing data in chunks"
            )
            ;;
        *"connection refused"*|*"Connection refused"*)
            error_type="Connection Error"
            suggestions+=(
                "Check if service is running"
                "Verify port number is correct"
                "Check firewall settings"
                "Ensure service is listening on correct interface"
            )
            ;;
        *)
            error_type="General Error"
            suggestions+=(
                "Check recent code changes"
                "Review error logs for more details"
                "Try reproducing with minimal example"
                "Search for similar issues online"
            )
            ;;
    esac

    echo ""
    highlight "🐛 Error Analysis:"
    echo "Type: $error_type"
    echo ""
    echo "Suggestions:"
    for suggestion in "${suggestions[@]}"; do
        echo "  💡 $suggestion"
    done

    # Language-specific suggestions
    if [ -n "$file_context" ] && [ -f "$file_context" ]; then
        echo ""
        echo "Language-specific suggestions:"
        case "${file_context##*.}" in
            js|ts)
                echo "  • Check console for additional errors"
                echo "  • Use 'debugger;' statement for breakpoints"
                echo "  • Check Node.js version compatibility"
                echo "  • Verify npm packages are installed"
                ;;
            py)
                echo "  • Check Python version compatibility"
                echo "  • Use try/except for error handling"
                echo "  • Check virtual environment is activated"
                echo "  • Verify required packages are installed"
                ;;
            sh)
                echo "  • Use 'set -x' for debug tracing"
                echo "  • Check bash/sh compatibility"
                echo "  • Use 'bash -n script.sh' to check syntax"
                echo "  • Quote variables to prevent word splitting"
                ;;
            go)
                echo "  • Use 'go fmt' to check formatting"
                echo "  • Check go.mod dependencies"
                echo "  • Use 'go vet' for static analysis"
                echo "  • Check GOPATH and GOROOT settings"
                ;;
        esac
    fi
}

# Interactive debugging session
debug_session() {
    local debug_file=$(capture_system_info)
    log "🔧 Starting interactive debugging session"
    info "Session logged to: $debug_file"

    echo ""
    echo "Debug Assistant Menu:"
    echo ""

    while true; do
        echo "1. 🐛 Analyze error message"
        echo "2. 📁 Debug specific file"
        echo "3. 🔍 Search for pattern in code"
        echo "4. 📊 Show system status"
        echo "5. 🧪 Run diagnostic tests"
        echo "6. 💾 Save debug session"
        echo "7. 🚪 Exit"
        echo ""
        echo -n "Choose option (1-7): "
        read -r choice

        case $choice in
            1)
                echo ""
                echo -n "Enter error message or paste error output: "
                read -r error_input
                echo -n "Related file (optional): "
                read -r file_input
                echo ""
                analyze_error "$error_input" "$file_input"
                ;;

            2)
                echo ""
                echo -n "File to debug: "
                read -r debug_file_input
                if [ -f "$debug_file_input" ]; then
                    debug_file_analysis "$debug_file_input"
                else
                    error "File not found: $debug_file_input"
                fi
                ;;

            3)
                echo ""
                echo -n "Pattern to search for: "
                read -r pattern
                echo -n "Directory to search (default: current): "
                read -r search_dir
                search_dir=${search_dir:-.}
                echo ""
                search_code_pattern "$pattern" "$search_dir"
                ;;

            4)
                echo ""
                show_system_status
                ;;

            5)
                echo ""
                run_diagnostic_tests
                ;;

            6)
                echo ""
                save_debug_session "$debug_file"
                ;;

            7)
                log "Debug session complete! 👋"
                exit 0
                ;;

            *)
                error "Invalid choice"
                ;;
        esac

        echo ""
        echo "Press Enter to continue..."
        read -r
        echo ""
    done
}

# Debug file analysis
debug_file_analysis() {
    local file="$1"

    log "🔍 Analyzing file: $file"

    # Basic file info
    echo "File: $file"
    echo "Size: $(ls -lh "$file" | awk '{print $5}')"
    echo "Modified: $(ls -l "$file" | awk '{print $6, $7, $8}')"
    echo "Type: ${file##*.}"
    echo ""

    # Syntax check based on file type
    case "${file##*.}" in
        js)
            if command -v node > /dev/null; then
                info "Running Node.js syntax check..."
                if node -c "$file" 2>/dev/null; then
                    echo "✅ JavaScript syntax is valid"
                else
                    echo "❌ JavaScript syntax errors found:"
                    node -c "$file" 2>&1 | head -5
                fi
            fi
            ;;

        py)
            if command -v python3 > /dev/null; then
                info "Running Python syntax check..."
                if python3 -m py_compile "$file" 2>/dev/null; then
                    echo "✅ Python syntax is valid"
                else
                    echo "❌ Python syntax errors found:"
                    python3 -m py_compile "$file" 2>&1 | head -5
                fi
            fi
            ;;

        sh)
            info "Running Bash syntax check..."
            if bash -n "$file" 2>/dev/null; then
                echo "✅ Bash syntax is valid"
            else
                echo "❌ Bash syntax errors found:"
                bash -n "$file" 2>&1 | head -5
            fi
            ;;

        go)
            if command -v go > /dev/null; then
                info "Running Go syntax check..."
                if go fmt "$file" > /dev/null 2>&1; then
                    echo "✅ Go syntax is valid"
                else
                    echo "❌ Go formatting issues found"
                fi
            fi
            ;;
    esac

    echo ""

    # Show potential issues
    info "Checking for common issues..."

    # Check for common problematic patterns
    local issues_found=false

    if grep -n "TODO\|FIXME\|BUG\|HACK" "$file" > /dev/null 2>&1; then
        echo "📝 TODO/FIXME comments found:"
        grep -n "TODO\|FIXME\|BUG\|HACK" "$file" | head -3
        issues_found=true
    fi

    if grep -n "console\.log\|print(\|println\|fmt\.Print" "$file" > /dev/null 2>&1; then
        echo "🔍 Debug statements found:"
        grep -n "console\.log\|print(\|println\|fmt\.Print" "$file" | head -3
        issues_found=true
    fi

    if ! $issues_found; then
        echo "✅ No obvious issues found"
    fi

    echo ""

    # Recent changes if in git repo
    if git rev-parse --git-dir > /dev/null 2>&1; then
        info "Recent changes to this file:"
        git log --oneline -n 3 -- "$file" 2>/dev/null || echo "No git history found for this file"
    fi
}

# Search for patterns in code
search_code_pattern() {
    local pattern="$1"
    local directory="$2"

    log "🔍 Searching for pattern: '$pattern' in $directory"

    # Search in common code files
    local found_files=()
    while IFS= read -r -d '' file; do
        found_files+=("$file")
    done < <(find "$directory" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.sh" -o -name "*.java" -o -name "*.cpp" \) -print0 2>/dev/null | head -20)

    if [ ${#found_files[@]} -eq 0 ]; then
        warn "No code files found in $directory"
        return
    fi

    local matches_found=false
    for file in "${found_files[@]}"; do
        local matches=$(grep -n "$pattern" "$file" 2>/dev/null || true)
        if [ -n "$matches" ]; then
            echo ""
            highlight "📁 $file:"
            echo "$matches" | head -5
            matches_found=true
        fi
    done

    if ! $matches_found; then
        info "Pattern '$pattern' not found in any code files"
    fi
}

# Show system status
show_system_status() {
    log "📊 System Status"

    # Memory usage
    if command -v free > /dev/null; then
        echo "Memory Usage:"
        free -h | head -2
        echo ""
    fi

    # Disk usage
    echo "Disk Usage:"
    df -h . | head -2
    echo ""

    # Process load
    if [ -f "/proc/loadavg" ]; then
        local load=$(cat /proc/loadavg | cut -d' ' -f1-3)
        echo "Load Average: $load"
        echo ""
    fi

    # Recent system errors (if accessible)
    if [ -r "/var/log/syslog" ]; then
        echo "Recent System Errors:"
        tail -5 /var/log/syslog | grep -i error || echo "No recent errors found"
        echo ""
    fi

    # Development server processes
    echo "Development Processes:"
    ps aux | grep -E "(node|python|go run|java)" | grep -v grep | head -5 || echo "No development processes found"
}

# Run diagnostic tests
run_diagnostic_tests() {
    log "🧪 Running diagnostic tests..."

    # Test common development tools
    local tools=("git" "node" "python3" "go" "java" "docker")
    echo "Tool availability:"
    for tool in "${tools[@]}"; do
        if command -v "$tool" > /dev/null; then
            echo "  ✅ $tool: $(command -v "$tool")"
        else
            echo "  ❌ $tool: not found"
        fi
    done
    echo ""

    # Test network connectivity
    echo "Network connectivity:"
    if ping -c 1 google.com > /dev/null 2>&1; then
        echo "  ✅ Internet connection: OK"
    else
        echo "  ❌ Internet connection: Failed"
    fi

    if ping -c 1 localhost > /dev/null 2>&1; then
        echo "  ✅ Localhost: OK"
    else
        echo "  ❌ Localhost: Failed"
    fi
    echo ""

    # Test file permissions
    echo "File permissions in current directory:"
    local unreadable_files=$(find . -maxdepth 2 -type f ! -readable 2>/dev/null | head -3)
    if [ -n "$unreadable_files" ]; then
        echo "  ⚠️  Some files are not readable:"
        echo "$unreadable_files"
    else
        echo "  ✅ All files readable"
    fi

    # Check for large log files
    echo ""
    echo "Large files (>10MB) in current directory:"
    find . -maxdepth 2 -type f -size +10M 2>/dev/null | head -3 || echo "  ✅ No large files found"
}

# Save debug session
save_debug_session() {
    local session_file="$1"
    local save_file="debug-session-$(date +%Y%m%d_%H%M%S).md"

    log "💾 Saving debug session to: $save_file"

    cat > "$save_file" << EOF
# Debug Session Report

$(cat "$session_file")

## Session Summary
- Duration: Started $(date)
- Issues investigated: [Add summary here]
- Solutions found: [Add summary here]
- Next steps: [Add action items here]

---
Generated by High-Efficiency Programmer Debug Assistant
EOF

    info "Debug session saved to: $save_file"
}

# Quick error lookup
quick_lookup() {
    local error_pattern="$1"

    log "🔎 Quick lookup for: $error_pattern"
    analyze_error "$error_pattern" ""
}

# Main function
main() {
    case "${1:-session}" in
        "analyze"|"a")
            if [ -z "$2" ]; then
                error "Usage: $0 analyze 'error message' [file]"
                exit 1
            fi
            analyze_error "$2" "$3"
            ;;

        "file"|"f")
            if [ -z "$2" ]; then
                error "Usage: $0 file <filename>"
                exit 1
            fi
            debug_file_analysis "$2"
            ;;

        "search"|"s")
            if [ -z "$2" ]; then
                error "Usage: $0 search <pattern> [directory]"
                exit 1
            fi
            search_code_pattern "$2" "${3:-.}"
            ;;

        "status"|"st")
            show_system_status
            ;;

        "test"|"t")
            run_diagnostic_tests
            ;;

        "lookup"|"l")
            if [ -z "$2" ]; then
                error "Usage: $0 lookup 'error pattern'"
                exit 1
            fi
            quick_lookup "$2"
            ;;

        "session"|"i")
            debug_session
            ;;

        "help"|"-h"|"--help")
            echo "Debug Assistant - AI-powered debugging companion"
            echo ""
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  analyze, a <error> [file]    Analyze error message"
            echo "  file, f <filename>           Debug specific file"
            echo "  search, s <pattern> [dir]    Search for pattern in code"
            echo "  status, st                   Show system status"
            echo "  test, t                      Run diagnostic tests"
            echo "  lookup, l <error>            Quick error lookup"
            echo "  session, i                   Interactive debugging session (default)"
            echo "  help                         Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 analyze 'permission denied' script.sh"
            echo "  $0 file src/main.js"
            echo "  $0 search 'undefined variable'"
            echo "  $0 session"
            ;;

        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

main "$@"
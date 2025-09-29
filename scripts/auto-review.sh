#!/bin/bash

# Auto Review Script
# Automated code review with AI assistance

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
REVIEW_DIR="/tmp/hep-reviews"

# Create review directory
mkdir -p "$REVIEW_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[REVIEW] $1${NC}"
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

# Check if in git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not in a git repository"
        exit 1
    fi
}

# Get changed files
get_changed_files() {
    local comparison="${1:-HEAD~1}"
    git diff --name-only "$comparison" | grep -E '\.(js|ts|py|go|rs|java|cpp|c|sh|php)$' || true
}

# Get file diff
get_file_diff() {
    local file="$1"
    local comparison="${2:-HEAD~1}"
    git diff "$comparison" -- "$file"
}

# Analyze code complexity
analyze_complexity() {
    local file="$1"

    info "🧮 Analyzing complexity for $file"

    case "${file##*.}" in
        js|ts)
            # Count functions, loops, conditions
            local functions=$(grep -c "function\|=>" "$file" 2>/dev/null || echo "0")
            local loops=$(grep -c "for\|while" "$file" 2>/dev/null || echo "0")
            local conditions=$(grep -c "if\|switch\|case" "$file" 2>/dev/null || echo "0")
            local lines=$(wc -l < "$file")

            echo "  Functions: $functions"
            echo "  Loops: $loops"
            echo "  Conditions: $conditions"
            echo "  Lines: $lines"

            if [ "$lines" -gt 300 ]; then
                warn "  File is large (>300 lines) - consider splitting"
            fi
            ;;
        py)
            local functions=$(grep -c "^def\|^async def" "$file" 2>/dev/null || echo "0")
            local classes=$(grep -c "^class" "$file" 2>/dev/null || echo "0")
            local imports=$(grep -c "^import\|^from.*import" "$file" 2>/dev/null || echo "0")
            local lines=$(wc -l < "$file")

            echo "  Functions: $functions"
            echo "  Classes: $classes"
            echo "  Imports: $imports"
            echo "  Lines: $lines"

            if [ "$lines" -gt 500 ]; then
                warn "  File is large (>500 lines) - consider splitting"
            fi
            ;;
        go)
            local functions=$(grep -c "^func" "$file" 2>/dev/null || echo "0")
            local structs=$(grep -c "^type.*struct" "$file" 2>/dev/null || echo "0")
            local interfaces=$(grep -c "^type.*interface" "$file" 2>/dev/null || echo "0")
            local lines=$(wc -l < "$file")

            echo "  Functions: $functions"
            echo "  Structs: $structs"
            echo "  Interfaces: $interfaces"
            echo "  Lines: $lines"
            ;;
        *)
            local lines=$(wc -l < "$file")
            echo "  Lines: $lines"
            ;;
    esac
}

# Check code quality issues
check_quality_issues() {
    local file="$1"

    info "🔍 Checking quality issues for $file"

    local issues=()

    # General checks
    if grep -n "TODO\|FIXME\|HACK\|XXX" "$file" > /dev/null 2>&1; then
        issues+=("Contains TODO/FIXME comments")
    fi

    if grep -n "console\.log\|print(\|println!\|fmt\.Print" "$file" > /dev/null 2>&1; then
        issues+=("Contains debug print statements")
    fi

    # Language-specific checks
    case "${file##*.}" in
        js|ts)
            if grep -n "var " "$file" > /dev/null 2>&1; then
                issues+=("Uses 'var' instead of 'let'/'const'")
            fi

            if grep -n "== " "$file" > /dev/null 2>&1; then
                issues+=("Uses '==' instead of '==='")
            fi

            if grep -n "function.*{$" "$file" | wc -l | awk '{if($1>20) print "too many"}' | grep -q "too many"; then
                issues+=("File has many functions - consider splitting")
            fi
            ;;

        py)
            if grep -n "import \*" "$file" > /dev/null 2>&1; then
                issues+=("Uses wildcard imports")
            fi

            if grep -n "except:" "$file" > /dev/null 2>&1; then
                issues+=("Uses bare except clauses")
            fi

            if ! head -1 "$file" | grep -q "#!/usr/bin/env python\|# -*- coding:" && [ $(wc -l < "$file") -gt 10 ]; then
                issues+=("Missing encoding declaration or shebang")
            fi
            ;;

        go)
            if ! grep -q "package " "$file"; then
                issues+=("Missing package declaration")
            fi

            if grep -n "fmt\.Print" "$file" > /dev/null 2>&1; then
                issues+=("Uses fmt.Print for debugging")
            fi
            ;;

        sh)
            if ! head -1 "$file" | grep -q "#!/bin/bash\|#!/bin/sh"; then
                issues+=("Missing shebang")
            fi

            if ! grep -q "set -e" "$file" && [ $(wc -l < "$file") -gt 20 ]; then
                issues+=("Missing 'set -e' for error handling")
            fi
            ;;
    esac

    if [ ${#issues[@]} -gt 0 ]; then
        echo -e "${YELLOW}Issues found:${NC}"
        for issue in "${issues[@]}"; do
            echo "  ❌ $issue"
        done
    else
        echo -e "${GREEN}  ✅ No obvious issues found${NC}"
    fi
}

# Security checks
check_security() {
    local file="$1"

    info "🔒 Security check for $file"

    local security_issues=()

    # Check for common security issues
    if grep -ni "password\|secret\|token\|api_key" "$file" | grep -v "placeholder\|example\|test" > /dev/null 2>&1; then
        security_issues+=("Potential hardcoded credentials")
    fi

    if grep -n "eval\|exec\|system\|shell_exec" "$file" > /dev/null 2>&1; then
        security_issues+=("Potentially dangerous function calls")
    fi

    case "${file##*.}" in
        js|ts)
            if grep -n "innerHTML\|document\.write" "$file" > /dev/null 2>&1; then
                security_issues+=("Potential XSS vulnerability")
            fi
            ;;
        py)
            if grep -n "subprocess\|os\.system" "$file" > /dev/null 2>&1; then
                security_issues+=("System command execution - verify input validation")
            fi
            ;;
        sh)
            if grep -n '\$(' "$file" | grep -v "echo\|date\|pwd\|dirname" > /dev/null 2>&1; then
                security_issues+=("Command substitution - verify input sanitization")
            fi
            ;;
    esac

    if [ ${#security_issues[@]} -gt 0 ]; then
        echo -e "${RED}Security concerns:${NC}"
        for issue in "${security_issues[@]}"; do
            echo "  ⚠️  $issue"
        done
    else
        echo -e "${GREEN}  ✅ No security issues detected${NC}"
    fi
}

# Performance analysis
analyze_performance() {
    local file="$1"

    info "⚡ Performance analysis for $file"

    local perf_issues=()

    case "${file##*.}" in
        js|ts)
            if grep -n "for.*in.*" "$file" > /dev/null 2>&1; then
                perf_issues+=("Consider for...of instead of for...in")
            fi

            if grep -n "innerHTML.*+=" "$file" > /dev/null 2>&1; then
                perf_issues+=("innerHTML concatenation can be slow")
            fi
            ;;

        py)
            if grep -n "\.append.*for.*in" "$file" > /dev/null 2>&1; then
                perf_issues+=("Consider list comprehension instead of append in loop")
            fi

            if grep -n "global " "$file" > /dev/null 2>&1; then
                perf_issues+=("Global variables can impact performance")
            fi
            ;;

        go)
            if grep -n "fmt\.Sprintf.*+.*fmt\.Sprintf" "$file" > /dev/null 2>&1; then
                perf_issues+=("Multiple string formatting calls - consider strings.Builder")
            fi
            ;;
    esac

    # Check for large functions
    case "${file##*.}" in
        js|ts|py|go)
            local large_funcs=$(awk '
                /^function|^def |^func / { start=NR; fname=$2 }
                /^}$|^[[:space:]]*$/ {
                    if (start && NR-start > 50) {
                        print "Function " fname " is large (" NR-start " lines)"
                    }
                    start=0
                }
            ' "$file")

            if [ -n "$large_funcs" ]; then
                perf_issues+=("$large_funcs")
            fi
            ;;
    esac

    if [ ${#perf_issues[@]} -gt 0 ]; then
        echo -e "${YELLOW}Performance suggestions:${NC}"
        for issue in "${perf_issues[@]}"; do
            echo "  💡 $issue"
        done
    else
        echo -e "${GREEN}  ✅ No performance issues detected${NC}"
    fi
}

# Generate review report
generate_review_report() {
    local files=("$@")
    local report_file="$REVIEW_DIR/review-$(date +%Y%m%d_%H%M%S).md"

    log "📄 Generating review report: $report_file"

    cat > "$report_file" << EOF
# Code Review Report

**Generated:** $(date)
**Repository:** $(git remote get-url origin 2>/dev/null || echo "Local repository")
**Branch:** $(git branch --show-current)
**Commit:** $(git rev-parse --short HEAD)

## Summary

- **Files reviewed:** ${#files[@]}
- **Total changes:** $(git diff --stat HEAD~1 | tail -1 || echo "N/A")

## Files Analyzed

EOF

    for file in "${files[@]}"; do
        echo "### 📁 $file" >> "$report_file"
        echo "" >> "$report_file"

        # Add diff stats
        local additions=$(git diff --numstat HEAD~1 -- "$file" | cut -f1)
        local deletions=$(git diff --numstat HEAD~1 -- "$file" | cut -f2)
        echo "**Changes:** +$additions -$deletions lines" >> "$report_file"
        echo "" >> "$report_file"

        # Add complexity metrics
        echo "**Complexity:**" >> "$report_file"
        analyze_complexity "$file" >> "$report_file" 2>&1
        echo "" >> "$report_file"

        # Add diff preview
        echo "**Changes preview:**" >> "$report_file"
        echo '```diff' >> "$report_file"
        git diff HEAD~1 -- "$file" | head -50 >> "$report_file"
        echo '```' >> "$report_file"
        echo "" >> "$report_file"
    done

    # Add recommendations
    cat >> "$report_file" << EOF

## Recommendations

1. ✅ **Code Quality:** Ensure consistent formatting and naming
2. 🔒 **Security:** Verify input validation and avoid hardcoded secrets
3. ⚡ **Performance:** Consider optimization opportunities
4. 🧪 **Testing:** Add or update tests for new functionality
5. 📝 **Documentation:** Update comments and README if needed

## Next Steps

- [ ] Address any security concerns
- [ ] Add tests if missing
- [ ] Update documentation
- [ ] Consider refactoring large functions
- [ ] Run full test suite before merge

---
*Generated by High-Efficiency Programmer System*
EOF

    info "Review report saved to: $report_file"

    # Show report summary
    echo ""
    highlight "📊 Review Summary:"
    echo "Files: ${#files[@]}"
    echo "Report: $report_file"
}

# Interactive review mode
interactive_review() {
    log "🔍 Starting interactive code review"

    while true; do
        echo ""
        echo "Review Options:"
        echo "1. Review changed files (vs last commit)"
        echo "2. Review specific file"
        echo "3. Review staged changes"
        echo "4. Full project review"
        echo "5. Generate review report"
        echo "6. Exit"
        echo ""
        echo -n "Choose option (1-6): "
        read -r choice

        case $choice in
            1)
                echo ""
                local files=($(get_changed_files))
                if [ ${#files[@]} -eq 0 ]; then
                    info "No changed files found"
                else
                    log "Reviewing ${#files[@]} changed files..."
                    for file in "${files[@]}"; do
                        echo ""
                        highlight "📁 Reviewing: $file"
                        analyze_complexity "$file"
                        check_quality_issues "$file"
                        check_security "$file"
                        analyze_performance "$file"
                    done
                fi
                ;;
            2)
                echo ""
                echo -n "File path to review: "
                read -r file_path
                if [ -f "$file_path" ]; then
                    echo ""
                    highlight "📁 Reviewing: $file_path"
                    analyze_complexity "$file_path"
                    check_quality_issues "$file_path"
                    check_security "$file_path"
                    analyze_performance "$file_path"
                else
                    error "File not found: $file_path"
                fi
                ;;
            3)
                echo ""
                local staged_files=($(git diff --cached --name-only | grep -E '\.(js|ts|py|go|rs|java|cpp|c|sh|php)$' || true))
                if [ ${#staged_files[@]} -eq 0 ]; then
                    info "No staged files found"
                else
                    log "Reviewing ${#staged_files[@]} staged files..."
                    for file in "${staged_files[@]}"; do
                        echo ""
                        highlight "📁 Reviewing: $file"
                        analyze_complexity "$file"
                        check_quality_issues "$file"
                        check_security "$file"
                        analyze_performance "$file"
                    done
                fi
                ;;
            4)
                echo ""
                warn "Full project review can take time. Continue? (y/N)"
                read -r confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    log "Starting full project review..."
                    local all_files=($(find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs" | grep -v node_modules | grep -v ".git" | head -20))
                    for file in "${all_files[@]}"; do
                        echo ""
                        highlight "📁 Reviewing: $file"
                        check_quality_issues "$file"
                        check_security "$file"
                    done
                else
                    info "Full review cancelled"
                fi
                ;;
            5)
                echo ""
                local files_to_report=($(get_changed_files))
                if [ ${#files_to_report[@]} -eq 0 ]; then
                    warn "No changed files to report on"
                else
                    generate_review_report "${files_to_report[@]}"
                fi
                ;;
            6)
                log "Review session complete! 👋"
                exit 0
                ;;
            *)
                error "Invalid choice"
                ;;
        esac

        echo ""
        echo "Press Enter to continue..."
        read -r
    done
}

# Main function
main() {
    check_git_repo

    case "${1:-interactive}" in
        "changed"|"c")
            local files=($(get_changed_files "${2:-HEAD~1}"))
            if [ ${#files[@]} -eq 0 ]; then
                info "No changed files found"
                exit 0
            fi

            log "Reviewing ${#files[@]} changed files..."
            for file in "${files[@]}"; do
                echo ""
                highlight "📁 $file"
                analyze_complexity "$file"
                check_quality_issues "$file"
                check_security "$file"
                analyze_performance "$file"
            done
            ;;

        "file"|"f")
            if [ -z "$2" ]; then
                error "Usage: $0 file <filename>"
                exit 1
            fi

            if [ ! -f "$2" ]; then
                error "File not found: $2"
                exit 1
            fi

            highlight "📁 Reviewing: $2"
            analyze_complexity "$2"
            check_quality_issues "$2"
            check_security "$2"
            analyze_performance "$2"
            ;;

        "staged"|"s")
            local staged_files=($(git diff --cached --name-only | grep -E '\.(js|ts|py|go|rs|java|cpp|c|sh|php)$' || true))
            if [ ${#staged_files[@]} -eq 0 ]; then
                info "No staged files found"
                exit 0
            fi

            log "Reviewing ${#staged_files[@]} staged files..."
            for file in "${staged_files[@]}"; do
                echo ""
                highlight "📁 $file"
                analyze_complexity "$file"
                check_quality_issues "$file"
                check_security "$file"
                analyze_performance "$file"
            done
            ;;

        "report"|"r")
            local files_for_report=($(get_changed_files "${2:-HEAD~1}"))
            if [ ${#files_for_report[@]} -eq 0 ]; then
                warn "No changed files to report on"
                exit 1
            fi
            generate_review_report "${files_for_report[@]}"
            ;;

        "interactive"|"i")
            interactive_review
            ;;

        "help"|"-h"|"--help")
            echo "Auto Review - Automated code review with AI assistance"
            echo ""
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  changed, c [commit]    Review changed files (default: vs HEAD~1)"
            echo "  file, f <filename>     Review specific file"
            echo "  staged, s              Review staged files"
            echo "  report, r [commit]     Generate review report"
            echo "  interactive, i         Interactive review mode (default)"
            echo "  help                   Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 changed            # Review changes vs last commit"
            echo "  $0 file src/main.js   # Review specific file"
            echo "  $0 staged             # Review staged changes"
            echo "  $0 report             # Generate markdown report"
            ;;

        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

main "$@"
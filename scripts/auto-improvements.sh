#!/bin/bash

# Auto Improvements Script
# Automated code analysis and improvement suggestions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
DATA_DIR="$HOME/.hep-data"
IMPROVEMENTS_LOG="$DATA_DIR/improvements.json"

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
    echo -e "${GREEN}[IMPROVEMENTS] $1${NC}"
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

suggestion() {
    echo -e "${CYAN}💡 $1${NC}"
}

# Initialize improvements log
init_improvements_log() {
    if [ ! -f "$IMPROVEMENTS_LOG" ]; then
        cat > "$IMPROVEMENTS_LOG" << EOF
{
    "suggestions": [],
    "applied": [],
    "ignored": [],
    "project_stats": {},
    "last_scan": null
}
EOF
        log "Initialized improvements log"
    fi
}

# Scan project for improvement opportunities
scan_project() {
    local target_dir="${1:-.}"

    log "🔍 Scanning project for improvement opportunities..."

    init_improvements_log

    # Clear previous suggestions
    jq '.suggestions = [] | .last_scan = now' "$IMPROVEMENTS_LOG" > "/tmp/improvements_temp.json"
    mv "/tmp/improvements_temp.json" "$IMPROVEMENTS_LOG"

    # Find code files
    local code_files=()
    while IFS= read -r -d '' file; do
        code_files+=("$file")
    done < <(find "$target_dir" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.sh" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/target/*" -not -path "*/build/*" -print0 2>/dev/null)

    if [ ${#code_files[@]} -eq 0 ]; then
        warn "No code files found for analysis"
        return
    fi

    info "Analyzing ${#code_files[@]} code files..."

    local suggestions=()
    local total_issues=0

    # Analyze each file
    for file in "${code_files[@]}"; do
        local file_suggestions=$(analyze_file "$file")
        if [ -n "$file_suggestions" ]; then
            suggestions+=("$file_suggestions")
            total_issues=$((total_issues + 1))
        fi
    done

    # Project-level analysis
    analyze_project_structure "$target_dir"

    # Generate summary
    echo ""
    highlight "📊 Scan Results"
    echo "Files analyzed: ${#code_files[@]}"
    echo "Files with suggestions: $total_issues"
    echo "Total suggestions generated: $(jq '.suggestions | length' "$IMPROVEMENTS_LOG")"

    show_priority_suggestions
}

# Analyze individual file
analyze_file() {
    local file="$1"
    local suggestions=()

    # Language-specific analysis
    case "${file##*.}" in
        js|ts)
            analyze_javascript_file "$file"
            ;;
        py)
            analyze_python_file "$file"
            ;;
        go)
            analyze_go_file "$file"
            ;;
        rs)
            analyze_rust_file "$file"
            ;;
        sh)
            analyze_shell_file "$file"
            ;;
        java)
            analyze_java_file "$file"
            ;;
    esac
}

# JavaScript/TypeScript analysis
analyze_javascript_file() {
    local file="$1"
    local suggestions=()

    # Check for var usage
    if grep -n "var " "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "style" "Replace 'var' with 'let' or 'const' for better scoping" "medium"
    fi

    # Check for == usage
    if grep -n "[^=!]==[^=]" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "style" "Use '===' instead of '==' for strict equality" "medium"
    fi

    # Check for console.log in production code
    if grep -n "console\.log" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "cleanup" "Remove console.log statements before production" "low"
    fi

    # Check for large functions
    local function_lines=$(awk '/^function|^const.*=.*=>/{start=NR} /^}$/{if(NR-start>50) print "Function at line " start " is too long (" NR-start " lines)"}' "$file")
    if [ -n "$function_lines" ]; then
        add_suggestion "$file" "refactor" "Consider breaking down large functions: $function_lines" "high"
    fi

    # Check for missing error handling
    if grep -n "fetch\|axios\|request" "$file" > /dev/null 2>&1 && ! grep -n "catch\|\.catch\|try.*catch" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "error_handling" "Add error handling for async operations" "high"
    fi

    # Check for magic numbers
    local magic_numbers=$(grep -n "[^a-zA-Z][0-9]\{2,\}[^a-zA-Z]" "$file" | grep -v "0\|1\|2\|10\|100" | head -3)
    if [ -n "$magic_numbers" ]; then
        add_suggestion "$file" "maintainability" "Consider extracting magic numbers into named constants" "medium"
    fi
}

# Python analysis
analyze_python_file() {
    local file="$1"

    # Check for wildcard imports
    if grep -n "from .* import \*" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "style" "Avoid wildcard imports for better code clarity" "medium"
    fi

    # Check for bare except clauses
    if grep -n "except:" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "error_handling" "Use specific exception types instead of bare 'except:'" "high"
    fi

    # Check for print statements (potential debug code)
    if grep -n "print(" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "cleanup" "Consider using logging instead of print statements" "low"
    fi

    # Check for long lines
    local long_lines=$(awk 'length>120 {print "Line " NR ": " length " characters"}' "$file" | head -3)
    if [ -n "$long_lines" ]; then
        add_suggestion "$file" "style" "Consider breaking long lines (>120 chars): $long_lines" "low"
    fi

    # Check for missing docstrings in functions
    if grep -n "^def " "$file" > /dev/null 2>&1; then
        local functions_without_docs=$(awk '/^def / {func=NR; getline; if($0 !~ /^[[:space:]]*"""/) print "Function at line " func " missing docstring"}' "$file" | head -2)
        if [ -n "$functions_without_docs" ]; then
            add_suggestion "$file" "documentation" "Add docstrings to functions: $functions_without_docs" "medium"
        fi
    fi
}

# Go analysis
analyze_go_file() {
    local file="$1"

    # Check for missing error handling
    if grep -n "err.*=" "$file" > /dev/null 2>&1 && ! grep -n "if err != nil" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "error_handling" "Check for proper error handling patterns" "high"
    fi

    # Check for fmt.Print usage (debug statements)
    if grep -n "fmt\.Print" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "cleanup" "Remove debug print statements" "low"
    fi

    # Check for missing package comments
    if ! head -5 "$file" | grep -q "// Package\|//.*package" && grep -q "^package " "$file"; then
        add_suggestion "$file" "documentation" "Add package documentation comment" "low"
    fi
}

# Shell script analysis
analyze_shell_file() {
    local file="$1"

    # Check for missing shebang
    if ! head -1 "$file" | grep -q "^#!/"; then
        add_suggestion "$file" "compatibility" "Add shebang line for better portability" "medium"
    fi

    # Check for missing 'set -e'
    if ! grep -q "set -e" "$file" && [ $(wc -l < "$file") -gt 20 ]; then
        add_suggestion "$file" "reliability" "Consider adding 'set -e' for better error handling" "medium"
    fi

    # Check for unquoted variables
    local unquoted_vars=$(grep -n '\$[a-zA-Z_][a-zA-Z0-9_]*[^"]' "$file" | grep -v echo | head -2)
    if [ -n "$unquoted_vars" ]; then
        add_suggestion "$file" "reliability" "Quote variables to prevent word splitting: $unquoted_vars" "high"
    fi
}

# Rust analysis
analyze_rust_file() {
    local file="$1"

    # Check for unwrap() usage
    if grep -n "\.unwrap()" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "error_handling" "Consider using proper error handling instead of unwrap()" "high"
    fi

    # Check for println! (debug statements)
    if grep -n "println!" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "cleanup" "Remove debug println! statements" "low"
    fi
}

# Java analysis
analyze_java_file() {
    local file="$1"

    # Check for System.out.println (debug statements)
    if grep -n "System\.out\.println" "$file" > /dev/null 2>&1; then
        add_suggestion "$file" "cleanup" "Use proper logging instead of System.out.println" "low"
    fi

    # Check for missing Javadoc on public methods
    if grep -n "public.*(" "$file" > /dev/null 2>&1; then
        local methods_without_docs=$(awk '/public.*\(/ {method=NR; for(i=1;i<=3;i++) {getline prev; if(prev ~ /\/\*\*/) found=1} if(!found) print "Method at line " method " missing Javadoc"; found=0}' "$file" | head -2)
        if [ -n "$methods_without_docs" ]; then
            add_suggestion "$file" "documentation" "Add Javadoc to public methods: $methods_without_docs" "medium"
        fi
    fi
}

# Project structure analysis
analyze_project_structure() {
    local project_dir="$1"

    # Check for common files
    if [ ! -f "$project_dir/README.md" ]; then
        add_suggestion "project" "documentation" "Add a README.md file to document the project" "high"
    fi

    if [ ! -f "$project_dir/.gitignore" ] && git rev-parse --git-dir > /dev/null 2>&1; then
        add_suggestion "project" "git" "Add .gitignore file to exclude unnecessary files" "medium"
    fi

    # Language-specific project structure
    if [ -f "$project_dir/package.json" ]; then
        # Node.js project
        if [ ! -d "$project_dir/tests" ] && [ ! -d "$project_dir/test" ] && [ ! -d "$project_dir/__tests__" ]; then
            add_suggestion "project" "testing" "Create a test directory for your JavaScript project" "medium"
        fi

        if ! grep -q "scripts" "$project_dir/package.json" || ! grep -q "test" "$project_dir/package.json"; then
            add_suggestion "project" "build" "Add npm scripts for testing and building" "low"
        fi
    fi

    if [ -f "$project_dir/requirements.txt" ] || [ -f "$project_dir/pyproject.toml" ]; then
        # Python project
        if [ ! -d "$project_dir/tests" ] && [ ! -d "$project_dir/test" ]; then
            add_suggestion "project" "testing" "Create a test directory for your Python project" "medium"
        fi
    fi

    # Check for large directories
    local large_dirs=$(find "$project_dir" -type d -not -path "*/node_modules*" -not -path "*/.git*" -exec sh -c 'echo $(find "{}" -maxdepth 1 -type f | wc -l) {}' \; | awk '$1 > 20 {print $2 " has " $1 " files"}' | head -2)
    if [ -n "$large_dirs" ]; then
        add_suggestion "project" "organization" "Consider organizing large directories: $large_dirs" "low"
    fi
}

# Add suggestion to log
add_suggestion() {
    local file="$1"
    local category="$2"
    local description="$3"
    local priority="$4"

    local suggestion=$(cat << EOF
{
    "file": "$file",
    "category": "$category",
    "description": "$description",
    "priority": "$priority",
    "timestamp": "$(date -Iseconds)",
    "status": "new"
}
EOF
    )

    local updated_log=$(jq ".suggestions += [$suggestion]" "$IMPROVEMENTS_LOG")
    echo "$updated_log" > "$IMPROVEMENTS_LOG"
}

# Show priority suggestions
show_priority_suggestions() {
    init_improvements_log

    echo ""
    highlight "🎯 Priority Suggestions"

    # High priority suggestions
    local high_priority=$(jq -r '.suggestions | map(select(.priority == "high")) | sort_by(.category) | .[] | "🔴 [\(.category)] \(.file): \(.description)"' "$IMPROVEMENTS_LOG" 2>/dev/null)

    if [ -n "$high_priority" ]; then
        echo ""
        echo "High Priority:"
        echo "$high_priority" | head -5
    fi

    # Medium priority suggestions
    local medium_priority=$(jq -r '.suggestions | map(select(.priority == "medium")) | sort_by(.category) | .[] | "🟡 [\(.category)] \(.file): \(.description)"' "$IMPROVEMENTS_LOG" 2>/dev/null)

    if [ -n "$medium_priority" ]; then
        echo ""
        echo "Medium Priority:"
        echo "$medium_priority" | head -5
    fi

    # Show suggestion categories
    echo ""
    highlight "📊 Suggestion Categories"
    jq -r '.suggestions | group_by(.category) | .[] | "\(.[0].category): \(length) suggestions"' "$IMPROVEMENTS_LOG" | sort
}

# Show detailed suggestions
show_detailed_suggestions() {
    local category="$1"
    local priority="$2"

    init_improvements_log

    highlight "📋 Detailed Suggestions"

    local filter='.'
    if [ -n "$category" ]; then
        filter="$filter | map(select(.category == \"$category\"))"
    fi
    if [ -n "$priority" ]; then
        filter="$filter | map(select(.priority == \"$priority\"))"
    fi

    local suggestions=$(jq -r ".suggestions | $filter | sort_by(.priority, .category) | .[] | \"📁 \(.file)\n   Category: \(.category)\n   Priority: \(.priority)\n   📝 \(.description)\n\"" "$IMPROVEMENTS_LOG" 2>/dev/null)

    if [ -n "$suggestions" ]; then
        echo "$suggestions"
    else
        info "No suggestions found matching the criteria"
    fi
}

# Apply automatic improvements
apply_automatic_improvements() {
    log "🔧 Applying automatic improvements..."

    # Example automatic improvements
    local applied_count=0

    # Remove trailing whitespace
    find . -type f -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs" | while read -r file; do
        if sed -i 's/[[:space:]]*$//' "$file" 2>/dev/null; then
            applied_count=$((applied_count + 1))
            info "Removed trailing whitespace from $file"
        fi
    done

    # Add final newlines
    find . -type f -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs" | while read -r file; do
        if [ -n "$(tail -c1 "$file")" ]; then
            echo "" >> "$file"
            info "Added final newline to $file"
            applied_count=$((applied_count + 1))
        fi
    done

    info "Applied $applied_count automatic improvements"
}

# Generate improvement report
generate_improvement_report() {
    local output_file="improvement-report-$(date +%Y%m%d).md"

    init_improvements_log

    log "📄 Generating improvement report: $output_file"

    cat > "$output_file" << EOF
# Code Improvement Report

**Generated:** $(date)
**Project:** $(basename "$(pwd)")
**Last Scan:** $(jq -r '.last_scan // "Never"' "$IMPROVEMENTS_LOG")

## Summary

$(jq -r '.suggestions | length' "$IMPROVEMENTS_LOG") total suggestions found across the project.

### By Priority
- High Priority: $(jq -r '.suggestions | map(select(.priority == "high")) | length' "$IMPROVEMENTS_LOG") suggestions
- Medium Priority: $(jq -r '.suggestions | map(select(.priority == "medium")) | length' "$IMPROVEMENTS_LOG") suggestions
- Low Priority: $(jq -r '.suggestions | map(select(.priority == "low")) | length' "$IMPROVEMENTS_LOG") suggestions

### By Category
$(jq -r '.suggestions | group_by(.category) | .[] | "- \(.[0].category | ascii_upcase): \(length) suggestions"' "$IMPROVEMENTS_LOG")

## High Priority Issues

$(jq -r '.suggestions | map(select(.priority == "high")) | sort_by(.category) | .[] | "### \(.file)\n**Category:** \(.category)\n**Issue:** \(.description)\n"' "$IMPROVEMENTS_LOG")

## Recommendations

1. **Address High Priority Issues First** - Focus on error handling and reliability improvements
2. **Establish Code Standards** - Implement consistent formatting and style guidelines
3. **Add Documentation** - Improve code maintainability with proper documentation
4. **Implement Testing** - Ensure code quality with comprehensive test coverage
5. **Regular Maintenance** - Schedule regular code reviews and improvement scans

---
*Generated by High-Efficiency Programmer System - Auto Improvements*
EOF

    info "Report saved to: $output_file"
}

# Main function
main() {
    case "${1:-scan}" in
        "scan"|"s")
            scan_project "${2:-.}"
            ;;

        "show"|"list"|"l")
            show_detailed_suggestions "$2" "$3"
            ;;

        "priority"|"p")
            show_priority_suggestions
            ;;

        "apply"|"a")
            apply_automatic_improvements
            ;;

        "report"|"r")
            generate_improvement_report
            ;;

        "clear"|"c")
            echo '{"suggestions": [], "applied": [], "ignored": [], "project_stats": {}, "last_scan": null}' > "$IMPROVEMENTS_LOG"
            log "Cleared improvement suggestions"
            ;;

        "help"|"-h"|"--help")
            echo "Auto Improvements - Automated code analysis and suggestions"
            echo ""
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  scan, s [directory]        Scan project for improvements (default: current)"
            echo "  show, list, l [cat] [pri]  Show detailed suggestions"
            echo "  priority, p                Show priority suggestions"
            echo "  apply, a                   Apply automatic improvements"
            echo "  report, r                  Generate improvement report"
            echo "  clear, c                   Clear suggestion log"
            echo "  help                       Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 scan                    # Scan current project"
            echo "  $0 show style high         # Show high priority style suggestions"
            echo "  $0 apply                   # Apply automatic fixes"
            echo "  $0 report                  # Generate improvement report"
            ;;

        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

main "$@"
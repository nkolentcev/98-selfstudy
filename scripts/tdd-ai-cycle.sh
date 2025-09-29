#!/bin/bash

# TDD AI Cycle Script
# Test-Driven Development with AI assistance

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
AI_HELPER="$SCRIPT_DIR/ai-helper.sh"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[TDD] $1${NC}"
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

# Detect project type and test framework
detect_test_framework() {
    local project_type=""
    local test_command=""
    local test_pattern=""

    # Check for various project types
    if [ -f "package.json" ]; then
        project_type="javascript"
        if grep -q "jest" package.json; then
            test_command="npm test"
            test_pattern="*.test.js|*.spec.js"
        elif grep -q "vitest" package.json; then
            test_command="npm run test"
            test_pattern="*.test.js|*.spec.js"
        elif grep -q "mocha" package.json; then
            test_command="npm test"
            test_pattern="*.test.js|*.spec.js"
        else
            test_command="npm test"
            test_pattern="*.test.js"
        fi
    elif [ -f "Cargo.toml" ]; then
        project_type="rust"
        test_command="cargo test"
        test_pattern="*.rs"
    elif [ -f "go.mod" ] || [ -f "go.sum" ]; then
        project_type="go"
        test_command="go test ./..."
        test_pattern="*_test.go"
    elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
        project_type="python"
        if [ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml; then
            test_command="pytest"
        elif pip list | grep -q pytest; then
            test_command="pytest"
        else
            test_command="python -m unittest discover"
        fi
        test_pattern="test_*.py|*_test.py"
    elif [ -f "Gemfile" ]; then
        project_type="ruby"
        test_command="bundle exec rspec"
        test_pattern="*_spec.rb"
    else
        project_type="generic"
        test_command="make test"
        test_pattern="test_*"
    fi

    echo "$project_type|$test_command|$test_pattern"
}

# Run tests and capture results
run_tests() {
    local test_command="$1"
    local output_file="/tmp/test_output_$(date +%s).log"

    log "🧪 Running tests: $test_command"

    # Run tests and capture output
    set +e
    eval "$test_command" > "$output_file" 2>&1
    local exit_code=$?
    set -e

    # Display results
    if [ $exit_code -eq 0 ]; then
        highlight "✅ All tests passed!"
        grep -E "(passed|✓|OK)" "$output_file" | tail -5 || true
    else
        highlight "❌ Tests failed!"
        echo ""
        echo "Test output:"
        cat "$output_file" | tail -20
    fi

    echo "$exit_code|$output_file"
}

# AI-powered test generation
generate_test_with_ai() {
    local feature_description="$1"
    local file_to_test="$2"
    local project_info=$(detect_test_framework)
    local project_type=$(echo "$project_info" | cut -d'|' -f1)

    log "🤖 Generating test for: $feature_description"

    # Create test template based on project type
    case "$project_type" in
        "javascript")
            echo "// Test for: $feature_description"
            echo "// Generated on: $(date)"
            echo ""
            echo "describe('$feature_description', () => {"
            echo "  test('should implement basic functionality', () => {"
            echo "    // TODO: Implement test"
            echo "    expect(true).toBe(false); // This should fail initially"
            echo "  });"
            echo "});"
            ;;
        "python")
            echo "# Test for: $feature_description"
            echo "# Generated on: $(date)"
            echo ""
            echo "import pytest"
            echo ""
            echo "class Test$(echo "$feature_description" | sed 's/ //g'):"
            echo "    def test_basic_functionality(self):"
            echo '        """Test basic functionality"""'
            echo "        # TODO: Implement test"
            echo "        assert False, 'Not implemented'"
            ;;
        "go")
            echo "// Test for: $feature_description"
            echo "// Generated on: $(date)"
            echo ""
            echo "package main"
            echo ""
            echo "import \"testing\""
            echo ""
            echo "func Test$(echo "$feature_description" | sed 's/ //g')(t *testing.T) {"
            echo "    // TODO: Implement test"
            echo "    t.Fatal(\"Not implemented\")"
            echo "}"
            ;;
        "rust")
            echo "// Test for: $feature_description"
            echo "// Generated on: $(date)"
            echo ""
            echo "#[cfg(test)]"
            echo "mod tests {"
            echo "    use super::*;"
            echo ""
            echo "    #[test]"
            echo "    fn test_$(echo "$feature_description" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')() {"
            echo "        // TODO: Implement test"
            echo "        panic!(\"Not implemented\");"
            echo "    }"
            echo "}"
            ;;
        *)
            echo "# Test for: $feature_description"
            echo "# Generated on: $(date)"
            echo "# TODO: Implement test that initially fails"
            ;;
    esac
}

# AI-powered implementation suggestions
suggest_implementation() {
    local failing_test="$1"
    local project_info=$(detect_test_framework)
    local project_type=$(echo "$project_info" | cut -d'|' -f1)

    log "🤖 Analyzing failing test and suggesting implementation..."

    # Parse test failure output
    echo "Test failure analysis:"
    echo "Project type: $project_type"
    echo ""

    # Basic implementation suggestions based on common patterns
    echo "💡 Implementation suggestions:"
    case "$project_type" in
        "javascript")
            echo "1. Create the function/class being tested"
            echo "2. Return the expected value/type"
            echo "3. Handle edge cases mentioned in tests"
            echo "4. Use TypeScript for better type safety"
            ;;
        "python")
            echo "1. Define the class/function being tested"
            echo "2. Implement basic functionality to pass tests"
            echo "3. Use type hints for clarity"
            echo "4. Follow PEP 8 style guidelines"
            ;;
        "go")
            echo "1. Define the function with correct signature"
            echo "2. Return appropriate zero values initially"
            echo "3. Handle error cases properly"
            echo "4. Use Go conventions for naming"
            ;;
        "rust")
            echo "1. Define the function/struct being tested"
            echo "2. Use Result<T, E> for error handling"
            echo "3. Consider ownership and borrowing"
            echo "4. Use Rust naming conventions"
            ;;
    esac

    echo ""
    echo "🔄 TDD Cycle Reminder:"
    echo "1. Write a failing test (RED)"
    echo "2. Write minimal code to pass (GREEN)"
    echo "3. Refactor and improve (REFACTOR)"
}

# Interactive TDD cycle
interactive_tdd_cycle() {
    local project_info=$(detect_test_framework)
    local project_type=$(echo "$project_info" | cut -d'|' -f1)
    local test_command=$(echo "$project_info" | cut -d'|' -f2)

    highlight "🔄 Starting Interactive TDD Cycle"
    echo "Project type: $project_type"
    echo "Test command: $test_command"
    echo ""

    local cycle_count=1

    while true; do
        echo ""
        highlight "=== TDD CYCLE #$cycle_count ==="
        echo ""

        echo "Current phase options:"
        echo "1. 🔴 RED - Write failing test"
        echo "2. 🟢 GREEN - Make test pass"
        echo "3. 🔵 REFACTOR - Improve code"
        echo "4. ▶️  RUN - Run all tests"
        echo "5. 🤖 AI - Get AI assistance"
        echo "6. 📊 STATUS - Show current status"
        echo "7. 🚪 EXIT - End TDD session"
        echo ""
        echo -n "Choose option (1-7): "
        read -r choice

        case $choice in
            1)
                echo ""
                log "🔴 RED Phase - Write Failing Test"
                echo -n "Feature to test: "
                read -r feature
                echo -n "Test file path (or press Enter for suggestion): "
                read -r test_file

                if [ -z "$test_file" ]; then
                    case "$project_type" in
                        "javascript")
                            test_file="tests/$(echo "$feature" | tr ' ' '_' | tr '[:upper:]' '[:lower:]').test.js"
                            ;;
                        "python")
                            test_file="test_$(echo "$feature" | tr ' ' '_' | tr '[:upper:]' '[:lower:]').py"
                            ;;
                        "go")
                            test_file="$(echo "$feature" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')_test.go"
                            ;;
                        *)
                            test_file="test_$(echo "$feature" | tr ' ' '_').txt"
                            ;;
                    esac
                fi

                echo ""
                echo "Generated test template:"
                echo "========================"
                generate_test_with_ai "$feature" "$test_file"
                echo "========================"
                echo ""
                echo "Save this to: $test_file"
                echo "Then run tests to see it fail (RED phase)"
                ;;

            2)
                echo ""
                log "🟢 GREEN Phase - Make Test Pass"
                echo "Write minimal code to make the failing test pass."
                echo "Focus on making it work, not making it perfect."
                echo ""
                echo "Press Enter when ready to run tests..."
                read -r

                local result=$(run_tests "$test_command")
                local exit_code=$(echo "$result" | cut -d'|' -f1)

                if [ "$exit_code" -eq 0 ]; then
                    highlight "✅ GREEN achieved! Tests are passing."
                else
                    warn "❌ Still failing. Need more implementation."
                    suggest_implementation "$(echo "$result" | cut -d'|' -f2)"
                fi
                ;;

            3)
                echo ""
                log "🔵 REFACTOR Phase - Improve Code"
                echo "Now improve the code while keeping tests green."
                echo "Focus on:"
                echo "• Code readability"
                echo "• Performance"
                echo "• Design patterns"
                echo "• DRY principle"
                echo ""
                echo "Press Enter when ready to run tests..."
                read -r

                local result=$(run_tests "$test_command")
                local exit_code=$(echo "$result" | cut -d'|' -f1)

                if [ "$exit_code" -eq 0 ]; then
                    highlight "✅ Refactoring successful! Tests still green."
                else
                    error "❌ Refactoring broke tests! Fix before continuing."
                fi
                ;;

            4)
                echo ""
                run_tests "$test_command"
                ;;

            5)
                echo ""
                log "🤖 AI Assistance"
                echo "1. Analyze test failure"
                echo "2. Suggest implementation"
                echo "3. Code review"
                echo "4. General help"
                echo ""
                echo -n "Choose AI assistance (1-4): "
                read -r ai_choice

                case $ai_choice in
                    1|2)
                        suggest_implementation ""
                        ;;
                    3)
                        echo -n "File to review: "
                        read -r review_file
                        if [ -f "$review_file" ]; then
                            "$AI_HELPER" analyze "$review_file"
                        else
                            error "File not found: $review_file"
                        fi
                        ;;
                    4)
                        echo "TDD Tips:"
                        echo "• Write the simplest test first"
                        echo "• Write just enough code to pass"
                        echo "• Refactor only when tests are green"
                        echo "• Use descriptive test names"
                        echo "• One assertion per test (usually)"
                        ;;
                esac
                ;;

            6)
                echo ""
                log "📊 Current Status"
                local result=$(run_tests "$test_command")
                local exit_code=$(echo "$result" | cut -d'|' -f1)

                if [ "$exit_code" -eq 0 ]; then
                    echo "🟢 All tests passing - Ready for refactor or next feature"
                else
                    echo "🔴 Tests failing - Need implementation or fixes"
                fi

                # Show test file stats
                local test_files=$(find . -name "*.test.*" -o -name "*_test.*" -o -name "test_*" 2>/dev/null | wc -l)
                echo "Test files found: $test_files"
                ;;

            7)
                log "🏁 TDD Session Complete!"
                echo ""
                echo "Session summary:"
                echo "• Cycles completed: $cycle_count"
                echo "• Project type: $project_type"
                echo ""

                # Final test run
                local result=$(run_tests "$test_command")
                local exit_code=$(echo "$result" | cut -d'|' -f1)

                if [ "$exit_code" -eq 0 ]; then
                    highlight "✅ Ending with all tests passing - Great job!"
                else
                    warn "⚠️  Ending with failing tests - Consider fixing before pushing"
                fi
                exit 0
                ;;

            *)
                error "Invalid choice"
                ;;
        esac

        cycle_count=$((cycle_count + 1))
    done
}

# Quick TDD commands
quick_red() {
    local feature="$1"
    if [ -z "$feature" ]; then
        echo -n "Feature to test: "
        read -r feature
    fi

    log "🔴 Generating failing test for: $feature"
    generate_test_with_ai "$feature" ""
}

quick_test() {
    local project_info=$(detect_test_framework)
    local test_command=$(echo "$project_info" | cut -d'|' -f2)
    run_tests "$test_command"
}

# Main function
main() {
    case "${1:-interactive}" in
        "red"|"r")
            quick_red "$2"
            ;;
        "green"|"g")
            log "🟢 GREEN Phase - Implement minimal code to pass tests"
            echo "Write just enough code to make the failing test pass."
            ;;
        "refactor"|"f")
            log "🔵 REFACTOR Phase - Improve code while keeping tests green"
            echo "Improve code quality without breaking functionality."
            ;;
        "test"|"t")
            quick_test
            ;;
        "cycle"|"c"|"interactive")
            interactive_tdd_cycle
            ;;
        "detect"|"d")
            local info=$(detect_test_framework)
            echo "Project Type: $(echo "$info" | cut -d'|' -f1)"
            echo "Test Command: $(echo "$info" | cut -d'|' -f2)"
            echo "Test Pattern: $(echo "$info" | cut -d'|' -f3)"
            ;;
        "help"|"-h"|"--help")
            echo "TDD AI Cycle - Test-Driven Development with AI assistance"
            echo ""
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  cycle, c           Interactive TDD cycle (default)"
            echo "  red, r [feature]   Generate failing test"
            echo "  green, g           Make tests pass"
            echo "  refactor, f        Improve code"
            echo "  test, t            Run tests"
            echo "  detect, d          Detect project type and test framework"
            echo "  help               Show this help"
            echo ""
            echo "TDD Cycle:"
            echo "  1. 🔴 RED - Write failing test"
            echo "  2. 🟢 GREEN - Make test pass with minimal code"
            echo "  3. 🔵 REFACTOR - Improve code while keeping tests green"
            echo ""
            echo "Examples:"
            echo "  $0 cycle           # Start interactive TDD session"
            echo "  $0 red 'user login' # Generate test for user login"
            echo "  $0 test            # Run all tests"
            ;;
        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

main "$@"
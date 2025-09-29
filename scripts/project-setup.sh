#!/bin/bash

# Project Setup Script
# Automated project initialization with best practices

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[SETUP] $1${NC}"
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

# Create templates directory if it doesn't exist
mkdir -p "$TEMPLATES_DIR"

# Project templates
create_javascript_project() {
    local project_name="$1"
    local project_type="${2:-node}"

    log "🚀 Creating JavaScript/Node.js project: $project_name"

    mkdir -p "$project_name"
    cd "$project_name"

    # Create package.json
    cat > package.json << EOF
{
  "name": "$project_name",
  "version": "1.0.0",
  "description": "A JavaScript project created with High-Efficiency Programmer System",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix",
    "format": "prettier --write src/"
  },
  "keywords": [],
  "author": "$(git config user.name 2>/dev/null || echo 'Your Name')",
  "license": "MIT",
  "devDependencies": {
    "jest": "^29.0.0",
    "nodemon": "^3.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0"
  },
  "dependencies": {}
}
EOF

    # Create directory structure
    mkdir -p src tests docs

    # Create main file
    cat > src/index.js << EOF
/**
 * $project_name
 * Created with High-Efficiency Programmer System
 */

const main = () => {
    console.log('Hello from $project_name!');
};

if (require.main === module) {
    main();
}

module.exports = { main };
EOF

    # Create test file
    cat > tests/index.test.js << EOF
const { main } = require('../src/index');

describe('$project_name', () => {
    test('should run without errors', () => {
        expect(() => main()).not.toThrow();
    });
});
EOF

    # Create .gitignore
    cat > .gitignore << EOF
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.DS_Store
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
*.log
coverage/
.nyc_output/
dist/
build/
.cache/
EOF

    # Create README.md
    create_readme "$project_name" "JavaScript/Node.js"

    # Create ESLint config
    cat > .eslintrc.js << EOF
module.exports = {
    env: {
        node: true,
        es2021: true,
        jest: true,
    },
    extends: ['eslint:recommended'],
    parserOptions: {
        ecmaVersion: 12,
        sourceType: 'module',
    },
    rules: {
        'no-console': 'warn',
        'no-unused-vars': 'error',
    },
};
EOF

    # Create Prettier config
    cat > .prettierrc << EOF
{
    "semi": true,
    "trailingComma": "es5",
    "singleQuote": true,
    "printWidth": 80,
    "tabWidth": 4
}
EOF

    info "✅ JavaScript project structure created"
    cd ..
}

create_python_project() {
    local project_name="$1"
    local project_type="${2:-package}"

    log "🐍 Creating Python project: $project_name"

    mkdir -p "$project_name"
    cd "$project_name"

    # Create directory structure
    mkdir -p src/"$project_name" tests docs

    # Create pyproject.toml
    cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$project_name"
version = "0.1.0"
description = "A Python project created with High-Efficiency Programmer System"
authors = [{name = "$(git config user.name 2>/dev/null || echo 'Your Name')", email = "$(git config user.email 2>/dev/null || echo 'your.email@example.com')"}]
license = {text = "MIT"}
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "black>=22.0",
    "flake8>=5.0",
    "mypy>=1.0",
    "pytest-cov>=4.0",
]

[project.urls]
Homepage = "https://github.com/yourusername/$project_name"
Repository = "https://github.com/yourusername/$project_name.git"

[tool.black]
line-length = 88
target-version = ['py38']

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
addopts = "--cov=src/$project_name --cov-report=html --cov-report=term-missing"
EOF

    # Create main module
    cat > src/"$project_name"/__init__.py << EOF
"""
$project_name - A Python project created with High-Efficiency Programmer System
"""

__version__ = "0.1.0"
__author__ = "$(git config user.name 2>/dev/null || echo 'Your Name')"

from .main import main

__all__ = ["main"]
EOF

    cat > src/"$project_name"/main.py << EOF
"""
Main module for $project_name
"""

def main() -> None:
    """Main function"""
    print(f"Hello from {__name__}!")

if __name__ == "__main__":
    main()
EOF

    # Create test file
    cat > tests/test_main.py << EOF
"""
Tests for main module
"""
import pytest
from $project_name.main import main

def test_main():
    """Test main function runs without errors"""
    # This is a placeholder test
    assert main() is None
EOF

    # Create .gitignore
    cat > .gitignore << EOF
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

.coverage
htmlcov/
.tox/
.pytest_cache/
.mypy_cache/
.coverage.*

*.log
.DS_Store
EOF

    # Create README.md
    create_readme "$project_name" "Python"

    # Create requirements files
    cat > requirements.txt << EOF
# Add your project dependencies here
EOF

    cat > requirements-dev.txt << EOF
pytest>=7.0
black>=22.0
flake8>=5.0
mypy>=1.0
pytest-cov>=4.0
EOF

    info "✅ Python project structure created"
    cd ..
}

create_go_project() {
    local project_name="$1"

    log "🐹 Creating Go project: $project_name"

    mkdir -p "$project_name"
    cd "$project_name"

    # Initialize go module
    go mod init "$project_name"

    # Create directory structure
    mkdir -p cmd/"$project_name" pkg internal docs

    # Create main.go
    cat > cmd/"$project_name"/main.go << EOF
package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Printf("Hello from %s!\n", os.Args[0])
}
EOF

    # Create package structure
    cat > pkg/hello.go << EOF
package pkg

// Hello returns a greeting message
func Hello(name string) string {
	if name == "" {
		name = "World"
	}
	return fmt.Sprintf("Hello, %s!", name)
}
EOF

    # Create test file
    cat > pkg/hello_test.go << EOF
package pkg

import "testing"

func TestHello(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{"empty name", "", "Hello, World!"},
		{"with name", "Go", "Hello, Go!"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := Hello(tt.input)
			if result != tt.expected {
				t.Errorf("Hello(%q) = %q, want %q", tt.input, result, tt.expected)
			}
		})
	}
}
EOF

    # Create .gitignore
    cat > .gitignore << EOF
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with \`go test -c\`
*.test

# Output of the go coverage tool
*.out

# Dependency directories
vendor/

# Go workspace file
go.work

# IDE files
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db
EOF

    # Create README.md
    create_readme "$project_name" "Go"

    # Create Makefile
    cat > Makefile << EOF
.PHONY: build test clean run fmt vet

BINARY_NAME=$project_name
MAIN_PATH=./cmd/$project_name

build:
	go build -o bin/\$(BINARY_NAME) \$(MAIN_PATH)

test:
	go test -v ./...

clean:
	go clean
	rm -f bin/\$(BINARY_NAME)

run:
	go run \$(MAIN_PATH)

fmt:
	go fmt ./...

vet:
	go vet ./...

coverage:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

install-deps:
	go mod download
	go mod tidy

.DEFAULT_GOAL := build
EOF

    info "✅ Go project structure created"
    cd ..
}

create_rust_project() {
    local project_name="$1"

    log "🦀 Creating Rust project: $project_name"

    if ! command -v cargo > /dev/null; then
        error "Cargo not found. Please install Rust first."
        return 1
    fi

    cargo new "$project_name"
    cd "$project_name"

    # Update Cargo.toml
    cat >> Cargo.toml << EOF

[profile.dev]
debug = true

[profile.release]
lto = true
codegen-units = 1

[[bin]]
name = "$project_name"
path = "src/main.rs"
EOF

    # Create lib.rs
    cat > src/lib.rs << EOF
//! $project_name
//!
//! A Rust project created with High-Efficiency Programmer System

pub fn hello(name: &str) -> String {
    if name.is_empty() {
        "Hello, World!".to_string()
    } else {
        format!("Hello, {}!", name)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hello_empty() {
        assert_eq!(hello(""), "Hello, World!");
    }

    #[test]
    fn test_hello_with_name() {
        assert_eq!(hello("Rust"), "Hello, Rust!");
    }
}
EOF

    # Update main.rs
    cat > src/main.rs << EOF
use $project_name::hello;

fn main() {
    println!("{}", hello("$project_name"));
}
EOF

    # Create README.md
    create_readme "$project_name" "Rust"

    info "✅ Rust project structure created"
    cd ..
}

create_readme() {
    local project_name="$1"
    local project_type="$2"

    cat > README.md << EOF
# $project_name

A $project_type project created with High-Efficiency Programmer System.

## Description

[Add your project description here]

## Installation

[Add installation instructions here]

## Usage

[Add usage examples here]

## Development

### Prerequisites

- [List prerequisites here]

### Setup

1. Clone the repository
2. [Add setup steps here]

### Running Tests

[Add test commands here]

### Code Formatting

[Add formatting commands here]

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run the test suite
6. Create a pull request

## License

MIT License - see LICENSE file for details.

---

Created with ❤️ using [High-Efficiency Programmer System](https://github.com/yourusername/high-efficiency-programmer-system)
EOF

    # Create LICENSE file
    cat > LICENSE << EOF
MIT License

Copyright (c) $(date +%Y) $(git config user.name 2>/dev/null || echo 'Your Name')

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
}

# Interactive project setup
interactive_setup() {
    highlight "🚀 High-Efficiency Programmer Project Setup"
    echo ""

    # Get project details
    echo -n "Project name: "
    read -r project_name

    if [ -z "$project_name" ]; then
        error "Project name is required"
        exit 1
    fi

    # Check if directory exists
    if [ -d "$project_name" ]; then
        warn "Directory '$project_name' already exists"
        echo -n "Continue anyway? (y/N): "
        read -r continue_setup
        if [ "$continue_setup" != "y" ] && [ "$continue_setup" != "Y" ]; then
            info "Setup cancelled"
            exit 0
        fi
    fi

    echo ""
    echo "Project types:"
    echo "1. JavaScript/Node.js"
    echo "2. Python"
    echo "3. Go"
    echo "4. Rust"
    echo "5. Shell script project"
    echo ""
    echo -n "Choose project type (1-5): "
    read -r project_type

    case "$project_type" in
        1)
            create_javascript_project "$project_name"
            ;;
        2)
            create_python_project "$project_name"
            ;;
        3)
            create_go_project "$project_name"
            ;;
        4)
            create_rust_project "$project_name"
            ;;
        5)
            create_shell_project "$project_name"
            ;;
        *)
            error "Invalid project type"
            exit 1
            ;;
    esac

    # Initialize git repository
    cd "$project_name"
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo ""
        echo -n "Initialize git repository? (Y/n): "
        read -r init_git
        if [ "$init_git" != "n" ] && [ "$init_git" != "N" ]; then
            git init
            git add .
            git commit -m "Initial commit - project created with High-Efficiency Programmer System"
            info "Git repository initialized"
        fi
    fi

    # Setup development environment
    echo ""
    echo -n "Install dependencies now? (Y/n): "
    read -r install_deps
    if [ "$install_deps" != "n" ] && [ "$install_deps" != "N" ]; then
        case "$project_type" in
            1)
                if command -v npm > /dev/null; then
                    npm install
                    info "NPM dependencies installed"
                fi
                ;;
            2)
                if command -v pip > /dev/null; then
                    pip install -r requirements-dev.txt
                    info "Python dependencies installed"
                fi
                ;;
            3)
                go mod download
                info "Go dependencies downloaded"
                ;;
            4)
                cargo build
                info "Rust project built"
                ;;
        esac
    fi

    cd ..

    # Show next steps
    echo ""
    highlight "✅ Project setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. cd $project_name"
    echo "2. Start coding!"
    echo ""
    echo "Available commands in your new project:"
    case "$project_type" in
        1)
            echo "  npm run dev     - Start development server"
            echo "  npm test        - Run tests"
            echo "  npm run lint    - Lint code"
            ;;
        2)
            echo "  pytest          - Run tests"
            echo "  black .         - Format code"
            echo "  flake8          - Lint code"
            ;;
        3)
            echo "  make run        - Run the program"
            echo "  make test       - Run tests"
            echo "  make build      - Build binary"
            ;;
        4)
            echo "  cargo run       - Run the program"
            echo "  cargo test      - Run tests"
            echo "  cargo build     - Build project"
            ;;
    esac
}

create_shell_project() {
    local project_name="$1"

    log "🐚 Creating Shell script project: $project_name"

    mkdir -p "$project_name"
    cd "$project_name"

    # Create directory structure
    mkdir -p bin lib tests docs

    # Create main script
    cat > bin/"$project_name" << EOF
#!/bin/bash

# $project_name
# Created with High-Efficiency Programmer System

set -e

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="\$SCRIPT_DIR/../lib"

# Source library functions
source "\$LIB_DIR/common.sh"

main() {
    log "Hello from $project_name!"
}

main "\$@"
EOF

    chmod +x bin/"$project_name"

    # Create library file
    cat > lib/common.sh << EOF
#!/bin/bash

# Common functions for $project_name

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "\${GREEN}[\$(date +'%H:%M:%S')] \$1\${NC}"
}

warn() {
    echo -e "\${YELLOW}[WARN] \$1\${NC}"
}

error() {
    echo -e "\${RED}[ERROR] \$1\${NC}"
}
EOF

    # Create test file
    cat > tests/test_main.sh << EOF
#!/bin/bash

# Tests for $project_name

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="\$(dirname "\$SCRIPT_DIR")"

test_main_execution() {
    local output=\$("\$PROJECT_DIR/bin/$project_name" 2>&1)
    if [[ "\$output" == *"Hello from $project_name"* ]]; then
        echo "✅ Main execution test passed"
        return 0
    else
        echo "❌ Main execution test failed"
        return 1
    fi
}

main() {
    echo "Running tests for $project_name..."
    test_main_execution
}

main "\$@"
EOF

    chmod +x tests/test_main.sh

    # Create Makefile
    cat > Makefile << EOF
.PHONY: test install clean

BINARY_NAME=$project_name
INSTALL_PATH=/usr/local/bin

test:
	@./tests/test_main.sh

install:
	cp bin/\$(BINARY_NAME) \$(INSTALL_PATH)/
	chmod +x \$(INSTALL_PATH)/\$(BINARY_NAME)

clean:
	@echo "Nothing to clean"

run:
	@./bin/\$(BINARY_NAME)

.DEFAULT_GOAL := test
EOF

    # Create .gitignore
    cat > .gitignore << EOF
*.log
.DS_Store
Thumbs.db
*~
EOF

    # Create README.md
    create_readme "$project_name" "Shell Script"

    info "✅ Shell script project structure created"
    cd ..
}

# Main function
main() {
    case "${1:-interactive}" in
        "js"|"javascript"|"node")
            if [ -z "$2" ]; then
                error "Usage: $0 js <project_name>"
                exit 1
            fi
            create_javascript_project "$2"
            ;;

        "py"|"python")
            if [ -z "$2" ]; then
                error "Usage: $0 python <project_name>"
                exit 1
            fi
            create_python_project "$2"
            ;;

        "go")
            if [ -z "$2" ]; then
                error "Usage: $0 go <project_name>"
                exit 1
            fi
            create_go_project "$2"
            ;;

        "rust"|"rs")
            if [ -z "$2" ]; then
                error "Usage: $0 rust <project_name>"
                exit 1
            fi
            create_rust_project "$2"
            ;;

        "shell"|"sh")
            if [ -z "$2" ]; then
                error "Usage: $0 shell <project_name>"
                exit 1
            fi
            create_shell_project "$2"
            ;;

        "interactive"|"i")
            interactive_setup
            ;;

        "help"|"-h"|"--help")
            echo "Project Setup - Automated project initialization"
            echo ""
            echo "Usage: $0 [COMMAND] [PROJECT_NAME]"
            echo ""
            echo "Commands:"
            echo "  js, javascript <name>        Create JavaScript/Node.js project"
            echo "  py, python <name>            Create Python project"
            echo "  go <name>                    Create Go project"
            echo "  rust, rs <name>              Create Rust project"
            echo "  shell, sh <name>             Create Shell script project"
            echo "  interactive, i               Interactive setup (default)"
            echo "  help                         Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 js my-app                 # Create Node.js project"
            echo "  $0 python my-package         # Create Python project"
            echo "  $0 go my-service             # Create Go project"
            echo "  $0 interactive               # Interactive setup"
            ;;

        *)
            # Try to use first argument as project name in interactive mode
            if [ -n "$1" ] && [ ! -d "$1" ]; then
                echo "Project name: $1"
                project_name="$1"
                # Continue with interactive setup but with pre-filled name
                # ... (simplified for now, just call interactive)
                interactive_setup
            else
                error "Unknown command: $1"
                echo "Use '$0 help' for available commands"
                exit 1
            fi
            ;;
    esac
}

main "$@"
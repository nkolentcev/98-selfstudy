# Неделя 1: Настройка окружения и первые шаги
*Дни 1-7 плана "Обучение как код"*

## 🎯 Цели недели
- [ ] Настроить полное dev окружение (Go, Rust, Docker, VS Code)
- [ ] Создать первые проекты на Go и Rust
- [ ] Освоить базовый Git workflow
- [ ] Запустить первые контейнеры Docker
- [ ] Настроить Flutter и Tauri для будущего использования

---

## 📅 ДЕНЬ 1 (ПОНЕДЕЛЬНИК) - Базовая установка

### 🌅 Утренняя сессия (1.5 часа) - 07:00-08:30
**Установка основного стека**

#### Шаг 1: Go установка (20 мин)
```bash
# Для Linux/macOS
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# Проверка установки
go version
```

#### Шаг 2: Rust установка (15 мин)
```bash
# Установка через rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# Проверка установки
rustc --version
cargo --version
```

#### Шаг 3: Docker установка (30 мин)
```bash
# Ubuntu 24.04 (Noble) — установка из официального репозитория Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Настроить ключ и репозиторий Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo $UBUNTU_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Добавить пользователя в группу docker и проверить без sudo
sudo usermod -aG docker $USER
newgrp docker <<EOF
docker --version
docker compose version
docker run --rm hello-world
EOF
```

#### Шаг 4: Git настройка (15 мин)
```bash
# Базовая настройка
git config --global user.name "Ваше Имя"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main

# Генерация SSH ключа для GitHub
ssh-keygen -t ed25519 -C "your.email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Показать публичный ключ для добавления в GitHub
cat ~/.ssh/id_ed25519.pub

# Рекомендуемые права на ключи и проверка подключения к GitHub
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
# Проверка SSH соединения с GitHub (ожидается сообщение об успешной аутентификации)
ssh -T git@github.com || true

### 🌙 Вечерняя сессия (2 часа) - 19:00-21:00
**GitHub setup и первые проекты**

#### Шаг 1: Docker команды (30 мин)
```bash
# Проверка установки
docker run hello-world

# Базовые команды
docker images
docker ps
docker ps -a

# Запуск Ubuntu контейнера
docker run -it ubuntu:latest /bin/bash
# Внутри контейнера:
apt update && apt install curl
exit

# Создание образа из контейнера
docker commit <container_id> my-ubuntu-with-curl
docker images
```

#### Шаг 2: Dockerfile для Go проекта (30 мин)
```bash
cd go-projects/hello-world
```

Создать `Dockerfile`:
```dockerfile
# Multi-stage build
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o hello main.go

# Final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/hello .
CMD ["./hello"]
```

Создать `.dockerignore`:
```
.git
README.md
Dockerfile
.dockerignore
```

#### Шаг 3: Сборка и тестирование (30 мин)
```bash
# Сборка образа
docker build -t go-hello-world .

# Запуск контейнера
docker run go-hello-world
docker run go-hello-world ./hello "Docker User"

# Проверка размера образа
docker images go-hello-world
```

---

### 🌙 Вечерняя сессия (2 часа) - 19:00-21:00
**Docker Compose и VS Code настройка**

#### Шаг 1: Docker Compose для разработки (45 мин)
```bash
cd ../../
```

Создать `docker-compose.yml`:
```yaml
version: '3.8'

services:
  go-dev:
    build: 
      context: ./go-projects/hello-world
      dockerfile: Dockerfile
    volumes:
      - ./go-projects:/workspace/go-projects
    working_dir: /workspace/go-projects/hello-world
    command: tail -f /dev/null
    container_name: go-dev-container

  rust-dev:
    image: rust:1.75
    volumes:
      - ./rust-projects:/workspace/rust-projects
    working_dir: /workspace/rust-projects/hello-world
    command: tail -f /dev/null
    container_name: rust-dev-container

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: devdb
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: devpass123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

Запустить окружение:
```bash
docker compose up -d
docker compose ps
```

#### Шаг 2: VS Code расширения (30 мин)
Установить необходимые расширения:
- Go (Google)
- rust-analyzer
- Docker
- GitLens
- Remote - Containers
- Better Comments
- Error Lens

Настроить `settings.json`:
```json
{
    "go.formatTool": "gofmt",
    "go.lintTool": "golangci-lint",
    "go.testFlags": ["-v"],
    "rust-analyzer.check.command": "check",
    "rust-analyzer.cargo.buildScripts.enable": true,
    "docker.showStartPage": false,
    "git.autofetch": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    }
}
```

#### Шаг 3: Dockerfile для Rust (45 мин)
```bash
cd rust-projects/hello-world
```

Создать `Dockerfile`:
```dockerfile
FROM rust:1.75-slim as builder

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release && rm src/main.rs

COPY src ./src
RUN touch src/main.rs && cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY --from=builder /app/target/release/hello-world .
CMD ["./hello-world"]
```

Сборка и тестирование:
```bash
docker build -t rust-hello-world .
docker run rust-hello-world
```

#### Шаг 4: Обновление docker-compose.yml (20 мин)
```yaml
version: '3.8'

services:
  go-hello:
    build: ./go-projects/hello-world
    container_name: go-hello

  rust-hello:
    build: ./rust-projects/hello-world
    container_name: rust-hello

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: devdb
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: devpass123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### 📝 Задачи на день:
- [ ] Изучить основные Docker команды
- [ ] Создать Dockerfile для Go проекта
- [ ] Настроить VS Code с необходимыми расширениями
- [ ] Создать docker-compose.yml для dev окружения
- [ ] Создать Dockerfile для Rust проекта

---

## 📅 ДЕНЬ 3 (СРЕДА) - Git workflow

### 🌅 Утренняя сессия (1.5 часа) - 07:00-08:30
**Git продвинутые возможности**

#### Шаг 1: Branching стратегия (30 мин)
```bash
# Создание feature branch
git checkout -b feature/cli-improvements
git branch # посмотреть все ветки

# Изучение истории
git log --oneline --graph
git log --oneline --graph --all
```

#### Шаг 2: Игнорирование файлов (20 мин)
Обновить `.gitignore`:
```
# Binaries
*.exe
*.exe~
*.dll
*.so
*.dylib

# Go
vendor/
*.sum

# Rust
target/
**/*.rs.bk

# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/

# Tauri
src-tauri/target

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Docker
.dockerignore

# Logs
*.log
logs/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
```

#### Шаг 3: Продвинутые Git команды (40 мин)
```bash
# Stash изменения
echo "temporary change" >> temp.txt
git add temp.txt
git stash push -m "temporary work"
git stash list
git stash pop

# Интерактивные commits
git add -p

# Rebase vs merge
git checkout main
git merge feature/cli-improvements
git checkout -b feature/test-rebase
# сделать изменения
git rebase main

# Cherry-pick
git log --oneline
git cherry-pick <commit-hash>

# Работа с remote
git remote -v
git remote add upstream <url>
git fetch upstream
```

---

### 🌙 Вечерняя сессия (2 часа) - 19:00-21:00
**Практика Git workflow и улучшение проектов**

#### Шаг 1: Улучшение Go проекта (45 мин)
```bash
cd go-projects/hello-world
git checkout -b feature/go-cli-enhancement
```

Создать `cmd/root.go`:
```go
package cmd

import (
    "fmt"
    "os"
    "time"

    "github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
    Use:   "hello",
    Short: "A simple CLI application",
    Long:  `A simple CLI application built with Go and Cobra for learning purposes.`,
    Run: func(cmd *cobra.Command, args []string) {
        name, _ := cmd.Flags().GetString("name")
        showTime, _ := cmd.Flags().GetBool("time")
        
        if name != "" {
            fmt.Printf("Hello, %s! Welcome to Go learning journey!\n", name)
        } else {
            fmt.Println("Hello, World!")
        }
        
        if showTime {
            fmt.Printf("Current time: %s\n", time.Now().Format("2006-01-02 15:04:05"))
        }
    },
}

func Execute() {
    if err := rootCmd.Execute(); err != nil {
        fmt.Println(err)
        os.Exit(1)
    }
}

func init() {
    rootCmd.Flags().StringP("name", "n", "", "Name to greet")
    rootCmd.Flags().BoolP("time", "t", false, "Show current time")
}
```

Обновить `main.go`:
```go
package main

import "github.com/username/learning-as-code/go-projects/hello-world/cmd"

func main() {
    cmd.Execute()
}
```

Обновить `go.mod`:
```bash
go mod init github.com/username/learning-as-code/go-projects/hello-world
go get github.com/spf13/cobra@latest
go mod tidy
```

#### Шаг 2: Тестирование Go проекта (30 мин)
Создать `cmd/root_test.go`:
```go
package cmd

import (
    "bytes"
    "os"
    "strings"
    "testing"
)

func TestRootCommand(t *testing.T) {
    tests := []struct {
        name     string
        args     []string
        expected string
    }{
        {
            name:     "default greeting",
            args:     []string{},
            expected: "Hello, World!",
        },
        {
            name:     "custom name",
            args:     []string{"--name", "Gopher"},
            expected: "Hello, Gopher!",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Захватить stdout
            old := os.Stdout
            r, w, _ := os.Pipe()
            os.Stdout = w

            // Выполнить команду
            rootCmd.SetArgs(tt.args)
            rootCmd.Execute()

            // Восстановить stdout
            w.Close()
            os.Stdout = old

            var buf bytes.Buffer
            buf.ReadFrom(r)
            output := buf.String()

            if !strings.Contains(output, tt.expected) {
                t.Errorf("Expected output to contain '%s', got '%s'", tt.expected, output)
            }
        })
    }
}
```

Запустить тесты:
```bash
go test ./...
```

#### Шаг 3: Улучшение Rust проекта (45 мин)
```bash
cd ../../rust-projects/hello-world
git checkout -b feature/rust-cli-enhancement
```

Обновить `Cargo.toml`:
```toml
[package]
name = "hello-world"
version = "0.1.0"
edition = "2021"

[dependencies]
clap = { version = "4.4", features = ["derive"] }
chrono = { version = "0.4", features = ["serde"] }
```

Обновить `src/main.rs`:
```rust
use clap::Parser;
use chrono::Utc;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    /// Name to greet
    #[arg(short, long)]
    name: Option<String>,

    /// Show current time
    #[arg(short, long)]
    time: bool,
}

fn main() {
    let cli = Cli::parse();

    match cli.name {
        Some(name) => println!("Hello, {}! Welcome to Rust learning journey!", name),
        None => println!("Hello, World!"),
    }

    if cli.time {
        println!("Current time: {}", Utc::now().format("%Y-%m-%d %H:%M:%S"));
    }

    // Демонстрация Rust особенностей
    demonstrate_ownership();
    demonstrate_error_handling();
}

fn demonstrate_ownership() {
    let mut message = String::from("Learning Rust ownership");
    let borrowed_message = &message;
    println!("Borrowed: {}", borrowed_message);
    
    message.push_str(" - step by step!");
    println!("Modified: {}", message);
}

fn demonstrate_error_handling() -> Result<(), Box<dyn std::error::Error>> {
    let number: i32 = "42".parse()?;
    println!("Parsed number: {}", number);
    
    match "not_a_number".parse::<i32>() {
        Ok(n) => println!("Parsed: {}", n),
        Err(e) => println!("Failed to parse: {}", e),
    }
    
    Ok(())
}
```

Создать тесты `src/lib.rs`:
```rust
pub fn add(left: usize, right: usize) -> usize {
    left + right
}

pub fn greet(name: Option<&str>) -> String {
    match name {
        Some(n) => format!("Hello, {}! Welcome to Rust learning journey!", n),
        None => "Hello, World!".to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }

    #[test]
    fn test_greet_with_name() {
        let result = greet(Some("Rustacean"));
        assert!(result.contains("Rustacean"));
    }

    #[test]
    fn test_greet_without_name() {
        let result = greet(None);
        assert_eq!(result, "Hello, World!");
    }
}
```

Тестирование:
```bash
cargo test
cargo run -- --help
cargo run -- --name Rustacean --time
```

### 📝 Задачи на день:
- [ ] Изучить Git branching и merging
- [ ] Настроить продвинутый .gitignore
- [ ] Улучшить Go проект с Cobra CLI
- [ ] Добавить тесты в Go проект
- [ ] Улучшить Rust проект с Clap
- [ ] Добавить тесты в Rust проект

---

## 📅 ДЕНЬ 4 (ЧЕТВЕРГ) - Rust углубление

### 🌅 Утренняя сессия (1.5 часа) - 07:00-08:30
**Изучение Rust концепций**

#### Шаг 1: Ownership и borrowing (45 мин)
Создать `rust-projects/ownership-examples/src/main.rs`:
```rust
fn main() {
    println!("=== Ownership Examples ===");
    
    // Example 1: Move semantics
    let s1 = String::from("hello");
    let s2 = s1; // s1 moved to s2
    // println!("{}", s1); // This would cause compile error
    println!("s2: {}", s2);
    
    // Example 2: Clone
    let s3 = String::from("world");
    let s4 = s3.clone();
    println!("s3: {}, s4: {}", s3, s4);
    
    // Example 3: References
    let s5 = String::from("borrowing");
    let len = calculate_length(&s5);
    println!("Length of '{}' is {}", s5, len);
    
    // Example 4: Mutable references
    let mut s6 = String::from("mutable");
    change_string(&mut s6);
    println!("Changed: {}", s6);
    
    // Example 5: Lifetimes
    let result = longest("hello", "world");
    println!("Longest: {}", result);
    
    // Example 6: Structs with ownership
    let user = User::new("Alice".to_string(), "alice@example.com".to_string());
    user.display();
    
    // Example 7: Vec and ownership
    demonstrate_vec_ownership();
}

fn calculate_length(s: &String) -> usize {
    s.len()
} // s goes out of scope but doesn't drop because it's borrowed

fn change_string(s: &mut String) {
    s.push_str(" - modified!");
}

fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

struct User {
    name: String,
    email: String,
}

impl User {
    fn new(name: String, email: String) -> User {
        User { name, email }
    }
    
    fn display(&self) {
        println!("User: {} ({})", self.name, self.email);
    }
}

fn demonstrate_vec_ownership() {
    let mut vec = vec![1, 2, 3, 4, 5];
    
    // Borrowing elements
    let first = &vec[0];
    println!("First element: {}", first);
    
    // vec.push(6); // This would cause error because vec is borrowed
    
    // Moving elements
    let moved_vec = vec;
    println!("Moved vec: {:?}", moved_vec);
    
    // Working with iterators
    let doubled: Vec<i32> = moved_vec.iter().map(|x| x * 2).collect();
    println!("Doubled: {:?}", doubled);
}
```

#### Шаг 2: Error handling (45 мин)
Создать `rust-projects/error-handling/src/main.rs`:
```rust
use std::fs::File;
use std::io::{self, Read};
use std::num::ParseIntError;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("=== Error Handling Examples ===");
    
    // Example 1: Option handling
    let numbers = vec!["1", "2", "not_a_number", "4"];
    for number_str in numbers {
        match parse_number(number_str) {
            Some(n) => println!("Parsed: {}", n),
            None => println!("Could not parse: {}", number_str),
        }
    }
    
    // Example 2: Result with custom error types
    match divide(10.0, 0.0) {
        Ok(result) => println!("Division result: {}", result),
        Err(e) => println!("Division error: {}", e),
    }
    
    // Example 3: ? operator
    let content = read_file_content("test.txt")?;
    println!("File content: {}", content);
    
    // Example 4: Multiple error types
    let result = process_input("42");
    match result {
        Ok(value) => println!("Processed value: {}", value),
        Err(e) => println!("Processing error: {}", e),
    }
    
    Ok(())
}

fn parse_number(s: &str) -> Option<i32> {
    s.parse().ok()
}

#[derive(Debug)]
enum MathError {
    DivisionByZero,
}

impl std::fmt::Display for MathError {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self {
            MathError::DivisionByZero => write!(f, "Cannot divide by zero"),
        }
    }
}

impl std::error::Error for MathError {}

fn divide(a: f64, b: f64) -> Result<f64, MathError> {
    if b == 0.0 {
        Err(MathError::DivisionByZero)
    } else {
        Ok(a / b)
    }
}

fn read_file_content(filename: &str) -> io::Result<String> {
    let mut file = File::open(filename)?;
    let mut content = String::new();
    file.read_to_string(&mut content)?;
    Ok(content)
}

fn process_input(input: &str) -> Result<i32, Box<dyn std::error::Error>> {
    let number: i32 = input.parse()?;
    if number < 0 {
        return Err("Number cannot be negative".into());
    }
    Ok(number * 2)
}
```

---

### 🌙 Вечерняя сессия (2 часа) - 19:00-21:00
**Rust HTTP server**

#### Шаг 1: Создание HTTP сервера (60 мин)
```bash
cd rust-projects
cargo new http-server
cd http-server
```

Обновить `Cargo.toml`:
```toml
[package]
name = "http-server"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1.0", features = ["full"] }
warp = "0.3"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
uuid = { version = "1.0", features = ["v4"] }
```

Создать `src/main.rs`:
```rust
use warp::Filter;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use uuid::Uuid;

type Items = Arc<Mutex<HashMap<String, Item>>>;

#[derive(Debug, Deserialize, Serialize, Clone)]
struct Item {
    id: String,
    name: String,
    description: String,
    completed: bool,
}

#[derive(Debug, Deserialize)]
struct CreateItem {
    name: String,
    description: String,
}

#[tokio::main]
async fn main() {
    let items: Items = Arc::new(Mutex::new(HashMap::new()));

    // GET /items
    let get_items = warp::path("items")
        .and(warp::get())
        .and(with_items(items.clone()))
        .and_then(get_items_handler);

    // POST /items
    let create_item = warp::path("items")
        .and(warp::post())
        .and(warp::body::json())
        .and(with_items(items.clone()))
        .and_then(create_item_handler);

    // PUT /items/:id
    let update_item = warp::path!("items" / String)
        .and(warp::put())
        .and(warp::body::json())
        .and(with_items(items.clone()))
        .and_then(update_item_handler);

    // DELETE /items/:id
    let delete_item = warp::path!("items" / String)
        .and(warp::delete())
        .and(with_items(items.clone()))
        .and_then(delete_item_handler);

    // Health check
    let health = warp::path("health")
        .and(warp::get())
        .map(|| warp::reply::with_status("OK", warp::http::StatusCode::OK));

    let routes = get_items
        .or(create_item)
        .or(update_item)
        .or(delete_item)
        .or(health)
        .with(warp::cors().allow_any_origin());

    println!("Server starting on http://localhost:3030");
    warp::serve(routes)
        .run(([127, 0, 0, 1], 3030))
        .await;
}

fn with_items(items: Items) -> impl Filter<Extract = (Items,), Error = std::convert::Infallible> + Clone {
    warp::any().map(move || items.clone())
}

async fn get_items_handler(items: Items) -> Result<impl warp::Reply, warp::Rejection> {
    let items_map = items.lock().unwrap();
    let items_vec: Vec<Item> = items_map.values().cloned().collect();
    Ok(warp::reply::json(&items_vec))
}

async fn create_item_handler(create_item: CreateItem, items: Items) -> Result<impl warp::Reply, warp::Rejection> {
    let mut items_map = items.lock().unwrap();
    let id = Uuid::new_v4().to_string();
    let item = Item {
        id: id.clone(),
        name: create_item.name,
        description: create_item.description,
        completed: false,
    };
    items_map.insert(id, item.clone());
    Ok(warp::reply::with_status(warp::reply::json(&item), warp::http::StatusCode::CREATED))
}

async fn update_item_handler(id: String, updated_item: Item, items: Items) -> Result<impl warp::Reply, warp::Rejection> {
    let mut items_map = items.lock().unwrap();
    if let Some(item) = items_map.get_mut(&id) {
        item.name = updated_item.name;
        item.description = updated_item.description;
        item.completed = updated_item.completed;
        Ok(warp::reply::json(item))
    } else {
        Ok(warp::reply::with_status(warp::reply::json(&"Item not found"), warp::http::StatusCode::NOT_FOUND))
    }
}

async fn delete_item_handler(id: String, items: Items) -> Result<impl warp::Reply, warp::Rejection> {
    let mut items_map = items.lock().unwrap();
    if items_map.remove(&id).is_some() {
        Ok(warp::reply::with_status("Item deleted", warp::http::StatusCode::OK))
    } else {
        Ok(warp::reply::with_status("Item not found", warp::http::StatusCode::NOT_FOUND))
    }
}
```

#### Шаг 2: Тестирование API (30 мин)
Создать `test_api.sh`:
```bash
#!/bin/bash

echo "Testing Rust HTTP Server API"
echo "============================"

# Start server in background (you need to run 'cargo run' first)

# Test health endpoint
echo "1. Health check:"
curl -X GET http://localhost:3030/health
echo -e "\n"

# Test GET items (should be empty)
echo "2. Get all items (empty):"
curl -X GET http://localhost:3030/items
echo -e "\n"

# Test POST item
echo "3. Create item:"
curl -X POST http://localhost:3030/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Learn Rust", "description": "Master Rust programming language"}'
echo -e "\n"

# Test GET items (should have one item)
echo "4. Get all items (with data):"
curl -X GET http://localhost:3030/items
echo -e "\n"

# You'll need to replace ID with actual ID from previous response
# Test UPDATE item
echo "5. Update item (replace ID):"
echo "curl -X PUT http://localhost:3030/items/{ID} -H \"Content-Type: application/json\" -d '{\"id\":\"{ID}\",\"name\":\"Learn Advanced Rust\",\"description\":\"Master advanced Rust concepts\",\"completed\":true}'"

# Test DELETE item
echo "6. Delete item (replace ID):"
echo "curl -X DELETE http://localhost:3030/items/{ID}"
```

#### Шаг 3: Docker для Rust сервера (30 мин)
Создать `Dockerfile`:
```dockerfile
FROM rust:1.75 as builder

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm src/main.rs

COPY src ./src
RUN touch src/main.rs
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY --from=builder /app/target/release/http-server .

EXPOSE 3030

CMD ["./http-server"]
```

Сборка и запуск:
```bash
docker build -t rust-http-server .
docker run -p 3030:3030 rust-http-server
```

### 📝 Задачи на день:
- [ ] Изучить ownership и borrowing в Rust
- [ ] Создать примеры error handling
- [ ] Построить HTTP сервер на Rust с warp
- [ ] Протестировать API endpoints
- [ ] Dockerize Rust HTTP сервер

---

## 📅 ДЕНЬ 5 (ПЯТНИЦА) - Flutter setup

### 🌅 Утренняя сессия (1.5 часа) - 07:00-08:30
**Установка и настройка Flutter**

#### Шаг 1: Flutter SDK установка (30 мин)
```bash
# Для Linux
cd ~/
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.5-stable.tar.xz
tar xf flutter_linux_3.16.5-stable.tar.xz

# Добавить в PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Проверка установки
flutter --version
flutter doctor
```

#### Шаг 2: Android Studio setup (опционально) (30 мин)
```bash
# Установка Android Studio (если нужна Android разработка)
# Скачать с официального сайта

# Принять лицензии
flutter doctor --android-licenses

# Проверить настройку
flutter doctor
```

#### Шаг 3: VS Code Flutter setup (30 мин)
Установить расширения:
- Flutter
- Dart

Настроить Flutter в VS Code:
```bash
# Создать тестовый проект
flutter create test_flutter_app
cd test_flutter_app
code .
```

---

### 🌙 Вечерняя сессия (2 часа) - 19:00-21:00
**Первое Flutter приложение**

#### Шаг 1: Создание проекта (30 мин)
```bash
cd flutter-projects
flutter create todo_app
cd todo_app
```

#### Шаг 2: Базовое Todo приложение (90 мин)
Заменить `lib/main.dart`:
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> _todos = [];
  final TextEditingController _textController = TextEditingController();

  void _addTodo() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _todos.add(TodoItem(
          id: DateTime.now().millisecondsSinceEpoch,
          title: _textController.text,
          isCompleted: false,
        ));
        _textController.clear();
      });
    }
  }

  void _toggleTodo(int id) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index].isCompleted = !_todos[index].isCompleted;
      }
    });
  }

  void _deleteTodo(int id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Todo App'),
        backgroundColor: Colors.blue[600],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Add a new todo...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: _todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No todos yet!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Add one using the input above',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (_) => _toggleTodo(todo.id),
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: todo.isCompleted
                                  ? Colors.grey[600]
                                  : Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTodo(todo.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Total: ${_todos.length}'),
                Text('Completed: ${_todos.where((t) => t.isCompleted).length}'),
                Text('Remaining: ${_todos.where((t) => !t.isCompleted).length}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class TodoItem {
  final int id;
  String title;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }
}
```

#### Шаг 3: Тестирование Flutter приложения (10 мин)
```bash
# Запуск на web (если настроено)
flutter run -d chrome

# Запуск на desktop (если настроено)
flutter run -d linux

# Сборка для web
flutter build web
```

### 📝 Задачи на день:
- [ ] Установить Flutter SDK
- [ ] Настроить VS Code для Flutter разработки
- [ ] Создать первое Flutter приложение (Todo)
- [ ] Протестировать приложение на разных платформах
- [ ] Изучить основы Flutter widget system

---

## 📅 ДЕНЬ 6 (СУББОТА) - Tauri с Svelte

### 🌅 Утренняя сессия (2 часа) - 09:00-11:00
**Установка и настройка Tauri + Svelte**

#### Шаг 1: Установка зависимостей (30 мин)
```bash
# Установка Node.js (если не установлен)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Установка Rust зависимостей для Tauri
sudo apt-get install libwebkit2gtk-4.0-dev build-essential curl wget libssl-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev

# Установка Tauri CLI
cargo install tauri-cli
```

#### Шаг 2: Создание Tauri + Svelte проекта (45 мин)
```bash
cd tauri-projects

# Создать Svelte приложение
npm create svelte@latest hello-tauri-svelte
cd hello-tauri-svelte

# Выбрать опции:
# - Skeleton project
# - TypeScript: Yes
# - ESLint: Yes  
# - Prettier: Yes
# - Playwright: No (пока)

# Установить зависимости
npm install
```

#### Шаг 3: Инициализация Tauri (45 мин)
```bash
# Инициализировать Tauri в Svelte проекте
cargo tauri init

# Ответить на вопросы:
# App name: Hello Tauri Svelte
# Window title: Hello Tauri with Svelte
# Web assets location: ../build
# Dev server URL: http://localhost:5173
# Frontend dev command: npm run dev
# Frontend build command: npm run build
```

Обновить `vite.config.js` для Tauri:
```javascript
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [sveltekit()],
  
  // Tauri expects a fixed port, fail if that port is not available
  server: {
    port: 5173,
    strictPort: true,
  },
  
  // Tauri environment variables
  envPrefix: ['VITE_', 'TAURI_PLATFORM', 'TAURI_ARCH', 'TAURI_FAMILY', 'TAURI_PLATFORM_VERSION', 'TAURI_PLATFORM_TYPE', 'TAURI_DEBUG'],
  
  build: {
    // Tauri supports es2021
    target: process.env.TAURI_PLATFORM == 'windows' ? 'chrome105' : 'safari13',
    // don't minify for debug builds
    minify: !process.env.TAURI_DEBUG ? 'esbuild' : false,
    // produce sourcemaps for debug builds
    sourcemap: !!process.env.TAURI_DEBUG,
  },
});
```

---

### 🌙 Вечерняя сессия (3 часа) - 15:00-18:00
**Разработка Tauri + Svelte приложения**

#### Шаг 1: Настройка Tauri API в Svelte (30 мин)
```bash
# Установить Tauri API для frontend
npm install @tauri-apps/api
```

Создать `src/lib/tauri.js`:
```javascript
import { invoke } from '@tauri-apps/api/tauri';
import { appWindow } from '@tauri-apps/api/window';

export { invoke, appWindow };

// Utility functions for Tauri commands
export async function greetUser(name) {
  return await invoke('greet', { name });
}

export async function getSystemInfo() {
  return await invoke('get_system_info');
}

export async function saveFile(content) {
  return await invoke('save_file', { content });
}

export async function readFile() {
  return await invoke('read_file');
}
```

#### Шаг 2: Создание Svelte компонентов (90 мин)
Создать `src/lib/components/GreetCard.svelte`:
```svelte
<script>
  import { greetUser } from '../tauri.js';
  
  let name = '';
  let greetMsg = '';
  let loading = false;

  async function handleGreet() {
    if (!name.trim()) return;
    
    loading = true;
    try {
      greetMsg = await greetUser(name);
    } catch (error) {
      greetMsg = `Error: ${error}`;
    } finally {
      loading = false;
    }
  }
</script>

<div class="card">
  <h2>🦀 Greet Function</h2>
  
  <div class="input-group">
    <input 
      bind:value={name} 
      placeholder="Enter your name..." 
      on:keypress={(e) => e.key === 'Enter' && handleGreet()}
      disabled={loading}
    />
    <button on:click={handleGreet} disabled={loading || !name.trim()}>
      {loading ? 'Loading...' : 'Greet'}
    </button>
  </div>
  
  {#if greetMsg}
    <div class="message" class:error={greetMsg.startsWith('Error')}>
      {greetMsg}
    </div>
  {/if}
</div>

<style>
  .card {
    background: rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 24px;
    margin: 16px 0;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    transition: transform 0.2s ease;
  }
  
  .card:hover {
    transform: translateY(-2px);
  }
  
  .input-group {
    display: flex;
    gap: 12px;
    margin: 16px 0;
    align-items: center;
  }
  
  input {
    flex: 1;
    padding: 12px 16px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.1);
    color: white;
    font-size: 14px;
  }
  
  input::placeholder {
    color: rgba(255, 255, 255, 0.7);
  }
  
  button {
    background: rgba(255, 255, 255, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 8px;
    color: white;
    padding: 12px 20px;
    cursor: pointer;
    transition: all 0.2s ease;
    font-weight: 500;
  }
  
  button:hover:not(:disabled) {
    background: rgba(255, 255, 255, 0.3);
    transform: translateY(-1px);
  }
  
  button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  .message {
    margin-top: 16px;
    padding: 12px;
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.1);
    font-weight: 500;
  }
  
  .message.error {
    background: rgba(255, 0, 0, 0.2);
    border: 1px solid rgba(255, 0, 0, 0.3);
  }
</style>
```

Создать `src/lib/components/SystemInfoCard.svelte`:
```svelte
<script>
  import { getSystemInfo } from '../tauri.js';
  
  let systemInfo = null;
  let loading = false;
  let error = null;

  async function fetchSystemInfo() {
    loading = true;
    error = null;
    
    try {
      systemInfo = await getSystemInfo();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }
</script>

<div class="card">
  <h2>💻 System Information</h2>
  
  <button on:click={fetchSystemInfo} disabled={loading}>
    {loading ? 'Loading...' : 'Get System Info'}
  </button>
  
  {#if error}
    <div class="error">Error: {error}</div>
  {/if}
  
  {#if systemInfo}
    <div class="system-info">
      <div class="info-grid">
        <div class="info-item">
          <span class="label">OS:</span>
          <span class="value">{systemInfo.os}</span>
        </div>
        <div class="info-item">
          <span class="label">Architecture:</span>
          <span class="value">{systemInfo.arch}</span>
        </div>
        <div class="info-item">
          <span class="label">Hostname:</span>
          <span class="value">{systemInfo.hostname}</span>
        </div>
        <div class="info-item">
          <span class="label">CPU Cores:</span>
          <span class="value">{systemInfo.cpu_count}</span>
        </div>
        <div class="info-item">
          <span class="label">Total Memory:</span>
          <span class="value">{(systemInfo.total_memory / (1024 * 1024 * 1024)).toFixed(2)} GB</span>
        </div>
        <div class="info-item">
          <span class="label">Available Memory:</span>
          <span class="value">{(systemInfo.available_memory / (1024 * 1024 * 1024)).toFixed(2)} GB</span>
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  .card {
    background: rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 24px;
    margin: 16px 0;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
  }
  
  button {
    background: rgba(255, 255, 255, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 8px;
    color: white;
    padding: 12px 20px;
    cursor: pointer;
    transition: all 0.2s ease;
    font-weight: 500;
    margin-bottom: 16px;
  }
  
  button:hover:not(:disabled) {
    background: rgba(255, 255, 255, 0.3);
    transform: translateY(-1px);
  }
  
  button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  .system-info {
    margin-top: 16px;
  }
  
  .info-grid {
    display: grid;
    gap: 12px;
  }
  
  .info-item {
    display: flex;
    justify-content: space-between;
    padding: 8px 12px;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 6px;
    border: 1px solid rgba(255, 255, 255, 0.1);
  }
  
  .label {
    font-weight: 600;
    color: rgba(255, 255, 255, 0.9);
  }
  
  .value {
    font-family: 'Courier New', monospace;
    color: rgba(255, 255, 255, 0.8);
  }
  
  .error {
    color: #ff6b6b;
    background: rgba(255, 0, 0, 0.1);
    padding: 12px;
    border-radius: 6px;
    border: 1px solid rgba(255, 0, 0, 0.2);
  }
</style>
```

Создать `src/lib/components/FileOperationsCard.svelte`:
```svelte
<script>
  import { saveFile, readFile } from '../tauri.js';
  
  let fileContent = '';
  let result = '';
  let loading = false;

  async function handleSaveFile() {
    loading = true;
    try {
      const content = `Hello from Tauri + Svelte!\nTimestamp: ${new Date().toISOString()}\nUser input: ${fileContent || 'No user input'}`;
      result = await saveFile(content);
    } catch (error) {
      result = `Error saving: ${error}`;
    } finally {
      loading = false;
    }
  }

  async function handleReadFile() {
    loading = true;
    try {
      const content = await readFile();
      result = `File content:\n${content}`;
    } catch (error) {
      result = `Error reading: ${error}`;
    } finally {
      loading = false;
    }
  }
</script>

<div class="card">
  <h2>📁 File Operations</h2>
  
  <div class="input-group">
    <textarea 
      bind:value={fileContent} 
      placeholder="Enter some text to save..."
      disabled={loading}
    ></textarea>
  </div>
  
  <div class="button-group">
    <button on:click={handleSaveFile} disabled={loading}>
      {loading ? 'Saving...' : '💾 Save File'}
    </button>
    <button on:click={handleReadFile} disabled={loading}>
      {loading ? 'Reading...' : '📖 Read File'}
    </button>
  </div>
  
  {#if result}
    <div class="result" class:error={result.includes('Error')}>
      <pre>{result}</pre>
    </div>
  {/if}
</div>

<style>
  .card {
    background: rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 24px;
    margin: 16px 0;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
  }
  
  textarea {
    width: 100%;
    min-height: 80px;
    padding: 12px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.1);
    color: white;
    resize: vertical;
    font-family: inherit;
  }
  
  textarea::placeholder {
    color: rgba(255, 255, 255, 0.7);
  }
  
  .button-group {
    display: flex;
    gap: 12px;
    margin-top: 16px;
  }
  
  button {
    background: rgba(255, 255, 255, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 8px;
    color: white;
    padding: 12px 20px;
    cursor: pointer;
    transition: all 0.2s ease;
    font-weight: 500;
  }
  
  button:hover:not(:disabled) {
    background: rgba(255, 255, 255, 0.3);
    transform: translateY(-1px);
  }
  
  button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  .result {
    margin-top: 16px;
    padding: 12px;
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
  }
  
  .result.error {
    background: rgba(255, 0, 0, 0.1);
    border-color: rgba(255, 0, 0, 0.3);
  }
  
  pre {
    margin: 0;
    font-family: 'Courier New', monospace;
    font-size: 13px;
    line-height: 1.4;
    white-space: pre-wrap;
  }
</style>
```

#### Шаг 3: Главная страница приложения (60 мин)
Обновить `src/routes/+page.svelte`:
```svelte
<script>
  import GreetCard from '$lib/components/GreetCard.svelte';
  import SystemInfoCard from '$lib/components/SystemInfoCard.svelte';
  import FileOperationsCard from '$lib/components/FileOperationsCard.svelte';
  
  import { onMount } from 'svelte';
  import { appWindow } from '$lib/tauri.js';

  onMount(async () => {
    // Set window title
    await appWindow.setTitle('Hello Tauri + Svelte 🦀');
  });
</script>

<svelte:head>
  <title>Hello Tauri + Svelte</title>
  <meta name="description" content="Tauri desktop app built with Svelte" />
</svelte:head>

<div class="container">
  <header>
    <h1>🦀 Welcome to Tauri + Svelte!</h1>
    <p>A blazingly fast desktop app with Rust backend and Svelte frontend</p>
  </header>

  <main>
    <GreetCard />
    <SystemInfoCard />
    <FileOperationsCard />
  </main>

  <footer>
    <p>Built with ❤️ using Tauri + Svelte + Rust</p>
    <div class="tech-stack">
      <span class="tech">Rust</span>
      <span class="tech">Svelte</span>
      <span class="tech">Tauri</span>
    </div>
  </footer>
</div>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 
                 'Ubuntu', 'Cantarell', 'Open Sans', 'Helvetica Neue', sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    color: white;
    overflow-x: hidden;
  }

  .container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }

  header {
    text-align: center;
    margin-bottom: 32px;
  }

  h1 {
    font-size: 2.5rem;
    margin: 0 0 12px 0;
    background: linear-gradient(45deg, #fff, #f0f0f0);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    text-align: center;
  }

  header p {
    font-size: 1.1rem;
    opacity: 0.9;
    margin: 0;
  }

  main {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  footer {
    text-align: center;
    margin-top: 32px;
    padding-top: 24px;
    border-top: 1px solid rgba(255, 255, 255, 0.2);
    opacity: 0.8;
  }

  footer p {
    margin: 0 0 12px 0;
  }

  .tech-stack {
    display: flex;
    justify-content: center;
    gap: 12px;
    flex-wrap: wrap;
  }

  .tech {
    background: rgba(255, 255, 255, 0.1);
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 0.9rem;
    border: 1px solid rgba(255, 255, 255, 0.2);
  }

  @media (max-width: 600px) {
    .container {
      padding: 16px;
    }
    
    h1 {
      font-size: 2rem;
    }
    
    header p {
      font-size: 1rem;
    }
  }
</style>
```

#### Шаг 2: Backend логика (Rust) (90 мин)
Обновить `src-tauri/src/main.rs`:
```rust
// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::fs;
use std::path::Path;
use serde::Serialize;
use tauri::Manager;

#[derive(Serialize)]
struct SystemInfo {
    os: String,
    arch: String,
    total_memory: u64,
    available_memory: u64,
    cpu_count: usize,
    hostname: String,
}

// Learn more about Tauri commands at https://tauri.app/v1/guides/features/command
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust and Tauri! 🦀", name)
}

#[tauri::command]
fn get_system_info() -> Result<SystemInfo, String> {
    use sysinfo::{System, SystemExt, CpuExt};
    
    let mut sys = System::new_all();
    sys.refresh_all();
    
    Ok(SystemInfo {
        os: sys.name().unwrap_or_else(|| "Unknown".to_string()),
        arch: std::env::consts::ARCH.to_string(),
        total_memory: sys.total_memory(),
        available_memory: sys.available_memory(),
        cpu_count: sys.cpus().len(),
        hostname: sys.host_name().unwrap_or_else(|| "Unknown".to_string()),
    })
}

#[tauri::command]
fn save_file(content: String) -> Result<String, String> {
    let path = "tauri_test_file.txt";
    
    match fs::write(path, content) {
        Ok(_) => Ok(format!("File saved successfully to {}", path)),
        Err(e) => Err(format!("Failed to save file: {}", e)),
    }
}

#[tauri::command]
fn read_file() -> Result<String, String> {
    let path = "tauri_test_file.txt";
    
    if !Path::new(path).exists() {
        return Err("File doesn't exist. Save a file first!".to_string());
    }
    
    match fs::read_to_string(path) {
        Ok(content) => Ok(content),
        Err(e) => Err(format!("Failed to read file: {}", e)),
    }
}

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            let window = app.get_window("main").unwrap();
            window.set_title("Hello Tauri - Learning Rust Desktop Apps")?;
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            greet,
            get_system_info,
            save_file,
            read_file
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

Обновить `src-tauri/Cargo.toml` (добавить зависимости):
```toml
[dependencies]
serde_json = "1.0"
serde = { version = "1.0", features = ["derive"] }
tauri = { version = "1.0", features = ["api-all"] }
sysinfo = "0.29"
```

#### Шаг 3: Настройка и запуск (30 мин)
```bash
# Установить npm зависимости
npm install

# Запуск в dev режиме
cargo tauri dev

# Сборка релиза
cargo tauri build
```

### 📝 Задачи на день:
- [ ] Установить Tauri и зависимости
- [ ] Создать первое Tauri приложение
- [ ] Настроить frontend с Vite
- [ ] Реализовать Rust backend команды
- [ ] Протестировать взаимодействие frontend-backend

---

## 📅 ДЕНЬ 7 (ВОСКРЕСЕНЬЕ) - Рефлексия и планирование

### 🌅 Утренняя сессия (2 часа) - 09:00-11:00
**Документирование прогресса**

#### Шаг 1: Обновление README проектов (45 мин)
Создать подробный `README.md` в корне:
```markdown
# Learning as Code - Week 1 Progress

## 🎯 Completed Goals
- [x] Set up complete development environment (Go, Rust, Docker, VS Code)
- [x] Created first projects in Go and Rust
- [x] Learned basic Git workflow and branching
- [x] Built and ran first Docker containers
- [x] Set up Flutter development environment
- [x] Created first Tauri desktop application

## 📂 Project Structure
```
learning-as-code/
├── go-projects/
│   └── hello-world/          # Go CLI with Cobra
├── rust-projects/
│   ├── hello-world/          # Rust CLI with Clap
│   ├── ownership-examples/   # Rust ownership concepts
│   ├── error-handling/       # Rust error handling patterns
│   └── http-server/          # REST API with Warp
├── flutter-projects/
│   └── todo_app/            # Flutter Todo application
├── tauri-projects/
│   └── hello-tauri/         # Desktop app with system integration
└── docs/
    └── week1-learnings.md
```

## 🛠️ Technologies Learned

### Go
- Basic syntax and idioms
- Goroutines and channels introduction
- HTTP server development
- CLI development with Cobra
- Testing fundamentals

### Rust
- Ownership and borrowing system
- Error handling with Result/Option
- Async programming with Tokio
- HTTP server with Warp
- CLI development with Clap

### Flutter
- Widget system basics
- State management with StatefulWidget
- Material Design components
- Cross-platform development

### Tauri
- Rust backend + Web frontend architecture
- System API integration
- File operations
- Cross-platform desktop development

### DevOps
- Docker containerization
- Docker Compose for multi-service apps
- Git workflow and branching strategies
- VS Code development environment setup

## 📊 Statistics
- **Lines of code written**: ~800 (Go: 300, Rust: 400, Dart: 100)
- **Projects created**: 7
- **Technologies learned**: 6
- **Docker images built**: 4
- **Git commits**: 12

## 🔍 Key Learnings

1. **Rust ownership system** is complex but prevents many runtime errors
2. **Go's simplicity** makes it excellent for quick prototyping
3. **Docker** significantly simplifies development environment setup
4. **Tauri** provides excellent performance for desktop apps
5. **Flutter** enables rapid cross-platform development

## 🚀 Next Week Goals (Week 2)
- [ ] Build more complex CLI tools
- [ ] Implement database integration
- [ ] Create web scrapers
- [ ] Develop chat application with WebSockets
- [ ] Enhance Tauri app with more system integrations

## 🐛 Challenges Faced
1. Rust ownership system learning curve
2. Docker permission issues on Linux
3. Flutter web setup complexity
4. Tauri frontend-backend communication setup

## 💡 Solutions Found
1. Used Rust ownership examples and practice
2. Added user to docker group
3. Used flutter doctor for diagnostics
4. Followed Tauri documentation carefully
```

#### Шаг 2: Создание week1-learnings.md (45 мин)
```bash
mkdir -p docs
```

Создать `docs/week1-learnings.md`:
```markdown
# Week 1: Development Environment and First Projects

## Daily Progress

### Day 1: Environment Setup
**Time invested**: 3.5 hours
**Key achievements**:
- Mastered Docker basics and multi-stage builds
- Created Dockerfiles for Go and Rust projects
- Set up docker-compose for development environment
- Configured VS Code with essential extensions

**Challenges**:
- Understanding Docker multi-stage builds
- VS Code extension conflicts

**Solutions**:
- Studied Docker documentation and examples
- Configured extensions step by step with proper settings.json

### Day 3: Git Workflow Mastery
**Time invested**: 3.5 hours
**Key achievements**:
- Learned advanced Git commands (stash, rebase, cherry-pick)
- Enhanced Go project with Cobra CLI framework
- Added comprehensive testing to both Go and Rust projects
- Implemented proper branching strategy

**Challenges**:
- Understanding Git rebase vs merge
- Cobra CLI integration complexity

**Solutions**:
- Practiced with test repository first
- Followed Cobra documentation step by step

### Day 4: Rust Deep Dive
**Time invested**: 3.5 hours
**Key achievements**:
- Mastered Rust ownership and borrowing concepts
- Built comprehensive error handling examples
- Created HTTP REST API server with Warp
- Implemented async Rust programming

**Challenges**:
- Rust ownership system complexity
- Async programming concepts
- HTTP server error handling

**Solutions**:
- Created extensive ownership examples
- Used Rust compiler error messages as learning tool
- Studied Tokio documentation

### Day 5: Flutter Introduction
**Time invested**: 3.5 hours
**Key achievements**:
- Installed and configured Flutter SDK
- Built functional Todo application
- Learned Flutter widget system
- Implemented state management with StatefulWidget

**Challenges**:
- Flutter SDK setup complexity
- Understanding widget lifecycle

**Solutions**:
- Used flutter doctor for diagnostics
- Created simple examples before complex app

### Day 6: Tauri Desktop Development
**Time invested**: 5 hours
**Key achievements**:
- Set up Tauri development environment
- Created desktop app with system integration
- Implemented Rust backend commands
- Built modern web-based UI with Vite

**Challenges**:
- Tauri dependencies installation
- Frontend-backend communication setup
- System info API integration

**Solutions**:
- Followed platform-specific installation guides
- Used Tauri documentation and examples
- Implemented sysinfo crate for system data

### Day 7: Documentation and Reflection
**Time invested**: 4 hours
**Key achievements**:
- Comprehensive project documentation
- Progress analysis and metrics
- Planning for week 2
- Code cleanup and optimization

## Technical Skills Developed

### Programming Languages
1. **Go Programming**
   - Basic syntax and idioms
   - Concurrency with goroutines
   - HTTP server development
   - CLI tools with Cobra
   - Testing patterns

2. **Rust Programming**
   - Ownership and borrowing system
   - Error handling patterns
   - Async programming with Tokio
   - HTTP servers with Warp
   - System programming concepts

3. **Dart/Flutter**
   - Widget system architecture
   - State management
   - Material Design implementation
   - Cross-platform development

### Tools and Frameworks
1. **Docker**
   - Containerization concepts
   - Multi-stage builds
   - Docker Compose orchestration
   - Development environment setup

2. **Git**
   - Advanced workflow patterns
   - Branching strategies
   - Collaboration patterns
   - Version control best practices

3. **VS Code**
   - Extension ecosystem
   - Development environment configuration
   - Debugging setup
   - Productivity optimization

## Code Quality Metrics

### Lines of Code by Language
- **Go**: ~300 lines
- **Rust**: ~400 lines
- **Dart**: ~100 lines
- **JavaScript**: ~50 lines
- **Docker**: ~40 lines
- **Markdown**: ~200 lines

### Test Coverage
- **Go projects**: 80%+ test coverage
- **Rust projects**: 75%+ test coverage
- **Flutter projects**: Basic widget tests

### Project Complexity
- **Simple projects**: 4 (Hello World variants)
- **Medium projects**: 2 (Todo app, HTTP server)
- **Complex projects**: 1 (Tauri desktop app)

## Performance Analysis

### Build Times
- **Go projects**: ~2-5 seconds
- **Rust projects**: ~30-60 seconds (initial), ~5-10 seconds (incremental)
- **Flutter projects**: ~15-30 seconds
- **Tauri projects**: ~60-120 seconds

### Resource Usage
- **Memory**: Go < Flutter < Rust < Tauri
- **CPU**: Similar across platforms during development
- **Disk**: Rust (target/) > Flutter (.dart_tool) > Go (minimal)

## Learning Methodology Insights

### What Worked Well
1. **Hands-on approach**: Building real projects instead of just tutorials
2. **Daily progression**: Consistent 3-4 hours daily schedule
3. **Documentation habit**: Writing down challenges and solutions
4. **Multi-language comparison**: Learning Go and Rust simultaneously
5. **Tool integration**: Setting up proper development environment first

### Areas for Improvement
1. **AI integration**: Haven't started using local LLMs yet
2. **Testing discipline**: Could write tests first (TDD)
3. **Performance profiling**: Need to learn optimization techniques
4. **Architecture patterns**: Focus more on design patterns

### Recommended Adjustments for Week 2
1. **Start integrating local LLMs** for code assistance
2. **Implement TDD approach** for new projects
3. **Add performance benchmarking** to daily routine
4. **Begin architecture pattern study**

## Resources Used

### Documentation
- [Go official documentation](https://golang.org/doc/)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Flutter documentation](https://flutter.dev/docs)
- [Tauri documentation](https://tauri.app/v1/guides/)
- [Docker documentation](https://docs.docker.com/)

### Libraries and Frameworks
- **Go**: Cobra CLI, standard library
- **Rust**: Tokio, Warp, Clap, Serde, Sysinfo
- **Flutter**: Material Design, standard widgets
- **Tauri**: System APIs, Vite frontend

### Tools
- **IDE**: VS Code with language extensions
- **Version Control**: Git with GitHub
- **Containerization**: Docker and Docker Compose
- **Build Systems**: Go modules, Cargo, Flutter tools, npm

## Week 2 Preparation

### Environment Setup
- [ ] Install Ollama for local LLM support
- [ ] Set up LLaMA 7B model
- [ ] Configure AI coding assistants
- [ ] Prepare database environment (PostgreSQL)

### Learning Objectives
1. **Database Integration**
   - SQL with PostgreSQL
   - ORM usage (GORM for Go, Diesel for Rust)
   - Database migrations and schema management

2. **Web Development**
   - Advanced HTTP concepts
   - WebSocket implementation
   - REST API best practices

3. **Testing and Quality**
   - Test-driven development
   - Integration testing
   - Performance testing

4. **AI Integration**
   - Local LLM setup and usage
   - AI-assisted coding workflows
   - Code generation and review

### Project Ideas
1. **CLI File Manager** (Go/Rust comparison)
2. **Web Scraper** with concurrent processing
3. **Chat Application** with WebSocket server
4. **Desktop System Monitor** with Tauri
5. **Flutter Mobile App** with backend integration

## Conclusion

Week 1 successfully established a solid foundation in modern development practices. The combination of Go, Rust, Flutter, and Tauri provides a comprehensive toolkit for full-stack development. The focus on practical projects rather than theoretical learning proved effective.

Key success factors:
- Consistent daily practice
- Hands-on project approach
- Proper tooling setup
- Documentation discipline

Ready to advance to Week 2 with database integration and more complex projects.
```

#### Шаг 3: Коммиты и обновления (30 мин)
```bash
# Обновить все изменения
git add .
git commit -m "Week 1 complete: Documentation, reflection, and planning

- Added comprehensive README.md with project overview
- Created detailed week1-learnings.md documentation
- Documented all 7 projects and technologies learned
- Analyzed progress and identified areas for improvement
- Prepared roadmap for Week 2

Projects completed:
- Go CLI tools with Cobra
- Rust HTTP server with Warp
- Flutter Todo application
- Tauri desktop app with system integration
- Docker containerization for all projects
- Comprehensive testing and documentation"

git push origin main

# Создать тег для завершения недели 1
git tag -a v1.0-week1 -m "Week 1 completion: Development environment and first projects"
git push origin v1.0-week1
```

---

### 🌙 Дневная сессия (3 часа) - 14:00-17:00
**Подготовка к неделе 2 и advanced планирование**

#### Шаг 1: Ollama и LLM setup (60 мин)
```bash
# Установка Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Запуск Ollama
ollama serve &

# Установка LLaMA 7B модели
ollama pull llama2:7b

# Тестирование
ollama run llama2:7b "Explain Rust ownership in simple terms"
```

#### Шаг 2: Advanced Git setup (45 мин)
Создать `.gitmessage` template:
```bash
cat > ~/.gitmessage << 'EOF'
# Title: Summary, imperative, start upper case, don't end with a period
# No more than 50 chars. #### 50 chars is here:  #

# Remember blank line between title and body.

# Body: Explain *what* and *why* (not *how*). Include task ID (Jira issue).
# Wrap at 72 chars. ################################## which is here:  #


# At the end: Include Co-authored-by for all contributors. 
# Include at least one empty line before it. Format: 
# Co-authored-by: name <user@users.noreply.github.com>
#
# How to Write a Git Commit Message:
# https://chris.beams.io/posts/git-commit/
#
# 1. Separate subject from body with a blank line
# 2. Limit the subject line to 50 characters
# 3. Capitalize the subject line
# 4. Do not end the subject line with a period
# 5. Use the imperative mood in the subject line
# 6. Wrap the body at 72 characters
# 7. Use the body to explain what and why vs. how
EOF

git config --global commit.template ~/.gitmessage
```

Настроить Git hooks:
```bash
mkdir -p .git/hooks

# Pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh

echo "Running pre-commit checks..."

# Run Go tests
if [ -d "go-projects" ]; then
    echo "Running Go tests..."
    for dir in go-projects/*/; do
        if [ -f "$dir/go.mod" ]; then
            (cd "$dir" && go test ./...)
        fi
    done
fi

# Run Rust tests
if [ -d "rust-projects" ]; then
    echo "Running Rust tests..."
    for dir in rust-projects/*/; do
        if [ -f "$dir/Cargo.toml" ]; then
            (cd "$dir" && cargo test)
        fi
    done
fi

# Run Flutter tests
if [ -d "flutter-projects" ]; then
    echo "Running Flutter tests..."
    for dir in flutter-projects/*/; do
        if [ -f "$dir/pubspec.yaml" ]; then
            (cd "$dir" && flutter test)
        fi
    done
fi

echo "Pre-commit checks completed."
EOF

chmod +x .git/hooks/pre-commit
```

#### Шаг 3: Week 2 детальное планирование (75 мин)
Создать `docs/week2-plan.md`:
```markdown
# Week 2: Database Integration and Advanced Projects
*Days 8-14 of Learning as Code Plan*

## 🎯 Week Goals
- [ ] Master SQL and NoSQL database integration
- [ ] Build complex CLI applications
- [ ] Implement WebSocket real-time communication
- [ ] Create desktop applications with system integration
- [ ] Start using local LLM for code assistance

## 📅 Daily Breakdown

### Day 8 (Monday): Database Foundations
**Focus**: PostgreSQL setup and basic operations

**Morning Session (1.5h)**:
- PostgreSQL installation and setup
- Basic SQL operations (CRUD)
- Database design principles
- Schema creation and migrations

**Evening Session (2h)**:
- Go database integration with database/sql
- Connection pooling and best practices
- Simple CRUD application in Go
- Error handling for database operations

**Deliverables**:
- PostgreSQL running in Docker
- Go application with database CRUD operations
- Database schema for todo application

### Day 9 (Tuesday): ORM and Advanced Queries
**Focus**: GORM for Go and Diesel for Rust

**Morning Session (1.5h)**:
- GORM installation and setup
- Model definitions and relationships
- Auto-migrations and schema management
- Advanced queries and joins

**Evening Session (2h)**:
- Rust Diesel ORM setup
- Schema management with Diesel
- Query building and type safety
- Comparison of Go vs Rust database approaches

**Deliverables**:
- Go application using GORM
- Rust application using Diesel
- Comparative analysis document

### Day 10 (Wednesday): CLI Applications Deep Dive
**Focus**: Advanced command-line tools

**Morning Session (1.5h)**:
- File system operations
- Command-line argument parsing
- Configuration file handling
- Logging and error reporting

**Evening Session (2h)**:
- Build file manager CLI in Go
- Build system monitor CLI in Rust
- Interactive CLI interfaces
- Cross-platform considerations

**Deliverables**:
- Advanced CLI file manager (Go)
- System monitoring tool (Rust)
- Both tools packaged and documented

### Day 11 (Thursday): Web Scraping and Concurrency
**Focus**: Concurrent data processing

**Morning Session (1.5h)**:
- HTTP client programming
- HTML parsing and data extraction
- Rate limiting and respectful scraping
- Error handling for network operations

**Evening Session (2h)**:
- Concurrent scraping with goroutines
- Async scraping with Tokio
- Data storage and processing
- Performance comparison

**Deliverables**:
- Web scraper in Go with goroutines
- Web scraper in Rust with async/await
- Performance benchmarks and analysis

### Day 12 (Friday): WebSocket and Real-time Apps
**Focus**: Real-time communication

**Morning Session (1.5h)**:
- WebSocket protocol understanding
- Server-side WebSocket implementation
- Client-side WebSocket handling
- Message broadcasting patterns

**Evening Session (2h)**:
- Chat server in Go/Rust
- Flutter WebSocket client
- Real-time message delivery
- Connection management and error handling

**Deliverables**:
- WebSocket chat server
- Flutter chat client application
- Real-time communication working end-to-end

### Day 13 (Saturday): Desktop Applications Advanced
**Focus**: Advanced Tauri development

**Morning Session (2h)**:
- System tray integration
- File system watching
- Native notifications
- Menu system implementation

**Afternoon Session (3h)**:
- Database integration in Tauri
- Settings persistence
- Auto-updater implementation
- Performance monitoring display

**Deliverables**:
- Advanced system monitoring app
- Settings and persistence system
- System tray integration

### Day 14 (Sunday): AI Integration and Week Review
**Focus**: Local LLM integration and documentation

**Morning Session (2h)**:
- Ollama integration in development workflow
- AI-assisted code generation
- Code review with LLM
- Documentation generation

**Afternoon Session (2h)**:
- Week 2 progress documentation
- Code cleanup and optimization
- Performance analysis
- Week 3 planning

**Deliverables**:
- AI-integrated development workflow
- Comprehensive week 2 documentation
- Optimized and tested codebase

## 🛠️ Technologies Focus

### Databases
- **PostgreSQL**: Primary relational database
- **Redis**: Caching and session storage
- **SQLite**: Embedded database for desktop apps

### Libraries and Frameworks
**Go**:
- `database/sql` - Standard database interface
- `gorm.io/gorm` - ORM framework
- `github.com/gorilla/websocket` - WebSocket support
- `github.com/goquery` - HTML parsing

**Rust**:
- `diesel` - ORM and query builder
- `tokio-tungstenite` - WebSocket support
- `scraper` - HTML parsing
- `reqwest` - HTTP client

**Flutter**:
- `web_socket_channel` - WebSocket client
- `http` - HTTP client
- `sqflite` - SQLite database
- `provider` - State management

**Tauri**:
- `tauri-plugin-sql` - Database integration
- `tauri-plugin-store` - Persistent storage
- `tauri-plugin-updater` - Auto-updates

## 📊 Success Metrics

### Quantitative Goals
- [ ] 5+ database-integrated applications
- [ ] 3+ CLI tools with advanced features
- [ ] 1 real-time chat application
- [ ] 1 advanced desktop application
- [ ] 10+ automated tests per project
- [ ] <100ms response times for database queries

### Qualitative Goals
- [ ] Understanding of database design principles
- [ ] Mastery of concurrent programming patterns
- [ ] Real-time application architecture knowledge
- [ ] AI-assisted development workflow
- [ ] Production-ready error handling

## 🚀 Stretch Goals
- [ ] Deploy applications to cloud platforms
- [ ] Implement authentication systems
- [ ] Add monitoring and logging
- [ ] Create API documentation
- [ ] Performance optimization and profiling

## 📚 Resources and References
- [PostgreSQL Tutorial](https://www.postgresql.org/docs/current/tutorial.html)
- [GORM Documentation](https://gorm.io/docs/)
- [Diesel Documentation](https://diesel.rs/guides/)
- [WebSocket RFC 6455](https://tools.ietf.org/html/rfc6455)
- [Tauri Plugins](https://tauri.app/v1/guides/features/plugin)

## 🔄 Daily Routine
1. **Morning standup** (10 min): Review yesterday, plan today
2. **LLM consultation** (ongoing): Use AI for problem-solving
3. **Code implementation** (2-3 hours): Focus work
4. **Testing and documentation** (30 min): Quality assurance
5. **Evening review** (15 min): Progress reflection

Ready to advance to more complex, production-ready applications in Week 2!
```

### 📝 Задачи на день:
- [ ] Создать подробную документацию недели 1
- [ ] Проанализировать прогресс и метрики
- [ ] Установить Ollama и протестировать LLM
- [ ] Настроить продвинутый Git workflow
- [ ] Создать детальный план недели 2
- [ ] Подготовить окружение для работы с базами данных

---

## 🔄 Еженедельная рефлексия

### ✅ Достижения недели
1. **Техническая основа**: Создана полная среда разработки
2. **Языки программирования**: Освоены основы Go, Rust, Dart
3. **Инструменты**: Docker, Git, VS Code настроены и протестированы
4. **Проекты**: 7 функциональных приложений
5. **Архитектура**: Понимание desktop, web, mobile разработки

### 🔍 Ключевые инсайты
1. **Rust vs Go**: Rust сложнее, но безопаснее; Go проще и быстрее для прототипирования
2. **Docker**: Значительно упрощает development environment
3. **Flutter**: Отличный выбор для cross-platform UI
4. **Tauri**: Превосходная производительность для desktop apps

### 🎯 Области для улучшения
1. **Тестирование**: Нужно больше unit и integration тестов
2. **Архитектура**: Изучить design patterns и best practices
3. **AI интеграция**: Начать использовать LLM в workflow
4. **Performance**: Добавить benchmarking и профилирование

### 📈 Метрики недели
- **Время обучения**: 25 часов
- **Строки кода**: ~800
- **Проекты**: 7
- **Технологии**: 6
- **Git коммиты**: 15

### 🚀 Готовность к неделе 2
Недель 1 заложила прочный фундамент. Готов переходить к более сложным проектам с базами данных, real-time коммуникацией и AI-интеграцией.

**Уровень уверенности**: 85%
**Мотивация**: Высокая
**Готовность к вызовам**: Готов к усложнению

---

*Неделя 1 завершена успешно! 🎉 Переходим к неделе 2 с базами данных и advanced проектами.* achievements**:
- Successfully installed Go, Rust, Docker, Git, VS Code
- Created GitHub repository with proper structure
- Built first Hello World applications in Go and Rust

**Challenges**:
- Docker installation permissions on Linux
- SSH key setup for GitHub

**Solutions**:
- Added user to docker group: `sudo usermod -aG docker $USER`
- Generated ed25519 key for better security

### Day 2: Docker Mastery
**Time invested**: 3.5 hours
**Key achievements**:
- Mastered Docker basics and multi-stage builds
- Created Dockerfiles for Go and Rust projects
- Set up docker-compose for development environment
- Configured VS Code with essential extensions

**Challenges**:
- Understanding Docker multi-stage builds
- VS Code extension conflicts

**Solutions**:
- Studied Docker documentation and examples
- Configured extensions step by step with proper settings.json

### Day 3: Git Workflow Mastery
**Time invested**: 3.5 hours
**Key achievements**:
- Learned advanced Git commands (stash, rebase, cherry-pick)
- Enhanced Go project with Cobra CLI framework
- Added comprehensive testing to both Go and Rust projects
- Implemented proper branching strategy

**Challenges**:
- Understanding Git rebase vs merge
- Cobra CLI integration complexity

**Solutions**:
- Practiced with test repository first
- Followed Cobra documentation step by step

### Day 4: Rust Deep Dive
**Time invested**: 3.5 hours
**Key achievements**:
- Mastered Rust ownership and borrowing concepts
- Built comprehensive error handling examples
- Created HTTP REST API server with Warp
- Implemented async Rust programming

**Challenges**:
- Rust ownership system complexity
- Async programming concepts
- HTTP server error handling

**Solutions**:
- Created extensive ownership examples
- Used Rust compiler error messages as learning tool
- Studied Tokio documentation

### Day 5: Flutter Introduction
**Time invested**: 3.5 hours
**Key achievements**:
- Installed and configured Flutter SDK
- Built functional Todo application
- Learned Flutter widget system
- Implemented state management with StatefulWidget

**Challenges**:
- Flutter SDK setup complexity
- Understanding widget lifecycle

**Solutions**:
- Used flutter doctor for diagnostics
- Created simple examples before complex app

### Day 6: Tauri Desktop Development
**Time invested**: 5 hours
**Key achievements**:
- Set up Tauri development environment
- Created desktop app with system integration
- Implemented Rust backend commands
- Built modern web-based UI with Vite

**Challenges**:
- Tauri dependencies installation
- Frontend-backend communication setup
- System info API integration

**Solutions**:
- Followed platform-specific installation guides
- Used Tauri documentation and examples
- Implemented sysinfo crate for system data

### Day 7: Documentation and Reflection
**Time invested**: 4 hours
**Key achievements**:
- Comprehensive project documentation
- Progress analysis and metrics
- Planning for week 2
- Code cleanup and optimization

## Technical Skills Developed

### Programming Languages
1. **Go Programming**
   - Basic syntax and idioms
   - Concurrency with goroutines
   - HTTP server development
   - CLI tools with Cobra
   - Testing patterns

2. **Rust Programming**
   - Ownership and borrowing system
   - Error handling patterns
   - Async programming with Tokio
   - HTTP servers with Warp
   - System programming concepts

3. **Dart/Flutter**
   - Widget system architecture
   - State management
   - Material Design implementation
   - Cross-platform development

### Tools and Frameworks
1. **Docker**
   - Containerization concepts
   - Multi-stage builds
   - Docker Compose orchestration
   - Development environment setup

2. **Git**
   - Advanced workflow patterns
   - Branching strategies
   - Collaboration patterns
   - Version control best practices

3. **VS Code**
   - Extension ecosystem
   - Development environment configuration
   - Debugging setup
   - Productivity optimization

## Code Quality Metrics

### Lines of Code by Language
- **Go**: ~300 lines
- **Rust**: ~400 lines
- **Dart**: ~100 lines
- **JavaScript**: ~50 lines
- **Docker**: ~40 lines
- **Markdown**: ~200 lines

### Test Coverage
- **Go projects**: 80%+ test coverage
- **Rust projects**: 75%+ test coverage
- **Flutter projects**: Basic widget tests

### Project Complexity
- **Simple projects**: 4 (Hello World variants)
- **Medium projects**: 2 (Todo app, HTTP server)
- **Complex projects**: 1 (Tauri desktop app)

## Performance Analysis

### Build Times
- **Go projects**: ~2-5 seconds
- **Rust projects**: ~30-60 seconds (initial), ~5-10 seconds (incremental)
- **Flutter projects**: ~15-30 seconds
- **Tauri projects**: ~60-120 seconds

### Resource Usage
- **Memory**: Go < Flutter < Rust < Tauri
- **CPU**: Similar across platforms during development
- **Disk**: Rust (target/) > Flutter (.dart_tool) > Go (minimal)

## Learning Methodology Insights

### What Worked Well
1. **Hands-on approach**: Building real projects instead of just tutorials
2. **Daily progression**: Consistent 3-4 hours daily schedule
3. **Documentation habit**: Writing down challenges and solutions
4. **Multi-language comparison**: Learning Go and Rust simultaneously
5. **Tool integration**: Setting up proper development environment first

### Areas for Improvement
1. **AI integration**: Haven't started using local LLMs yet
2. **Testing discipline**: Could write tests first (TDD)
3. **Performance profiling**: Need to learn optimization techniques
4. **Architecture patterns**: Focus more on design patterns

### Recommended Adjustments for Week 2
1. **Start integrating local LLMs** for code assistance
2. **Implement TDD approach** for new projects
3. **Add performance benchmarking** to daily routine
4. **Begin architecture pattern study**

## Resources Used

### Documentation
- [Go official documentation](https://golang.org/doc/)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Flutter documentation](https://flutter.dev/docs)
- [Tauri documentation](https://tauri.app/v1/guides/)
- [Docker documentation](https://docs.docker.com/)

### Libraries and Frameworks
- **Go**: Cobra CLI, standard library
- **Rust**: Tokio, Warp, Clap, Serde, Sysinfo
- **Flutter**: Material Design, standard widgets
- **Tauri**: System APIs, Vite frontend

### Tools
- **IDE**: VS Code with language extensions
- **Version Control**: Git with GitHub
- **Containerization**: Docker and Docker Compose
- **Build Systems**: Go modules, Cargo, Flutter tools, npm

## Week 2 Preparation

### Environment Setup
- [ ] Install Ollama for local LLM support
- [ ] Set up LLaMA 7B model
- [ ] Configure AI coding assistants
- [ ] Prepare database environment (PostgreSQL)

### Learning Objectives
1. **Database Integration**
   - SQL with PostgreSQL
   - ORM usage (GORM for Go, Diesel for Rust)
   - Database migrations and schema management

2. **Web Development**
   - Advanced HTTP concepts
   - WebSocket implementation
   - REST API best practices

3. **Testing and Quality**
   - Test-driven development
   - Integration testing
   - Performance testing

4. **AI Integration**
   - Local LLM setup and usage
   - AI-assisted coding workflows
   - Code generation and review

### Project Ideas
1. **CLI File Manager** (Go/Rust comparison)
2. **Web Scraper** with concurrent processing
3. **Chat Application** with WebSocket server
4. **Desktop System Monitor** with Tauri
5. **Flutter Mobile App** with backend integration

## Conclusion

Week 1 successfully established a solid foundation in modern development practices. The combination of Go, Rust, Flutter, and Tauri provides a comprehensive toolkit for full-stack development. The focus on practical projects rather than theoretical learning proved effective.

Key success factors:
- Consistent daily practice
- Hands-on project approach
- Proper tooling setup
- Documentation discipline

Ready to advance to Week 2 with database integration and more complex projects.

---

## 🔄 Еженедельная рефлексия

### ✅ Достижения недели
1. **Техническая основа**: Создана полная среда разработки
2. **Языки программирования**: Освоены основы Go, Rust, Dart
3. **Инструменты**: Docker, Git, VS Code настроены и протестированы
4. **Проекты**: 7 функциональных приложений
5. **Архитектура**: Понимание desktop, web, mobile разработки

### 🔍 Ключевые инсайты
1. **Rust vs Go**: Rust сложнее, но безопаснее; Go проще и быстрее для прототипирования
2. **Docker**: Значительно упрощает development environment
3. **Flutter**: Отличный выбор для cross-platform UI
4. **Tauri**: Превосходная производительность для desktop apps

### 🎯 Области для улучшения
1. **Тестирование**: Нужно больше unit и integration тестов
2. **Архитектура**: Изучить design patterns и best practices
3. **AI интеграция**: Начать использовать LLM в workflow
4. **Performance**: Добавить benchmarking и профилирование

### 📈 Метрики недели
- **Время обучения**: 25 часов
- **Строки кода**: ~800
- **Проекты**: 7
- **Технологии**: 6
- **Git коммиты**: 15

### 🚀 Готовность к неделе 2
Недель 1 заложила прочный фундамент. Готов переходить к более сложным проектам с базами данных, real-time коммуникацией и AI-интеграцией.

**Уровень уверенности**: 85%
**Мотивация**: Высокая
**Готовность к вызовам**: Готов к усложнению

---

*Неделя 1 завершена успешно! 🎉 Переходим к неделе 2 с базами данных и advanced проектами.*
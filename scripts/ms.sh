#!/bin/bash
echo "🚀 Starting High-Efficiency Dev Session"

# 1. Обновить все репозитории
find ~/repo -name ".git" -type d | while read git_dir; do
    repo_dir=$(dirname "$git_dir")
    echo "Updating $repo_dir"
    git -C "$repo_dir" pull --rebase
done

# 2. Запустить необходимые сервисы
docker compose up -d postgres redis ollama
ollama pull deepseek-coder:16b-instruct-q4_K_M > /dev/null 2>&1

# 3. Подготовить AI ассистента
echo "AI готов к работе:" > /tmp/ai-session.log
ollama run deepseek-coder:16b-instruct-q4_K_M "Hello! Ready for a productive coding session. What are we building today?" >> /tmp/ai-session.log

# 4. Активировать focus mode
killall Telegram 2>/dev/null || true
echo "Focus mode activated ✅"

# 5. Показать план дня
cat ~/planning/today.md 2>/dev/null || echo "⚠️  План дня не найден"
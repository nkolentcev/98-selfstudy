# Руководство по устранению неполадок - Система Высокоэффективного Программиста

## 🔧 Быстрые исправления

### Наиболее распространенные проблемы

#### 1. Ошибки «Отказано в доступе»
```bash
# Исправление разрешений скриптов
chmod +x high-efficiency-programmer.sh
chmod +x scripts/*.sh

# Если проблемы продолжаются:
find . -name "*.sh" -exec chmod +x {} \;
```

#### 2. «Команда jq не найдена»
```bash
# Ubuntu/Debian
sudo apt install jq

# CentOS/RHEL/Fedora
sudo yum install jq
# или для новых версий:
sudo dnf install jq

# macOS с Homebrew
brew install jq

# Проверка установки
jq --version
```

#### 3. Git не настроен
```bash
# Настройка Git глобально
git config --global user.name "Ваше Имя"
git config --global user.email "your.email@example.com"

# Проверка конфигурации
git config --global --list
```

#### 4. Скрипты не выполняются
```bash
# Проверьте, находитесь ли вы в правильном каталоге
pwd
ls -la high-efficiency-programmer.sh

# Запускайте явно через bash при необходимости
bash high-efficiency-programmer.sh help
```

## 🐛 Подробное устранение неполадок

### Проблемы с установкой

#### Проблема: Сбой скрипта настройки
**Симптомы:**
- Процесс настройки неожиданно останавливается
- Ошибки во время `./scripts/setup-reminders.sh init`

**Решения:**
```bash
# Проверка системных требований
./scripts/setup-reminders.sh tools

# Выполнение отдельных шагов настройки
./scripts/setup-reminders.sh git
./scripts/setup-reminders.sh profile
./scripts/setup-reminders.sh shell

# Проверка статуса настройки
./scripts/setup-reminders.sh status
```

#### Проблема: Отсутствующие зависимости
**Симптомы:**
- Команды выдают ошибку "команда не найдена"
- Функции не работают корректно

**Решения:**
```bash
# Проверка, какие инструменты отсутствуют
for tool in git curl jq node python3; do
    if command -v $tool >/dev/null 2>&1; then
        echo "✅ $tool установлен"
    else
        echo "❌ $tool отсутствует"
    fi
done

# Установите отсутствующие инструменты в зависимости от вашей ОС
# См. installation.md для инструкций по конкретным платформам
```

### Проблемы во время выполнения

#### Проблема: Режим фокуса не запускается
**Симптомы:**
- Таймер отображается некорректно
- Сессия не отслеживается правильно

**Решения:**
```bash
# Тестирование режима фокуса с короткой сессией
./scripts/focus-mode.sh focus 1

# Проверка существования каталога данных
ls -la ~/.hep-data/

# Создание каталога данных, если он отсутствует
mkdir -p ~/.hep-data

# Тестирование с подробным выводом
bash -x ./scripts/focus-mode.sh focus 5
```

#### Problem: Time Tracking Not Working
**Symptoms:**
- Sessions don't start/stop
- Data not saved
- Summary shows no data

**Solutions:**
```bash
# Check data file
cat ~/.hep-data/time-tracking.json

# Manually initialize if corrupted
echo '{"sessions": [], "projects": {}, "categories": {}}' > ~/.hep-data/time-tracking.json

# Test basic tracking
./scripts/time-tracker.sh start "test" "development" "testing tracking"
sleep 5
./scripts/time-tracker.sh stop
./scripts/time-tracker.sh status
```

#### Problem: Dashboard Doesn't Load
**Symptoms:**
- HTML dashboard is blank
- Browser shows errors
- No data displayed

**Solutions:**
```bash
# Generate fresh dashboard
./scripts/create-dashboard.sh both

# Check if data exists
ls -la ~/.hep-data/

# Test with text dashboard first
./scripts/create-dashboard.sh text

# Check browser console for JavaScript errors
# Open browser developer tools (F12)
```

#### Problem: AI Assistant Not Responding
**Symptoms:**
- AI commands hang
- No responses from assistant
- Error messages in AI interactions

**Solutions:**
```bash
# Test basic AI functionality
./scripts/ai-helper.sh help

# Check if context file is valid JSON
cat ~/.hep-data/ai-context.json | jq .

# Reinitialize AI data if needed
rm ~/.hep-data/ai-context.json
rm ~/.hep-data/ai-conversations.json
./scripts/personal-ai-assistant.sh context

# Test simple query
./scripts/ai-helper.sh analyze --help
```

### Git Integration Issues

#### Problem: Git Status Not Detected
**Symptoms:**
- Morning routine shows no Git repositories
- Productivity metrics show no commits

**Solutions:**
```bash
# Check if you're in a Git repository
git status

# If not in a repo, initialize one
git init
git add .
git commit -m "Initial commit"

# Check Git configuration
git config --list

# Test Git integration
./scripts/auto-review.sh changed
```

#### Problem: Code Review Fails
**Symptoms:**
- Auto-review shows no files
- Analysis doesn't run on code

**Solutions:**
```bash
# Check if there are changed files
git status
git diff --name-only HEAD~1

# Test with specific file
./scripts/auto-review.sh file path/to/your/file.js

# Check file permissions
ls -la path/to/your/file.js

# Run review with verbose output
bash -x ./scripts/auto-review.sh changed
```

### Data and Configuration Issues

#### Problem: Productivity Metrics Missing
**Symptoms:**
- Dashboard shows no data
- Metrics commands return empty results

**Solutions:**
```bash
# Check data directory
ls -la ~/.hep-data/

# Initialize metrics if needed
./scripts/productivity-metrics.sh record

# Check data file structure
cat ~/.hep-data/productivity-metrics.json | jq .

# Reset metrics if corrupted
rm ~/.hep-data/productivity-metrics.json
./scripts/productivity-metrics.sh record
```

#### Problem: Configuration Lost
**Symptoms:**
- Settings don't persist
- Profile data missing
- System asks for setup again

**Solutions:**
```bash
# Check setup status
./scripts/setup-reminders.sh status

# Verify config files
ls -la config/
cat config/developer-profile.md

# Re-run setup if needed
./scripts/setup-reminders.sh init

# Check data directory permissions
ls -la ~/.hep-data/
# Should show files owned by your user
```

## 💻 Platform-Specific Issues

### Linux Issues

#### Problem: Package Installation Fails
```bash
# Update package lists first
sudo apt update  # Ubuntu/Debian
sudo yum update   # CentOS/RHEL

# Try alternative installation methods
# For jq on older systems:
wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x jq-linux64
sudo mv jq-linux64 /usr/local/bin/jq
```

#### Problem: Shell Integration Issues
```bash
# Check which shell you're using
echo $SHELL

# For bash users
echo 'source ~/.bashrc' >> ~/.bash_profile

# For zsh users
echo 'source ~/.zshrc' >> ~/.zprofile

# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc
```

### macOS Issues

#### Problem: Command Line Tools Missing
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcode-select -p
```

#### Problem: Homebrew Not Working
```bash
# Install Homebrew if missing
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update Homebrew
brew update
brew doctor
```

### Windows (WSL2) Issues

#### Problem: WSL2 Not Working Properly
```bash
# Update WSL2
wsl --update

# Check WSL version
wsl --list --verbose

# Ensure using WSL2
wsl --set-version Ubuntu 2
```

#### Problem: File Permissions in WSL2
```bash
# Fix Windows-Linux file permission issues
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000,umask=22,fmask=111
```

## 🔍 Debugging Commands

### System Diagnostics
```bash
# Check overall system health
./scripts/debug-assistant.sh test

# Verify all components
./scripts/setup-reminders.sh status
./scripts/debug-assistant.sh status

# Check data integrity
for file in ~/.hep-data/*.json; do
    echo "Checking $file:"
    cat "$file" | jq . > /dev/null && echo "✅ Valid JSON" || echo "❌ Invalid JSON"
done
```

### Verbose Execution
```bash
# Run commands with debug output
bash -x ./high-efficiency-programmer.sh start
bash -x ./scripts/focus-mode.sh focus 5
bash -x ./scripts/time-tracker.sh start "test"
```

### Log Analysis
```bash
# Check system logs for errors (Linux)
sudo tail -f /var/log/syslog | grep -i error

# Check application logs
ls -la ~/.hep-data/
tail -f ~/.hep-data/*.log 2>/dev/null
```

## 📊 Performance Issues

### Problem: Slow Performance
**Symptoms:**
- Scripts take a long time to run
- Dashboard generation is slow
- System feels sluggish

**Solutions:**
```bash
# Check available memory
free -h

# Check disk space
df -h

# Clean up large data files
find ~/.hep-data -name "*.json" -exec du -h {} \; | sort -rh

# Reduce data retention if needed
# Edit scripts to limit historical data
```

### Problem: High CPU Usage
**Solutions:**
```bash
# Check running processes
top | grep bash

# Kill hanging processes if needed
pkill -f "high-efficiency-programmer"

# Restart with clean state
./high-efficiency-programmer.sh help
```

## 🔒 Security Issues

### Problem: Permission Errors
```bash
# Fix data directory permissions
chmod -R 755 ~/.hep-data
chown -R $(whoami):$(whoami) ~/.hep-data

# Fix script permissions
chmod +x scripts/*.sh
chmod +x high-efficiency-programmer.sh
```

### Problem: Git Credential Issues
```bash
# Check Git credential configuration
git config --list | grep credential

# Set up credential helper
git config --global credential.helper store
# or for better security:
git config --global credential.helper cache --timeout=3600
```

## 📞 Получение дополнительной помощи

### Ресурсы для самопомощи
1. **Проверьте логи:** Посмотрите в `~/.hep-data/` на любые лог-файлы
2. **Запустите диагностику:** Используйте `./scripts/debug-assistant.sh test`
3. **Проверьте настройку:** Запустите `./scripts/setup-reminders.sh status`
4. **Тестируйте компоненты:** Попробуйте отдельные скрипты для изоляции проблем

### Документация
- [Руководство по установке](installation.md) - Настройка и требования
- [Руководство по ежедневному использованию](daily-usage.md) - Как использовать функции
- [README.md](../README.md) - Обзор проекта

### Поддержка сообщества
- **GitHub Issues**: Сообщайте об ошибках и запрашивайте новые функции
- **Обсуждения**: Задавайте вопросы и делитесь советами
- **Wiki**: Советы по устранению неполадок от сообщества

### Создание отчета об ошибке

При сообщении о проблемах включите:

```bash
# Информация о системе
uname -a
echo $SHELL
git --version
jq --version

# Статус системы HEP
./scripts/setup-reminders.sh status
ls -la ~/.hep-data/

# Шаги воспроизведения ошибки
# Укажите точные команды, которые вызывают проблему
# Включите полный вывод ошибки
```

### Команды восстановления

Если ничего не помогает, попробуйте полное сбрасывание:

```bash
# Создайте резервную копию вашей конфигурации
cp -r config/ config-backup/
cp -r ~/.hep-data ~/.hep-data-backup

# Полное сбрасывание
rm -rf ~/.hep-data/
./scripts/setup-reminders.sh init

# Восстановление конфигурации при необходимости
cp -r config-backup/* config/
```

---

*Помните: Большинство проблем можно решить, убедившись, что все зависимости установлены, а скрипты имеют правильные разрешения на выполнение. В случае сомнений начинайте с базовых исправлений и постепенно переходите к более сложным решениям.*
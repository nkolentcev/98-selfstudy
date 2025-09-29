# Руководство по установке - Система Высокоэффективного Программиста

## 🚀 Быстрый старт

Система Высокоэффективного Программиста спроектирована как автономная и легкая в установке. Следуйте этим шагам для быстрого запуска.

## 📋 Предварительные требования

### Необходимые инструменты
- **Bash** (4.0 или выше) - Для запуска системных скриптов
- **Git** (2.0 или выше) - Для интеграции с системой контроля версий
- **curl** - Для веб-запросов и API вызов
- **jq** - Для обработки JSON (используется метриками и отслеживанием)

### Рекомендуемые инструменты
- **Node.js** (14+ или LTS) - Для анализа JavaScript проектов
- **Python 3** (3.7+) - Для анализа Python проектов
- **Visual Studio Code** - Основной поддерживаемый редактор
- **Docker** - Для контейнеризованных рабочих процессов разработки

### Поддержка платформ
- ✅ **Linux** (Ubuntu, Debian, CentOS, Arch и т.д.)
- ✅ **macOS** (10.14+)
- ✅ **Windows** (рекомендуется WSL2)
- ⚠️ **Windows без WSL** (Ограниченная поддержка, некоторые функции могут не работать)

## 📥 Методы установки

### Метод 1: Клонирование через Git (рекомендуется)

1. **Клонируйте репозиторий:**
   ```bash
   git clone https://github.com/yourusername/high-efficiency-programmer-system.git
   cd high-efficiency-programmer-system
   ```

2. **Сделайте основной скрипт исполняемым:**
   ```bash
   chmod +x high-efficiency-programmer.sh
   chmod +x scripts/*.sh
   ```

3. **Запустите интерактивную настройку:**
   ```bash
   ./scripts/setup-reminders.sh init
   ```

4. **Запустите систему:**
   ```bash
   ./high-efficiency-programmer.sh start
   ```

### Метод 2: Скачивание ZIP-архива

1. **Скачайте последний релиз:**
   - Перейдите на [страницу релизов](https://github.com/yourusername/high-efficiency-programmer-system/releases)
   - Скачайте последний ZIP-файл
   - Распакуйте в желаемое место

2. **Сделайте скрипты исполняемыми:**
   ```bash
   cd high-efficiency-programmer-system
   chmod +x high-efficiency-programmer.sh
   chmod +x scripts/*.sh
   ```

3. **Продолжите настройку:**
   ```bash
   ./scripts/setup-reminders.sh init
   ```

### Метод 3: Менеджеры пакетов

#### Homebrew (macOS/Linux)
```bash
# Скоро будет доступно
brew install high-efficiency-programmer
```

#### npm (Кросс-платформенный)
```bash
# Скоро будет доступно
npm install -g high-efficiency-programmer
```

## 🔧 Подробные шаги установки

### Шаг 1: Проверка системных требований

Запустите проверку требований для убеждения, что ваша система имеет все необходимые инструменты:

```bash
./scripts/setup-reminders.sh tools
```

Если какие-либо необходимые инструменты отсутствуют, установите их:

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install git curl jq nodejs npm python3 python3-pip
```

#### CentOS/RHEL/Fedora:
```bash
sudo yum install git curl jq nodejs npm python3 python3-pip
# или для новых версий:
sudo dnf install git curl jq nodejs npm python3 python3-pip
```

#### macOS (с Homebrew):
```bash
brew install git curl jq node python3
```

#### Arch Linux:
```bash
sudo pacman -S git curl jq nodejs npm python python-pip
```

### Шаг 2: Конфигурация Git

Система интегрируется с Git для отслеживания продуктивности. Настройте Git, если это еще не сделано:

```bash
git config --global user.name "Ваше Имя"
git config --global user.email "your.email@example.com"
```

### Шаг 3: Интерактивная настройка

Запустите комплексный процесс настройки:

```bash
./scripts/setup-reminders.sh init
```

Это проведет вас через:
- ✅ Проверка инструментов
- ⚙️ Конфигурация Git
- 👤 Создание профиля разработчика
- 🔗 Интеграция с оболочкой (псевдонимы)
- 📁 Настройка структуры каталогов

### Шаг 4: Проверка установки

Проверьте установку, запустив:

```bash
./high-efficiency-programmer.sh help
```

Вы должны увидеть основное меню справки со всеми доступными командами.

## 📁 Структура каталогов

После установки структура ваших каталогов будет выглядеть так:

```
high-efficiency-programmer-system/
├── high-efficiency-programmer.sh    # Основная точка входа
├── scripts/                         # Все системные скрипты
│   ├── ai-helper.sh
│   ├── auto-improvements.sh
│   ├── auto-review.sh
│   ├── create-dashboard.sh
│   ├── debug-assistant.sh
│   ├── evening-retrospective.sh
│   ├── focus-mode.sh
│   ├── morning-routine.sh
│   ├── personal-ai-assistant.sh
│   ├── productivity-metrics.sh
│   ├── project-setup.sh
│   ├── setup-reminders.sh
│   ├── tdd-ai-cycle.sh
│   └── time-tracker.sh
├── config/                          # Конфигурационные файлы
│   └── developer-profile.md
├── planning/                        # Шаблоны планирования
│   ├── daily-template.md
│   └── weeks-2-4-plan.md
├── dashboard/                       # Файлы дашборда
│   └── index.html
├── docs/                           # Документация
│   ├── installation.md (этот файл)
│   ├── daily-usage.md
│   └── troubleshooting.md
└── README.md                       # Обзор проекта
```

## 🔧 Опции конфигурации

### Интеграция с оболочкой

Процесс настройки добавит псевдонимы в конфигурацию вашей оболочки:

```bash
# Добавлено в ~/.bashrc или ~/.zshrc
alias hep='./high-efficiency-programmer.sh'
alias hep-start='./high-efficiency-programmer.sh start'
alias hep-focus='./high-efficiency-programmer.sh focus'
alias hep-ai='./high-efficiency-programmer.sh ai'
```

### Интеграция с PATH (опционально)

Чтобы использовать систему из любого места, добавьте ее в ваш PATH:

```bash
# Добавьте в ~/.bashrc или ~/.zshrc
export PATH="$PATH:/path/to/high-efficiency-programmer-system"

# Затем вы можете использовать:
high-efficiency-programmer.sh start
# или
hep start  # если псевдонимы установлены
```

### Хранение данных

Система хранит данные в `~/.hep-data/`:
- `time-tracking.json` - Данные отслеживания времени
- `focus-sessions.json` - История фокус-сессий
- `productivity-metrics.json` - Метрики продуктивности
- `setup-status.json` - Статус завершения настройки

## ✅ Post-Installation Verification

### Basic Functionality Test

Run these commands to verify everything works:

```bash
# Test main script
./high-efficiency-programmer.sh help

# Test morning routine
./high-efficiency-programmer.sh morning --quiet

# Test focus mode (short session)
./high-efficiency-programmer.sh focus 1

# Test AI assistant
./high-efficiency-programmer.sh ai "Hello, test message"

# Test dashboard generation
./scripts/create-dashboard.sh text
```

### Feature Test Checklist

- [ ] Main script executes without errors
- [ ] Morning routine runs successfully
- [ ] Focus mode starts and completes
- [ ] Time tracking functions work
- [ ] Dashboard generates properly
- [ ] Git integration detects repositories
- [ ] AI assistant responds to queries

## 🔄 Upgrading

### From Git Repository

```bash
cd high-efficiency-programmer-system
git pull origin main
chmod +x scripts/*.sh  # Ensure permissions are preserved
./scripts/setup-reminders.sh status  # Check if re-setup is needed
```

### Manual Upgrade

1. Download the new version
2. Back up your configuration: `cp -r config/ config-backup/`
3. Replace system files (keep config/ and data/)
4. Run setup check: `./scripts/setup-reminders.sh status`

## 🗑️ Uninstallation

If you need to remove the system:

```bash
# Remove data directory (optional, contains your tracking data)
rm -rf ~/.hep-data/

# Remove shell aliases (edit ~/.bashrc or ~/.zshrc manually)
# Remove the line: # High-Efficiency Programmer System aliases

# Remove the main directory
rm -rf /path/to/high-efficiency-programmer-system
```

## 🐛 Installation Troubleshooting

### Common Issues

#### "Permission denied" errors
```bash
chmod +x high-efficiency-programmer.sh
chmod +x scripts/*.sh
```

#### "jq: command not found"
Install jq using your package manager:
- Ubuntu/Debian: `sudo apt install jq`
- macOS: `brew install jq`
- CentOS: `sudo yum install jq`

#### Git not configured
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

#### "No such file or directory" for scripts
Ensure you're in the correct directory:
```bash
cd high-efficiency-programmer-system
ls -la scripts/  # Should show all .sh files
```

### Platform-Specific Issues

#### Windows WSL2
- Ensure WSL2 is properly installed
- Use Ubuntu or Debian distribution in WSL2
- Install Linux versions of required tools

#### macOS
- Install Xcode Command Line Tools: `xcode-select --install`
- Use Homebrew for package management
- Some tools may require different installation methods

#### Linux
- Ensure you have sudo access for package installation
- Some distributions may have different package names
- Check your shell (bash/zsh) configuration

### Получение помощи

Если вы столкнулись с проблемами, не освещенными здесь:

1. Проверьте [руководство по устранению неполадок](troubleshooting.md)
2. Просмотрите [руководство по ежедневному использованию](daily-usage.md)
3. Откройте вопрос в репозитории GitHub
4. Присоединяйтесь к обсуждениям сообщества

## 🎯 Следующие шаги

После успешной установки:

1. **Прочитайте [руководство по ежедневному использованию](daily-usage.md)**
2. **Заполните свой профиль разработчика** в `config/developer-profile.md`
3. **Запустите свою первую утреннюю рутину:** `./high-efficiency-programmer.sh start`
4. **Попробуйте фокус-сессию:** `./high-efficiency-programmer.sh focus`
5. **Исследуйте ИИ-ассистента:** `./high-efficiency-programmer.sh ai`

Добро пожаловать в ваше высокоэффективное путешествие по программированию! 🚀
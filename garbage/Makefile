.DEFAULT_GOAL := help

.PHONY: help review-plan review-code _go-checks _rust-checks

help:
	@echo "Available targets:"
	@echo "  make review-plan  - вывести промпт для ревью плана (Claude Code)"
	@echo "  make review-code  - вывести промпт для код-ревью (Claude Code) и запустить легкие локальные проверки"

# Выводит промпт для ревью учебного плана неделя 1
review-plan:
	@echo "=========== CLAUDE CODE PROMPT: PLAN REVIEW ==========="
	@echo "Контекст: у меня Ubuntu 24.04 и чистый VS Code. Проведи рецензию файла week1_detailed_plan.md в корне репозитория."
	@echo "Проверь:"
	@echo "- актуальность инструкций по установке Docker, Go, Rust, VS Code для Ubuntu 24.04"
	@echo "- post-install проверки (docker без sudo, ssh -T git@github.com, code --version)"
	@echo "- полноту .gitignore и настройки Git"
	@echo "- чек-лист готовности среды и этапы Дня 1"
	@echo "- реалистичность таймбоксов и буферов"
	@echo "Выведи: краткое summary, список рисков/узких мест, конкретные улучшения и приоритеты."
	@echo "Формат ответа: кратко и по делу, списками."
	@echo "======================================================="

# Выводит промпт для код-ревью и запускает безопасные локальные проверки форматирования
review-code: _go-checks _rust-checks
	@echo "=========== CLAUDE CODE PROMPT: CODE REVIEW ==========="
	@echo "Проведи код-ревью текущего репозитория. Цели: читаемость, структура, минимальные best practices."
	@echo "Если проекты отсутствуют — укажи, что нужно добавить минимальные примеры (Go/Rust) и тесты."
	@echo "Сфокусируйся на: структуре каталогов, README, .gitignore, тестах, Dockerfile, docker-compose, make-целях."
	@echo "Выведи actionable список задач (приоритет, оценка времени)."
	@echo "======================================================="

# Безопасные локальные проверки для Go (только форматирование, без сети)
_go-checks:
	@command -v go >/dev/null 2>&1 || { echo "Go не установлен — пропускаю Go проверки"; exit 0; }
	@echo "[Go] Проверка форматирования (*.go)"
	@files=$$(find . -type f -name '*.go'); \
	if [ -n "$$files" ]; then \
		echo "Файлы Go найдены. gofmt -l:"; \
		gofmt -l $$files || true; \
	else \
		echo "Файлы Go не найдены — пропускаю"; \
	fi

# Безопасные локальные проверки для Rust (только формат, без сборки)
_rust-checks:
	@command -v cargo >/dev/null 2>&1 || { echo "Rust/Cargo не установлен — пропускаю Rust проверки"; exit 0; }
	@echo "[Rust] Проверка форматирования (cargo fmt --check, если доступен rustfmt)"
	@rustup component list 2>/dev/null | grep -q 'rustfmt.*(installed)' && cargo fmt --all -- --check || echo "rustfmt не установлен — пропускаю cargo fmt проверку"

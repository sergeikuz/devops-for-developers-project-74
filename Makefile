# устанавливаем зависимости
install-dependensies:
	docker run -it -w /root -v `pwd`/app:/root node:20.12.2 make setup

# запускаем проект
start-project:
	docker run -it -w /root -v `pwd`/app:/root -p 8080:8080 node:20.12.2 make dev

# Запуск тестов через Docker Compose
test:
	docker-compose -f docker-compose.yml up --abort-on-container-exit --exit-code-from app
# Запуск dev-режима
dev:
	docker-compose up
# Установка зависимостей
setup:
	docker-compose run --rm app make setup

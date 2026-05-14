# устанавливаем зависимости
install-dependensies:
	docker run -it -w /root -v `pwd`/app:/root node:20.12.2 make setup

# запускаем проект
start-project:
	docker run -it -w /root -v `pwd`/app:/root -p 8080:8080 node:20.12.2 make dev

# CI: запуск тестов через Docker Compose
ci:
	docker-compose -f docker-compose.yml up --abort-on-container-exit --exit-code-from app

# Запуск тестов через Docker Compose (production образ)
test:
	docker-compose -f docker-compose.yml up --abort-on-container-exit --exit-code-from app

# Запуск dev-режима (локальный Dockerfile + volume)
dev:
	docker-compose up

# Установка зависимостей
setup:
	docker-compose run --rm app make setup

# Сборка production образа
build:
	docker-compose -f docker-compose.yml build app

# Push production образа на Docker Hub
push:
	docker-compose -f docker-compose.yml push app

# Логин в Docker Hub
login:
	docker login

### Hexlet tests and linter status:
[![Actions Status](https://github.com/sergeikuz/devops-for-developers-project-74/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/sergeikuz/devops-for-developers-project-74/actions)

# DevOps for Developers

Проект для изучения Docker и Docker Compose на примере приложения [JS Fastify Blog](https://github.com/hexlet-components/js-fastify-blog) — блога на Node.js + Fastify.

## Требования

- Docker
- Docker Compose (версия не ниже 1.27.0)
- Make

## Быстрый старт

### 1. Клонирование приложения

```bash
git clone git@github.com:hexlet-components/js-fastify-blog.git app
rm -rf app/.git
```

### 2. Установка зависимостей

```bash
make setup
```

### 3. Запуск

```bash
# Режим разработки
make dev

# Запуск тестов
make test
```

## Доступные команды

| Команда | Описание |
|---|---|
| `make setup` | Установка зависимостей (`npm install` + миграции БД) |
| `make dev` | Запуск dev-сервера с hot-reload на `http://127.0.0.1:8080` |
| `make test` | Запуск тестов через Docker Compose |

## Структура проекта

| Файл | Назначение |
|---|---|
| `Dockerfile` | Базовый образ: Node.js 20.12.2, рабочая директория `/app` |
| `docker-compose.yml` | Основная конфигурация — запуск тестов (production-режим) |
| `docker-compose.override.yml` | Override для локальной разработки — проброс порта 8080, команда `make dev` |
| `.dockerignore` | Исключение `node_modules/`, `dist/`, `.env`, `*.sqlite` из Docker-контекста |
| `Makefile` | Удобные команды для работы с Docker Compose |

## Как это работает

Проект использует **схему с двумя Docker Compose файлами**:

### Тестовый режим (`docker-compose.yml`)

Основной файл описывает сервис `app`, который при запуске выполняет `make test`. Используется для CI/CD и проверки перед деплоем.

```bash
# Запуск ТОЛЬКО тестов (без override)
docker-compose -f docker-compose.yml up --abort-on-container-exit --exit-code-from app
```

### Режим разработки (`docker-compose.yml` + `docker-compose.override.yml`)

Docker Compose автоматически подхватывает `docker-compose.override.yml` и объединяет его с основным файлом. Override добавляет:
- Проброс порта `8080:8080` — приложение доступно в браузере
- Переопределение команды на `make dev` — dev-сервер с hot-reload

```bash
# Запуск dev-режима (оба файла)
docker-compose up
```

### Схема работы

```
Хост-машина (ваш код в app/)
         ↑
         │ volume (проброс ./app:/app)
         ↓
  ┌──────────────────┐
  │  Docker контейнер │
  │  node:20.12.2     │
  │  make test / dev  │
  └──────────────────┘
         ↑
         │ port 8080:8080 (только в dev)
         ↓
  http://127.0.0.1:8080
```

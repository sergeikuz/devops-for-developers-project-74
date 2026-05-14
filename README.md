### Hexlet tests and linter status:
[![Actions Status](https://github.com/sergeikuz/devops-for-developers-project-74/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/sergeikuz/devops-for-developers-project-74/actions)

### CI Status:
[![CI](https://github.com/sergeikuz/devops-for-developers-project-74/actions/workflows/push.yml/badge.svg)](https://github.com/sergeikuz/devops-for-developers-project-74/actions/workflows/push.yml)

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
| `make test` | Запуск тестов через Docker Compose (production образ) |
| `make build` | Сборка production образа из `Dockerfile.production` |
| `make push` | Push production образа на Docker Hub |
| `make login` | Авторизация в Docker Hub |

## Структура проекта

| Файл | Назначение |
|---|---|
| `Dockerfile` | Минимальный образ для локальной разработки (только `FROM` + `WORKDIR`) |
| `Dockerfile.production` | Полный образ для тестов и продакшена (зависимости + код встроены) |
| `docker-compose.yml` | Основная конфигурация — тесты, использует `Dockerfile.production`, образ на Docker Hub |
| `docker-compose.override.yml` | Override для разработки — использует `Dockerfile`, проброс порта и volume |
| `.dockerignore` | Исключение `node_modules/`, `dist/`, `.env`, `*.sqlite` из Docker-контекста |
| `Makefile` | Удобные команды для работы с Docker Compose |

## Как это работает

Проект использует **схему с двумя Docker Compose файлами** и **двумя Dockerfile**:

### Тестовый режим (`docker-compose.yml`)

Основной файл описывает сервис `app`, который:
- Собирается из `Dockerfile.production` (полная установка зависимостей + код в образе)
- Имеет тег `sergei3333/devops-for-developers-project-74` для Docker Hub
- При запуске выполняет `make test`

```bash
# Запуск ТОЛЬКО тестов (без override)
docker-compose -f docker-compose.yml up --abort-on-container-exit --exit-code-from app
```

### Режим разработки (`docker-compose.yml` + `docker-compose.override.yml`)

Docker Compose автоматически подхватывает `docker-compose.override.yml` и объединяет его с основным файлом. Override переопределяет:
- `Dockerfile` вместо `Dockerfile.production` — минимальный образ
- `volumes: ./app:/app` — код пробрасывается с хоста для быстрой итерации
- `ports: 8080:8080` — приложение доступно в браузере
- `command: make dev` — dev-сервер с hot-reload

```bash
# Запуск dev-режима (оба файла)
docker-compose up
```

### Docker Hub

Production образ собирается и загружается на Docker Hub:

```bash
# Сборка
make build

# Push на Docker Hub
make push

# Проверка — запуск образа с Docker Hub
docker run -p 8080:8080 -e NODE_ENV=development sergei3333/devops-for-developers-project-74 make dev
```

### Схема работы

```
                  ┌─────────────────────────────────┐
                  │        Хост-машина              │
                  │                                 │
  app/  ← ваш код (редактируете в IDE)              │
       ↑                                             │
       │ volume (ТОЛЬКО в dev-режиме)               │
       ↓                                             │
  ┌────────────────────────────────────────┐        │
  │          Docker контейнер               │        │
  │                                         │        │
  │  /app  ← код (из volume или из образа)  │        │
  │  node:20.12.2 ← Node.js внутри          │        │
  │  make test  или  make dev               │        │
  └────────────────────────────────────────┘        │
                    ↑                               │
                    │ port 8080:8080 (только в dev) │
                    ↓                               │
           http://127.0.0.1:8080 ← браузер          │
                  └─────────────────────────────────┘

  Режимы:
  ┌──────────┬──────────────────────┬───────────────┐
  │ Режим    │ Dockerfile           │ Volumes       │
  ├──────────┼──────────────────────┼───────────────┤
  │ Тесты    │ Dockerfile.production│ нет           │
  │ Dev      │ Dockerfile           │ ./app:/app    │
  └──────────┴──────────────────────┴───────────────┘
```

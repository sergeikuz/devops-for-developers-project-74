# устанавливаем зависимости
install-dependensies:
	docker run -it -w /root -v `pwd`/app:/root node:20.12.2 make setup

# запускаем проект
start-project:
	docker run -it -w /root -v `pwd`/app:/root -p 8080:8080 node:20.12.2 make dev

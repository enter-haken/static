.PHONY: default loc clean install uninstall up down exec

default: clean install 

install:
	mix do escript.build --force, escript.install --force

uninstall:
	mix escript.uninstall static

loc:
	for code in $$(find ./lib -type f); do cat $$code; done | grep "\S" | wc -l

clean:
	rm static || true

up:
	docker-compose up --build -d

down:
	docker-compose down

exec:
	docker exec -it static /bin/bash

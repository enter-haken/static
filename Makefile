.PHONY: default loc clean install uninstall

default: clean install 

install:
	mix do escript.build --force, escript.install --force

uninstall:
	mix escript.uninstall static

loc:
	for code in $$(find ./lib -type f); do cat $$code; done | grep "\S" | wc -l

clean:
	rm static || true

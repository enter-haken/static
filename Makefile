.PHONY: build default loc serve all copy

default: all 

all: clean build 

install:
	mix do escript.build, escript.install --force

uninstall:
	mix escript.uninstall static

build:
	mix static.generate --content-path /tmp/content --output-path /tmp/output --static-path /tmp/static

serve:
	python -m http.server --directory /tmp/output

loc:
	for code in $$(find ./lib -type f); do cat $$code; done | grep "\S" | wc -l

copy:
	cp -r ~/src/enter-haken/book/priv/content/ /tmp
	cp -r ~/src/enter-haken/book/priv/static/ /tmp

clean:
	rm -rf /tmp/output/ || true
	rm static || true

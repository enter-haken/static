.PHONY: build default loc

default: build

build:
	mix static.generate --content-path /tmp/content --output-path xxx

loc:
	for code in $$(find ./lib -type f); do cat $$code; done | grep "\S" | wc -l

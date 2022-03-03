.PHONY: build default loc serve all

default: all 

all: build serve

build:
	mix static.generate --content-path /tmp/content --output-path /tmp/output

serve:
	python -m http.server --directory /tmp/output

loc:
	for code in $$(find ./lib -type f); do cat $$code; done | grep "\S" | wc -l

.PHONY: build default

default: build


build:
	mix static.generate --content-path /tmp/content --output-path xxx

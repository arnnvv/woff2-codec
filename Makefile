ENGINE ?= docker
IMAGE ?= woff2-standalone-wasm-builder
CLANG_FORMAT ?= clang-format
SOURCE = src/woff2_wasm.cc

.PHONY: build check-format format

build:
	mkdir -p dist
	$(ENGINE) build -t $(IMAGE) .
	$(ENGINE) run --rm -v "$(CURDIR)/dist:/out" $(IMAGE)

check-format:
	$(CLANG_FORMAT) --dry-run --Werror $(SOURCE)

format:
	$(CLANG_FORMAT) -i $(SOURCE)

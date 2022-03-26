SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
srcdir = Sources

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
SOURCES = $(wildcard $(srcdir)/**/*.swift)

.DEFAULT_GOAL = all

.PHONY: all
all: bartycrouch

bartycrouch: $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"

bartycrouch_universal: $(SOURCES)
	@swift build \
		-c release \
		--arch arm64 --arch x86_64 \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"

.PHONY: install
install: bartycrouch
	@install -d "$(bindir)" "$(libdir)"
	@install "$(BUILDDIR)/release/bartycrouch" "$(bindir)"

.PHONY: portable_zip
portable_zip: bartycrouch_universal
	rm -f "$(BUILDDIR)/Apple/Products/Release/portable_bartycrouch.zip"
	zip -j "$(BUILDDIR)/Apple/Products/Release/portable_bartycrouch.zip" "$(BUILDDIR)/Apple/Products/Release/bartycrouch" "$(REPODIR)/LICENSE"
	echo "Portable ZIP created at: $(BUILDDIR)/Apple/Products/Release/portable_bartycrouch.zip"

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/bartycrouch"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release

.PHONY: clean
clean: distclean
	@rm -rf $(BUILDDIR)

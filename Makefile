SHELL = /bin/bash

prefix ?= /opt/homebrew
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
		--scratch-path "$(BUILDDIR)"

bartycrouch_universal: $(SOURCES)
	@swift build \
		-c release \
		--arch arm64 --arch x86_64 \
		--disable-sandbox \
		--scratch-path "$(BUILDDIR)"

.PHONY: install
install: bartycrouch
	@install -d "$(bindir)" "$(libdir)"
	@install "$(BUILDDIR)/release/bartycrouch" "$(bindir)"

.PHONY: portable_zip
portable_zip: bartycrouch_universal
	@rm -f "$(BUILDDIR)/Apple/Products/Release/portable_bartycrouch.zip"
	
	$(eval TMP := $(shell mktemp -d))
	@cp "$(BUILDDIR)/Apple/Products/Release/bartycrouch" "$(TMP)/bartycrouch"
	@install_name_tool -add_rpath "@executable_path/." "$(TMP)/bartycrouch"
	
	@zip -q -j "$(BUILDDIR)/Apple/Products/Release/portable_bartycrouch.zip" \
		"$(TMP)/bartycrouch" \
		"$(REPODIR)/LICENSE" \
	@echo "Portable ZIP created at: $(BUILDDIR)/Apple/Products/Release/portable_bartycrouch.zip"
	@rm -rf $(TMP)

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/bartycrouch"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release

.PHONY: clean
clean: distclean
	@rm -rf $(BUILDDIR)

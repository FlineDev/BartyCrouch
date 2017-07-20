TEMPORARY_FOLDER?=/tmp/BartyCrouch.dst
BUILD_TOOL?=xcodebuild

XCODEFLAGS=-project 'BartyCrouch.xcodeproj' \
	-scheme 'BartyCrouch CLI' \
	-configuration 'Release' \
	DSTROOT=$(TEMPORARY_FOLDER) \
	OTHER_LDFLAGS=-Wl,-headerpad_max_install_names

BINARIES_FOLDER=/usr/local/bin
LICENSE_PATH="$(shell pwd)/LICENSE.md"

clean:
	rm -rf "$(TEMPORARY_FOLDER)"
	$(BUILD_TOOL) $(XCODEFLAGS) clean

installables: clean
	$(BUILD_TOOL) $(XCODEFLAGS) install

portable_zip: installables
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/bartycrouch" "$(TEMPORARY_FOLDER)"
	rm -f "./portable_bartycrouch.zip"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_FOLDER)"
	(cd "$(TEMPORARY_FOLDER)"; zip -yr - "bartycrouch" "LICENSE.md") > "./portable_bartycrouch.zip"

#!/bin/bash
set -ev
SWIFT_SNAPSHOT="swift-3.0-PREVIEW-6"
XCTEST_SNAPSHOT="swift-3.0-PREVIEW-6"

echo "Installing ${SWIFT_SNAPSHOT}..."
if [ ! -f "${SWIFT_SNAPSHOT}-ubuntu14.04.tar.gz" ]; then
  curl -s -L -O "https://swift.org/builds/$(echo $SWIFT_SNAPSHOT | tr A-Z a-z)/ubuntu1404/${SWIFT_SNAPSHOT}/${SWIFT_SNAPSHOT}-ubuntu14.04.tar.gz"
fi

tar -zxf "${SWIFT_SNAPSHOT}-ubuntu14.04.tar.gz"
sudo rm -rf /swift
sudo mv "${SWIFT_SNAPSHOT}-ubuntu14.04" /swift

# Force the use of the gold linker
# See https://bugs.swift.org/browse/SR-1023 and https://github.com/apple/swift/pull/2609
sudo rm /usr/bin/ld
sudo ln -s /usr/bin/ld.gold /usr/bin/ld

echo "Installing XCTest..."
if [ ! -f "${XCTEST_SNAPSHOT}.tar.gz" ]; then
  curl -s -L -O "https://github.com/apple/swift-corelibs-xctest/archive/${XCTEST_SNAPSHOT}.tar.gz"
fi
tar -zxvf "${XCTEST_SNAPSHOT}.tar.gz"
cd "swift-corelibs-xctest-${XCTEST_SNAPSHOT}"
sudo ./build_script.py --swiftc="/swift/usr/bin/swiftc" --build-dir="/tmp/XCTest_build" --foundation-build-dir="/swift/usr/lib/swift/linux" --library-install-path="/swift/usr/lib/swift/linux" --module-install-path="/swift/usr/lib/swift/linux/x86_64"
cd ..
rm -rf "swift-corelibs-xctest-${XCTEST_SNAPSHOT}"

#!/bin/bash
set -ev
SWIFT_SNAPSHOT="swift-DEVELOPMENT-SNAPSHOT-2016-02-25-a"
XCTEST_SNAPSHOT="swift-DEVELOPMENT-SNAPSHOT-2016-02-25-a"

echo "Installing ${SWIFT_SNAPSHOT}..."
if [ ! -f "${SWIFT_SNAPSHOT}-ubuntu14.04.tar.gz" ]; then
  curl -s -L -O "https://swift.org/builds/development/ubuntu1404/${SWIFT_SNAPSHOT}/${SWIFT_SNAPSHOT}-ubuntu14.04.tar.gz"
fi

tar -zxvf "${SWIFT_SNAPSHOT}-ubuntu14.04.tar.gz"
sudo rm -rf /swift
sudo mv "${SWIFT_SNAPSHOT}-ubuntu14.04" /swift

echo "Installing XCTest..."
if [ ! -f "${XCTEST_SNAPSHOT}.tar.gz" ]; then
  curl -s -L -O "https://github.com/apple/swift-corelibs-xctest/archive/${XCTEST_SNAPSHOT}.tar.gz"
fi
tar -zxvf "${XCTEST_SNAPSHOT}.tar.gz"
cd "swift-corelibs-xctest-${XCTEST_SNAPSHOT}"
sudo ./build_script.py --swiftc="/swift/usr/bin/swiftc" --build-dir="/tmp/XCTest_build" --swift-build-dir="/swift/usr" --library-install-path="/swift/usr/lib/swift/linux" --module-install-path="/swift/usr/lib/swift/linux/x86_64" --arch x86_64
cd ..
rm -rf "swift-corelibs-xctest-${XCTEST_SNAPSHOT}"

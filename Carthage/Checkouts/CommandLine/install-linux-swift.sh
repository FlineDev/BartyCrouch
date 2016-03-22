#!/bin/bash
set -ev
SWIFT_SNAPSHOT="swift-2.2-SNAPSHOT-2016-01-06-a"

echo "Installing ${SWIFT_SNAPSHOT}..."
curl -s -L -O "https://swift.org/builds/ubuntu1404/${SWIFT_SNAPSHOT}/${SWIFT_SNAPSHOT}-ubuntu14.04.tar.gz"
tar -zxvf "${SWIFT_SNAPSHOT}-ubuntu14.04.tar.gz"
sudo mv "${SWIFT_SNAPSHOT}-ubuntu14.04" /swift

echo "Installing XCTest..."
curl -s -L -O "https://github.com/apple/swift-corelibs-xctest/archive/${SWIFT_SNAPSHOT}.tar.gz"
tar -zxvf "${SWIFT_SNAPSHOT}.tar.gz"
cd "swift-corelibs-xctest-${SWIFT_SNAPSHOT}"
./build_script.py --swiftc="/swift/usr/bin/swiftc" --build-dir="/tmp/XCTest_build" --swift-build-dir="/swift/usr" --library-install-path="/swift/usr/lib/swift/linux" --module-install-path="/swift/usr/lib/swift/linux/x86_64"
cd ..
rm -rf "swift-corelibs-xctest-${SWIFT_SNAPSHOT}"

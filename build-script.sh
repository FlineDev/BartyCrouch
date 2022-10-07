#!/bin/bash
set -euxo pipefail

# turned off due to Swift 5.7 update issue
#swift-format --recursive Sources Tests Package.swift --in-place

swiftlint --strict

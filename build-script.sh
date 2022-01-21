#!/bin/bash
set -euxo pipefail

swift-format --recursive Sources Tests Package.swift --in-place

swiftlint --strict

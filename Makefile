GIT_VERSION := $(shell git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD)

run:
	flutter run --dart-define=GIT_VERSION=$(GIT_VERSION)

build:
	flutter build apk --dart-define=GIT_VERSION=$(GIT_VERSION)

install:
	adb install -r build/app/outputs/flutter-apk/app-release.apk

.PHONY: run build

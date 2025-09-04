# PlantWise Flutter App Makefile
# Cross-platform build automation for development tasks

# Variables
APP_NAME = plantwise
BUILD_DIR = build
COVERAGE_DIR = coverage

# Default target
.DEFAULT_GOAL := help

# Detect OS
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    RM := powershell -Command "Remove-Item -Recurse -Force"
    MKDIR := powershell -Command "New-Item -ItemType Directory -Force"
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        DETECTED_OS := Linux
    endif
    ifeq ($(UNAME_S),Darwin)
        DETECTED_OS := macOS
    endif
    RM := rm -rf
    MKDIR := mkdir -p
endif

##@ Help
help: ## Display this help
	@echo "PlantWise Flutter Build System"
	@echo "=============================="
	@echo "Detected OS: $(DETECTED_OS)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development
clean: ## Clean all build artifacts and generated files
	@echo "🧹 Cleaning project..."
	flutter clean
	@echo "🗑️  Removing generated files..."
	@find . -name "*.g.dart" -delete 2>/dev/null || true
	@find . -name "*.freezed.dart" -delete 2>/dev/null || true
	@echo "✅ Project cleaned"

deps: ## Get Flutter dependencies
	@echo "📦 Getting dependencies..."
	flutter pub get
	@echo "✅ Dependencies installed"

generate: deps ## Run code generation
	@echo "🔧 Running code generation..."
	flutter packages pub run build_runner build --delete-conflicting-outputs
	@echo "✅ Code generation completed"

##@ Quality Assurance
format: ## Format Dart code
	@echo "🎨 Formatting code..."
	dart format .
	@echo "✅ Code formatted"

analyze: ## Run static analysis
	@echo "🔍 Analyzing code..."
	flutter analyze
	@echo "✅ Analysis completed"

lint: format analyze ## Run formatting and analysis

test: ## Run all tests
	@echo "🧪 Running tests..."
	flutter test --coverage
	@echo "✅ Tests completed"

test-unit: ## Run unit tests only
	@echo "🧪 Running unit tests..."
	flutter test test/ --coverage
	@echo "✅ Unit tests completed"

##@ Building
build-debug-android: generate ## Build Android APK (debug)
	@echo "🤖 Building Android APK (debug)..."
	flutter build apk --debug
	@echo "✅ Android debug APK built: $(BUILD_DIR)/app/outputs/flutter-apk/app-debug.apk"

build-android: generate ## Build Android APK (release)
	@echo "🤖 Building Android APK (release)..."
	flutter build apk --release
	@echo "✅ Android APK built: $(BUILD_DIR)/app/outputs/flutter-apk/app-release.apk"

build-android-bundle: generate ## Build Android App Bundle
	@echo "🤖 Building Android App Bundle..."
	flutter build appbundle --release
	@echo "✅ Android App Bundle built: $(BUILD_DIR)/app/outputs/bundle/release/app-release.aab"

build-ios: generate ## Build iOS app (macOS only)
ifeq ($(DETECTED_OS),macOS)
	@echo "🍎 Building iOS app..."
	flutter build ios --release
	@echo "✅ iOS app built"
else
	@echo "❌ iOS builds are only supported on macOS"
endif

build-web: generate ## Build web app
	@echo "🌐 Building web app..."
	flutter build web --release
	@echo "✅ Web app built: $(BUILD_DIR)/web/"

build-windows: generate ## Build Windows app (Windows only)
ifeq ($(DETECTED_OS),Windows)
	@echo "🪟 Building Windows app..."
	flutter build windows --release
	@echo "✅ Windows app built: $(BUILD_DIR)/windows/x64/runner/Release/"
else
	@echo "❌ Windows builds are only supported on Windows"
endif

build-linux: generate ## Build Linux app (Linux only)
ifeq ($(DETECTED_OS),Linux)
	@echo "🐧 Building Linux app..."
	flutter build linux --release
	@echo "✅ Linux app built: $(BUILD_DIR)/linux/x64/release/bundle/"
else
	@echo "❌ Linux builds are only supported on Linux"
endif

build-macos: generate ## Build macOS app (macOS only)
ifeq ($(DETECTED_OS),macOS)
	@echo "🖥️  Building macOS app..."
	flutter build macos --release
	@echo "✅ macOS app built: $(BUILD_DIR)/macos/Build/Products/Release/"
else
	@echo "❌ macOS builds are only supported on macOS"
endif

##@ Platform-specific builds
build-mobile: ## Build for mobile platforms (Android and iOS if available)
ifeq ($(DETECTED_OS),macOS)
	$(MAKE) build-android build-ios
else
	$(MAKE) build-android
endif

build-desktop: ## Build for desktop platforms based on current OS
ifeq ($(DETECTED_OS),Windows)
	$(MAKE) build-windows
else ifeq ($(DETECTED_OS),macOS)
	$(MAKE) build-macos
else ifeq ($(DETECTED_OS),Linux)
	$(MAKE) build-linux
endif

build-all: ## Build for all supported platforms on current OS
	$(MAKE) build-mobile build-desktop build-web

##@ Development Server
serve: ## Run Flutter app in development mode
	@echo "🚀 Starting development server..."
	flutter run

serve-web: ## Run Flutter web app
	@echo "🌐 Starting web development server..."
	flutter run -d web-server --web-hostname=0.0.0.0 --web-port=3000

##@ Utilities
doctor: ## Run Flutter doctor
	@echo "🩺 Running Flutter doctor..."
	flutter doctor -v

upgrade: ## Upgrade Flutter dependencies
	@echo "⬆️  Upgrading dependencies..."
	flutter pub upgrade --major-versions

outdated: ## Check for outdated dependencies
	@echo "📅 Checking for outdated packages..."
	flutter pub outdated

create-launcher-icons: ## Generate launcher icons
	@echo "🎯 Generating launcher icons..."
	flutter pub get
	flutter pub run flutter_launcher_icons:main

##@ Maintenance
reset: clean deps generate ## Reset project (clean + deps + generate)
	@echo "🔄 Project reset complete"

full-build: clean deps generate lint test build-android build-web ## Complete build pipeline
	@echo "🎉 Full build pipeline completed"

##@ Information
info: ## Show project information
	@echo "Project: PlantWise"
	@echo "Type: Flutter Mobile App"
	@echo "Platforms: Android, iOS, Web, Windows"
	@echo "Current OS: $(DETECTED_OS)"
	@echo "Flutter Version:"
	@flutter --version

# Phony targets
.PHONY: help clean deps generate format analyze lint test test-unit \
        build-debug-android build-android build-android-bundle build-ios build-web \
        build-windows build-linux build-macos build-mobile build-desktop build-all \
        serve serve-web doctor upgrade outdated create-launcher-icons \
        reset full-build info

# 🚀 PlantWise Build System

This document explains how to build and deploy the PlantWise Flutter application using the provided build automation tools.

## 📋 Prerequisites

- **Flutter SDK**: Version 3.24.x or higher
- **Dart SDK**: Included with Flutter
- **Git**: For version control and deployment
- **Platform-specific tools**:
  - **Android**: Android SDK, Java 17+
  - **iOS**: Xcode (macOS only)
  - **Web**: Any modern web browser
  - **Windows**: Visual Studio 2019+ or Visual Studio Build Tools

## 🛠️ Build Tools Overview

The project includes several build automation tools:

| Tool | Platform | Description |
|------|----------|-------------|
| `build.ps1` | Windows | Comprehensive PowerShell build script |
| `Makefile` | Cross-platform | Unix-style build automation |
| `.github/workflows/ci-cd.yml` | GitHub | CI/CD pipeline for automated builds |
| `scripts/dev-setup.ps1` | Windows | Development environment setup |
| `scripts/deploy.ps1` | Windows | Release deployment script |

## 🚀 Quick Start

### Initial Setup
```powershell
# Clone the repository
git clone <repository-url>
cd plantWise

# Run development setup (Windows)
.\scripts\dev-setup.ps1

# OR manually set up dependencies
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Common Build Tasks

#### Using PowerShell Script (Windows)
```powershell
# Show all available tasks
.\build.ps1 -Task help

# Clean project
.\build.ps1 -Task clean

# Run tests
.\build.ps1 -Task test

# Build Android APK
.\build.ps1 -Task build-android

# Build for web
.\build.ps1 -Task build-web

# Run complete build pipeline
.\build.ps1 -Task all
```

#### Using Makefile (Cross-platform)
```bash
# Show all available commands
make help

# Clean project
make clean

# Run tests
make test

# Build Android APK
make build-android

# Build for web
make build-web

# Build for current platform
make build-desktop

# Complete build pipeline
make full-build
```

## 🏗️ Build Commands Reference

### Development Commands

| PowerShell | Makefile | Description |
|------------|----------|-------------|
| `.\build.ps1 -Task clean` | `make clean` | Clean build artifacts |
| `.\build.ps1 -Task deps` | `make deps` | Install dependencies |
| `.\build.ps1 -Task generate` | `make generate` | Run code generation |
| `.\build.ps1 -Task format` | `make format` | Format Dart code |
| `.\build.ps1 -Task analyze` | `make analyze` | Run static analysis |
| `.\build.ps1 -Task test` | `make test` | Run all tests |

### Build Commands

| PowerShell | Makefile | Description |
|------------|----------|-------------|
| `.\build.ps1 -Task build-android` | `make build-android` | Build Android APK (release) |
| `.\build.ps1 -Task build-web` | `make build-web` | Build web application |
| `.\build.ps1 -Task build-windows` | `make build-windows` | Build Windows app |
| `.\build.ps1 -Task build-ios` | `make build-ios` | Build iOS app (macOS only) |

### Configuration Options

The PowerShell script supports different build configurations:

```powershell
# Debug build (with debugging symbols)
.\build.ps1 -Task build-android -Configuration debug

# Profile build (for performance testing)
.\build.ps1 -Task build-android -Configuration profile

# Release build (optimized, default)
.\build.ps1 -Task build-android -Configuration release
```

## 📱 Platform-Specific Builds

### Android
```powershell
# APK for manual installation
.\build.ps1 -Task build-android

# App Bundle for Google Play Store (using CI/CD)
# This requires the CI/CD pipeline or manual Flutter command
flutter build appbundle --release
```

### iOS (macOS only)
```powershell
# iOS build
.\build.ps1 -Task build-ios

# Note: iOS builds require macOS and Xcode
# Code signing is handled separately
```

### Web
```powershell
# Web build
.\build.ps1 -Task build-web

# Serve locally for testing
make serve-web
# or
flutter run -d web-server --web-port=3000
```

### Windows
```powershell
# Windows desktop app
.\build.ps1 -Task build-windows
```

## 🚢 Deployment

### Using the Deployment Script
```powershell
# Deploy version 1.2.3 for all platforms
.\scripts\deploy.ps1 -Version "1.2.3" -Platform "all"

# Deploy for specific platform
.\scripts\deploy.ps1 -Version "1.2.3" -Platform "android"

# Skip tests during deployment
.\scripts\deploy.ps1 -Version "1.2.3" -Platform "all" -SkipTests
```

The deployment script will:
1. Validate the version format
2. Run pre-deployment checks (tests, analysis)
3. Update the version in `pubspec.yaml`
4. Create release notes template
5. Build for the specified platform(s)
6. Create Git tag
7. Generate deployment summary

### Manual Deployment Steps
1. **Update version** in `pubspec.yaml`
2. **Run tests**: `.\build.ps1 -Task test`
3. **Build artifacts**: `.\build.ps1 -Task build-android` (or other platforms)
4. **Create Git tag**: `git tag -a v1.2.3 -m "Release 1.2.3"`
5. **Push tag**: `git push origin v1.2.3`
6. **Upload to stores/hosting**

## 🔄 CI/CD Pipeline

The project includes a GitHub Actions workflow (`.github/workflows/ci-cd.yml`) that automatically:

- **On Pull Requests**: Runs tests, analysis, and security scans
- **On Pushes to main/develop**: Builds and tests all platforms
- **On Tags (v*.*.*)**: Creates release builds and GitHub releases
- **Web Deployment**: Automatically deploys web builds to GitHub Pages

### Triggering Releases
```bash
# Create and push a version tag to trigger release
git tag v1.2.3
git push origin v1.2.3
```

## 📁 Build Artifacts

After building, artifacts are located in:

```
build/
├── app/outputs/flutter-apk/          # Android APKs
├── app/outputs/bundle/release/       # Android App Bundles
├── ios/iphoneos/                     # iOS builds
├── web/                              # Web builds
└── windows/x64/runner/Release/       # Windows builds
```

## 🔧 Configuration Files

### Build Scripts
- `build.ps1` - Main PowerShell build script
- `Makefile` - Cross-platform build automation
- `scripts/dev-setup.ps1` - Development environment setup
- `scripts/deploy.ps1` - Deployment automation

### CI/CD
- `.github/workflows/ci-cd.yml` - GitHub Actions workflow

### Flutter Configuration
- `pubspec.yaml` - Dependencies and app configuration
- `analysis_options.yaml` - Code analysis rules

## 🐛 Troubleshooting

### Common Issues

**Flutter not found**
```powershell
# Ensure Flutter is in PATH
flutter --version
```

**Build failures**
```powershell
# Clean and rebuild
.\build.ps1 -Task clean
.\build.ps1 -Task deps
.\build.ps1 -Task generate
```

**Code generation issues**
```powershell
# Force regenerate all code
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Permission errors (Windows)**
```powershell
# Run PowerShell as Administrator if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Platform-Specific Issues

**Android builds failing**
- Ensure Android SDK is properly configured
- Check Java version (requires Java 17+)
- Verify Android licenses: `flutter doctor --android-licenses`

**iOS builds failing (macOS)**
- Ensure Xcode is installed and up to date
- Check iOS simulator availability
- Verify Apple Developer account setup

**Windows builds failing**
- Install Visual Studio 2019+ with C++ tools
- Ensure Windows SDK is available

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase Documentation](https://firebase.google.com/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🤝 Contributing

When contributing to the build system:

1. Test your changes on multiple platforms if possible
2. Update this documentation for any new build commands
3. Ensure CI/CD pipeline still passes
4. Follow the existing code style and patterns

For more information about the project itself, see the main [README.md](README.md).

#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Development setup script for PlantWise Flutter application
.DESCRIPTION
    Automates the initial setup process for new developers joining the project
.EXAMPLE
    .\scripts\dev-setup.ps1
#>

# Colors for output
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

function Write-Header {
    param([string]$Message)
    Write-Host "${Blue}================================${Reset}"
    Write-Host "${Cyan} $Message ${Reset}"
    Write-Host "${Blue}================================${Reset}"
}

function Write-Success {
    param([string]$Message)
    Write-Host "${Green}✅ $Message${Reset}"
}

function Write-Info {
    param([string]$Message)
    Write-Host "${Yellow}ℹ️  $Message${Reset}"
}

Write-Header "PlantWise Development Setup"

Write-Info "Setting up development environment for PlantWise..."

# Check Flutter installation
Write-Info "Checking Flutter installation..."
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Flutter is installed"
        Write-Host $flutterVersion
    }
} catch {
    Write-Host "${Red}❌ Flutter not found. Please install Flutter from https://flutter.dev${Reset}"
    exit 1
}

# Run Flutter doctor
Write-Info "Running Flutter doctor..."
flutter doctor

# Get dependencies
Write-Info "Installing project dependencies..."
flutter pub get

# Run code generation
Write-Info "Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Create necessary directories
Write-Info "Creating project directories..."
$dirs = @("assets/models", "assets/data", "coverage", "docs")
foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Success "Created directory: $dir"
    }
}

# Setup Git hooks (if git is available)
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Info "Setting up Git hooks..."
    
    $preCommitHook = @"
#!/bin/sh
# Pre-commit hook for PlantWise
echo "Running pre-commit checks..."

# Format code
dart format .

# Run analysis
flutter analyze

# Run tests
flutter test

echo "✅ Pre-commit checks passed"
"@

    $hookDir = ".git/hooks"
    if (Test-Path $hookDir) {
        $preCommitHook | Out-File -FilePath "$hookDir/pre-commit" -Encoding UTF8
        # Make executable on Unix-like systems
        if ($env:OS -ne "Windows_NT") {
            chmod +x "$hookDir/pre-commit"
        }
        Write-Success "Git pre-commit hook installed"
    }
} else {
    Write-Info "Git not found, skipping hook setup"
}

# Display next steps
Write-Header "Setup Complete!"
Write-Host @"
${Green}🎉 Development environment setup completed successfully!${Reset}

${Yellow}Next steps:${Reset}
1. Open your preferred IDE (VS Code, Android Studio, or IntelliJ)
2. Install Flutter and Dart extensions/plugins
3. Run the app: ${Cyan}flutter run${Reset}

${Yellow}Available build commands:${Reset}
• PowerShell: ${Cyan}.\build.ps1 -Task help${Reset}
• Make: ${Cyan}make help${Reset}

${Yellow}Common development tasks:${Reset}
• Clean project: ${Cyan}.\build.ps1 -Task clean${Reset} or ${Cyan}make clean${Reset}
• Run tests: ${Cyan}.\build.ps1 -Task test${Reset} or ${Cyan}make test${Reset}
• Build for Android: ${Cyan}.\build.ps1 -Task build-android${Reset} or ${Cyan}make build-android${Reset}
• Format code: ${Cyan}.\build.ps1 -Task format${Reset} or ${Cyan}make format${Reset}

${Yellow}Project structure:${Reset}
• Main app: ${Cyan}lib/main.dart${Reset}
• Tests: ${Cyan}test/${Reset}
• Assets: ${Cyan}assets/${Reset}
• Build configurations: ${Cyan}build.ps1${Reset}, ${Cyan}Makefile${Reset}

Happy coding! 🚀🌱
"@

#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Build script for PlantWise Flutter application
.DESCRIPTION
    Comprehensive build script that handles various build tasks for the PlantWise Flutter app
.PARAMETER Task
    The build task to execute (clean, deps, generate, test, build-android, build-ios, build-web, build-windows, analyze, format, help)
.PARAMETER Configuration
    Build configuration (debug, profile, release) - defaults to release
.PARAMETER Verbose
    Enable verbose output
.EXAMPLE
    .\build.ps1 -Task help
    .\build.ps1 -Task clean
    .\build.ps1 -Task build-android -Configuration release
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("clean", "deps", "generate", "test", "build-android", "build-ios", "build-web", "build-windows", "analyze", "format", "help", "all")]
    [string]$Task,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("debug", "profile", "release")]
    [string]$Configuration = "release",
    
    [Parameter(Mandatory = $false)]
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Magenta = "`e[35m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

function Write-TaskHeader {
    param([string]$TaskName)
    Write-Host "${Blue}================================${Reset}" -NoNewline
    Write-Host "${Cyan} $TaskName ${Reset}" -NoNewline
    Write-Host "${Blue}================================${Reset}"
}

function Write-Success {
    param([string]$Message)
    Write-Host "${Green}✓ $Message${Reset}"
}

function Write-Error {
    param([string]$Message)
    Write-Host "${Red}✗ $Message${Reset}"
}

function Write-Warning {
    param([string]$Message)
    Write-Host "${Yellow}⚠ $Message${Reset}"
}

function Test-FlutterInstalled {
    try {
        $flutterVersion = flutter --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Flutter is installed"
            if ($Verbose) {
                Write-Host $flutterVersion
            }
            return $true
        }
    }
    catch {
        Write-Error "Flutter is not installed or not in PATH"
        return $false
    }
}

function Invoke-Clean {
    Write-TaskHeader "Cleaning Project"
    
    Write-Host "Cleaning Flutter build artifacts..."
    flutter clean
    
    Write-Host "Removing generated files..."
    Get-ChildItem -Path "." -Recurse -Name "*.g.dart" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path "." -Recurse -Name "*.freezed.dart" | Remove-Item -Force -ErrorAction SilentlyContinue
    
    # Clean platform-specific build directories
    $buildDirs = @("build", "android\.gradle", "android\app\build", "ios\build", "web\build", "windows\build")
    foreach ($dir in $buildDirs) {
        if (Test-Path $dir) {
            Write-Host "Removing $dir..."
            Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Write-Success "Project cleaned successfully"
}

function Invoke-GetDependencies {
    Write-TaskHeader "Getting Dependencies"
    
    Write-Host "Getting Flutter packages..."
    flutter pub get
    
    Write-Success "Dependencies retrieved successfully"
}

function Invoke-CodeGeneration {
    Write-TaskHeader "Running Code Generation"
    
    Write-Host "Running build_runner for code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    Write-Success "Code generation completed successfully"
}

function Invoke-Tests {
    Write-TaskHeader "Running Tests"
    
    Write-Host "Running Flutter tests..."
    flutter test --coverage
    
    if (Test-Path "coverage\lcov.info") {
        Write-Success "Tests completed with coverage report generated"
        Write-Host "${Cyan}Coverage report: coverage\lcov.info${Reset}"
    } else {
        Write-Success "Tests completed successfully"
    }
}

function Invoke-BuildAndroid {
    Write-TaskHeader "Building Android APK"
    
    Write-Host "Building Android APK in $Configuration mode..."
    
    switch ($Configuration) {
        "debug" { flutter build apk --debug }
        "profile" { flutter build apk --profile }
        "release" { flutter build apk --release }
    }
    
    $apkPath = "build\app\outputs\flutter-apk\app-$Configuration.apk"
    if (Test-Path $apkPath) {
        Write-Success "Android APK built successfully"
        Write-Host "${Cyan}APK location: $apkPath${Reset}"
    } else {
        Write-Error "Android APK build failed"
    }
}

function Invoke-BuildiOS {
    Write-TaskHeader "Building iOS"
    
    if ($IsWindows) {
        Write-Warning "iOS builds are not supported on Windows"
        return
    }
    
    Write-Host "Building iOS app in $Configuration mode..."
    flutter build ios --$Configuration
    
    Write-Success "iOS build completed successfully"
}

function Invoke-BuildWeb {
    Write-TaskHeader "Building Web"
    
    Write-Host "Building web app in $Configuration mode..."
    flutter build web --$Configuration
    
    if (Test-Path "build\web\index.html") {
        Write-Success "Web app built successfully"
        Write-Host "${Cyan}Web build location: build\web\${Reset}"
    } else {
        Write-Error "Web build failed"
    }
}

function Invoke-BuildWindows {
    Write-TaskHeader "Building Windows"
    
    Write-Host "Building Windows app in $Configuration mode..."
    flutter build windows --$Configuration
    
    $exePath = "build\windows\x64\runner\$Configuration\plantwise.exe"
    if (Test-Path $exePath) {
        Write-Success "Windows app built successfully"
        Write-Host "${Cyan}Executable location: $exePath${Reset}"
    } else {
        Write-Error "Windows build failed"
    }
}

function Invoke-Analyze {
    Write-TaskHeader "Analyzing Code"
    
    Write-Host "Running Flutter analyze..."
    flutter analyze
    
    Write-Success "Code analysis completed"
}

function Invoke-Format {
    Write-TaskHeader "Formatting Code"
    
    Write-Host "Formatting Dart code..."
    dart format --set-exit-if-changed .
    
    Write-Success "Code formatting completed"
}

function Show-Help {
    Write-Host @"
${Cyan}PlantWise Build Script${Reset}

${Yellow}Usage:${Reset}
    .\build.ps1 -Task <task> [-Configuration <config>] [-Verbose]

${Yellow}Tasks:${Reset}
    ${Green}clean${Reset}           Clean build artifacts and generated files
    ${Green}deps${Reset}            Get Flutter dependencies (pub get)
    ${Green}generate${Reset}        Run code generation (build_runner)
    ${Green}test${Reset}            Run Flutter tests with coverage
    ${Green}build-android${Reset}   Build Android APK
    ${Green}build-ios${Reset}       Build iOS app (macOS only)
    ${Green}build-web${Reset}       Build web app
    ${Green}build-windows${Reset}   Build Windows app
    ${Green}analyze${Reset}         Run Flutter analyzer
    ${Green}format${Reset}          Format Dart code
    ${Green}all${Reset}             Run complete build pipeline
    ${Green}help${Reset}            Show this help message

${Yellow}Configurations:${Reset}
    ${Green}debug${Reset}           Debug build with assertions enabled
    ${Green}profile${Reset}         Profile build for performance testing
    ${Green}release${Reset}         Release build (default)

${Yellow}Examples:${Reset}
    .\build.ps1 -Task clean
    .\build.ps1 -Task build-android -Configuration release
    .\build.ps1 -Task test -Verbose
    .\build.ps1 -Task all -Configuration debug
"@
}

function Invoke-All {
    Write-TaskHeader "Running Complete Build Pipeline"
    
    $tasks = @("clean", "deps", "generate", "format", "analyze", "test", "build-android", "build-web", "build-windows")
    
    foreach ($taskName in $tasks) {
        try {
            switch ($taskName) {
                "clean" { Invoke-Clean }
                "deps" { Invoke-GetDependencies }
                "generate" { Invoke-CodeGeneration }
                "format" { Invoke-Format }
                "analyze" { Invoke-Analyze }
                "test" { Invoke-Tests }
                "build-android" { Invoke-BuildAndroid }
                "build-web" { Invoke-BuildWeb }
                "build-windows" { Invoke-BuildWindows }
            }
        }
        catch {
            Write-Error "Task '$taskName' failed: $($_.Exception.Message)"
            exit 1
        }
    }
    
    Write-Success "Complete build pipeline finished successfully"
}

# Main execution
try {
    Write-Host "${Magenta}PlantWise Build Script${Reset}"
    Write-Host "${Yellow}Configuration: $Configuration${Reset}"
    Write-Host ""
    
    # Check if Flutter is installed
    if (-not (Test-FlutterInstalled)) {
        Write-Error "Flutter is required but not found. Please install Flutter and add it to your PATH."
        exit 1
    }
    
    # Execute the requested task
    switch ($Task) {
        "clean" { Invoke-Clean }
        "deps" { Invoke-GetDependencies }
        "generate" { Invoke-CodeGeneration }
        "test" { Invoke-Tests }
        "build-android" { Invoke-BuildAndroid }
        "build-ios" { Invoke-BuildiOS }
        "build-web" { Invoke-BuildWeb }
        "build-windows" { Invoke-BuildWindows }
        "analyze" { Invoke-Analyze }
        "format" { Invoke-Format }
        "help" { Show-Help }
        "all" { Invoke-All }
    }
    
    Write-Host ""
    Write-Success "Task '$Task' completed successfully!"
}
catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
}

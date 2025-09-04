#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Deployment script for PlantWise Flutter application
.DESCRIPTION
    Handles version management, building, and deployment preparation
.PARAMETER Version
    Version number to release (e.g., 1.2.3)
.PARAMETER Platform
    Platform to build for (android, ios, web, windows, all)
.PARAMETER Environment
    Environment to deploy to (staging, production)
.PARAMETER SkipTests
    Skip running tests before deployment
.EXAMPLE
    .\scripts\deploy.ps1 -Version "1.2.3" -Platform "all" -Environment "production"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("android", "ios", "web", "windows", "all")]
    [string]$Platform = "all",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("staging", "production")]
    [string]$Environment = "production",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipTests
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Magenta = "`e[35m"
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

function Write-Warning {
    param([string]$Message)
    Write-Host "${Yellow}⚠️  $Message${Reset}"
}

function Write-Error {
    param([string]$Message)
    Write-Host "${Red}❌ $Message${Reset}"
}

function Write-Info {
    param([string]$Message)
    Write-Host "${Yellow}ℹ️  $Message${Reset}"
}

function Test-VersionFormat {
    param([string]$Version)
    return $Version -match '^\d+\.\d+\.\d+$'
}

function Update-PubspecVersion {
    param([string]$NewVersion)
    
    $pubspecPath = "pubspec.yaml"
    if (!(Test-Path $pubspecPath)) {
        Write-Error "pubspec.yaml not found"
        return $false
    }
    
    $content = Get-Content $pubspecPath -Raw
    $content = $content -replace 'version:\s*\d+\.\d+\.\d+\+\d+', "version: $NewVersion+1"
    
    Set-Content $pubspecPath $content
    Write-Success "Updated version in pubspec.yaml to $NewVersion"
    return $true
}

function Invoke-PreDeploymentChecks {
    Write-Header "Pre-deployment Checks"
    
    # Check if we're on a clean git state
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitStatus = git status --porcelain
        if ($gitStatus) {
            Write-Warning "Git working directory is not clean"
            Write-Host "Uncommitted changes:"
            Write-Host $gitStatus
            
            $continue = Read-Host "Continue anyway? (y/N)"
            if ($continue -ne "y" -and $continue -ne "Y") {
                Write-Error "Deployment cancelled"
                exit 1
            }
        } else {
            Write-Success "Git working directory is clean"
        }
    }
    
    # Check Flutter installation
    try {
        flutter --version | Out-Null
        Write-Success "Flutter is available"
    } catch {
        Write-Error "Flutter is not installed or not in PATH"
        exit 1
    }
    
    # Run tests unless skipped
    if (-not $SkipTests) {
        Write-Info "Running tests..."
        .\build.ps1 -Task test
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Tests failed"
            exit 1
        }
        Write-Success "All tests passed"
    } else {
        Write-Warning "Skipping tests"
    }
    
    # Run code analysis
    Write-Info "Running code analysis..."
    .\build.ps1 -Task analyze
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Code analysis failed"
        exit 1
    }
    Write-Success "Code analysis passed"
}

function Invoke-BuildForPlatform {
    param([string]$PlatformName)
    
    Write-Header "Building for $PlatformName"
    
    switch ($PlatformName.ToLower()) {
        "android" {
            .\build.ps1 -Task build-android -Configuration release
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Android build completed"
            } else {
                Write-Error "Android build failed"
                return $false
            }
        }
        "ios" {
            if ($env:OS -ne "Windows_NT") {
                .\build.ps1 -Task build-ios -Configuration release
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "iOS build completed"
                } else {
                    Write-Error "iOS build failed"
                    return $false
                }
            } else {
                Write-Warning "iOS builds are not supported on Windows"
            }
        }
        "web" {
            .\build.ps1 -Task build-web -Configuration release
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Web build completed"
            } else {
                Write-Error "Web build failed"
                return $false
            }
        }
        "windows" {
            if ($env:OS -eq "Windows_NT") {
                .\build.ps1 -Task build-windows -Configuration release
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Windows build completed"
                } else {
                    Write-Error "Windows build failed"
                    return $false
                }
            } else {
                Write-Warning "Windows builds are only supported on Windows"
            }
        }
        "all" {
            $platforms = @("android", "web")
            if ($env:OS -eq "Windows_NT") {
                $platforms += "windows"
            }
            if ($env:OS -ne "Windows_NT") {
                $platforms += "ios"
            }
            
            foreach ($p in $platforms) {
                $result = Invoke-BuildForPlatform $p
                if (-not $result) {
                    return $false
                }
            }
        }
    }
    
    return $true
}

function New-ReleaseNotes {
    param([string]$Version)
    
    $releaseNotesPath = "RELEASE_NOTES.md"
    $date = Get-Date -Format "yyyy-MM-dd"
    
    $template = @"
# Release Notes - Version $Version

## 🌱 PlantWise v$Version - Released $date

### ✨ New Features
- 

### 🐛 Bug Fixes
- 

### 🔧 Improvements
- 

### 📱 Platform Updates
- **Android**: 
- **iOS**: 
- **Web**: 
- **Windows**: 

### 🔐 Security
- 

### 📚 Documentation
- 

### 🧪 Testing
- 

### 🏗️ Build & Deployment
- Updated to version $Version

---

For technical details and full changelog, see the Git history.
"@

    if (!(Test-Path $releaseNotesPath)) {
        $template | Out-File -FilePath $releaseNotesPath -Encoding UTF8
        Write-Success "Created release notes template: $releaseNotesPath"
        Write-Info "Please edit the release notes before continuing"
        
        # Try to open the file in default editor
        if (Get-Command notepad -ErrorAction SilentlyContinue) {
            Start-Process notepad $releaseNotesPath
        }
        
        Read-Host "Press Enter after editing release notes to continue"
    }
}

function Invoke-GitTagging {
    param([string]$Version)
    
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Info "Creating Git tag for version $Version"
        
        # Add and commit version changes
        git add pubspec.yaml RELEASE_NOTES.md
        git commit -m "chore: bump version to $Version"
        
        # Create annotated tag
        git tag -a "v$Version" -m "Release version $Version"
        
        Write-Success "Created Git tag v$Version"
        Write-Info "Don't forget to push the tag: git push origin v$Version"
    } else {
        Write-Warning "Git not available, skipping tagging"
    }
}

function Show-DeploymentSummary {
    param([string]$Version, [string]$Platform, [string]$Environment)
    
    Write-Header "Deployment Summary"
    
    Write-Host @"
${Green}🎉 Deployment preparation completed successfully!${Reset}

${Yellow}Version:${Reset} ${Cyan}$Version${Reset}
${Yellow}Platform(s):${Reset} ${Cyan}$Platform${Reset}
${Yellow}Environment:${Reset} ${Cyan}$Environment${Reset}

${Yellow}📁 Build Artifacts:${Reset}
"@

    # List build artifacts
    $buildDir = "build"
    if (Test-Path $buildDir) {
        $artifacts = @()
        
        if (Test-Path "build\app\outputs\flutter-apk\*.apk") {
            $artifacts += "• Android APK: build\app\outputs\flutter-apk\"
        }
        
        if (Test-Path "build\app\outputs\bundle\release\*.aab") {
            $artifacts += "• Android Bundle: build\app\outputs\bundle\release\"
        }
        
        if (Test-Path "build\web\index.html") {
            $artifacts += "• Web Build: build\web\"
        }
        
        if (Test-Path "build\windows\x64\runner\Release\") {
            $artifacts += "• Windows Build: build\windows\x64\runner\Release\"
        }
        
        if ($artifacts.Count -gt 0) {
            $artifacts | ForEach-Object { Write-Host "  $_" }
        } else {
            Write-Host "  ${Yellow}No build artifacts found${Reset}"
        }
    }

    Write-Host @"

${Yellow}🚀 Next Steps:${Reset}
1. Review the build artifacts
2. Test the builds on target devices/platforms
3. Upload to app stores or deploy to hosting platform
4. Push Git tag: ${Cyan}git push origin v$Version${Reset}
5. Create GitHub release with the generated artifacts

${Yellow}📝 Release Notes:${Reset} RELEASE_NOTES.md
${Yellow}🏷️  Git Tag:${Reset} v$Version (created locally)
"@
}

# Main execution
try {
    Write-Header "PlantWise Deployment Script"
    Write-Host "${Magenta}Version: $Version${Reset}"
    Write-Host "${Magenta}Platform: $Platform${Reset}"
    Write-Host "${Magenta}Environment: $Environment${Reset}"
    Write-Host ""
    
    # Validate version format
    if (-not (Test-VersionFormat $Version)) {
        Write-Error "Invalid version format. Use semantic versioning (e.g., 1.2.3)"
        exit 1
    }
    
    # Pre-deployment checks
    Invoke-PreDeploymentChecks
    
    # Update version
    if (-not (Update-PubspecVersion $Version)) {
        exit 1
    }
    
    # Create release notes
    New-ReleaseNotes $Version
    
    # Clean and prepare
    Write-Header "Preparing Build Environment"
    .\build.ps1 -Task clean
    .\build.ps1 -Task deps
    .\build.ps1 -Task generate
    
    # Build for specified platform(s)
    $buildSuccess = Invoke-BuildForPlatform $Platform
    if (-not $buildSuccess) {
        Write-Error "Build failed"
        exit 1
    }
    
    # Git tagging
    Invoke-GitTagging $Version
    
    # Show summary
    Show-DeploymentSummary $Version $Platform $Environment
    
    Write-Success "Deployment preparation completed successfully!"
    
} catch {
    Write-Error "Deployment failed: $($_.Exception.Message)"
    exit 1
}

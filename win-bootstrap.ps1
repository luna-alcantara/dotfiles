# win-bootstrap.ps1 - Windows 11 bootstrap for dotfiles

param(
    [switch]$SkipWsl,
    [switch]$SkipChoco,
    [switch]$SkipPackages,
    [switch]$SkipDotfiles
)

$ErrorActionPreference = 'Stop'

# -------------------------------------------------
# Admin elevation
# -------------------------------------------------

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$id
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Elevate {
    $myArgs = @()
    if ($SkipWsl) { $myArgs += '-SkipWsl' }
    if ($SkipChoco) { $myArgs += '-SkipChoco' }
    if ($SkipPackages) { $myArgs += '-SkipPackages' }
    if ($SkipDotfiles) { $myArgs += '-SkipDotfiles' }

    Start-Process -FilePath powershell.exe -Verb RunAs -ArgumentList (
        "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $($myArgs -join ' ')"
    )
    exit
}

if (!(Test-Admin)) {
    Write-Host 'Elevating to administrator...' -ForegroundColor Yellow
    Elevate
}

# -------------------------------------------------
# Log helper
# -------------------------------------------------

function Log($msg) {
    Write-Host "`n==> $msg" -ForegroundColor Green
}

# -------------------------------------------------
# 1. WSL setup
# -------------------------------------------------

if (!$SkipWsl) {
    Log 'Enabling WSL and installing default distribution'

    wsl --install

    Log 'Updating WSL kernel'

    wsl --update

    Log 'Setting WSL 2 as default version'

    wsl --set-default-version 2

    $distros = wsl --list --quiet 2>$null
    if ($distros -notcontains 'Ubuntu') {
        Log 'Installing Ubuntu distribution'
        wsl --install -d Ubuntu
    } else {
        Log 'Ubuntu distribution already installed'
    }
} else {
    Write-Host 'Skipping WSL setup (-SkipWsl)' -ForegroundColor Cyan
}

# -------------------------------------------------
# 2. Chocolatey
# -------------------------------------------------

if (!$SkipChoco) {
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Log 'Installing Chocolatey'

        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression (
            (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
        )
    } else {
        Log 'Chocolatey already installed'
    }

    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:ChocolateyInstall = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Machine')
    if (-not $env:ChocolateyInstall) {
        $env:ChocolateyInstall = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'User')
    }
    if (-not $env:ChocolateyInstall) {
        $env:ChocolateyInstall = "$env:ProgramData\chocolatey"
    }
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco feature enable -n allowGlobalConfirmation
    }
} else {
    Write-Host 'Skipping Chocolatey install (-SkipChoco)' -ForegroundColor Cyan
}

# -------------------------------------------------
# 3. Chocolatey packages
# -------------------------------------------------

if (!$SkipPackages) {
    Log 'Installing Git via Chocolatey'
    choco install git -y --no-progress

    Log 'Installing Alacritty via Chocolatey'
    choco install alacritty -y --no-progress
} else {
    Write-Host 'Skipping package install (-SkipPackages)' -ForegroundColor Cyan
}

# -------------------------------------------------
# 4. Deploy Alacritty dotfiles
# -------------------------------------------------

if (!$SkipDotfiles) {
    Log 'Deploying Alacritty config from dotfiles'

    $tmpDir = Join-Path $env:TEMP "dotfiles-$([System.IO.Path]::GetRandomFileName())"

    git clone --depth 1 --single-branch https://github.com/luna-alcantara/dotfiles.git $tmpDir

    $src = Join-Path $tmpDir 'alacritty\.config\alacritty'
    $dst = "$env:APPDATA\alacritty"

    if (!(Test-Path $dst)) {
        New-Item -ItemType Directory -Path $dst -Force | Out-Null
    }

    Copy-Item (Join-Path $src '*') $dst -Recurse -Force

    Remove-Item -Recurse -Force $tmpDir

    $alacrittyToml = "$env:APPDATA\alacritty\alacritty.toml"
    $wslShellConfig = @"
[shell]
program = "wsl.exe"
args = ["-d", "Ubuntu"]
"@

    if (!(Test-Path $alacrittyToml)) {
        Set-Content -Path $alacrittyToml -Value $wslShellConfig
        Log 'Created alacritty.toml with WSL shell config'
    } else {
        $content = Get-Content -Path $alacrittyToml -Raw
        if ($content -notmatch '\[shell\]') {
            Add-Content -Path $alacrittyToml -Value "`n$wslShellConfig"
            Log 'Appended WSL shell config to alacritty.toml'
        } else {
            Log 'alacritty.toml already has a [shell] config, leaving it as-is'
        }
    }
} else {
    Write-Host 'Skipping dotfile deploy (-SkipDotfiles)' -ForegroundColor Cyan
}

# -------------------------------------------------
# 5. Summary
# -------------------------------------------------

Log 'Summary'

Write-Host "`nWSL distros:" -ForegroundColor Cyan
wsl --list --verbose

if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "`nChocolatey: $((choco --version))" -ForegroundColor Cyan
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "Git: $((git --version))" -ForegroundColor Cyan
}

Write-Host "`nAlacritty config deployed to: $env:APPDATA\alacritty" -ForegroundColor Cyan

Write-Host "`nDone." -ForegroundColor Green

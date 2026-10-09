$ErrorActionPreference = "Stop"

$Dotfiles = $PSScriptRoot
$BackupDir = Join-Path $env:USERPROFILE ".dotfiles-backup\$(Get-Date -Format yyyyMMdd_HHmmss)"

function Info($msg) { Write-Host "[ok] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }

function Install-Scoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Info "scoop ja instalado"
        return
    }
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

function Install-Packages {
    $buckets = scoop bucket list | ForEach-Object { $_.Name }
    foreach ($bucket in @("extras", "nerd-fonts")) {
        if ($buckets -notcontains $bucket) { scoop bucket add $bucket }
    }
    $installed = scoop list 6>$null | ForEach-Object { $_.Name }
    foreach ($pkg in @("git", "neovim", "ripgrep", "fd", "tree-sitter", "mingw", "Hack-NF")) {
        if ($installed -contains $pkg) {
            Info "$pkg ja instalado"
        } else {
            scoop install $pkg
        }
    }
}

function Link-Dir($Source, $Target) {
    $src = Join-Path $Dotfiles $Source
    if (-not (Test-Path $src)) {
        Warn "Origem nao encontrada: $src"
        return
    }
    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.LinkType -eq "Junction" -and $item.Target -contains $src) {
            Info "Ja linkado: $Target"
            return
        }
        New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
        Move-Item $Target (Join-Path $BackupDir (Split-Path $Target -Leaf))
        Warn "Backup: $Target -> $BackupDir"
    }
    New-Item -ItemType Junction -Path $Target -Target $src | Out-Null
    Info "Linkado: $Target -> $src"
}

Install-Scoop
Install-Packages
Link-Dir ".config\nvim" (Join-Path $env:LOCALAPPDATA "nvim")

Write-Host ""
Write-Host "Pronto. Abra o nvim uma vez para o lazy instalar os plugins."

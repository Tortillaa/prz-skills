<#
.SYNOPSIS
    Installs skills from this repo into an agent's user-level skills directory.

.DESCRIPTION
    Creates a symbolic link (or a copy with -Copy, or when symlinks are not
    permitted) for each skill in skills/ inside the target agent directory:
      cursor -> ~/.cursor/skills
      claude -> ~/.claude/skills
      agents -> ~/.agents/skills

.EXAMPLE
    ./scripts/install.ps1 -Target cursor

.EXAMPLE
    ./scripts/install.ps1 -Target claude -Skill example-skill -Force
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('cursor', 'claude', 'agents')]
    [string]$Target,

    [string[]]$Skill,

    [switch]$Copy,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillsRoot = Join-Path $repoRoot 'skills'

$targetDirs = @{
    cursor = Join-Path $HOME '.cursor/skills'
    claude = Join-Path $HOME '.claude/skills'
    agents = Join-Path $HOME '.agents/skills'
}
$destRoot = $targetDirs[$Target]
New-Item -ItemType Directory -Force -Path $destRoot | Out-Null

if ($Skill) {
    $sources = foreach ($name in $Skill) {
        $path = Join-Path $skillsRoot $name
        if (-not (Test-Path (Join-Path $path 'SKILL.md'))) {
            throw "Skill '$name' not found in $skillsRoot"
        }
        Get-Item $path
    }
} else {
    $sources = Get-ChildItem -Directory $skillsRoot |
        Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }
}

foreach ($src in $sources) {
    $dest = Join-Path $destRoot $src.Name

    if (Test-Path $dest) {
        $existing = Get-Item $dest -Force
        $isOurLink = $existing.LinkType -eq 'SymbolicLink' -and $existing.Target -contains $src.FullName
        if ($isOurLink -and -not $Copy) {
            Write-Host "[skip]    $($src.Name) (already linked)"
            continue
        }
        if (-not $Force) {
            Write-Warning "$dest already exists; use -Force to replace it."
            continue
        }
        if ($existing.LinkType) {
            $existing.Delete()
        } else {
            Remove-Item -Recurse -Force $dest
        }
    }

    if (-not $Copy) {
        try {
            New-Item -ItemType SymbolicLink -Path $dest -Target $src.FullName | Out-Null
            Write-Host "[linked]  $($src.Name) -> $dest"
            continue
        } catch {
            Write-Warning "Could not create symlink for $($src.Name) (enable Developer Mode or run elevated). Copying instead."
        }
    }

    Copy-Item -Recurse -Path $src.FullName -Destination $dest
    Write-Host "[copied]  $($src.Name) -> $dest"
}

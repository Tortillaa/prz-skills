<#
.SYNOPSIS
    Installs, uninstalls or lists skills from this repo in an agent's skills directory.

.DESCRIPTION
    Creates a symbolic link (or a copy with -Copy, or when symlinks are not
    permitted) for each skill in skills/ inside the target agent directory.

    User level (default)     Project level (-Project <path>)
      cursor -> ~/.cursor/skills    <path>/.cursor/skills
      claude -> ~/.claude/skills    <path>/.claude/skills
      agents -> ~/.agents/skills    <path>/.agents/skills

    -Uninstall only removes skills whose names exist in this repo. Links to this
    repo are removed directly; copies and links pointing elsewhere need -Force.

.EXAMPLE
    ./scripts/install.cmd -Target cursor

.EXAMPLE
    ./scripts/install.cmd -Target claude -Skill "prz-grillme,prz-plan" -Force

.EXAMPLE
    ./scripts/install.cmd -Target cursor -Project ../my-app

.EXAMPLE
    ./scripts/install.cmd -Target cursor -List

.EXAMPLE
    ./scripts/install.cmd -Target cursor -Uninstall -Skill prz-plan
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('cursor', 'claude', 'agents')]
    [string]$Target,

    [string[]]$Skill,

    [string]$Project,

    [switch]$Copy,

    [switch]$Force,

    [switch]$Uninstall,

    [switch]$List
)

$ErrorActionPreference = 'Stop'

if ($Uninstall -and $List) { throw '-Uninstall and -List cannot be combined.' }
if (($Uninstall -or $List) -and $Copy) { throw '-Copy only applies to installs.' }

# install.cmd forwards -Skill as one comma-separated string. Direct PowerShell
# calls already pass a string array. Split either form into names.
if ($Skill) {
    $Skill = @(
        $Skill | ForEach-Object { $_ -split ',' } |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ }
    )
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillsRoot = Join-Path $repoRoot 'skills'

if ($Project) {
    if (-not (Test-Path -PathType Container $Project)) {
        throw "Project directory '$Project' does not exist."
    }
    $baseDir = (Resolve-Path $Project).Path
} else {
    $baseDir = $HOME
}
$destRoot = Join-Path $baseDir ".$Target/skills"

$repoSkills = Get-ChildItem -Directory $skillsRoot |
    Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }

if ($Skill) {
    $sources = foreach ($name in $Skill) {
        $match = $repoSkills | Where-Object Name -eq $name
        if (-not $match) { throw "Skill '$name' not found in $skillsRoot" }
        $match
    }
} else {
    $sources = $repoSkills
}

function Get-SkillStatus([string]$Dest, [string]$SourcePath) {
    if (-not (Test-Path $Dest)) { return 'not installed' }
    $item = Get-Item $Dest -Force
    if ($item.LinkType) {
        if ($item.Target -contains $SourcePath) { return 'linked' }
        return 'linked elsewhere'
    }
    return 'copied'
}

function Remove-Installed([string]$Dest) {
    $item = Get-Item $Dest -Force
    if ($item.LinkType) {
        $item.Delete()
    } else {
        Remove-Item -Recurse -Force $Dest
    }
}

function Install-Skill($Src) {
    $dest = Join-Path $destRoot $Src.Name
    $status = Get-SkillStatus $dest $Src.FullName

    if ($status -eq 'linked' -and -not $Copy) {
        Write-Host "[skip]    $($Src.Name) (already linked)"
        return
    }
    if ($status -ne 'not installed') {
        if (-not $Force) {
            Write-Warning "$dest already exists ($status); use -Force to replace it."
            return
        }
        Remove-Installed $dest
    }

    if (-not $Copy) {
        try {
            New-Item -ItemType SymbolicLink -Path $dest -Target $Src.FullName | Out-Null
            Write-Host "[linked]  $($Src.Name) -> $dest"
            return
        } catch {
            Write-Warning "Could not create symlink for $($Src.Name) (enable Developer Mode or run elevated). Copying instead."
        }
    }

    Copy-Item -Recurse -Path $Src.FullName -Destination $dest
    Write-Host "[copied]  $($Src.Name) -> $dest"
}

function Uninstall-Skill($Src) {
    $dest = Join-Path $destRoot $Src.Name
    $status = Get-SkillStatus $dest $Src.FullName

    switch ($status) {
        'not installed' {
            Write-Host "[skip]    $($Src.Name) (not installed)"
        }
        'linked' {
            Remove-Installed $dest
            Write-Host "[removed] $($Src.Name)"
        }
        default {
            if (-not $Force) {
                Write-Warning "$dest is $status (may contain local changes); use -Force to remove it."
                return
            }
            Remove-Installed $dest
            Write-Host "[removed] $($Src.Name) ($status)"
        }
    }
}

function Show-Skills {
    Write-Host "Destination: $destRoot"
    if (-not (Test-Path $destRoot)) {
        Write-Host '  (directory does not exist)'
    }

    $external = @()
    if (-not $Skill -and (Test-Path $destRoot)) {
        $external = @(Get-ChildItem -Force $destRoot |
            Where-Object { $_.PSIsContainer -and $repoSkills.Name -notcontains $_.Name })
    }

    $names = @($sources.Name) + @($external.Name)
    $width = ($names | Measure-Object -Maximum -Property Length).Maximum + 2

    foreach ($src in $sources) {
        $status = Get-SkillStatus (Join-Path $destRoot $src.Name) $src.FullName
        Write-Host ('  {0}{1}' -f $src.Name.PadRight($width), $status)
    }
    foreach ($item in $external) {
        Write-Host ('  {0}external (not from this repo)' -f $item.Name.PadRight($width))
    }
}

if ($List) {
    Show-Skills
} elseif ($Uninstall) {
    foreach ($src in $sources) { Uninstall-Skill $src }
} else {
    New-Item -ItemType Directory -Force -Path $destRoot | Out-Null
    foreach ($src in $sources) { Install-Skill $src }
}

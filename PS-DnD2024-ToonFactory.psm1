<#
.SYNOPSIS
    Dungeons and Dragons Character creator
.DESCRIPTION
    Combines stats, skills, background, and origin story into a formatted text block.
.PARAMETER InputPath
.PARAMETER Backup
.EXAMPLE
.EXAMPLE
.INPUTS
.OUTPUTS
.NOTES
    Author: archibaldburnsteel
    Version: 1.0
.LINK
#>
# PS-DnD2024-ToonFactory.psm1

# 1. Define the path to your source files
$SourcePath = Join-Path -Path $PSScriptRoot -ChildPath "src"

# 2. Get all .ps1 files, sorted by name (01, 02, 03...)
$Files = Get-ChildItem -Path $SourcePath -Filter "*.ps1" | Sort-Object Name

# 3. Dot-source each file into the module scope
foreach ($File in $Files) {
    try {
        . $File.FullName
    } catch {
        Write-Error "CRITICAL: Failed to load module component: $($File.Name). Error: $_"
    }
}

# 4. Optional: Add a hidden internal variable to track version or load time
$script:ModuleLoadTime = Get-Date
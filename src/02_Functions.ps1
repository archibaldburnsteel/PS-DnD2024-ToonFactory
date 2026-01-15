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
    Required Modules:
.LINK
#>

function FormatAbilityRow($label, $ability, $save) {
    $mod = $ability.GetModifier()
    $modStr = if ($mod -ge 0) { "+$mod" } else { "$mod" }

    $scoreStr = "($($ability.Score))"

    $saveTotal = $save.GetTotal()
    $saveStr = if ($saveTotal -ge 0) { "+$saveTotal" } else { "$saveTotal" }
    if ($save.Proficient) { $saveStr += "*" }

    $col1 = $label.PadRight(4)       # STR
    $col2 = $modStr.PadRight(4)      # +4
    $col3 = $scoreStr.PadRight(6)    # (19)
    $col4 = $saveStr.PadRight(4)      #  +6*

    return "    $col1 $col2 $col3 Save: $col4"
}

function New-DnDCharacter {
    return [ToonFactory]::Create()
}
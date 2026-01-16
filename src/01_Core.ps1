<#
.SYNOPSIS
    Dungeons and Dragons all the things
.DESCRIPTION
    forces correctness
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

enum GamingSets {
    dice
    dragonchess
    playingcards
    threedragonante
}

enum ClassName {
    Barbarian
    Bard
    Cleric
    Druid
    Fighter
    Monk
    Paladin
    Ranger
    Rogue
    Sorcerer
    Warlock
    Wizard
}

enum Languages {
    Common
    CommonSignLanguage
    Draconic
    Dwarvish
    Elvish
    Giant
    Gnomish
    Goblin
    Halfling
    Orc
}

class AbilityScore {
    [int]$Score

    AbilityScore([int]$score) {
        $this.Score = $score
    }

    [int] GetModifier() {
        return [math]::Floor(($this.Score - 10) / 2)
    }

    [string] ToString() {
        $mod = $this.GetModifier()
        $sign = if ($mod -ge 0) { "+$mod" } else { "$mod" }
        return "$sign ($($this.Score))"
    }
}

class SavingThrow {
    [string]$AbilityName
    [AbilityScore]$Ability
    [int]$ProficiencyBonus
    [bool]$Proficient

    SavingThrow([DnDClass]$character, [string]$save) {
        $this.AbilityName = $save
        $this.Ability = $character.$save.score
        $this.Proficient = $this.IsProficient($character)
        if ($this.Proficient) {
            $this.ProficiencyBonus = $character.Proficiency
        } else {
            $this.ProficiencyBonus = 0
        }
    }

    [int] GetTotal() {
        $mod = $this.Ability.GetModifier()
        return $mod + $this.ProficiencyBonus
    }

    [string] ToString() {
        $total = $this.GetTotal()
        $sign = if ($total -ge 0) { "+$total" } else { "$total" }
        if ($this.Proficient) {
            return "$sign" + "*"
        } else {
            return "$sign"
        }
    }

    [bool] IsProficient($character) {
        if ($this.AbilityName -in $character.SavingThrowProficiencies.ToArray()) {
            return $true
        }
        return $false
    }
}

class Skill {
    [string]$SkillName
    [AbilityScore]$Ability
    [bool]$Proficient
    [DnDClass]$character
    static [hashtable]$SkillLookup = @{
        "Athletics"       = "Strength"
        "Acrobatics"      = "Dexterity"
        "Sleight of Hand" = "Dexterity"
        "Stealth"         = "Dexterity"
        "Arcana"          = "Intelligence"
        "History"         = "Intelligence"
        "Investigation"   = "Intelligence"
        "Nature"          = "Intelligence"
        "Religion"        = "Intelligence"
        "Animal Handling" = "Wisdom"
        "Insight"         = "Wisdom"
        "Medicine"        = "Wisdom"
        "Perception"      = "Wisdom"
        "Survival"        = "Wisdom"
        "Deception"       = "Charisma"
        "Intimidation"    = "Charisma"
        "Performance"     = "Charisma"
        "Persuasion"      = "Charisma"
    }

    Skill([string]$name, [DnDClass]$character) {
        $this.SkillName = $name
        $this.character = $character
        $abilityName = [Skill]::SkillLookup[$name]
        $this.Ability = $character.$abilityName
        $this.Proficient = $name -in $character.SkillProficiencies
    }

    [int] GetTotal() {
        $mod = $this.Ability.GetModifier()
        $prof = if ($this.Proficient) { $this.Character.Proficiency } else { 0 }
        return $mod + $prof
    }

    [string] ToString() {
        $total = $this.GetTotal()
        $sign = if ($total -ge 0) { "+$total" } else { "$total" }
        return "$($this.SkillName): $sign"
    }
}

class DnDClass {
    [string]$CharacterClass
    [string]$PrimaryAbility
    [string]$Name
    [int]$Level
    [int]$ExperiencePoints
    [int]$HitPointDie
    [System.Collections.Generic.List[string]]$SavingThrowProficiencies
    [System.Collections.Generic.List[string]]$SkillProficiencies
    [System.Collections.Generic.List[string]]$WeaponProficiencies
    [Humanoid]$Species
    [System.Collections.Generic.List[string]]$KnownLanguages
    [Background]$BackGround
    [AbilityScore]$Strength
    [AbilityScore]$Dexterity
    [AbilityScore]$Constitution
    [AbilityScore]$Intelligence
    [AbilityScore]$Wisdom
    [AbilityScore]$Charisma
    [int]$TotalAbilityScores
    [int]$Proficiency
    [System.Collections.Generic.List[string]]$ArmorTraining
    [System.Collections.Generic.List[string]]$StartingEquipment
    [System.Collections.Generic.List[string]]$ClassFeatures
    [hashtable]$Skills
    [string]$OriginStory

    DnDClass() {
        $this.CharacterClass = $this.GetType().Name
        $this.Proficiency = 2
        $this.SavingThrowProficiencies = [System.Collections.Generic.List[string]]::New()
        $this.SkillProficiencies = [System.Collections.Generic.List[string]]::New()
        $this.WeaponProficiencies = [System.Collections.Generic.List[string]]::New()
        $this.ArmorTraining = [System.Collections.Generic.List[string]]::New()
        $this.ClassFeatures = [System.Collections.Generic.List[string]]::New()
        $this.KnownLanguages = [System.Collections.Generic.List[string]]::New()
        $languages = [enum]::GetValues([Languages])
        $this.KnownLanguages.AddRange([string[]](Get-Random -InputObject $languages -Count 3))
        $this.Skills = @{}

    }

    DnDClass( [Humanoid]$species, [Background]$background) {
        $this.CharacterClass = $this.GetType().Name
        $this.Species = $species
        $this.BackGround = $background
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.Proficiency = 2
        $this.GenerateOptimizedStats()
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies = [System.Collections.Generic.List[string]]::New()
        $this.SkillProficiencies = [System.Collections.Generic.List[string]]::New()
        $languages = [enum]::GetValues([Languages])
        $this.KnownLanguages.AddRange([string[]](Get-Random -InputObject $languages -Count 3))
        $this.Skills = @{}
        $this.BuildSkills()
    }

    [int] RollStats() {
        $Rolls = 1..4 | ForEach-Object { Get-Random -Minimum 1 -Maximum 7 }
        return ($Rolls | Measure-Object -Sum).Sum - ($Rolls | Measure-Object -Minimum).Minimum
    }

    [int] GetTotalAbilityScores() {
        return ($this.Strength.Score + $this.Dexterity.Score + $this.Constitution.Score + $this.Intelligence.Score + $this.Wisdom.Score + $this.Charisma.Score)
    }

    BuildSkills() {
        $skillNames = @(
            "Athletics",
            "Acrobatics",
            "Sleight of Hand",
            "Stealth",
            "Arcana",
            "History",
            "Investigation",
            "Nature",
            "Religion",
            "Animal Handling",
            "Insight",
            "Medicine",
            "Perception",
            "Survival",
            "Deception",
            "Intimidation",
            "Performance",
            "Persuasion"
        )
        foreach ($name in $skillNames) {
            $this.Skills[$name] = [Skill]::new($name, $this)
        }
    }

    hidden [void] GenerateOptimizedStats() {
        # Roll and sort stats (highest first) for optimal distribution
        $pool = (1..6 | ForEach-Object { $this.RollStats() }) | Sort-Object -Descending

        # Assign highest to primary, second-highest to Constitution
        $this.($this.PrimaryAbility) = $pool[0]

        # Constitution is critical for all classes
        if ($this.PrimaryAbility -ne 'Constitution') {
            $this.Constitution = $pool[1]
            $poolIndex = 2
        } else {
            $poolIndex = 1
        }

        # Distribute remaining stats
        $remainingStats = @('Strength', 'Dexterity', 'Constitution', 'Intelligence', 'Wisdom', 'Charisma') |
        Where-Object { $_ -ne $this.PrimaryAbility -and $_ -ne 'Constitution' }

        foreach ($statName in $remainingStats) {
            $this.$statName = $pool[$poolIndex++]
        }
    }

    [string] CharacterSheet() {
        $this.OriginStory = [StoryFactory]::GetOriginStory($this)
        $this.Name = [NameFactory]::GetName($this.Species)
        function FormatSkillCell($skill) {
            $name = $skill.SkillName.PadRight(16)
            $total = $skill.GetTotal()
            $modStr = if ($total -ge 0) { "+$total" } else { "$total" }
            if ($skill.Proficient) { $modStr += "*" }
            $modStr = $modStr.PadRight(4)
            return "$name $modStr"
        }
        # build 3‑column skill block
        $ack = $this.Skills.Values | Sort-Object SkillName
        $rows = 6
        $skillLines = @()
        for ($i = 0; $i -lt $rows; $i++) {
            $col1 = FormatSkillCell $ack[$i]
            $col2 = FormatSkillCell $ack[$i + 6]
            $col3 = FormatSkillCell $ack[$i + 12]
            $skillLines += "  $col1   $col2   $col3"
        }
        $skillsBlock = $skillLines -join "`n"

        return @"
=== $($this.Name) ===
Species: $($this.Species)
Class:   $($this.CharacterClass)
Level:   $($this.Level)
HP:      $($this.HitPointDie + $this.Constitution.GetModifier())
SPD:     $($this.Species.Speed)
Size:    $($this.Species.Size)
Passive Perception: $($this.Wisdom.GetModifier() + 10)
Initiative: $($this.Dexterity.GetModifier() + 10)

Ability Scores: $($this.TotalAbilityScores)
  $(FormatAbilityRow "STR" $this.Strength ([SavingThrow]::new($this,"Strength")))
  $(FormatAbilityRow "DEX" $this.Dexterity ([SavingThrow]::new($this,"Dexterity")))
  $(FormatAbilityRow "CON" $this.Constitution ([SavingThrow]::new($this,"Constitution")))
  $(FormatAbilityRow "INT" $this.Intelligence ([SavingThrow]::new($this,"Intelligence")))
  $(FormatAbilityRow "WIS" $this.Wisdom ([SavingThrow]::new($this,"Wisdom")))
  $(FormatAbilityRow "CHA" $this.Charisma ([SavingThrow]::new($this,"Charisma")))

Skills:
$skillsBlock

Background: $($this.Background.Name)
  Feat:               $([string]::Join(", ", $this.Background.Feat))
  Skills:             $([string]::Join(", ", $this.Background.SkillProficiencies))
  Tools:              $([string]::Join(", ", $this.Background.ToolProficiencies))
  Equipment:          $([string]::Join(", ", $this.Background.Equipment))
  Special Traits:     $([string]::Join(", ", $this.Species.SpecialTraits))

Origin:
$($this.OriginStory)
"@
    }
}

Class Barbarian : DnDClass {
    Barbarian([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.PrimaryAbility = 'Strength'
        $this.HitPointDie = 12
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Strength", "Constitution"))
        $Skills = @("Animal Handling", "Athletics", "Intimidation", "Nature", "Perception", "Survival")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 2))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Medium", "Shields"))
        $this.ClassFeatures.AddRange([string[]]("Rage", "Unarmored Defense", "Weapon Mastery"))
        $this.BuildSkills()
    }
}

Class Bard : DnDClass {

    Bard([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.PrimaryAbility = 'Charisma'
        $this.HitPointDie = 8
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Dexterity", "Charisma"))
        $Skills = @("Acrobatics", "Animal Handling", "Arcana", "Athletics", "Deception", "History", "Insight", "Intimidation", "Investigation", "Medicine", "Nature", "Perception", "Performance", "Persuasion", "Religion", "Sleight Of Hand", "Stealth", "Survival")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 3))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.Add("Simple")
        $this.ArmorTraining.Add("Light")
        $this.ClassFeatures.AddRange([string[]]("Bardic Inspiration", "Spellcasting"))
        $this.BuildSkills()
    }
}

Class Cleric : DnDClass {

    Cleric([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.PrimaryAbility = 'Wisdom'
        $this.HitPointDie = 8
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Wisdom", "Charisma"))
        $Skills = @("History", "Insight", "Medicine", "Persuasion", "Religion")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 2))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Medium", "Shields"))
        $choices = @("Protector", "Thamaturge")
        $DivineOrder = $choices
        $this.ClassFeatures.AddRange([string[]]("Spellcasting", $DivineOrder))
        $this.BuildSkills()
    }
}

Class Druid : DnDClass {

    Druid([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.PrimaryAbility = 'Wisdom'
        $this.HitPointDie = 8
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Wisdom", "Intelligence"))
        $Skills = @("Animal Handling", "Arcana", "Insight", "Medicine", "Nature", "Perception", "Religion", "Survival")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 2))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Shields"))
        $choice = @("Magician", "Warden")
        $primalOrder = Get-Random -InputObject $choice
        $this.ClassFeatures.AddRange([string[]]("Spellcasting", "Druidic", $primalOrder))
        $this.BuildSkills()
    }
}

Class Fighter : DnDClass {

    Fighter([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $statchoice = @("Strength", "Dexterity")
        $this.PrimaryAbility = Get-Random -InputObject $statchoice
        $this.HitPointDie = 10
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Strength", "Constitution"))
        $Skills = @("Acrobatics", "Animal Handling", "Athletics", "History", "Insight", "Intimidation", "Persuasion", "Perception", "Survival")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 2))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Medium", "Heavy", "Shields"))
        $choice = @("Archery", "Blind Fighting", "Defense", "Dueling", "Great Weapon", "Interception", "Protection", "Thrown Weapon", "Two-Weapon", "Unarmed")
        $FightingSyle = Get-Random -InputObject $choice
        $this.ClassFeatures.AddRange([string[]]("Second Wind", "Weapon Mastery", $FightingSyle))
        $this.BuildSkills()
    }
}

Class Monk : DnDClass {

    Monk([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $statchoice = @("Dexterity", "Wisdom")
        $this.PrimaryAbility = Get-Random -InputObject $statchoice
        $this.HitPointDie = 8
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Strength", "Dexterity"))
        $Skills = @("Acrobatics", "Athletics", "History", "Insight", "Religion", "Stealth")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 2))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("None"))
        $this.ClassFeatures.AddRange([string[]]("Martial Arts", "Unarmored Defense"))
        $this.BuildSkills()
    }
}

Class Paladin : DnDClass {

    Paladin([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $statchoice = @("Strength", "Charisma")
        $this.PrimaryAbility = Get-Random -InputObject $statchoice
        $this.HitPointDie = 10
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Wisdom", "Charisma"))
        $Skills = @("Athletics", "Insight", "Intimidation", "Medicine", "Persuasion", "Religion")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 2))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Medium", "Heavy", "Shields"))
        $this.ClassFeatures.AddRange([string[]]("Lay On Hands", "Spellcasting", "Weapon Mastery"))
        $this.BuildSkills()
    }
}

Class Ranger : DnDClass {

    Ranger([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $statchoice = @("Dexterity", "Wisdom")
        $this.PrimaryAbility = Get-Random -InputObject $statchoice
        $this.HitPointDie = 10
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Strength", "Dexterity"))
        $Skills = @("Animal Handling", "Athletics", "Insight", "Investigation", "Nature", "Perception", "Stealth", "Survival")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 2))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Medium", "Shields"))
        $this.ClassFeatures.AddRange([string[]]("Spellcasting", "Favored Enemy", "Weapon Mastery"))
        $this.BuildSkills()
    }
}

Class Rogue : DnDClass {

    Rogue([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.PrimaryAbility = "Dexterity"
        $this.HitPointDie = 8
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Dexterity", "Intelligence"))
        $Skills = @("Acrobatics", "Athletics", "Deception", "Insight", "Intimidation", "Investigation", "Perception", "Persuasion", "Sleight of Hand", "Stealth")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 4))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("Light"))
        $this.ClassFeatures.AddRange([string[]]("Expertise", "Sneak Attack", "Weapon Mastery", "Thieves' Cant"))
        $this.BuildSkills()
    }
}

Class Sorcerer : DnDClass {

    Sorcerer([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.PrimaryAbility = "Charisma"
        $this.HitPointDie = 6
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Constitution", "Charisma"))
        $Skills = @("Arcana", "Deception", "Insight", "Intimidation", "Persuasion", "Religion")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 2))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple"))
        $this.ArmorTraining.AddRange([string[]]("None"))
        $this.ClassFeatures.AddRange([string[]]("Spellcasting", "Innate Sorcery"))
        $this.BuildSkills()
    }
}

Class Warlock : DnDClass {

    Warlock([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.PrimaryAbility = "Charisma"
        $this.HitPointDie = 8
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Wisdom", "Charisma"))
        $Skills = @("Arcana", "Deception", "History", "Intimidation", "Investigation", "Nature", "Religion")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 2))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple"))
        $this.ArmorTraining.AddRange([string[]]("Light"))
        $this.ClassFeatures.AddRange([string[]]("Eldrith Invocations", "Pact Magic"))
        $this.BuildSkills()
    }
}

Class Wizard : DnDClass {

    Wizard([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.PrimaryAbility = "Intelligence"
        $this.HitPointDie = 6
        $this.Level = 1
        $this.ExperiencePoints = 0
        $this.GenerateOptimizedStats()
        foreach ($stat in $this.BackGround.AbilityScores) {
            $this.$stat.score = $this.$stat.score + 1
        }
        $this.TotalAbilityScores = $this.GetTotalAbilityScores()
        $this.SavingThrowProficiencies.AddRange([string[]]("Intelligence", "Wisdom"))
        $Skills = @("Arcana", "History", "Insight", "Investigation", "Medicine", "Nature", "Religion")
        $Skills = $Skills | Where-Object { $_ -ne $this.BackGround.SkillProficiencies[0] -and $_ -ne $this.BackGround.SkillProficiencies[1] }
        $this.SkillProficiencies.AddRange([string[]](Get-Random -InputObject $Skills -Count 2))
        $this.SkillProficiencies.AddRange($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple"))
        $this.ArmorTraining.AddRange([string[]]("None"))
        $this.ClassFeatures.AddRange([string[]]("Spellcasting", "Ritual Adept", "Arcane Recovery"))
        $this.BuildSkills()
    }
}
class StoryFactory {

    static [string] GetOriginStory([DnDClass]$character) {

        $speciesHooks = @{
            "Elf"        = "born beneath ancient boughs older than empires"
            "Dwarf"      = "raised in the echoing halls of stone and steel"
            "Human"      = "shaped by the restless churn of crowded cities"
            "Halfling"   = "raised among warm hearths, quick laughter, and quicker hands"
            "Orc"        = "forged in a world that respects only strength"
            "Dragonborn" = "carrying the weight of a draconic lineage that demands greatness"
            "Aasimar"    = "born with a spark of celestial light flickering behind their eyes, guided since childhood by dreams whispered from the Upper Planes"
            "Goliath"    = "hazed for being the smallest of the village they ran away"
            "Gnome"      = "possessing a mind that moves faster than their hands can keep up with"
            "Tiefling"   = "marked by a heritage they did not choose and a world that rarely lets them forget it"
        }

        $classHooks = @{
            "Barbarian" = "whose fury was first awakened by a wound the world refused to heal"
            "Wizard"    = "who discovered forbidden truths long before they understood their cost"
            "Rogue"     = "who learned early that shadows are often kinder than people"
            "Cleric"    = "who heard a whisper in the dark and chose to answer"
            "Fighter"   = "who trained until discipline became a second heartbeat"
            "Ranger"    = "who preferred the ways of the forest animals"
            "Druid"     = "who eschewed civilization to live off Nature's bounty"
            "Paladin"   = "who swore an oath that glows brighter than any torch in the dark"
            "Bard"      = "who discovered that the right word at the right time can topple thrones"
            "Warlock"   = "who bartered a piece of their soul for a glimpse of the truth"
            "Monk"      = "who found power in the stillness between breaths"
        }

        $incitingIncidents = @(
            "after a betrayal that carved a scar deeper than any blade",
            "when destiny tripped over them like a drunk in a tavern",
            "after witnessing something no one else believed",
            "when a simple favor spiraled wildly out of control",
            "after losing a bet they absolutely should not have taken",
            "after receiving a cryptic vision from their angelic guide that they still struggle to interpret"
            "when their celestial light accidentally revealed them to enemies who had hunted their bloodline for generations"
            "after their radiant power flared uncontrollably, forcing them to flee the only home they knew"
            "when they chose to follow a prophecy meant for someone else entirely"
            "after rejecting the destiny their celestial patron insisted upon"
        )

        $species = $character.Species.BaseSpecies
        $class = $character.CharacterClass.ToString()
        $speciesPart = $speciesHooks[$species]
        $classPart = $classHooks[$class]
        if (-not $speciesPart) { $speciesPart = "seeking their place in a vast world" }
        $incident = Get-Random -InputObject $incitingIncidents
        return "Born $species, $speciesPart, they became a $class $classPart $incident."
    }
}

class BackgroundFactory {
    hidden static [Type[]]$BackgroundTypes

    static BackgroundFactory() {
        [BackgroundFactory]::Initialize()
    }

    hidden static [void] Initialize() {
        $types = [Background].Assembly.GetTypes() | Where-Object { $_.IsSubClassOf([Background]) }
        [BackgroundFactory]::BackgroundTypes = $types
    }

    static [Background] CreateRandom() {
        $randomType = Get-Random -InputObject ([BackgroundFactory]::BackgroundTypes)
        return [Activator]::CreateInstance($randomType)
    }
}

class SpeciesFactory {
    hidden static [Type[]] $SpeciesTypes

    static SpeciesFactory() {
        [SpeciesFactory]::Initialize()
    }

    hidden static [void] Initialize() {
        $types = [Humanoid].Assembly.GetTypes() | Where-Object { $_.IsSubClassOf([Humanoid]) }
        [SpeciesFactory]::SpeciesTypes = $types
    }

    static [Humanoid] CreateRandom() {
        $randomType = Get-Random -InputObject ([SpeciesFactory]::SpeciesTypes)
        return [Activator]::CreateInstance($randomType)
    }
}

class ToonFactory {

    static [DnDClass]Create() {
        $species = [SpeciesFactory]::CreateRandom()
        $background = [BackgroundFactory]::CreateRandom()
        return [DnDClassFactory]::CreateRandom($species, $background)
    }
}

class DnDClassFactory {
    hidden static [Type[]]$ClassTypes

    static DnDClassFactory() {
        [DnDClassFactory]::Initialize()
    }

    hidden static [void] Initialize() {
        $types = [DnDClass].Assembly.GetTypes() | Where-Object { $_.IsSubclassOf([DnDClass]) }
        [DnDClassFactory]::ClassTypes = $types
    }

    static [DnDClass] CreateRandom([Humanoid]$species, [Background]$background) {
        $randomType = Get-Random -InputObject ([DnDClassFactory]::ClassTypes)
        return [Activator]::CreateInstance($randomType, [object[]]@($species, $background))
    }
}

class NameFactory {
    static [hashtable]$NameData = $null

    static [string] GetName([Humanoid]$species) {
        if ($null -eq [NameFactory]::NameData) {
            $path = Join-Path $PSScriptRoot "Names.json"
            if (Test-Path $path) {
                $json = Get-Content $path -Raw | ConvertFrom-Json
                [NameFactory]::NameData = @{}
                foreach ($prop in $json.PSObject.Properties) {
                    [NameFactory]::NameData[$prop.Name] = $prop.Value
                }
            } else {
                return "Error: Name.json Missing"
            }
        }
        $data = [NameFactory]::NameData[$species.BaseSpecies]
        if (-not $data) {
            $data = [NameFactory]::NameData["Human"]
        }
        $pattern = Get-Random $data.Patterns
        $parts = @{
            'P' = Get-Random $data.Prefix
            'M' = Get-Random $data.Middle
            'S' = Get-Random $data.Suffix
        }
        $name = $pattern
        foreach ($key in $parts.Keys) {
            $name = $name.Replace($key, $parts[$key])
        }
        $cleanName = $name.Replace("+", "").ToLower()
        return (Get-Culture).TextInfo.ToTitleCase($cleanName)
    }
}


class Humanoid {
    [string]$CreatureType
    [string]$BaseSpecies
    [string]$SpeciesName
    [string]$Size
    [int]$Speed
    [System.Collections.Generic.List[string]]$SpecialTraits

    Humanoid() {
        $this.SpecialTraits = [System.Collections.Generic.List[string]]::New()
        $this.CreatureType = "Humanoid"
        $this.BaseSpecies = $this.GetType().Name
    }
}

class Aasimar : Humanoid {
    Aasimar() {
        $this.Size = "Medium"
        $this.SpeciesName = 'Aasimar'
        $this.Speed = 30
        $this.SpecialTraits.Add("Celestial Resistance")
        $this.SpecialTraits.Add("Darkvision")
        $this.SpecialTraits.Add("Healing Hands")
        $this.SpecialTraits.Add("Light Bearer")
    }
}

class Dragonborn : Humanoid {
    Dragonborn() {
        $this.SpeciesName = 'Dragonborn'
        $this.Size = "Medium"
        $this.Speed = 30
        $this.SpecialTraits.Add("Draconic Ancestry")
        $this.SpecialTraits.Add("Breath Weapon")
        $this.SpecialTraits.Add("Damage Resistance")
        $this.SpecialTraits.Add("Darkvision")
    }
}

class Dwarf : Humanoid {
    Dwarf() {
        $this.SpeciesName = 'Dwarf'
        $this.Size = "Medium"
        $this.Speed = 30
        $this.SpecialTraits.Add("Darkvision")
        $this.SpecialTraits.Add("Dwarven Resilience")
        $this.SpecialTraits.Add("Dwarven Toughness")
        $this.SpecialTraits.Add("Stonecunning")
    }
}

class Elf : Humanoid {
    Elf() {
        $elfTypes = @('Drow', 'High Elf', 'Wood Elf')
        $type = Get-Random -InputObject $elfTypes
        $this.SpeciesName = $type
        $this.Size = "Medium"
        $this.Speed = 30
        $this.SpecialTraits.Add("Fey Ancestry")
        $this.SpecialTraits.Add("Keen Senses")
        $this.SpecialTraits.Add("Trance")
        switch ($type) {
            'Drow' {
                $this.SpecialTraits.Add("Prestidigitation")
                break;
            }
            'High Elf' {
                $this.SpecialTraits.Add("Elven Lineage: Prestidigitation")
                break;
            }
            'Wood Elf' {
                $this.Speed = 35
                $this.SpecialTraits.Add("Elven Lineage: Druidcraft")
                break;
            }
        }
    }
}

class Gnome : Humanoid {
    Gnome() {
        $gnomeTypes = @("Forest Gnome", "Rock Gnome")
        $type = Get-Random -InputObject $gnomeTypes
        $this.SpeciesName = $type
        $this.Size = "Small"
        $this.Speed = 30
        $this.SpecialTraits.Add("Darkvision")
        $this.SpecialTraits.Add("Gnomish Cunning")
        $this.SpecialTraits.Add("Gnomish Lineage")
        switch ($type) {
            'Forest Gnome' {
                $this.SpecialTraits.Add("Minor Illusion")
                $this.SpecialTraits.Add("Speak with Animals (prepared)")
                break;
            }
            'Rock Gnome' {
                $this.SpecialTraits.Add("Mending")
                $this.SpecialTraits.Add("Prestidigitation")
                $this.SpecialTraits.Add("Tiny Clockwork Device")
                break;
            }
        }

    }
}

class Goliath : Humanoid {
    Goliath() {
        $goliathTypes = @("Cloud", "Fire", "Frost", "Hill", "Stone", "Storm")
        $type = (Get-Random -InputObject $goliathTypes)
        $this.SpeciesName = $type + " " + "Goliath"
        $this.Size = "Medium"
        $this.Speed = 35
        $this.SpecialTraits.Add("Giant Ancestry")
        $this.SpecialTraits.Add("Powerful Build")
        switch ($type) {
            'Cloud' {
                $this.SpecialTraits.Add("Cloud's Jaunt")
                break;
            }
            'Fire' {
                $this.SpecialTraits.Add("Fire's Burn")
                break;
            }
            'Frost' {
                $this.SpecialTraits.Add("Frost's Chill")
                break;
            }
            'Hill' {
                $this.SpecialTraits.Add("Hill's Tumble")
                break;
            }
            'Stone' {
                $this.SpecialTraits.Add("Stone's Endurance")
                break;
            }
            'Storm' {
                $this.SpecialTraits.Add("Storm's Thunder")
                break;
            }
        }
    }
}

class Halfling : Humanoid {
    Halfling() {
        $this.SpeciesName = 'Halfling'
        $this.Size = "Small"
        $this.Speed = 30
        $this.SpecialTraits.Add("Brave")
        $this.SpecialTraits.Add("Halfling Nimbleness")
        $this.SpecialTraits.Add("Luck")
        $this.SpecialTraits.Add("Naturally Stealthy")
    }
}

class Human : Humanoid {
    Human() {
        $this.SpeciesName = 'Human'
        $this.Size = "Medium"
        $this.Speed = 30
        $this.SpecialTraits.Add("Resourceful")
        $this.SpecialTraits.Add("Skillful")
        $this.SpecialTraits.Add("Versatile")
    }
}

class Orc : Humanoid {
    Orc() {
        $this.SpeciesName = 'Orc'
        $this.Size = "Medium"
        $this.Speed = 30
        $this.SpecialTraits.Add("Adrenaline Rush")
        $this.SpecialTraits.Add("Darkvision")
        $this.SpecialTraits.Add("Relentless Endurance")
    }
}

class Tiefling : Humanoid {
    Tiefling() {
        $TieflingTypes = @("Abyssal", "Chthonic", "Infernal")
        $type = Get-Random -InputObject $TieflingTypes
        $this.SpeciesName = $type + ' Tiefling'
        $this.Size = "Medium"
        $this.Speed = 30
        $this.SpecialTraits.Add("Darkvision")
        $this.SpecialTraits.Add("Otherwordly Presence: Thaumaturgy")
        switch ($type) {
            'Abyssal' {
                $this.SpecialTraits.Add("Resistance: Poison")
                $this.SpecialTraits.Add("Poison Spray")
                break;
            }
            'Chthonic' {
                $this.SpecialTraits.Add("Resistance: Necrotic")
                $this.SpecialTraits.Add("Chill Touch")
                break;
            }
            'Infernal' {
                $this.SpecialTraits.Add("Resistance: Fire")
                $this.SpecialTraits.Add("Fire Bolt")
                break;
            }
        }

    }
}

class Background {
    [string]$Name
    [string]$Feat
    [System.Collections.Generic.List[string]]$AbilityScores
    [System.Collections.Generic.List[string]]$SkillProficiencies
    [System.Collections.Generic.List[string]]$ToolProficiencies
    [System.Collections.Generic.List[string]]$Equipment

    Background() {
        $this.Name = $this.GetType().Name
        $this.AbilityScores = [System.Collections.Generic.List[string]]::New()
        $this.SkillProficiencies = [System.Collections.Generic.List[string]]::New()
        $this.ToolProficiencies = [System.Collections.Generic.List[string]]::New()
        $this.Equipment = [System.Collections.Generic.List[string]]::New()
    }
}

class Acolyte : Background {
    Acolyte() {
        $this.AbilityScores.Add("Intelligence")
        $this.AbilityScores.Add("Wisdom")
        $this.AbilityScores.Add("Charisma")
        $this.Feat = 'Magic Initiate'
        $this.SkillProficiencies.Add("Insight")
        $this.SkillProficiencies.Add("Religion")
        $this.ToolProficiencies.Add("Calligrapher's Supplies")
        $this.Equipment.Add("Calligrapher's Supplies")
        $this.Equipment.Add("Book (prayers)")
        $this.Equipment.Add("Holy Symbol")
        $this.Equipment.Add("Parchment (10 sheets)")
        $this.Equipment.Add("Robe")
        $this.Equipment.Add("8GP")
    }
}

class Artisan : Background {
    Artisan() {
        $types = @("Alchemist's", "Brwer's", "Calligrapher's", "Carpenter's", "Cartographer's", "Cobbler's", "Cook's", "Glassblower's", "Jeweler's", "Leatherworker's", "Mason's", "Painter's", "Potter's", "Smith's", "Tinker's", "Weaver's", "Woodcarver's")
        $type = Get-Random -InputObject $types
        $this.AbilityScores.Add("Strength")
        $this.AbilityScores.Add("Dexterity")
        $this.AbilityScores.Add("Intelligence")
        $this.Feat = 'Crafter'
        $this.SkillProficiencies.Add("Investigation")
        $this.SkillProficiencies.Add("Persuasion")
        $this.ToolProficiencies.Add("$type Tools")
        $this.Equipment.Add("$type Tools")
        $this.Equipment.Add("Pouches (2)")
        $this.Equipment.Add("Traveler's Clothes")
        $this.Equipment.Add("32GP")
    }
}

class Charlatan : Background {
    Charlatan() {
        $this.AbilityScores.Add("Dexterity")
        $this.AbilityScores.Add("Constitution")
        $this.AbilityScores.Add("Charisma")
        $this.Feat = 'Skilled'
        $this.SkillProficiencies.Add("Deception")
        $this.SkillProficiencies.Add("Sleight of Hand")
        $this.ToolProficiencies.Add("Forgery Kit")
        $this.Equipment.Add("Forgery Kit")
        $this.Equipment.Add("Costume")
        $this.Equipment.Add("Fine Clothes")
        $this.Equipment.Add("15GP")
    }
}

class Criminal : Background {
    Criminal() {
        $this.AbilityScores.Add("Dexterity")
        $this.AbilityScores.Add("Constitution")
        $this.AbilityScores.Add("Intelligence")
        $this.Feat = 'Alert'
        $this.SkillProficiencies.Add("Sleight of Hand")
        $this.SkillProficiencies.Add("Stealth")
        $this.ToolProficiencies.Add("Thieves' Tools")
        $this.Equipment.Add("Daggers (2)")
        $this.Equipment.Add("Thieves' Tools")
        $this.Equipment.Add("Crowbar")
        $this.Equipment.Add("Pouches (2)")
        $this.Equipment.Add("Traveler's Clothes")
        $this.Equipment.Add("16GP")
    }
}

class Entertainer : Background {
    Entertainer() {
        $instruments = @("bagpipes", "drum", "dulcimer", "flute", "horn", "lute", "lyre", "pan flute", "shawm", "viol")
        $instrument = Get-Random -InputObject $instruments
        $this.AbilityScores.Add("Strength")
        $this.AbilityScores.Add("Dexterity")
        $this.AbilityScores.Add("Charisma")
        $this.Feat = 'Musician'
        $this.SkillProficiencies.Add("Acrobatics")
        $this.SkillProficiencies.Add("Performance")
        $this.ToolProficiencies.Add($instrument)
        $this.Equipment.Add($instrument)
        $this.Equipment.Add("Costumes (2)")
        $this.Equipment.Add("Mirror")
        $this.Equipment.Add("Perfume")
        $this.Equipment.Add("Traveler's Clothes")
        $this.Equipment.Add("11GP")
    }
}

class Farmer : Background {
    Farmer() {
        $this.AbilityScores.Add("Strength")
        $this.AbilityScores.Add("Constitution")
        $this.AbilityScores.Add("Wisdom")
        $this.Feat = 'Tough'
        $this.SkillProficiencies.Add("Animal Handling")
        $this.SkillProficiencies.Add("Nature")
        $this.ToolProficiencies.Add("Carpenter's Tools")
        $this.Equipment.Add("Sickle")
        $this.Equipment.Add("Carpenter's Tools")
        $this.Equipment.Add("Healer's Kit")
        $this.Equipment.Add("Iron Pot")
        $this.Equipment.Add("Shovel")
        $this.Equipment.Add("Traveler's Clothes")
        $this.Equipment.Add("30GP")
    }
}

class Guard : Background {
    Guard() {
        $gamingSets = [enum]::GetValues([GamingSets])
        $gamingSet = Get-Random -InputObject $gamingSets
        $this.AbilityScores.Add("Strength")
        $this.AbilityScores.Add("Intelligence")
        $this.AbilityScores.Add("Wisdom")
        $this.Feat = 'Alert'
        $this.SkillProficiencies.Add("Athletics")
        $this.SkillProficiencies.Add("Perception")
        $this.ToolProficiencies.Add($gamingSet)
        $this.Equipment.Add($gamingSet)
        $this.Equipment.Add("Spear")
        $this.Equipment.Add("Light Crossbow")
        $this.Equipment.Add("Bolts (20)")
        $this.Equipment.Add("Hooded Lantern")
        $this.Equipment.Add("Manacles")
        $this.Equipment.Add("Quiver")
        $this.Equipment.Add("Traveler's Clothes")
        $this.Equipment.Add("12GP")
    }
}

class Guide : Background {
    Guide() {
        $this.AbilityScores.Add("Dexterity")
        $this.AbilityScores.Add("Constitution")
        $this.AbilityScores.Add("Wisdom")
        $this.Feat = 'Magic Initiate'
        $this.SkillProficiencies.Add("Stealth")
        $this.SkillProficiencies.Add("Survival")
        $this.ToolProficiencies.Add("Cartographer's Tools")
        $this.Equipment.Add("Cartographer's Tools")
        $this.Equipment.Add("Shortbow")
        $this.Equipment.Add("Arrows (20)")
        $this.Equipment.Add("Bedroll")
        $this.Equipment.Add("Quiver")
        $this.Equipment.Add("Tent")
        $this.Equipment.Add("Traveler's Clothes")
        $this.Equipment.Add("3GP")
    }
}

class Hermit : Background {
    Hermit() {
        $this.AbilityScores.Add("Constitution")
        $this.AbilityScores.Add("Wisdom")
        $this.AbilityScores.Add("Charisma")
        $this.Feat = 'Healer'
        $this.SkillProficiencies.Add("Medicine")
        $this.SkillProficiencies.Add("Religion")
        $this.ToolProficiencies.Add("Herbalism Kit")
        $this.Equipment.Add("Herbalism Kit")
        $this.Equipment.Add("Quarterstaff")
        $this.Equipment.Add("Bedroll")
        $this.Equipment.Add("Book (philosophy)")
        $this.Equipment.Add("Lamp")
        $this.Equipment.Add("Oil (3 flasks)")
        $this.Equipment.Add("Traveler's Clothes")
        $this.Equipment.Add("16GP")
    }
}

class Merchant : Background {
    Merchant() {
        $this.AbilityScores.Add("Constitution")
        $this.AbilityScores.Add("Intelligence")
        $this.AbilityScores.Add("Charisma")
        $this.Feat = 'Lucky'
        $this.SkillProficiencies.Add("Animal Handling")
        $this.SkillProficiencies.Add("Persuasion")
        $this.ToolProficiencies.Add("Navigator's Tools")
        $this.Equipment.Add("Navigator's Tools")
        $this.Equipment.Add("Pouches (2)")
        $this.Equipment.Add("Traveler's Clothes")
        $this.Equipment.Add("22GP")
    }
}

class Noble : Background {
    Noble() {
        $gamingSets = [enum]::GetValues([GamingSets])
        $gamingSet = Get-Random -InputObject $gamingSets
        $this.AbilityScores.Add("Strength")
        $this.AbilityScores.Add("Intelligence")
        $this.AbilityScores.Add("Charisma")
        $this.Feat = 'Skilled'
        $this.SkillProficiencies.Add("History")
        $this.SkillProficiencies.Add("Persuasion")
        $this.ToolProficiencies.Add($gamingSet)
        $this.Equipment.Add($gamingSet)
        $this.Equipment.Add("Perfume")
        $this.Equipment.Add("Fine Clothes")
        $this.Equipment.Add("29GP")
    }
}

class Sage : Background {
    Sage() {
        $this.AbilityScores.Add("Constitution")
        $this.AbilityScores.Add("Intelligence")
        $this.AbilityScores.Add("Wisdom")
        $this.Feat = 'Magic Initiate'
        $this.SkillProficiencies.Add("Arcana")
        $this.SkillProficiencies.Add("History")
        $this.ToolProficiencies.Add("Calligrapher's Supplies")
        $this.Equipment.Add("Calligrapher's Supplies")
        $this.Equipment.Add("Quarterstaff")
        $this.Equipment.Add("Book (history)")
        $this.Equipment.Add("Parchment (8 sheets)")
        $this.Equipment.Add("Robe")
        $this.Equipment.Add("8GP")
    }
}

class Sailor : Background {
    Sailor() {
        $this.AbilityScores.Add("Strength")
        $this.AbilityScores.Add("Dexterity")
        $this.AbilityScores.Add("Wisdom")
        $this.Feat = 'Tavern Brawler'
        $this.SkillProficiencies.Add("Acrobatics")
        $this.SkillProficiencies.Add("Perception")
        $this.ToolProficiencies.Add("Navigator's Tools")
        $this.Equipment.Add("Navigator's Tools")
        $this.Equipment.Add("Dagger")
        $this.Equipment.Add("Rope")
        $this.Equipment.Add("Traveler's Cloths")
        $this.Equipment.Add("20GP")
    }
}

class Scribe : Background {
    Scribe() {
        $this.AbilityScores.Add("Dexterity")
        $this.AbilityScores.Add("Intelligence")
        $this.AbilityScores.Add("Wisdom")
        $this.Feat = 'Skilled'
        $this.SkillProficiencies.Add("Investigation")
        $this.SkillProficiencies.Add("Perception")
        $this.ToolProficiencies.Add("Calligrapher's Supplies")
        $this.Equipment.Add("Calligrapher's Supplies")
        $this.Equipment.Add("Fine Clothes")
        $this.Equipment.Add("Lamp")
        $this.Equipment.Add("Oil (3 flasks)")
        $this.Equipment.Add("Parchment (12 sheets)")
        $this.Equipment.Add("23GP")
    }
}

class Soldier : Background {
    Soldier() {
        $gamingSets = [enum]::GetValues([GamingSets])
        $gamingSet = Get-Random -InputObject $gamingSets
        $this.AbilityScores.Add("Strength")
        $this.AbilityScores.Add("Dexterity")
        $this.AbilityScores.Add("Constitution")
        $this.Feat = 'Savage Attacker'
        $this.SkillProficiencies.Add("Athletics")
        $this.SkillProficiencies.Add("Intimidation")
        $this.ToolProficiencies.Add($gamingSet)
        $this.Equipment.Add($gamingSet)
        $this.Equipment.Add("Spear")
        $this.Equipment.Add("Shortbow")
        $this.Equipment.Add("Arrows (20)")
        $this.Equipment.Add("Healer's Kit")
        $this.Equipment.Add("Traveler's Clothes")
        $this.Equipment.Add("14GP")
    }
}

class Wayfarer : Background {
    Wayfarer() {
        $gamingSets = [enum]::GetValues([GamingSets])
        $gamingSet = Get-Random -InputObject $gamingSets
        $this.AbilityScores.Add("Dexterity")
        $this.AbilityScores.Add("Wisdom")
        $this.AbilityScores.Add("Charisma")
        $this.Feat = 'Lucky'
        $this.SkillProficiencies.Add("Insight")
        $this.SkillProficiencies.Add("Stealth")
        $this.ToolProficiencies.Add("Thieves' Tools")
        $this.Equipment.Add("Thieves' Tools")
        $this.Equipment.Add("Daggers (2)")
        $this.Equipment.Add($gamingSet)
        $this.Equipment.Add("Bedroll")
        $this.Equipment.Add("Pouches (2)")
        $this.Equipment.Add("Traveler's Clothes")
        $this.Equipment.Add("16GP")
    }
}
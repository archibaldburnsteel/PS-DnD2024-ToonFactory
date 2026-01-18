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
$Script:Rng = [Random]::new()
$Script:HumanoidTypes = ([Humanoid].Assembly.GetTypes()).Where({ $_.IsSubClassOf([Humanoid]) })
$Script:BackgroundTypes = ([Background].Assembly.GetTypes()).Where({ $_.IsSubclassOf([Background]) })
$Script:ClassTypes = ([DnDClass].Assembly.GetTypes()).Where({ $_.IsSubclassOf([DnDClass]) })
$Script:AllSkillNames = [Skill]::SkillLookup.Keys
$Script:BaseStats = [string[]]('Strength', 'Dexterity', 'Constitution', 'Intelligence', 'Wisdom', 'Charisma')
$languages = [enum]::GetValues([Languages])
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

Class Wallet {
    [int] hidden $GoldPieces

    Wallet() {
        $this.GoldPieces = 0
    }

    Wallet([int]$initialDeposit) {
        if ($initialDeposit -lt 0) {
            throw [System.ArgumentOutOfRangeException]::New("value cant be negative")
        }
        $this.GoldPieces = $initialDeposit
    }

    [int]GetBalance() {
        return $this.GoldPieces
    }

    [string] ToString() {
        return ($this.GoldPieces.ToString() + " GP")
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
        switch ($abilityName) {
            "Strength" { $this.Ability = $character.Strength }
            "Dexterity" { $this.Ability = $character.Dexterity }
            "Constitution" { $this.Ability = $character.Constitution }
            "Intelligence" { $this.Ability = $character.Intelligence }
            "Wisdom" { $this.Ability = $character.Wisdom }
            "Charisma" { $this.Ability = $character.Charisma }
        }
        $this.Proficient = $character.SkillProficiencies.Contains($name)
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
    [System.Collections.Generic.HashSet[string]]$SkillProficiencies = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
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
    [Wallet]$Gold

    DnDClass() {
        $this.CharacterClass = $this.GetType().Name
        $this.Proficiency = 2
        $this.SavingThrowProficiencies = [System.Collections.Generic.List[string]]::New()
        $this.SkillProficiencies = [System.Collections.Generic.List[string]]::New()
        $this.WeaponProficiencies = [System.Collections.Generic.List[string]]::New()
        $this.ArmorTraining = [System.Collections.Generic.List[string]]::New()
        $this.ClassFeatures = [System.Collections.Generic.List[string]]::New()
        $this.KnownLanguages = [System.Collections.Generic.List[string]]::New()
        $this.StartingEquipment = [System.Collections.Generic.List[string]]::New()
        $count = $Script:languages.Count
        $SelectedIndices = New-Object System.Collections.Generic.HashSet[int]
        while ($SelectedIndices.Count -lt 3) {
            [void]$SelectedIndices.Add($Script:Rng.Next(0, $count))
        }
        foreach ($index in $SelectedIndices) {
            $this.KnownLanguages.Add($Script:languages[$index].ToString())
        }
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
        $this.StartingEquipment = [System.Collections.Generic.List[string]]::New()
        $this.Skills = @{}
        $count = $Script:languages.Count
        $SelectedIndices = New-Object System.Collections.Generic.HashSet[int]
        while ($SelectedIndices.Count -lt 3) {
            [void]$SelectedIndices.Add($Script:Rng.Next(0, $count))
        }
        foreach ($index in $SelectedIndices) {
            $this.KnownLanguages.Add($Script:languages[$index].ToString())
        }
        $this.BuildSkills()
    }

    [int] RollStats() {
        $Script:Rng = [Random]::new()
        $Sum = 0
        $Min = 7
        for ($i = 0; $i -lt 4; $i++) {
            $CurrentRoll = $Script:Rng.Next(1, 7)
            $Sum += $CurrentRoll
            if ($CurrentRoll -lt $Min) { $Min = $CurrentRoll }
        }
        return $Sum - $Min
    }

    [int] GetTotalAbilityScores() {
        return ($this.Strength.Score + $this.Dexterity.Score + $this.Constitution.Score + $this.Intelligence.Score + $this.Wisdom.Score + $this.Charisma.Score)
    }

    BuildSkills() {
        foreach ($name in $Script:AllSkillNames) {
            $this.Skills[$name] = [Skill]::new($name, $this)
        }
    }

    hidden [void] GenerateOptimizedStats() {
        $pool = [int[]]::new(6)
        for ($i = 0; $i -lt 6; $i++) {
            $pool[$i] = $this.RollStats()
        }
        [Array]::Sort($pool)
        [Array]::Reverse($pool)
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
        $remainingStats = $Script:BaseStats.Where({ $_ -ne $this.PrimaryAbility -and $_ -ne 'Constitution' })
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
                      $([string]::Join(", ", $this.StartingEquipment))
  Special Traits:     $([string]::Join(", ", $this.Species.SpecialTraits))

Origin:
$($this.OriginStory)

Gold:
$($this.Gold.ToString())
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
        $skillPool = @("Animal Handling", "Athletics", "Intimidation", "Nature", "Perception", "Survival")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Medium", "Shields"))
        $this.ClassFeatures.AddRange([string[]]("Rage", "Unarmored Defense", "Weapon Mastery"))
        $this.StartingEquipment.AddRange([string[]]("Greataxe", "Handaxe (4)", "Explorer's Pack"))
        $this.Gold = [Wallet]::New($background.Gold + 15)
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
        $skillPool = @("Acrobatics", "Animal Handling", "Arcana", "Athletics", "Deception", "History", "Insight", "Intimidation", "Investigation", "Medicine", "Nature", "Perception", "Performance", "Persuasion", "Religion", "Sleight Of Hand", "Stealth", "Survival")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.Add("Simple")
        $this.ArmorTraining.Add("Light")
        $this.ClassFeatures.AddRange([string[]]("Bardic Inspiration", "Spellcasting"))
        $this.BuildSkills()
        $this.StartingEquipment.AddRange([string[]]("Leather Armor", "Daggers (2)", "Lyre", "Entertainer's Pack"))
        $this.Gold = [Wallet]::New($background.Gold + 19)
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
        $skillPool = @("History", "Insight", "Medicine", "Persuasion", "Religion")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Medium", "Shields"))
        $choices = @("Protector", "Thamaturge")
        $DivineOrder = $choices
        $this.ClassFeatures.AddRange([string[]]("Spellcasting", $DivineOrder))
        $this.BuildSkills()
        $this.StartingEquipment.AddRange([string[]]("Chain Shirt", "Shield", "Mace", "Holy Symbol", "Priest's Pack"))
        $this.Gold = [Wallet]::New($background.Gold + 7)
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
        $skillPool = @("Animal Handling", "Arcana", "Insight", "Medicine", "Nature", "Perception", "Religion", "Survival")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Shields"))
        $choice = @("Magician", "Warden")
        $primalOrder = Get-Random -InputObject $choice
        $this.ClassFeatures.AddRange([string[]]("Spellcasting", "Druidic", $primalOrder))
        $this.BuildSkills()
        $this.StartingEquipment.AddRange([string[]]("Leather Armor", "Shield", "Sickle", "Druidic Focus (Quarterstaff)", "Explorer's Pack", "Herbalizm Kit"))
        $this.Gold = [Wallet]::New($background.Gold + 9)
    }
}

Class Fighter : DnDClass {

    Fighter([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.Gold = [Wallet]::New($background.Gold)
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
        $skillpool = @("Acrobatics", "Animal Handling", "Athletics", "History", "Insight", "Intimidation", "Persuasion", "Perception", "Survival")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Medium", "Heavy", "Shields"))
        $choice = @("Archery", "Blind Fighting", "Defense", "Dueling", "Great Weapon", "Interception", "Protection", "Thrown Weapon", "Two-Weapon", "Unarmed")
        $FightingSyle = Get-Random -InputObject $choice
        $this.ClassFeatures.AddRange([string[]]("Second Wind", "Weapon Mastery", $FightingSyle))
        if ($this.PrimaryAbility -eq 'Strength') {
            $this.StartingEquipment.AddRange([string[]]("Chain Mail", "Greatsword", "Flail", "Javelins (8)", "Dungeoneer's Pack"))
            $this.Gold = [Wallet]::New($background.Gold + 4)
        } else {
            $this.StartingEquipment.AddRange([string[]]("Studded Leather Armor", "Scimitar", "Shortsword", "Longbow", "Arrows (20)", "Quiver", "Dungeoneer's Pack"))
            $this.Gold = [Wallet]::New($background.Gold + 11)
        }
        $this.BuildSkills()
    }
}

Class Monk : DnDClass {

    Monk([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.Gold = [Wallet]::New($background.Gold)
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
        $skillPool = @("Acrobatics", "Athletics", "History", "Insight", "Religion", "Stealth")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("None"))
        $this.ClassFeatures.AddRange([string[]]("Martial Arts", "Unarmored Defense"))
        $this.StartingEquipment.AddRange([string[]]("Spear", "Dagger (5)", "Artisan's Tools", "Explorer's Pack"))
        $this.Gold = [Wallet]::New($background.Gold + 11)
        $this.BuildSkills()
    }
}

Class Paladin : DnDClass {

    Paladin([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.Gold = [Wallet]::New($background.Gold)
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
        $skillPool = @("Athletics", "Insight", "Intimidation", "Medicine", "Persuasion", "Religion")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Medium", "Heavy", "Shields"))
        $this.ClassFeatures.AddRange([string[]]("Lay On Hands", "Spellcasting", "Weapon Mastery"))
        $this.StartingEquipment.AddRange([string[]]("Chain Mail", "Shield", "Longsword", "Javelins (6)", "Priest's Pack", "Holy Symbol"))
        $this.Gold = [Wallet]::New($background.Gold + 9)
        $this.BuildSkills()
    }
}

Class Ranger : DnDClass {

    Ranger([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.Gold = [Wallet]::New($background.Gold)
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
        $skillPool = @("Animal Handling", "Athletics", "Insight", "Investigation", "Nature", "Perception", "Stealth", "Survival")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("Light", "Medium", "Shields"))
        $this.ClassFeatures.AddRange([string[]]("Spellcasting", "Favored Enemy", "Weapon Mastery"))
        $this.StartingEquipment.AddRange([string[]]("Studded Leather Armor", "Scimitar", "Shortsword", "Longbow", "Arrows (20)", "Quiver", "Druidic Focus (sprig of mistletoe)", "Explorer's Pack"))
        $this.Gold = [Wallet]::New($background.Gold + 7)
        $this.BuildSkills()
    }
}

Class Rogue : DnDClass {

    Rogue([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.Gold = [Wallet]::New($background.Gold)
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
        $skillPool = @("Acrobatics", "Athletics", "Deception", "Insight", "Intimidation", "Investigation", "Perception", "Persuasion", "Sleight of Hand", "Stealth")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple", "Martial"))
        $this.ArmorTraining.AddRange([string[]]("Light"))
        $this.ClassFeatures.AddRange([string[]]("Expertise", "Sneak Attack", "Weapon Mastery", "Thieves' Cant"))
        $this.StartingEquipment.AddRange([string[]]("Leather Armor", "Daggers (2)", "Shortsword", "Shortbow", "Arrows (20)", "Quiver", "Thieves' Tools", "Burglar's Pack"))
        $this.Gold = [Wallet]::New($background.Gold + 8)
        $this.BuildSkills()
    }
}

Class Sorcerer : DnDClass {

    Sorcerer([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.Gold = [Wallet]::New($background.Gold)
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
        $skillPool = @("Arcana", "Deception", "Insight", "Intimidation", "Persuasion", "Religion")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple"))
        $this.ArmorTraining.AddRange([string[]]("None"))
        $this.ClassFeatures.AddRange([string[]]("Spellcasting", "Innate Sorcery"))
        $this.StartingEquipment.AddRange([string[]]("Spear", "Daggers(2)", "Arcane Focus (crystal)", "Dungeoneer's Pack"))
        $this.Gold = [Wallet]::New($background.Gold + 28)
        $this.BuildSkills()
    }
}

Class Warlock : DnDClass {

    Warlock([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.Gold = [Wallet]::New($background.Gold)
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
        $skillPool = @("Arcana", "Deception", "History", "Intimidation", "Investigation", "Nature", "Religion")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple"))
        $this.ArmorTraining.AddRange([string[]]("Light"))
        $this.ClassFeatures.AddRange([string[]]("Eldrith Invocations", "Pact Magic"))
        $this.StartingEquipment.AddRange([string[]]("Leather Armor", "Sickle", "Daggers (2)", "Arcane Focus (orb)", "Book (occult lore)", "Scholar's Pack"))
        $this.Gold = [Wallet]::New($background.Gold + 15)
        $this.BuildSkills()
    }
}

Class Wizard : DnDClass {

    Wizard([Humanoid]$species, [Background]$background) : base() {
        $this.Species = $species
        $this.BackGround = $background
        $this.Gold = [Wallet]::New($background.Gold)
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
        $skillPool = @("Arcana", "History", "Insight", "Investigation", "Medicine", "Nature", "Religion")
        $available = $skillPool.Where({ -not $this.BackGround.SkillProficiencies.Contains($_) })
        $count = $available.Count
        if ($count -ge 2) {
            $idx1 = $Script:Rng.Next(0, $count)
            do { $idx2 = $Script:Rng.Next(0, $count) } while ($idx2 -eq $idx1)
            [void]$this.SkillProficiencies.Add($available[$idx1])
            [void]$this.SkillProficiencies.Add($available[$idx2])
        }
        $this.SkillProficiencies.UnionWith($this.BackGround.SkillProficiencies)
        $this.WeaponProficiencies.AddRange([string[]]("Simple"))
        $this.ArmorTraining.AddRange([string[]]("None"))
        $this.ClassFeatures.AddRange([string[]]("Spellcasting", "Ritual Adept", "Arcane Recovery"))
        $this.StartingEquipment.AddRange([string[]]("Daggers(2)", "Arcane Focus (Quarterstaff)", "Robe", "Spellbook", "Scholar's Pack"))
        $this.Gold = [Wallet]::New($background.Gold + 28)
        $this.BuildSkills()
    }
}
class StoryFactory {
    static [hashtable]$StoryData = $null

    static [string] GetOriginStory([DnDClass]$character) {
        if ($null -eq [StoryFactory]::StoryData ) {
            $storypath = Join-Path $PSScriptRoot "story.json"
            if (Test-Path $storypath) {
                $raw = Get-Content $storypath -Raw
                $parsed = $raw | ConvertFrom-Json -AsHashtable
                $cleanTable = [hashtable]::New()
                foreach ($k in $parsed.Keys) {
                    $cleanKey = $k.ToString().Trim()
                    $cleanTable[$cleanKey] = $parsed[$k]
                }
                [StoryFactory]::StoryData = $cleanTable
            } else {
                return "Error: story.json Missing"
            }
        }
        $stdata = [StoryFactory]::StoryData
        $species = $character.Species.BaseSpecies
        $class = $character.CharacterClass.ToString()
        $speciesPart = $stdata["speciesHooks"][$species]
        $classPart = $stdata["classHooks"][$class]
        if (-not $speciesPart) { $speciesPart = "seeking their place in a vast world" }
        $incident = [StoryFactory]::StoryData.incitingIncidents[$Script:Rng.Next(0, [StoryFactory]::StoryData.incitingIncidents.Count)]
        return "Born $species, $speciesPart, they became a $class $classPart $incident."
    }
}

class BackgroundFactory {
    hidden static [Type[]]$BackgroundTypes

    static BackgroundFactory() {
        [BackgroundFactory]::Initialize()
    }

    hidden static [void] Initialize() {
        [BackgroundFactory]::BackgroundTypes = $Script:BackgroundTypes
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
        [SpeciesFactory]::SpeciesTypes = $Script:HumanoidTypes
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
        [DnDClassFactory]::ClassTypes = $Script:ClassTypes
    }

    static [DnDClass] CreateRandom([Humanoid]$species, [Background]$background) {
        $randomType = Get-Random -InputObject $Script:ClassTypes #([DnDClassFactory]::ClassTypes)
        return [Activator]::CreateInstance($randomType, [object[]]@($species, $background))
    }
}

class NameFactory {
    static [hashtable]$NameData = $null

    static [string] GetName([Humanoid]$species) {
        if ($null -eq [NameFactory]::NameData) {
            $namepath = Join-Path $PSScriptRoot "Names.json"
            if (Test-Path $namepath) {
                $raw = Get-Content $namepath -Raw
                $parsed = $raw | ConvertFrom-Json -AsHashtable
                $clean = [hashtable]::New()
                foreach ($key in $parsed.Keys) {
                    $clean[$key.ToString().Trim()] = $parsed[$key]
                }
                [NameFactory]::NameData = $clean
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
    [int]$Gold

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
        $this.Gold = 8
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
        $this.Gold = 32
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
        $this.Gold = 15
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
        $this.Gold = 16
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
        $this.Gold = 11
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
        $this.Gold = 30
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
        $this.Gold = 12
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
        $this.Gold = 3
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
        $this.Gold = 16
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
        $this.Gold = 22
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
        $this.Gold = 29
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
        $this.Gold = 8
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
        $this.Gold = 20
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
        $this.Gold = 23
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
        $this.Gold = 14
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
        $this.Gold = 16
    }
}
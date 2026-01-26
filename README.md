# PS-DnD2024-ToonFactory 

> **"I play a lot of one-shots and I found character creation to be  time consuming."**
> This is my first major PowerShell module. I'm a big DnD fan and built this to learn classes. Feedback is welcome, but please be constructive.
> This project is a PowerShell-driven character factory for the 2024 D&D ruleset. It blends strong typing, procedural generation, and narrative logic to create fully-formed heroes with unique backstories in seconds.

## 🚀 Features

### 🛠️ Strongly Typed Class System
Every subsystem—abilities, skills, species, backgrounds, and narrative hooks—is modeled using PowerShell classes. This keeps the engine modular and extensible.

### 📈 Optimization Engine
The factory doesn't just roll dice it assigns the highest rolls to:
* **Primary Ability:** Based on class requirements.
* **Constitution:** To ensure survivability from Level 1.

### 📜 Narrative StoryFactory
The `StoryFactory` weaves together Species identity, Class archetypes, and curated "Inciting Incidents" into a cohesive, three-act origin story that functions as a campaign hook.

---

## 🎭 Sample Characters

> [!TIP]
> The character below was generated entirely by the engine, including the backstory logic.

=== Exiskash ===
Species: Tiefling
Class:   Cleric
Level:   1
HP:      11
SPD:     30
Size:    Medium
Passive Perception: 21
Initiative: 10

Ability Scores: 78
      STR  +2   (14)   Save: +2
      DEX  +0   (11)   Save: +0
      CON  +3   (16)   Save: +3
      INT  -1   (9)    Save: -1
      WIS  +4   (19)   Save: +6*
      CHA  -1   (9)    Save: +1*

Skills:
  Acrobatics       +0     Insight          +6*    Performance      -1
  Animal Handling  +4     Intimidation     -1     Persuasion       -1
  Arcana           -1     Investigation    -1     Religion         +1*
  Athletics        +2     Medicine         +4     Sleight of Hand  +0
  Deception        -1     Nature           -1     Stealth          +2*
  History          +1*    Perception       +4     Survival         +4

Background: Wayfarer
  Feat:               Lucky
  Skills:             Insight, Stealth
  Tools:              Thieves' Tools
  Equipment:          Thieves' Tools, Daggers (2), dragonchess, Bedroll, Pouches (2), Traveler's Clothes
                      Chain Shirt, Shield, Mace, Holy Symbol, Priest's Pack
  Special Traits:     Darkvision, Otherwordly Presence: Thaumaturgy, Resistance: Necrotic, Chill Touch

Origin:
Born Tiefling, marked by a heritage they did not choose and a world that rarely lets them forget it, they became a Cleric who heard a whisper in the dark and chose to answer after their radiant power flared uncontrollably, forcing them to flee the only home they knew.

Gold:
23 GP
---

## 💻 Installation & Usage
The easiest way to get DnDToonFactory is via the PowerShell Gallery:
```powershell
Install-Module -Name PS-DnD2024-ToonFactory -Scope CurrentUser
```
Manual Installation
If you prefer to run the source directly:
1. Clone the repo or download the module folder.
2. Import the module:

```powershell
Import-Module .\PS-DnD2024-ToonFactory.psd1

# Generate a random character
$toon = New-DnDCharacter

# Print the character sheet to the console
$toon.CharacterSheet()

# Export the Character sheet to html
$toon.ExportHtmlToFile('c:\temp\toon.html')

# PS-DnD2024-ToonFactory

> **"I play a lot of one-shots and I found character creation to be a timeconsumeing."**
> This is my first major PowerShell module. I'm a big DnD fan and built this to learn classes. Feedback is welcome, but please be constructive.
> This project is a PowerShell-driven character factory for the 2024 D&D ruleset. It blends strong typing, procedural generation, and narrative logic to create fully-formed heroes with unique backstories in seconds.

## 🚀 Features

### 🛠️ Strongly Typed Class System
Every subsystem—abilities, skills, species, backgrounds, and narrative hooks—is modeled using PowerShell classes. This keeps the engine modular and extensible.

### 📈 Optimization Engine
The factory doesn't just roll dice. Characters assign their highest rolls to:
* **Primary Ability:** Based on class requirements.
* **Constitution:** To ensure survivability from Level 1.

### 📜 Narrative StoryFactory
The `StoryFactory` weaves together Species identity, Class archetypes, and curated "Inciting Incidents" into a cohesive, three-act origin story that functions as a campaign hook.

---

## 🎭 Sample Characters

> [!TIP]
> Each character below was generated entirely by the engine, including the backstory logic.

**The Celestial Hermit**
*"Born Aasimar, born with a spark of celestial light flickering behind their eyes... they became a Cleric who heard a whisper in the dark..."*
* **Key Stats:** WIS 16 (+3), CON 14 (+2)
* **Origin Feat:** Healer

**The Reluctant Goliath**
*"Born Goliath, hazed for being the smallest of the village they ran away... they became a Barbarian whose fury was first awakened by a wound the world refused to heal..."*
* **Key Stats:** STR 17 (+3), CON 15 (+2)
* **Origin Feat:** Tough

---

## 💻 Installation & Usage

1. Clone the repo or download the module folder.
2. Import the module:

```powershell
Import-Module .\PS-DnD2024-ToonFactory.psd1

# Generate a random character
$toon = New-DnDCharacter

# Print the character sheet to the console
$toon.CharacterSheet()

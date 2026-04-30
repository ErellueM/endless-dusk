# Endless Dusk

A game for SWE lecture at DHBW Stuttgart Informatik 2025/26

# Contributors

## Teamname: Bugisoft

## Teammitglieder:
- Bayrakal Beric - Beric-61
- Wagner Timo - timopromotive
- Müller Erik - ErellueM
- Stoetter Mika - Mika1011
- Tarta Maximilian Robin - maxitaxi27
- Tillmann Felix - Sh4d0wnight

[![Godot Version](https://img.shields.io/badge/godot-4.5%2B-blue)](https://godotengine.org/)
[![License](https://img.shields.io/badge/license-Proprietary-red)](LICENSE)
[![Status](https://img.shields.io/badge/status-alpha-orange)](https://github.com/ErellueM/endless-dusk)

**Ein roguelike 2D-Auto-Battler im Pixelstil. Überlebe endlose Gegnerwellen und verbessere deine Fähigkeiten.**

> *Endless Dusk* ist ein schnelles, sücht-machendes Survival-Spiel inspiriert von *Vampire Survivors*. Spieler kämpfen gegen unendliche Wellen von Gegnern und sammeln zufällige Power-ups, um ihre Chancen zu verbessern.

---

## Zielgruppe

| Aspekt | Details |
|--------|---------|
| **Rolle** | Casual Gamer, Indie-Game-Enthusiast, Speed-Run-Spieler |
| **Fähigkeitslevel** | Anfänger bis Fortgeschrittene |
| **Kontext** | Spieler suchen nach schnellen, unterhaltsamen Sessions (5–15 Minuten) |
| **Hauptziel** | Möglichst lange überleben, höchste Punkt-Scores erreichen, neue Charaktere freischalten |

---

## Projektbeschreibung

**Endless Dusk** ist ein Roguelite-Survival-Spiel mit automatischem Kampfsystem.

Der Spieler kontrolliert einen Charakter in Top-Down-Perspektive und bewegt sich frei über die Spielkarte. Gegner spawnen kontinuierlich in Wellen mit steigender Intensität. Besiegte Gegner hinterlassen Power-ups, die den Charakter verstärken. Das Ziel: Möglichst lange überleben.

### Kernfeatures (v0.1.0-alpha)

| Feature | Details |
|---------|---------|
| ⚔️ **Automatisches Kampfsystem** | Waffen greifen automatisch an → Fokus auf Bewegung & Strategie |
| 🎮 **Vier spielbare Charaktere** | Crusader, Orc, Soldier, Wizard (jeder mit Bonus-Stats) |
| 💥 **Waffen-Arsenal** | 8–10 unterschiedliche Waffen (Axt, SMG, Blitze, etc.) |
| 📊 **Dynamisches Levelsystem** | Sammle XP, wähle aus 3 Upgrades pro Level |
| 🌊 **Wellen-basiertes Spawn** | Gegner spawnen per `EnemySpawner.gd` in realistischen Mustern |
| 🎨 **Handgemachte Pixel-Art** | Grafiken in Libresprite & Pixelorama erstellt

---

## Installation und Setup

### Systemanforderungen

- **Godot Engine** 4.5 oder neuer
- **Betriebssystem:** Windows, macOS, Linux
- **RAM:** Mindestens 2 GB
- **Speicher:** ~500 MB für Repository + Assets

### Installation

1. **Repository klonen**
   ```bash
   git clone https://github.com/ErellueM/endless-dusk.git
   cd endless-dusk
   ```

2. **Godot Engine installieren**
   - Besuche [godotengine.org](https://godotengine.org/download/)
   - Lade Version **4.5+** herunter und installiere sie

3. **Projekt öffnen**
   - Öffne Godot Engine
   - Wähle „Projekt öffnen" → Navigiere zum `endless-dusk`-Verzeichnis
   - Bestätige mit „Öffnen & Bearbeiten"

### Spiel ausführen

**Im Editor spielen:**
- Drücke **F5** oder klicke das ▶-Symbol oben rechts

**Exportieren (Standalone):**
```bash
# Für Windows
godot --export-debug Windows "endless-dusk-windows.exe"

# Für macOS
godot --export-debug "Mac OSX" "endless-dusk.zip"

# Für Linux
godot --export-debug Linux "endless-dusk"
```

---

## Getting Started – Dein erstes Spiel (5–10 Min)

### Die Spielmechanik verstehen

**In 30 Sekunden:**
- Du steuerst einen Charakter mit **WASD**
- Gegner spawnen und werden von dir automatisch bekämpft
- Besiegte Gegner geben XP & Items
- Level-Ups ermöglichen Upgrades
- Überleben = der einzige Zweck

**Erste erfolgreiche Runde:**  
Schaffe es 2+ Minuten ohne zu sterben.

---

### Schritt 1: Hier startest du (30 Sekunden)

**Startpunkt:**
- Hauptmenü öffnet sich beim Game-Start  
- Wähle einen Charakter im **CharacterSelection**-Screen aus
- Drücke „Start" → Map lädt

**Anfänger-Tipp:** Wähle **Crusader** (beste Balance)

---

### Schritt 2: Erste Gegner aktiv besiegen (1 Min)

Nachdem die Map geladen ist:

1. Bewege deinen Charakter mit **WASD** oder **Pfeiltasten**
2. Deine Waffe startet automatisch anzugreifen
3. Gehe näher an Gegner heran für schnellere Kills
4. Sammle die Items auf, die Gegner hinterlassen

**Währenddessen passiert im Spiel:**
```
EnemySpawner.gd → spawn_enemy_around_player()
├─ Gegner spawnen in zufälligem Winkel
├─ Entfernung: 150–300 Pixel
└─ Welle wird mit Zeit schwieriger
```

---

### Schritt 3: Power-Ups erkennen und sammeln (1 Min)

Besiegte Gegner lassen diese Items fallen:

| Item | Effekt | Icon |
|------|--------|------|
| 🟨 **XP-Orb** | +1–5 XP Pro Orb | Gelbe Kugel |
| 💰 **Gold** | +1–5 Punkte | Goldmünze |
| ⚔️ **Waffen-Drop** | Neue Waffe freischalten | Waffen-Symbol |

**Das ist wichtig:**
- Du musst näher als 100 Pixel an Items sein, um sie zu automatisch-sammeln (ItemMagnet)
- Gelbe XP-Orbs sind deine Priorität → füllen die Level-Leiste

---

### Schritt 4: Level-Up & Upgrade wählen (30 Sekunden)

Wenn deine XP-Leiste **100% voll** ist:

**Automatisch:**
- ⏸️ Spiel pausiert
- 3 **Upgrade-Optionen** erscheinen

**Du wählst eine aus:**
```
Option A: +15 Health
Option B: +20% Speed  
Option C: Neue Waffe
```

**In Code:**
```gdscript
# main/entities/player.gd (gain_xp implementation)
signal leveled_up

var level: int = 1
var current_xp: float = 0.0
var max_xp: float = 10.0

func gain_xp(amount: float):
   current_xp += amount * growth
   while current_xp >= max_xp:
      current_xp -= max_xp
      level += 1
      max_xp = int(max_xp * 1.2)
      pending_levelups += 1
   xp_changed.emit(current_xp, max_xp)
   check_levelups()
```

---

### Schritt 5: So lange spielen, bis du stirbst (Variable Zeit)

Das Spiel wird exponentiell schwerer:

| Minute | Gegner-Anzahl | Schwierigkeit |
|--------|---------------|---------------|
| 0–2 | ~5–10 | 🟩 Einfach |
| 2–4 | ~20–30 | 🟨 Mittel |
| 4–6 | ~50–100 | 🟠 Schwer |
| 6+ | 100+ | 🔴 Chaotisch |

**Das Spiel endet** wenn `health_component.current_health <= 0`

**Dann siehst du:**
- Deine finale **Überlebenszeit**
- Deinen **Score**
- **Statistiken** (Gegner besiegt, Schaden etc.)

---

### ✅ Erfolgs-Kriterium

Erste erfolgreiche Runde = **Überlebe 2+ Minuten ohne zu sterben**

---

## Konzept – Das Kern-Mental-Model

### "Progression durch Auto-Battle und Dezisionen"

Das Kern-Konzept von *Endless Dusk* ist elegant und einfach:

1. **Der Spieler fokussiert sich auf Timing und Position** – nicht auf Micro-Management
   - Du steuerst nur die Bewegung (WASD)
   - Deine Waffen greifen automatisch an
   - Dies reduziert Komplexität und erhöht Fokus auf Überlebensstrategien

2. **Zufällige Progression schafft unendliche Vielfalt**
   - Jedes Spiel ist anders
   - Power-ups erscheinen zufällig
   - Die "beste" Strategy ist adaptiv

3. **Einfache Regeln, unbegrenzte Komplexität**
   - Überleben = das einzige Ziel
   - Gegner werden immer stärker
   - Deine Stats wachsen exponentiell
   - Chaos vs. Meisterschaft: Je länger du spielst, desto wild wird es

**Warum funktioniert das?** Spieler lieben Progression ohne Frustration. Godot's Physics-System ermöglicht hunderte gleichzeitige Gegner. Das Pixelart-Ästhetik schafft eine niedliche und stressfreie Atmosphäre.

---

## Schritt-für-Schritt: So erhöhst du deine Chancen auf einen besseren Score

### Szenario
Du hast das Spiel gerade gestartet und möchtest länger als 5 Minuten überleben (aktuell schaffst du nur 2 Minuten).

### Lösung: Optimiere deine Upgrade-Auswahl

#### 1. **Verstehe die Upgrade-Kategorien**

Bei jedem Level-Up siehst du 3 Optionen aus diesen Kategorien:

| Kategorie | Effekt | Priorität |
|-----------|--------|-----------|
| **Health** | +10–20 Gesundheit | 🟥 Hoch (früh) |
| **Speed** | +15% Bewegungsgeschwindigkeit | 🟨 Mittel |
| **Might** | +15% Schaden | 🟩 Mittel |
| **Armor** | +5 Rüstung | 🟦 Gering (später) |
| **Recovery** | +2 Gesundheitsregeneration | 🟦 Gering (später) |

#### 2. **Early-Game Strategie (Level 1–5)**

   **Ziel:** So lange wie möglich überleben
   
   - ✅ Priorität 1: **Health-Upgrades** – Gesundheit ist dein primärer Ressource
   - ✅ Priorität 2: **Speed-Upgrades** – Schneller entkommen = weniger Schaden genommen
   - ❌ Vermeiden: Armor (zu früh irrelevant)

#### 3. **Mid-Game Strategie (Level 6–12)**

   **Ziel:** Mehr Gegner besiegen, Schaden beschleunigen
   
   - ✅ Priorität 1: **Might-Upgrades** – Schnellere Gegnervernichtung
   - ✅ Priorität 2: **Neue Waffen** – Vielfalt erhöht Chancen
   - ✅ Priorität 3: **Health** bei Bedarf

#### 4. **Late-Game Strategie (Level 13+)**

   **Ziel:** Maximale Effizienz
   
   - ✅ **Armor & Recovery** jetzt wichtig (du wirst viel getroffen)
   - ✅ **Luck-Upgrades** – Bessere Loot-Drops
   - ✅ **Area-Boni** – Größere Angriffsfläche

#### 5. **Implementierung**

Während du spielst:

```
Minuten 0–2:   Wähle HEALTH bei jedem Level-Up
Minuten 2–4:   Wechsel zu SPEED, behalt HEALTH wenn Gesundheit < 30%
Minuten 4+:    Balancie MIGHT, ARMOR, und Revival-Items
```

#### 6. **Ergebnis**

Mit dieser Strategie solltest du es auf **5–7 Minuten** schaffen, bevor die Gegnermengen untragbar werden.

---

## Verwendung – Die wichtigsten Tasten

| Aktion | Tastenkombo |
|--------|-------------|
| **Bewegung** | W / A / S / D oder Pfeiltasten |
| **Pause** | ESC |
| **Neustarten** | R (im Game-Over-Screen) |
| **Einstellungen** | Hauptmenü → Settings |

---

## Projektstruktur

```
endless-dusk/
├── main/                      # Haupt-Spiellogik
│   ├── entities/              # Spielobjekte (Spieler, Gegner, Items)
│   │   ├── player.gd         # Spieler-Logik
│   │   ├── Characters/       # Charakter-Definitionen
│   ├── systems/              # Game-Systeme
│   │   ├── enemy_spawner.gd  # Gegner-Spawn-Logik
│   │   ├── wave_handler.gd   # Wellen-Management
│   ├── ui/                   # Benutzeroberfläche
│   │   ├── ingameUI/        # In-Game-HUD
│   │   ├── general_menu/    # Hauptmenü
│   ├── global/              # Globale Manager
│   │   ├── audio_manager.gd # Musik & Sound
│   │   ├── damage_pool.gd   # Schaden-System
│   │   ├── xp_pool.gd       # XP-Verteilung
├── maps/                      # Spielkarten
│   └── map_1.tscn           # Erste Map
├── assets/                    # Grafiken & Audio
│   ├── art/                 # Pixel-Art-Dateien
│   ├── audio/               # Musik & Soundeffekte
├── tests/                     # Unit-Tests (gdUnit4)
├── project.godot            # Godot-Projektkonfiguration
└── README.md                # Diese Datei
```

---

## Developer-Reference (Kurzreferenz für Mitwirkende)

Kurze technische Übersicht mit direkten Dateiverweisen und Beispielsnippets (aus dem `main`-Ordner).

### Autoloads (siehe [project.godot](project.godot#L1-L40))
- `Global`: [Global.gd](Global.gd) — Spielstatistiken, Auswahl und Laufzeit-Status
- `SceneChanger`: [main/ui/sceneChanger/scene_changer.tscn](main/ui/sceneChanger/scene_changer.tscn) — Szenenwechsel (`SceneChanger.change_scene(path)`)
- `MusicManager`: [main/global/AudioManager.tscn](main/global/AudioManager.tscn) — Hintergrundmusik
- `SettingsManager`: [main/ui/general_menu/settings_menu/settings_manager.gd](main/ui/general_menu/settings_menu/settings_manager.gd) — Einstellungen
- `DamagePool`: [main/global/damage_pool.gd](main/global/damage_pool.gd) — Schadenszahlen spawnen
- `XpPool`: [main/global/xp_pool.gd](main/global/xp_pool.gd) — XP-Verwaltung
- `EnemyPool`: [main/global/enemy_pool.gd](main/global/enemy_pool.gd) — Gegner-Pooling

### Wichtige Dateien (Kurz)
- [maps/map_1.gd](maps/map_1.gd) — Instanziiert den Spieler und verbindet Signale
- [main/entities/player.gd](main/entities/player.gd) — `gain_xp`, `xp_changed`, `health_changed`, `leveled_up`
- [main/systems/wave_handler.gd](main/systems/wave_handler.gd) — Wellen- und Spawn-Logik
- [main/systems/enemy_spawner.gd](main/systems/enemy_spawner.gd) — `spawn_enemy_around_player` / `spawn_enemy_group`
- [main/ui/general_menu/main_menu/main_menu.gd](main/ui/general_menu/main_menu/main_menu.gd) — Menü-Pfade & Buttons
- [main/ui/CharacterSelection/character_seletion.gd](main/ui/CharacterSelection/character_seletion.gd) — Default-Auswahl (`soilder.tscn`; Tipp: Namen prüfen)

### Schnell‑Beispiele
```gdscript
# maps/map_1.gd — Spieler instanziieren (bereits im Projekt)
if Global.selected_character_scene:
   player = Global.selected_character_scene.instantiate()
   add_child(player)
   player.global_position = $PlayerSpawn.global_position
   player.xp_changed.connect(game_ui._on_player_xp_changed)
   player.health_changed.connect(game_ui._on_player_health_changed)
   player.leveled_up.connect(game_manager._on_player_leveled_up)
```

```gdscript
# spawn-Beispiel (WaveHandler nutzt den Spawner)
var slime_scene = preload("res://main/entities/enemies/simple_enemy/slime/slime.tscn")
$WaveManager/EnemySpawner.spawn_enemy_around_player(player, slime_scene, 300, 500)
```

```gdscript
# main/entities/player.gd — XP-Handling
func gain_xp(amount: float):
   current_xp += amount * growth
   while current_xp >= max_xp:
      current_xp -= max_xp
      level += 1
      max_xp = int(max_xp * 1.2)
      pending_levelups += 1
   xp_changed.emit(current_xp, max_xp)
   check_levelups()
```

### Tests (gdUnit4)
```bash
export GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
./addons/gdUnit4/runtest.sh
open reports/report_1/index.html
```
```bash
./addons/gdUnit4/runtest.sh --godot_binary /usr/local/bin/godot
```
 - Linux (bash):
 ```bash
 # Setze Godot-Binary (falls nicht im PATH)
 export GODOT_BIN="/usr/bin/godot"
 ./addons/gdUnit4/runtest.sh
 xdg-open reports/report_1/index.html
 ```

 - Windows (PowerShell):
 ```powershell
 # Setze Umgebungsvariable (PowerShell)
 $env:GODOT_BIN = 'C:\Program Files\Godot\Godot.exe'
 # Verwende das Windows-Wrapper-Skript
 .\addons\gdUnit4\runtest.cmd
 Start-Process 'reports\report_1\index.html'
 ```

 - Windows (CMD):
 ```cmd
 :: Setze Umgebungsvariable (CMD)
 set GODOT_BIN=C:\"Program Files"\Godot\Godot.exe
 :: Führe das Wrapper-Skript aus
 addons\gdUnit4\runtest.cmd
 start "" reports\report_1\index.html
 ```

### Debug‑Tipps
- Fehlende Szenen prüfen: [main/ui/general_menu/main_menu/main_menu.gd](main/ui/general_menu/main_menu/main_menu.gd) — Pfade sind dort als Konstanten definiert.
- Character-Dateien: [main/entities/Characters](main/entities/Characters) — Standard: `soilder.tscn` (Achtung: Schreibweise).
- Logs: `reports/` und `reports/report_1/index.html` nach Tests öffnen.

## Entwicklung & Beitragen

### Tech-Stack
- **Engine:** Godot 4.5
- **Sprache:** GDScript
- **Pixel-Art Tools:** Libresprite, Pixelorama
- **Sound:** Audacity, FL Studio
- **Testing:** gdUnit4

### Development Setup

1. Klone das Repository
2. Öffne in Godot 4.5+
3. Führe Tests aus: `F5` im Test-Baum oder über `gdUnit4`

### Wie du beitragen kannst

Wir freuen uns über Beiträge! Bitte:

1. **Fork** das Repository
2. Erstelle einen **Feature-Branch** (`git checkout -b feature/deine-idee`)
3. **Commit** deine Änderungen (`git commit -am 'Add feature'`)
4. **Push** und erstelle einen **Pull Request**

### Bekannte Probleme & TODOs

- [ ] Balancing der Gegner-Schwierigkeit
- [ ] Performance-Optimierung für 1000+ Gegner gleichzeitig
- [ ] Mobile-Support (iOS/Android)
- [ ] Zusätzliche Charaktere und Waffen
- [ ] Sound & Musik-Integration für alle Szenen

---

## Ressourcen & Weiterführende Links

### Offizielle Godot-Ressourcen
- [Godot Engine Dokumentation](https://docs.godotengine.org/)
- [GDScript Referenz](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Godot Tutorials (YouTube)](https://www.youtube.com/@GodotEngineOfficial)

### Tools
- [Libresprite](https://libresprite.github.io/) – Pixel-Art-Editor (kostenlos, Open Source)
- [Pixelorama](https://github.com/Orama-Interactive/Pixelorama) – Moderner Pixel-Art-Editor
- [gdUnit4](https://mikromanie.de/product/gdunit4/) – Godot Test-Framework

### Inspiration
- [Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors/) – Inspirations-Spiel
- [Roguelike & Roguelite Klassiker](https://en.wikipedia.org/wiki/Roguelike) – Genre-Verständnis

### Community
- [Godot Community Discord](https://discord.gg/godotengine)
- [Godot Forum](https://forum.godotengine.org/)
- [Endless Dusk Issues](https://github.com/ErellueM/endless-dusk/issues) – Bug Reports & Feature Requests

---

## Lizenz

Dieses Projekt ist proprietär lizenziert — **Alle Rechte vorbehalten**. Siehe [LICENSE](LICENSE) für Details.

---

<div align="center">

**Viel Spaß mit Endless Dusk! 🎮**

Überlebe. Verbessere dich. Meistere die Nacht.

</div>

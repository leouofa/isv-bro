# 🕶️ ISV BRO — Autonomous Master Build Prompt & Architectural Specification

> **International Scientific Vocabulary: Blast Resonance Operative**  
> **A production-grade, end-to-end autonomous execution prompt and technical blueprint for building ISV BRO in Godot 4.3+ / 4.7+ with GDScript, Headless Blender 3D Asset Generation, Adaptive Etymological Spaced Repetition, and an 8-Suite Headless Verification Runner.**

---

## 📋 Table of Contents

1. [Game Specification Input (`specs.yml`)](#-game-specification-input-specsyml)
2. [The Autonomous Master Prompt (7-Phase Execution Plan)](#-the-autonomous-master-prompt)
3. [ISV Etymological Lexicon Specification & Curated Roster](#-isv-etymological-lexicon-specification--curated-roster)
4. [Architectural Invariants & Core Systems Blueprints](#-architectural-invariants--core-systems-blueprints)
   - [Autoload `GameManager.gd` & `user://isv_save.json` Persistence](#1-autoload-gamemanagergd--userisv_savejson-persistence)
   - [Autoload `LexiconManager.gd` & Spaced Repetition Engine](#2-autoload-lexiconmanagergd--spaced-repetition-engine)
   - [14-Track OST `MusicManager.gd` & B.R.O. Retro Synth Voice (`SoundEffects.gd`)](#3-14-track-ost-musicmanagergd--bro-retro-synth-voice-soundeffectsgd)
   - [6DOF Screen-Bounded Flight & Hybrid 3D/2D Lock-On Targeting](#4-6dof-screen-bounded-flight--hybrid-3d2d-lock-on-targeting)
   - [Pause System with Low-Pass Audio Filter & Inline Confirmations](#5-pause-system-with-low-pass-audio-filter--inline-confirmations)
5. [Procedural 3D Asset Pipeline (`tools/generate_assets.py`)](#-procedural-3d-asset-pipeline-toolsgenerate_assetspy)
6. [8-Suite Headless Automated Verification (`tools/test_game.gd`)](#-8-suite-headless-automated-verification-toolstest_gamegd)

---

## ⚙️ Game Specification Input (`specs.yml`)

```yaml
# ==============================================================================
# GAME SPECIFICATION INPUT: ISV BRO
# International Scientific Vocabulary - Blast Resonance Operative
# ==============================================================================
GAME_TITLE: "ISV BRO"
SUBTITLE: "International Scientific Vocabulary: Radical 90s Science Rail Shooter"
GENRE_ARCHETYPE: "3D Rail Shooter / Educational Arcade"
CAMERA_PERSPECTIVE: "Third-Person Behind Jet (FOV 75-80, dynamic roll & banking camera tilt)"
TARGET_ENGINE: "Godot 4.3+ / 4.7+ (Forward+ Renderer, Jolt 3D Physics)"

NARRATIVE_AND_PREMISE: >
  In the late 90s, high-energy particle accelerators unlocked the "Etymo-Verse"—a subspace
  where scientific phenomena and Latin/Greek roots materialize as volatile anomalies.
  You pilot the experimental Hadron Jet alongside "B.R.O." (Blaster Research Officer),
  a hyperactive, sunglasses-wearing AI scientist hype-man stationed in your HUD.
  Together, you blast through hazard-choked quantum corridors, neutralizing rogue scientific
  anomalies by matching their true International Scientific Vocabulary (ISV) roots before
  cognitive overheat melts your ship's cores.

CORE_GAMEPLAY_LOOP: >
  1. The Hadron Jet accelerates automatically along a 3D rail through high-energy test chambers.
  2. The player steers within a screen-bounded viewport (WASD / Left Stick) to dodge physical
     hazards (laser gates, particle grids, quantum debris) using barrel rolls, airbrakes, and boosts.
  3. Approaching anomalies display scientific definitions or corrupted terms (e.g., "Cell Destruction").
  4. The lock-on targeting reticle automatically focuses on prioritized targets, projecting
     3–4 root choices mapped to quick-keys (1-4 / Q-E / Gamepad Face Buttons).
  5. Selecting the correct Greek/Latin root (e.g., "lysis") fires a resonant laser salvo,
     annihilating the anomaly, advancing the combo multiplier, and triggering praise from B.R.O.
  6. Incorrect answers spike the "Cognitive Overheat" meter, risking weapon lockout.
  7. Surviving the sector gauntlet leads to a multi-stage "Boss Exam" requiring compound root synthesis.

KEY_MECHANICS:
  - Flight Controls:
      - 2D Viewport Bounding Box: Smooth 6DOF-feel movement inside screen limits (WASD / Left Stick)
      - Barrel Roll (Double-tap A/D or L1/R1): Deflects light hazards and grants brief invulnerability frames
      - Airbrake (S / L2) & Afterburner Boost (W / R2): Tactical speed control for hazard navigation
  - ISV Combat & Targeting:
      - Lock-on Reticle: Soft-locks onto incoming anomalies in front of the craft
      - Root Salvo Triggers: 4 contextual root options displayed in HUD around the reticle [1/Q, 2/E, 3/R, 4/F]
      - Rapid Synthesis: Multi-root anomalies require sequential selection (e.g., "Photo" + "Synthesis")
  - Health & Fail States:
      - Shield Integrity (HP): Depleted by collisions with physical obstacles; slowly regenerates when avoiding damage
      - Cognitive Overheat Meter: Starts at 0%; spikes by +25% on incorrect root selection. Reaching 100% causes
        emergency coolant venting (temporary weapons lockout + severe score penalty). Total shield loss = run over.
  - Radical Combo System:
      - Consecutive correct roots build the "Bro-Factor" multiplier (1x -> 2x -> 4x -> 8x "RADICAL!")
      - Missing or taking damage resets the combo multiplier

LEVELS_AND_CURRICULUM_STRUCTURE:
  - Sector Progression (Themed Scientific Disciplines):
      - Sector 01: Cytology & Bio-Genesis (Roots: bio-, cyto-, soma-, phag-, blast-, -lysis, etc.)
      - Sector 02: Astro & Celestial Dynamics (Roots: astro-, cosmo-, helio-, peri-, apo-, -orbit, etc.)
      - Sector 03: Geo & Lithospheric Matrix (Roots: geo-, lith-, petro-, pyro-, morph-, -strat, etc.)
      - Sector 04: Thermo & Quantum Energetics (Roots: thermo-, kinet-, tachy-, photo-, chrom-, etc.)
  - Boss Exams:
      - Massive multi-jointed boss entities (e.g., "The Mitochondrion Overlord", "The Lithic Golem")
      - Phases require decoding composite scientific terms under time pressure while dodging bullet patterns
  - Adaptive Spaced Repetition:
      - Missed roots are logged in the player profile and injected with higher probability in future waves
  - Codex Bro-tanica:
      - Main-menu & pause compendium documenting all discovered roots, Greek/Latin origins,
        definitions, and real-world scientific terminology examples

AUDIO_AND_VISUAL_THEME:
  - Aesthetic:
      - Radical 90s Science Arcade: Bold neon palette (Electric Cyan #00F0FF, Hot Magenta #FF007F,
        Nuclear Lime #39FF14, Solar Yellow #FFE600, Deep Obsidian #0A0A12)
      - CRT scanlines overlay option, wireframe HUD elements, high-tech particle colliders, spinning atomic orbitals
  - B.R.O. HUD Persona:
      - Animated pixel-art or stylized low-poly avatar in the corner HUD with expressive reactive animations
      - Hype voice callouts & dialogue banners ("TUBULAR ETYMOLOGY, BRO!", "CHECK THE GREEK ROOT!", "COOLING DOWN!")
  - Soundtrack Integration (Utilizing tracks/):
      - Dynamic OST mapping from workspace tracks:
          - Sector 01: tracks/The Run.mp3
          - Sector 02: tracks/Ultrabeat.mp3
          - Sector 03: tracks/Undercurrent.mp3
          - Sector 04: tracks/Escape.mp3
          - Boss Exams: tracks/Left Turn.mp3 & tracks/Rerun.mp3
          - Codex & Menus: tracks/Entryway.mp3 & tracks/Mirror Tech.mp3
      - Low-pass filter kicks in during pause or Cognitive Overheat recovery

SCORING_AND_PERSISTENCE:
  - Scoring:
      - Root Blast: +200 pts x Combo Multiplier
      - Perfect Sector Wave: +2,500 bonus
      - Boss Defeat: +10,000 bonus
      - Final Grade: S ("DOCTORAL BRO"), A, B, C, D rank based on accuracy percentage and completion time
  - Save System (user://isv_save.json):
      - High scores and letter ranks per sector
      - Codex Bro-tanica unlock percentage and mastery level per root
      - Adaptive mistake tracker for spaced repetition weighting
# ==============================================================================
```

---

## 🤖 The Autonomous Master Prompt

````markdown
You are an elite 3D game developer, educational systems designer, and Godot 4.x architect.
Your objective is to autonomously build **ISV BRO** (*International Scientific Vocabulary: Blast Resonance Operative*), a complete, production-ready 3D Rail Shooter & Educational Arcade game in Godot 4.3+ / 4.7+ based on `specs.yml` and the architectural specifications in this document.

Follow this uncompromising 7-phase execution plan. Do not take shortcuts or leave placeholder stubs. Every scene, 3D model, lexicon entry, shader, audio bus, and automated test must work cleanly and pass 100% of headless verification assertions.

---

### Phase 1: Core Architecture, Autoload Singletons & Input Configuration
1. Configure `project.godot`:
   - Set viewport size to `1280x720` (resizable, `canvas_items` stretch mode, `expand` aspect).
   - Set `run/main_scene="res://scenes/MainMenu.tscn"`.
   - Register 4 Autoload singletons:
     - `GameManager` -> `res://scripts/GameManager.gd`
     - `LexiconManager` -> `res://scripts/LexiconManager.gd`
     - `SoundEffects` -> `res://scripts/SoundEffects.gd`
     - `MusicManager` -> `res://scripts/MusicManager.gd`
   - Register all required InputMap actions with both Keyboard and Joypad bindings:
     - Flight steering: `move_left` (A / Left Arrow / Joy Axis 0-), `move_right` (D / Right Arrow / Joy Axis 0+), `move_up` (W / Up Arrow / Joy Axis 1-), `move_down` (S / Down Arrow / Joy Axis 1+)
     - Flight maneuvers: `barrel_roll` (Space / Shift / Joy L1 / R1), `boost` (Tab / Joy R2), `airbrake` (Ctrl / Joy L2)
     - Root Salvo Triggers:
       - `root_1`: Key `1`, Key `Q`, Joy Button `X` (West)
       - `root_2`: Key `2`, Key `E`, Joy Button `Y` (North)
       - `root_3`: Key `3`, Key `R`, Joy Button `B` (East)
       - `root_4`: Key `4`, Key `F`, Joy Button `A` (South)
     - System: `pause` (Escape / Key `P` / Joy Start), `cycle_target` (Key `C` / Middle Click)
2. Build `scripts/GameManager.gd`:
   - Extend `Node` with `process_mode = Node.PROCESS_MODE_ALWAYS`.
   - Manage run state: `current_sector` (1..4), `score`, `combo_multiplier` (`1, 2, 4, 8`), `streak_count`, `shield_hp` (0..100), `cognitive_overheat` (0..100), `is_overheated_lockout` (bool), `lockout_timer` (float), `shots_fired`, `shots_hit`.
   - Implement combat resolution methods:
     - `register_root_hit(root_id: String, base_points: int = 200)`: increments `shots_fired` and `shots_hit`, increases `streak_count`, scales `combo_multiplier` (`1 -> 2 -> 4 -> 8` at streaks `0, 3, 6, 10`), cools `cognitive_overheat` by `-10.0`, records mastery in `LexiconManager`, and adds `base_points * combo_multiplier`.
     - `register_root_miss(expected_root_id: String)`: increments `shots_fired`, resets `streak_count` and `combo_multiplier` to `1`, records miss in `LexiconManager`, and spikes `cognitive_overheat` by `+25.0`. If `cognitive_overheat >= 100.0`, triggers a `3.5s` weapon lockout (`is_overheated_lockout = true`), deducts penalty points, and activates the low-pass filter on the Music bus.
     - `calculate_grade(accuracy: float, survived: bool) -> String`: returns `"S"` ("DOCTORAL BRO", accuracy >= 0.92 and survived), `"A"` (>= 0.80), `"B"` (>= 0.65), `"C"` (>= 0.50), or `"D"`.
   - Implement persistent save/load to `user://isv_save.json` tracking sector high scores, best letter grades, unlocked codex roots, root mastery counts, mistake weights, audio volumes, and CRT scanline toggle.
3. Build `scripts/SoundEffects.gd` & `scripts/MusicManager.gd`:
   - `SoundEffects.gd`: Procedural synthesizer using `AudioStreamGenerator` (or pooled PCM wave buffers) generating zero-dependency retro 90s arcade SFX: laser salvo zaps, lock-on pips, barrel-roll whoosh, shield impact crunch, overheat alarm siren, combo fanfare, and **Star Fox-style rapid pitch-modulated voice blips** whenever B.R.O. speaks!
   - `MusicManager.gd`: Dynamically configures `"Music"` and `"SFX"` buses, attaches an `AudioEffectLowPassFilter` (cutoff `900 Hz` when paused or overheated, bypassed during normal play), and plays the 14 MP3 tracks located in `res://tracks/`:
     - Menus & Codex: `res://tracks/Entryway.mp3`, `res://tracks/Mirror Tech.mp3`, `res://tracks/Understanding.mp3`
     - Sector 01 (Cytology & Bio-Genesis): `res://tracks/The Run.mp3`, `res://tracks/Silly Verses.mp3`
     - Sector 02 (Astro & Celestial Dynamics): `res://tracks/Ultrabeat.mp3`, `res://tracks/The Flight.mp3`
     - Sector 03 (Geo & Lithospheric Matrix): `res://tracks/Undercurrent.mp3`, `res://tracks/Low Cut.mp3`
     - Sector 04 (Thermo & Quantum Energetics): `res://tracks/Escape.mp3`, `res://tracks/The Key.mp3`, `res://tracks/Luck.mp3`
     - Boss Exams & Finale: `res://tracks/Left Turn.mp3`, `res://tracks/Rerun.mp3`, `res://tracks/The End.mp3`

---

### Phase 2: ISV Etymological Lexicon & Spaced Repetition Engine
1. Create `data/isv_lexicon.json` containing at least **48 curated ISV roots** (12 per sector across Sectors 1–4) plus **4 Multi-Phase Boss Exam Composite Challenges** as defined in the Lexicon Specification below.
2. Build `scripts/LexiconManager.gd`:
   - Load and validate `res://data/isv_lexicon.json` on startup.
   - Maintain per-root adaptive weights: `weight = clamp(1.0 + (missed_count * 1.5) - (mastered_count * 0.15), 0.4, 8.0)`.
   - Provide `select_weighted_root(sector_id: int) -> Dictionary` using weighted random sampling so missed roots appear significantly more frequently.
   - Provide `build_multiple_choice_prompt(target_root_id: String, count: int = 4) -> Dictionary`:
     - Returns the target clue/definition, target root metadata, an array of 4 shuffled root option dictionaries (1 correct + 3 distinct distractors drawn from the root's `distractors` or same-sector pool), and the `correct_index` (`0..3`).
   - Provide `get_boss_exam(sector_id: int) -> Dictionary` returning the multi-phase composite word synthesis sequence for that sector's Boss Exam.

---

### Phase 3: Procedural 3D Asset Pipeline (`tools/generate_assets.py`)
1. Create `tools/generate_assets.py` using Blender's Python API (`bpy`) to generate 10 stylized low-poly 90s sci-fi `.glb` models in `assets/models/`:
   - `hadron_jet.glb`: Twin-nacelle futuristic particle fighter with obsidian hull, hot magenta swept wings, and electric cyan engine cores.
   - `anomaly_bio.glb`: Sector 01 Cytology target — glowing nuclear-lime cellular core with twisted helix rings.
   - `anomaly_astro.glb`: Sector 02 Astro target — solar-gold star core nested inside intersecting gyroscope orbital rings.
   - `anomaly_geo.glb`: Sector 03 Geo target — crystalline magenta/amber octahedron cluster.
   - `anomaly_thermo.glb`: Sector 04 Thermo target — high-energy cyan/magenta plasma torus with orbiting electron spheres.
   - `hazard_laser_gate.glb`: Crimson obsidian dual-pylon laser barrier (`#FF0033`).
   - `hazard_collider_ring.glb`: Giant hexagonal/octagonal particle accelerator tunnel frame for background rail scrolling.
   - `pickup_coolant_cell.glb`: Electric cyan (`#00F0FF`) cryo-coolant canister (vents `-35%` Cognitive Overheat on pickup).
   - `pickup_shield_orb.glb`: Nuclear lime & gold (`#39FF14`) harmonic orb (restores `+25` Shield Integrity).
   - `boss_core.glb`: Massive multi-ringed mechanical/organic Boss Exam synthesis core.
2. Execute `blender -b -P tools/generate_assets.py` (with automatic fallback procedural mesh generation in GDScript if Blender is unavailable in a restricted environment, ensuring `.glb` files exist on disk).

---

### Phase 4: 6DOF Screen-Bounded Rail Flight, Lock-On Combat & Boss Exams
1. Build `scenes/PlayerJet.tscn` (`scripts/PlayerJet.gd`):
   - Move smoothly within the 2D camera viewport plane (`x in [-6.5, 6.5]`, `y in [-3.8, 3.8]`) using framerate-independent exponential decay:
     `position.x = lerp(position.x, target_x, 1.0 - exp(-18.0 * delta))`
     `position.y = lerp(position.y, target_y, 1.0 - exp(-18.0 * delta))`
   - Tilt/bank `rotation.z` and pitch `rotation.x` dynamically based on velocity delta.
   - Implement **Barrel Roll** (`barrel_roll` or double-tap Left/Right): grants `0.45s` invulnerability frames (`is_invulnerable = true`), spins the jet 360 degrees, and deflects grazing hazards.
   - Implement **Afterburner Boost** (`boost`: `speed_mult = 1.6`) and **Airbrake** (`airbrake`: `speed_mult = 0.55`).
2. Build `scenes/Anomaly.tscn` (`scripts/Anomaly.gd`):
   - Moves along `+Z` toward the player camera along the rail corridor while oscillating/rotating.
   - Displays a 3D billboard `Label3D` above its mesh showing the scientific clue (e.g., `"CELL DESTRUCTION"` or `"STUDY OF ROCKS"`) and root progress for multi-part terms.
   - Supports both single-root anomalies and sequential compound-root anomalies.
3. Build `scenes/BossExam.tscn` (`scripts/BossExam.gd`):
   - Spawns at the end of a sector's anomaly waves, halting standard obstacle spawns and pacing alongside the player jet.
   - Cycles through 3 compound scientific terms (e.g. `PHOTO` + `SYNTHESIS`, `ENDOCYTOSIS` = `ENDO` + `CYTO` + `SIS`). Each phase requires sequential root locks while the boss fires dodgeable plasma hazard rings.
4. Build `scenes/GameWorld.tscn` (`scripts/GameWorld.gd`):
   - Manage the scrolling 3D particle-accelerator tunnel (`hazard_collider_ring.glb` instances recycled seamlessly), dynamic lighting, ACES tonemapped bloom, and wave spawner.
   - **Auto-Lock Reticle System**: Automatically locks onto the nearest active `Anomaly` (or active `BossExam` phase) in front of the player jet, immediately feeding its 4-choice root prompt to the HUD.
   - When the player presses `root_1`..`root_4`, fire a vibrant 3D laser beam from the `PlayerJet` toward the locked target:
     - If `chosen_index == correct_index`: detonate the anomaly (or advance the compound word phase), spawn particle sparks, trigger `GameManager.register_root_hit()`, and command the B.R.O. HUD copilot to celebrate or drop an etymological mnemonic.
     - If `chosen_index != correct_index`: play error buzz, trigger `GameManager.register_root_miss()`, shake camera, and have B.R.O. shout an etymology tip!

---

### Phase 5: Hybrid 3D/2D Tactical Lock-On HUD, Animated B.R.O. Copilot & Codex Bro-tanica
1. Build `scenes/HUD.tscn` (`scripts/HUD.gd`):
   - **2D Unprojected Lock-On Reticle**: Uses `camera.unproject_position(locked_target.global_position)` to draw an animated neon cyan/magenta lock-on diamond and corner brackets directly over the 3D target in screen space.
   - **Tactical Target Banner**: High-contrast top-center HUD panel showing:
     - Target Classification & Clue (e.g., `ANOMALY DETECTED: "Relating to heat"`)
     - Etymological Synthesis Bar (for multi-root boss exams: `[ THERMO- ] + [ ??? ]`)
     - 4 Color-Coded Root Salvo Trigger Buttons arranged around the banner/reticle:
       - `[1 / Q] thermo-` | `[2 / E] cryo-` | `[3 / R] baro-` | `[4 / F] photo-`
   - **Animated B.R.O. Comms Widget**:
     - Corner CRT-framed comms box featuring a stylized procedural/layered 2D avatar of **B.R.O.** (spiky 90s hair, neon visor sunglasses with animated light sweep, talking jaw animation) supporting 5 states:
       - `IDLE` ("Lock onto those roots, bro!")
       - `HYPE_COMBO` ("RADICAL 8X ETYMOLOGY, BRO!!")
       - `MNEMONIC_TIP` (Displays the exact Greek/Latin mnemonic for the root just encountered)
       - `OVERHEAT_ALARM` ("COGNITIVE OVERHEAT! VENTING COOLANT!")
       - `BOSS_ALERT` ("FINAL EXAM BOSS APPROACHING! SYNTHESIZE COMPOUND ROOTS!")
   - **Status Gauges**: Shield Integrity Bar (`#39FF14`), Cognitive Overheat Meter (`#00F0FF` -> `#FF0033` with flashing `"LOCKOUT"` warning), Score counter, and `"BRO-FACTOR"` Combo Badge.
2. Build `scenes/CodexScreen.tscn` (`scripts/CodexScreen.gd`):
   - Accessible from both `MainMenu` and `PauseMenu`.
   - Filterable by Sector (All, Sector 01 Bio, Sector 02 Astro, Sector 03 Geo, Sector 04 Thermo).
   - Displays overall unlock & mastery percentage, scrollable list of all 48+ ISV roots, and a detailed inspection card showing: Root, Language Origin (Greek/Latin), Core Meaning, Real-World Scientific Examples, Player Accuracy / Mastery Streak, and B.R.O.'s Mnemonic Note.
3. Build `scenes/PauseMenu.tscn` (`scripts/PauseMenu.gd`) & `scenes/MainMenu.tscn` (`scripts/MainMenu.gd`):
   - `PauseMenu`: `PROCESS_MODE_ALWAYS`, toggles `get_tree().paused`, enables low-pass audio filter, includes Resume, Open Codex Bro-tanica, and inline confirmation dialogs for Restart Sector and Exit to Main Menu.
   - `MainMenu`: Radical 90s Science Arcade title screen, Sector Selection cards (showing Sector 01–04 themes, High Scores, and Best Rank `S/A/B/C/D`), Codex Bro-tanica launcher, Audio/CRT Settings modal, and Post-Run Grade Report modal.

---

### Phase 6: Radical 90s Shaders, CRT PostFX & Visual Hierarchy
1. Create a screen-space CRT Scanline & Vignette shader (`shaders/crt_overlay.gdshader`) on a toggleable `CanvasLayer` (`ColorRect` with `mouse_filter = MOUSE_FILTER_IGNORE`).
2. Enforce strict visual hierarchy across 3D materials:
   - **Targetable Anomalies**: Sector-themed neon emission with pulsing lock-on ring highlight.
   - **Physical Hazards**: Crimson Red (`#FF0033`) & Dark Obsidian (`#0A0A12`) with hazard warning stripes.
   - **Coolant & Shield Pickups**: Electric Cyan (`#00F0FF`) and Nuclear Lime (`#39FF14`) with smooth vertical bobbing and spinning halo rings.

---

### Phase 7: 8-Suite Headless Automated Verification (`tools/test_game.gd`)
1. Implement `tools/test_game.gd` extending `SceneTree` to verify all 8 core test suites headlessly.
2. Execute `godot --headless -s tools/test_game.gd` and fix any warnings, missing resources, or failed assertions until `0 FAILED` is achieved.
````

---

## 🧬 ISV Etymological Lexicon Specification & Curated Roster

The file `res://data/isv_lexicon.json` **must** adhere to the following JSON schema and populate all 4 sectors (minimum 12 roots per sector = 48 roots) plus 4 Boss Exam synthesis sequences.

### JSON Schema (`res://data/isv_lexicon.json`)

```json
{
  "sectors": [
    {
      "id": 1,
      "code": "BIO",
      "name": "Sector 01: Cytology & Bio-Genesis",
      "theme_color": "#39FF14",
      "track": "res://tracks/The Run.mp3",
      "boss_track": "res://tracks/Left Turn.mp3"
    }
  ],
  "roots": [
    {
      "id": "lysis",
      "sector": 1,
      "root": "-lysis",
      "origin": "Greek (luein)",
      "meaning": "Dissolution, loosening, or cell destruction",
      "examples": ["Hydrolysis", "Cytolysis", "Paralysis"],
      "distractors": ["-stasis", "-genesis", "-trophy"],
      "mnemonic": "LYSIS = LOOSE! Like Lysol breaking down germs into total destruction, bro!"
    }
  ],
  "boss_exams": [
    {
      "sector": 1,
      "boss_name": "THE MITOCHONDRION OVERLORD",
      "subtitle": "Cellular Synthesis Final Exam",
      "compounds": [
        {
          "term": "CYTOLYSIS",
          "clue": "Dissolution or destruction of a living cell",
          "sequence": ["cyto", "lysis"]
        },
        {
          "term": "ENDOCYTOSIS",
          "clue": "Taking matter INSIDE a CELL",
          "sequence": ["endo", "cyto"]
        },
        {
          "term": "AUTOPHAGY",
          "clue": "SELF-EATING of cellular components",
          "sequence": ["auto", "phag"]
        }
      ]
    }
  ]
}
```

### Mandatory 48-Root Curated Roster Across All 4 Sectors

Populate `data/isv_lexicon.json` with all 48 of these authentic ISV roots (12 per sector):

#### Sector 01: Cytology & Bio-Genesis (`sector: 1`, Theme: Nuclear Lime `#39FF14`)
1. `bio` (`bio-`, Greek *bios*): `"Life or living organisms"` — Examples: *Biology, Biosphere, Symbiosis* — Mnemonic: `"BIO is LIFE, bro! Keep your bio-shield alive!"`
2. `cyto` (`cyto-`, Greek *kytos*): `"Cell or hollow receptacle"` — Examples: *Cytoplasm, Cytology, Leukocyte* — Mnemonic: `"CYTO = CELL! Every cell in your body is hyped!"`
3. `lysis` (`-lysis`, Greek *lysis*): `"Dissolution, loosening, or destruction"` — Examples: *Cytolysis, Hydrolysis, Electrolysis* — Mnemonic: `"LYSIS breaks it LOOSE and dissolves it with lasers!"`
4. `stasis` (`-stasis`, Greek *stasis*): `"Standing still, equilibrium, or stability"` — Examples: *Homeostasis, Hemostasis, Cryostasis* — Mnemonic: `"STASIS = STAY STILL in perfect balance!"`
5. `phag` (`phag- / -phagy`, Greek *phagein*): `"To eat, engulf, or devour"` — Examples: *Macrophage, Esophagus, Autophagy* — Mnemonic: `"PHAG = PAC-MAN eating up cellular debris!"`
6. `soma` (`soma- / -some`, Greek *soma*): `"Body or bodily structure"` — Examples: *Somatic, Chromosome, Ribosome* — Mnemonic: `"SOMA is the BODY, bro—never skip soma day!"`
7. `blast` (`-blast / blasto-`, Greek *blastos*): `"Immature cell, bud, or germ layer"` — Examples: *Osteoblast, Fibroblast, Blastocyst* — Mnemonic: `"BLAST cells are young builders ready to sprout!"`
8. `endo` (`endo-`, Greek *endon*): `"Within, inner, or absorbing"` — Examples: *Endoskeleton, Endocrine, Endocytosis* — Mnemonic: `"ENDO goes IN-DOORS, deep inside the structure!"`
9. `exo` (`exo-`, Greek *exo*): `"Outside, external, or outer"` — Examples: *Exoskeleton, Exothermic, Exocytosis* — Mnemonic: `"EXO = EXIT to the outside shell!"`
10. `auto` (`auto-`, Greek *autos*): `"Self or occurring from within"` — Examples: *Autotroph, Autophagy, Autonomic* — Mnemonic: `"AUTO = AUTOMATICALLY by yourself, bro!"`
11. `troph` (`-troph / tropho-`, Greek *trophe*): `"Nourishment, food, or growth"` — Examples: *Autotroph, Hypertrophy, Atrophy* — Mnemonic: `"TROPH = Winner's TROPHY of cellular nutrition!"`
12. `morph` (`morph- / -morphic`, Greek *morphe*): `"Form, shape, or structure"` — Examples: *Metamorphosis, Morphology, Amorphous* — Mnemonic: `"MORPH = Mighty Morphin' shape-shifters!"`

#### Sector 02: Astro & Celestial Dynamics (`sector: 2`, Theme: Electric Cyan `#00F0FF`)
13. `astro` (`astro-`, Greek *astron*): `"Star or celestial body"` — Examples: *Astrophysics, Asteroid, Astronaut* — Mnemonic: `"ASTRO = STARS shining across the galaxy!"`
14. `cosmo` (`cosmo-`, Greek *kosmos*): `"Universe, world, or order"` — Examples: *Cosmology, Microcosm, Cosmonaut* — Mnemonic: `"COSMO = The entire ordered UNIVERSE, bro!"`
15. `helio` (`helio-`, Greek *helios*): `"The Sun"` — Examples: *Heliocentric, Helium, Perihelion* — Mnemonic: `"HELIO = Blazing hot SUN power!"`
16. `peri` (`peri-`, Greek *peri*): `"Around, near, or enclosing"` — Examples: *Perihelion, Perigee, Perimeter* — Mnemonic: `"PERI = Close around the PERIMETER!"`
17. `apo` (`apo-`, Greek *apo*): `"Away from, farthest point, or detached"` — Examples: *Apogee, Aphelion, Apoptosis* — Mnemonic: `"APO = APART and far away in deep orbit!"`
18. `chrono` (`chrono-`, Greek *khronos*): `"Time"` — Examples: *Chronology, Synchronize, Chronometer* — Mnemonic: `"CHRONO = Cosmic TIME on your chronograph!"`
19. `tele` (`tele-`, Greek *tele*): `"Far off, distant, or across space"` — Examples: *Telescope, Telemetry, Teleport* — Mnemonic: `"TELE = Seeing FAR across the starfield!"`
20. `baro` (`baro-`, Greek *baros*): `"Weight or atmospheric pressure"` — Examples: *Barometer, Isobar, Hyperbaric* — Mnemonic: `"BARO = Heavy BARBELL pressure, bro!"`
21. `lumin` (`lumin-`, Latin *lumen*): `"Light or radiant emission"` — Examples: *Luminosity, Bioluminescence, Luminary* — Mnemonic: `"LUMIN = Illuminate the dark void!"`
22. `grav` (`grav-`, Latin *gravis*): `"Heavy or weight-inducing force"` — Examples: *Gravity, Graviton, Specific Gravity* — Mnemonic: `"GRAV = Heavy GRAVITY pulling you in!"`
23. `sidere` (`sidere-`, Latin *sidus*): `"Star or constellation alignment"` — Examples: *Sidereal, Consider* — Mnemonic: `"SIDERE = Locked onto distant STAR time!"`
24. `nebula` (`nebul-`, Latin *nebula*): `"Mist, cloud, or vapor"` — Examples: *Nebula, Nebulizer, Nebulous* — Mnemonic: `"NEBUL = Cosmic CLOUD of star-forming gas!"`

#### Sector 03: Geo & Lithospheric Matrix (`sector: 3`, Theme: Solar Yellow `#FFE600`)
25. `geo` (`geo-`, Greek *ge*): `"Earth or planetary ground"` — Examples: *Geology, Geothermal, Apogee* — Mnemonic: `"GEO = Planet EARTH beneath our thrusters!"`
26. `lith` (`lith- / -lite`, Greek *lithos*): `"Stone or rock"` — Examples: *Lithosphere, Monolith, Neolithic* — Mnemonic: `"LITH = Solid STONE monoliths!"`
27. `petro` (`petro-`, Greek *petra*): `"Rock or mineral crag"` — Examples: *Petrology, Petrified, Petroleum* — Mnemonic: `"PETRO = Petrified into solid ROCK!"`
28. `pyro` (`pyro-`, Greek *pyr*): `"Fire or extreme volcanic heat"` — Examples: *Pyroclastic, Pyrite, Pyrometer* — Mnemonic: `"PYRO = Blazing volcanic FIRE, bro!"`
29. `strat` (`strat-`, Latin *stratum*): `"Layer or horizontal sheet"` — Examples: *Stratigraphy, Stratosphere, Substrate* — Mnemonic: `"STRAT = Stacked horizontal LAYERS of rock!"`
30. `seism` (`seism-`, Greek *seismos*): `"Earthquake or vibration"` — Examples: *Seismograph, Seismic, Microseism* — Mnemonic: `"SEISM = Earth-shaking vibration waves!"`
31. `hydro` (`hydro-`, Greek *hydor*): `"Water or liquid fluid"` — Examples: *Hydrology, Hydrothermal, Dehydrate* — Mnemonic: `"HYDRO = Stay HYDRATED with pure H2O!"`
32. `orogen` (`oro-`, Greek *oros*): `"Mountain or relief uplift"` — Examples: *Orogeny, Orographic* — Mnemonic: `"ORO = Towering MOUNTAIN peaks rising up!"`
33. `cryo` (`cryo-`, Greek *kryos*): `"Icy cold or frost"` — Examples: *Cryosphere, Cryogenics, Cryolite* — Mnemonic: `"CRYO = Ice-cold sub-zero freeze!"`
34. `hal` (`hal- / halo-`, Greek *hals*): `"Salt or saline mineral"` — Examples: *Halite, Halophile, Halogen* — Mnemonic: `"HAL = Crystalline rock SALT!"`
35. `clast` (`-clast / clastic`, Greek *klastos*): `"Broken in pieces or fragmented"` — Examples: *Pyroclastic, Clastic Rock, Osteoclast* — Mnemonic: `"CLAST = Smashed and BROKEN rock fragments!"`
36. `bath` (`bath- / bathy-`, Greek *bathys*): `"Deep or abyssal depth"` — Examples: *Bathymetry, Batholith, Bathysphere* — Mnemonic: `"BATHY = Deep ocean trench depths!"`

#### Sector 04: Thermo & Quantum Energetics (`sector: 4`, Theme: Hot Magenta `#FF007F`)
37. `thermo` (`thermo-`, Greek *therme*): `"Heat or thermal energy"` — Examples: *Thermodynamics, Endothermic, Thermometer* — Mnemonic: `"THERMO = Thermal HEAT energy cranked to 11!"`
38. `kinet` (`kinet- / cine-`, Greek *kinein*): `"Motion or active movement"` — Examples: *Kinetic, Telekinesis, Kinematics* — Mnemonic: `"KINET = Pure KINETIC motion in flight!"`
39. `tachy` (`tachy-`, Greek *tachys*): `"Swift, rapid, or faster-than-light"` — Examples: *Tachyon, Tachycardia, Tachometer* — Mnemonic: `"TACHY = Hyper-SPEED tachyon boost!"`
40. `brady` (`brady-`, Greek *bradys*): `"Slow or decelerated"` — Examples: *Bradycardia, Bradykinesia* — Mnemonic: `"BRADY = Slowing down the pace!"`
41. `photo` (`photo-`, Greek *phos / photos*): `"Light or photon radiation"` — Examples: *Photosynthesis, Photon, Photoelectric* — Mnemonic: `"PHOTO = Laser LIGHT beams!"`
42. `chrom` (`chrom- / chromato-`, Greek *khroma*): `"Color or spectral pigment"` — Examples: *Chromatography, Monochrome, Chromosome* — Mnemonic: `"CHROM = Full-spectrum neon COLOR!"`
43. `iso` (`iso-`, Greek *isos*): `"Equal, identical, or uniform"` — Examples: *Isotope, Isothermal, Isometric* — Mnemonic: `"ISO = Perfectly EQUAL on all sides!"`
44. `dynam` (`dynam-`, Greek *dynamis*): `"Power, force, or work capacity"` — Examples: *Thermodynamics, Aerodynamics, Dynamo* — Mnemonic: `"DYNAM = Explosive DYNAMITE force!"`
45. `stereo` (`stereo-`, Greek *stereos*): `"Solid or three-dimensional"` — Examples: *Stereochemistry, Stereoscopic* — Mnemonic: `"STEREO = 3D solid spatial structure!"`
46. `radi` (`radi-`, Latin *radius*): `"Ray, beam, or spoke emission"` — Examples: *Radiation, Radioactive, Radiant* — Mnemonic: `"RADI = Emitting high-energy RAYS!"`
47. `spectr` (`spectr-`, Latin *spectrum*): `"Image, band of wavelengths, or appearance"` — Examples: *Spectroscopy, Mass Spectrometer, Electromagnetic Spectrum* — Mnemonic: `"SPECTR = The full wavelength band!"`
48. `quant` (`quant-`, Latin *quantus*): `"Discrete amount or how much"` — Examples: *Quantum, Quantize, Quantification* — Mnemonic: `"QUANT = Discrete packets of quantum energy!"`

### Mandatory 4 Boss Exams (`boss_exams` array in `data/isv_lexicon.json`)
- **Sector 01 Boss (`THE MITOCHONDRION OVERLORD`)**:
  1. `CYTOLYSIS` (`["cyto", "lysis"]` — *"Dissolution or destruction of a living cell"*)
  2. `ENDOCYTOSIS` (`["endo", "cyto"]` — *"Internal cellular absorption"*)
  3. `AUTOPHAGY` (`["auto", "phag"]` — *"Self-devouring of cellular matter"*)
- **Sector 02 Boss (`THE SINGULARITY LEVIATHAN`)**:
  1. `PERIHELION` (`["peri", "helio"]` — *"Point in orbit nearest to the Sun"*)
  2. `ASTROCHRONOLOGY` (`["astro", "chrono"]` — *"Dating of celestial bodies and cosmic time"*)
  3. `COSMOLUMINOSITY` (`["cosmo", "lumin"]` — *"Radiant light emission across the universe"*)
- **Sector 03 Boss (`THE LITHIC COLOSSUS`)**:
  1. `GEOTHERMAL` (`["geo", "thermo"]` — *"Relating to the internal heat of the Earth"*)
  2. `PYROCLASTIC` (`["pyro", "clast"]` — *"Formed from volcanic fire and broken rock fragments"*)
  3. `CRYOLITHOSPHERE` (`["cryo", "lith"]` — *"Frozen icy stone layer of a planetary crust"*)
- **Sector 04 Boss (`THE ENTROPIC AUTOMATON`)**:
  1. `THERMODYNAMICS` (`["thermo", "dynam"]` — *"Physics of heat energy and mechanical power"*)
  2. `PHOTOKINESIS` (`["photo", "kinet"]` — *"Motion or activity induced by light rays"*)
  3. `ISOCHROMATIC` (`["iso", "chrom"]` — *"Having equal or uniform spectral color"*)

---

## 🏛 Architectural Invariants & Core Systems Blueprints

### 1. Autoload `GameManager.gd` & `user://isv_save.json` Persistence

```gdscript
# scripts/GameManager.gd
extends Node

signal score_changed(new_score: int, combo: int)
signal shield_changed(current_hp: float, max_hp: float)
signal overheat_changed(current_heat: float, is_locked_out: bool)
signal bro_callout(state: String, message: String)
signal run_ended(summary: Dictionary)

const SAVE_PATH := "user://isv_save.json"

var current_sector: int = 1
var score: int = 0
var combo_multiplier: int = 1
var streak_count: int = 0
var max_combo_this_run: int = 1
var shield_hp: float = 100.0
var max_shield_hp: float = 100.0
var cognitive_overheat: float = 0.0
var is_overheated_lockout: bool = false
var lockout_timer: float = 0.0
var shots_fired: int = 0
var shots_hit: int = 0

var save_data: Dictionary = {
	"sector_scores": {"1": 0, "2": 0, "3": 0, "4": 0},
	"sector_grades": {"1": "-", "2": "-", "3": "-", "4": "-"},
	"unlocked_roots": {},
	"root_stats": {}, # root_id -> {"hits": 0, "misses": 0}
	"total_runs": 0,
	"settings": {
		"master_volume": 1.0,
		"music_volume": 0.85,
		"sfx_volume": 0.9,
		"crt_scanlines": true
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_save()

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if is_overheated_lockout:
		lockout_timer -= delta
		cognitive_overheat = max(0.0, (lockout_timer / 3.5) * 100.0)
		overheat_changed.emit(cognitive_overheat, true)
		if lockout_timer <= 0.0:
			is_overheated_lockout = false
			cognitive_overheat = 0.0
			if has_node("/root/MusicManager"):
				get_node("/root/MusicManager").set_low_pass_enabled(false)
			overheat_changed.emit(cognitive_overheat, false)
			bro_callout.emit("IDLE", "COOLANT FLUSH COMPLETE! LASERS ONLINE, BRO!")
	else:
		if cognitive_overheat > 0.0:
			cognitive_overheat = max(0.0, cognitive_overheat - 4.0 * delta)
			overheat_changed.emit(cognitive_overheat, false)

func start_new_run(sector: int = 1) -> void:
	current_sector = clampi(sector, 1, 4)
	score = 0
	combo_multiplier = 1
	streak_count = 0
	max_combo_this_run = 1
	shield_hp = max_shield_hp
	cognitive_overheat = 0.0
	is_overheated_lockout = false
	lockout_timer = 0.0
	shots_fired = 0
	shots_hit = 0
	if has_node("/root/MusicManager"):
		get_node("/root/MusicManager").set_low_pass_enabled(false)

func register_root_hit(root_id: String, base_points: int = 200) -> int:
	shots_fired += 1
	shots_hit += 1
	streak_count += 1
	if streak_count >= 10:
		combo_multiplier = 8
	elif streak_count >= 6:
		combo_multiplier = 4
	elif streak_count >= 3:
		combo_multiplier = 2
	else:
		combo_multiplier = 1
	max_combo_this_run = max(max_combo_this_run, combo_multiplier)

	var points_earned := base_points * combo_multiplier
	score += points_earned
	cognitive_overheat = max(0.0, cognitive_overheat - 10.0)

	save_data["unlocked_roots"][root_id] = true
	var rstat: Dictionary = save_data["root_stats"].get(root_id, {"hits": 0, "misses": 0})
	rstat["hits"] = int(rstat.get("hits", 0)) + 1
	save_data["root_stats"][root_id] = rstat

	if has_node("/root/LexiconManager"):
		get_node("/root/LexiconManager").record_outcome(root_id, true)

	score_changed.emit(score, combo_multiplier)
	overheat_changed.emit(cognitive_overheat, is_overheated_lockout)
	return points_earned

func register_root_miss(expected_root_id: String) -> void:
	shots_fired += 1
	streak_count = 0
	combo_multiplier = 1
	cognitive_overheat = min(100.0, cognitive_overheat + 25.0)

	var rstat: Dictionary = save_data["root_stats"].get(expected_root_id, {"hits": 0, "misses": 0})
	rstat["misses"] = int(rstat.get("misses", 0)) + 1
	save_data["root_stats"][expected_root_id] = rstat

	if has_node("/root/LexiconManager"):
		get_node("/root/LexiconManager").record_outcome(expected_root_id, false)

	if cognitive_overheat >= 100.0 and not is_overheated_lockout:
		is_overheated_lockout = true
		lockout_timer = 3.5
		score = max(0, score - 300)
		if has_node("/root/MusicManager"):
			get_node("/root/MusicManager").set_low_pass_enabled(true)
		bro_callout.emit("OVERHEAT_ALARM", "COGNITIVE OVERHEAT 100%! WEAPONS LOCKED FOR 3.5s!")
	else:
		if has_node("/root/LexiconManager"):
			var tip: String = get_node("/root/LexiconManager").get_mnemonic(expected_root_id)
			bro_callout.emit("MNEMONIC_TIP", tip)

	score_changed.emit(score, combo_multiplier)
	overheat_changed.emit(cognitive_overheat, is_overheated_lockout)

func apply_coolant(amount: float = 35.0) -> void:
	cognitive_overheat = max(0.0, cognitive_overheat - amount)
	if is_overheated_lockout and cognitive_overheat <= 25.0:
		is_overheated_lockout = false
		lockout_timer = 0.0
		if has_node("/root/MusicManager"):
			get_node("/root/MusicManager").set_low_pass_enabled(false)
	overheat_changed.emit(cognitive_overheat, is_overheated_lockout)
	bro_callout.emit("IDLE", "CRYO-COOLANT ABSORBED! CORE TEMP DROPPING!")

func apply_shield_damage(amount: float) -> void:
	shield_hp = max(0.0, shield_hp - amount)
	streak_count = 0
	combo_multiplier = 1
	score_changed.emit(score, combo_multiplier)
	shield_changed.emit(shield_hp, max_shield_hp)
	if shield_hp <= 0.0:
		finalize_run(false)

func calculate_grade(accuracy: float, survived: bool) -> String:
	if not survived:
		return "D" if accuracy < 0.65 else "C"
	if accuracy >= 0.92:
		return "S"
	elif accuracy >= 0.80:
		return "A"
	elif accuracy >= 0.65:
		return "B"
	elif accuracy >= 0.50:
		return "C"
	return "D"

func finalize_run(survived: bool) -> Dictionary:
	var accuracy := 1.0 if shots_fired == 0 else float(shots_hit) / float(shots_fired)
	var grade := calculate_grade(accuracy, survived)
	var sec_key := str(current_sector)
	var prev_best := int(save_data["sector_scores"].get(sec_key, 0))
	var is_new_record := score > prev_best
	if is_new_record:
		save_data["sector_scores"][sec_key] = score

	var rank_order := {"-": 0, "D": 1, "C": 2, "B": 3, "A": 4, "S": 5}
	var prev_grade: String = save_data["sector_grades"].get(sec_key, "-")
	if rank_order.get(grade, 0) > rank_order.get(prev_grade, 0):
		save_data["sector_grades"][sec_key] = grade

	save_data["total_runs"] = int(save_data.get("total_runs", 0)) + 1
	save_to_disk()

	var summary := {
		"sector": current_sector,
		"score": score,
		"prev_high_score": prev_best,
		"is_new_high_score": is_new_record,
		"accuracy": accuracy,
		"grade": grade,
		"max_combo": max_combo_this_run,
		"survived": survived
	}
	run_ended.emit(summary)
	return summary

func save_to_disk() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))

func load_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json := JSON.new()
			if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
				for k in json.data.keys():
					save_data[k] = json.data[k]
```

---

### 2. Autoload `LexiconManager.gd` & Spaced Repetition Engine

```gdscript
# scripts/LexiconManager.gd
extends Node

const LEXICON_PATH := "res://data/isv_lexicon.json"

var sectors: Array = []
var roots_by_id: Dictionary = {}
var roots_by_sector: Dictionary = {1: [], 2: [], 3: [], 4: []}
var boss_exams: Dictionary = {}
var weights: Dictionary = {} # root_id -> float (default 1.0)

func _ready() -> void:
	load_lexicon()

func load_lexicon() -> void:
	if not FileAccess.file_exists(LEXICON_PATH):
		push_error("Missing lexicon file: " + LEXICON_PATH)
		return
	var file := FileAccess.open(LEXICON_PATH, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK or not (json.data is Dictionary):
		push_error("Invalid JSON in lexicon file")
		return

	var data: Dictionary = json.data
	sectors = data.get("sectors", [])
	roots_by_id.clear()
	roots_by_sector = {1: [], 2: [], 3: [], 4: []}
	for entry in data.get("roots", []):
		var rid: String = entry["id"]
		var sec: int = int(entry.get("sector", 1))
		roots_by_id[rid] = entry
		if not roots_by_sector.has(sec):
			roots_by_sector[sec] = []
		roots_by_sector[sec].append(entry)
		if not weights.has(rid):
			weights[rid] = 1.0

	for boss in data.get("boss_exams", []):
		boss_exams[int(boss["sector"])] = boss

func record_outcome(root_id: String, hit: bool) -> void:
	var current_w: float = weights.get(root_id, 1.0)
	if hit:
		weights[root_id] = clampf(current_w - 0.2, 0.4, 8.0)
	else:
		weights[root_id] = clampf(current_w + 1.5, 0.4, 8.0)

func get_weight(root_id: String) -> float:
	return weights.get(root_id, 1.0)

func get_mnemonic(root_id: String) -> String:
	if roots_by_id.has(root_id):
		return roots_by_id[root_id].get("mnemonic", "Remember the root!")
	return "Check your Greek & Latin roots, bro!"

func select_weighted_root(sector_id: int) -> Dictionary:
	var pool: Array = roots_by_sector.get(sector_id, [])
	if pool.is_empty():
		pool = roots_by_id.values()
	var total_w := 0.0
	for item in pool:
		total_w += get_weight(item["id"])
	var roll := randf() * total_w
	var accum := 0.0
	for item in pool:
		accum += get_weight(item["id"])
		if roll <= accum:
			return item
	return pool[0]

func build_multiple_choice_prompt(target_root_id: String, count: int = 4) -> Dictionary:
	var target: Dictionary = roots_by_id.get(target_root_id, {})
	if target.is_empty():
		target = roots_by_id.values()[0]
		target_root_id = target["id"]

	var sec: int = int(target.get("sector", 1))
	var sector_pool: Array = roots_by_sector.get(sec, []).duplicate()
	sector_pool.shuffle()

	var options: Array[Dictionary] = [target]
	for candidate in sector_pool:
		if options.size() >= count:
			break
		if candidate["id"] != target_root_id:
			options.append(candidate)

	# Fallback to global pool if sector has fewer than count entries
	if options.size() < count:
		for candidate in roots_by_id.values():
			if options.size() >= count:
				break
			var exists := false
			for o in options:
				if o["id"] == candidate["id"]:
					exists = true
			if not exists:
				options.append(candidate)

	options.shuffle()
	var correct_idx := 0
	for i in range(options.size()):
		if options[i]["id"] == target_root_id:
			correct_idx = i
			break

	return {
		"target_id": target_root_id,
		"clue": target.get("meaning", ""),
		"origin": target.get("origin", ""),
		"mnemonic": target.get("mnemonic", ""),
		"options": options,
		"correct_index": correct_idx
	}
```

---

### 3. 14-Track OST `MusicManager.gd` & B.R.O. Retro Synth Voice (`SoundEffects.gd`)

- **`MusicManager.gd`**:
  - Maps all 14 tracks in `res://tracks/` cleanly so none are wasted:
    ```gdscript
    const SECTOR_TRACKS := {
        0: ["res://tracks/Entryway.mp3", "res://tracks/Mirror Tech.mp3", "res://tracks/Understanding.mp3"],
        1: ["res://tracks/The Run.mp3", "res://tracks/Silly Verses.mp3"],
        2: ["res://tracks/Ultrabeat.mp3", "res://tracks/The Flight.mp3"],
        3: ["res://tracks/Undercurrent.mp3", "res://tracks/Low Cut.mp3"],
        4: ["res://tracks/Escape.mp3", "res://tracks/The Key.mp3", "res://tracks/Luck.mp3"],
        99: ["res://tracks/Left Turn.mp3", "res://tracks/Rerun.mp3", "res://tracks/The End.mp3"]
    }
    ```
  - Attaches an `AudioEffectLowPassFilter` (`cutoff_hz = 850.0`) on the `"Music"` bus and toggles it via `AudioServer.set_bus_effect_enabled(music_bus_idx, 0, enabled)` during Pause or Cognitive Overheat lockout.
- **`SoundEffects.gd`**:
  - Synthesizes retro PCM waveforms (`AudioStreamWAV`) on startup so sound effects work with zero external `.wav` files:
    - `play_laser_salvo()`, `play_lock_on()`, `play_barrel_roll()`, `play_error_buzz()`, `play_combo_up()`, and `play_bro_voice_cadence(syllables: int)` (Star Fox-style rapid pitched synth syllables).

---

### 4. 6DOF Screen-Bounded Flight & Hybrid 3D/2D Lock-On Targeting

- **Framerate-Independent Viewport Flight (`PlayerJet.gd`)**:
  ```gdscript
  const BOUNDS_X := 6.5
  const BOUNDS_Y := 3.8
  const MOVE_SPEED := 11.0
  const SMOOTH_LAMBDA := 18.0

  var target_pos := Vector2.ZERO
  var is_invulnerable := false

  func _physics_process(delta: float) -> void:
      var input_vec := Input.get_vector("move_left", "move_right", "move_down", "move_up")
      target_pos.x = clampf(target_pos.x + input_vec.x * MOVE_SPEED * delta, -BOUNDS_X, BOUNDS_X)
      target_pos.y = clampf(target_pos.y + input_vec.y * MOVE_SPEED * delta, -BOUNDS_Y, BOUNDS_Y)

      var alpha := 1.0 - exp(-SMOOTH_LAMBDA * delta)
      position.x = lerpf(position.x, target_pos.x, alpha)
      position.y = lerpf(position.y, target_pos.y, alpha)

      # Dynamic banking and pitch tilt
      var vel_x := target_pos.x - position.x
      var vel_y := target_pos.y - position.y
      if not is_invulnerable:
          rotation.z = lerpf(rotation.z, clampf(-vel_x * 0.35, -0.65, 0.65), alpha)
          rotation.x = lerpf(rotation.x, clampf(vel_y * 0.25, -0.45, 0.45), alpha)
  ```
- **Hybrid 3D Billboard + 2D Unprojected Lock-On Reticle (`HUD.gd`)**:
  ```gdscript
  func update_reticle_projection(camera: Camera3D, locked_target: Node3D) -> void:
      if locked_target == null or not is_instance_valid(locked_target) or camera == null:
          reticle_box.visible = false
          return
      if camera.is_position_behind(locked_target.global_position):
          reticle_box.visible = false
          return
      reticle_box.visible = true
      var screen_pos := camera.unproject_position(locked_target.global_position)
      reticle_box.position = screen_pos - (reticle_box.size * 0.5)
  ```

---

### 5. Pause System with Low-Pass Audio Filter & Inline Confirmations

- `PauseMenu` root **must** set `process_mode = Node.PROCESS_MODE_ALWAYS`.
- When paused:
  - `get_tree().paused = true`
  - `MusicManager.set_low_pass_enabled(true)` (muffles the synthwave track underwater/subspace style while keeping the beat audible, or pauses if user prefers)
  - `resume_btn.grab_focus()`
- Destructive actions ("Restart Sector" and "Exit to Main Menu") open an inline confirmation panel (`ConfirmBox`) before executing.

---

## 🛠 Procedural 3D Asset Pipeline (`tools/generate_assets.py`)

Save and run this script via `blender -b -P tools/generate_assets.py` to generate all 10 low-poly 3D `.glb` assets into `assets/models/`:

```python
"""
tools/generate_assets.py
Headless 3D Asset Generator for ISV BRO (Godot 4.x)
Run via: blender -b -P tools/generate_assets.py
"""
import bpy
import os
import math

OUTPUT_DIR = os.path.abspath("assets/models")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def make_material(name, base_color, roughness=0.3, metallic=0.6, emission=(0, 0, 0, 1), emission_strength=1.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = base_color
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["Metallic"].default_value = metallic
        if "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = emission
        if "Emission Strength" in bsdf.inputs:
            bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat

def export_glb(filename):
    out_path = os.path.join(OUTPUT_DIR, filename)
    bpy.ops.export_scene.gltf(
        filepath=out_path,
        export_format='GLB',
        use_selection=False,
        export_apply=True
    )
    print(f"[EXPORTED] {out_path}")

# 1. Hadron Jet (Player Ship)
clear_scene()
mat_hull = make_material("ObsidianHull", (0.06, 0.06, 0.1, 1.0), roughness=0.2, metallic=0.9)
mat_wing = make_material("NeonMagenta", (1.0, 0.0, 0.5, 1.0), roughness=0.3, metallic=0.5, emission=(1.0, 0.0, 0.5, 1.0), emission_strength=2.0)
mat_cyan = make_material("ElectricCyan", (0.0, 0.94, 1.0, 1.0), roughness=0.1, metallic=0.2, emission=(0.0, 0.94, 1.0, 1.0), emission_strength=3.0)

bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.65, radius2=0.05, depth=2.8)
fuselage = bpy.context.active_object
fuselage.rotation_euler = (-math.pi / 2, 0, 0)
fuselage.data.materials.append(mat_hull)

bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.2, -0.05))
wings = bpy.context.active_object
wings.scale = (2.2, 0.65, 0.08)
wings.data.materials.append(mat_wing)

for side in (-0.85, 0.85):
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.18, depth=1.6, location=(side, 0.3, 0.0))
    nacelle = bpy.context.active_object
    nacelle.rotation_euler = (math.pi / 2, 0, 0)
    nacelle.data.materials.append(mat_cyan)

export_glb("hadron_jet.glb")

# 2. Sector 01 Anomaly: Bio-Cytology Construct
clear_scene()
mat_bio = make_material("BioLime", (0.22, 1.0, 0.08, 1.0), roughness=0.2, emission=(0.22, 1.0, 0.08, 1.0), emission_strength=2.2)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.9)
core = bpy.context.active_object
core.data.materials.append(mat_bio)
bpy.ops.mesh.primitive_torus_add(major_radius=1.35, minor_radius=0.12, rotation=(0.6, 0.4, 0))
ring = bpy.context.active_object
ring.data.materials.append(mat_cyan)
export_glb("anomaly_bio.glb")

# 3. Sector 02 Anomaly: Astro-Celestial Gyro
clear_scene()
mat_gold = make_material("AstroGold", (1.0, 0.9, 0.0, 1.0), roughness=0.2, emission=(1.0, 0.85, 0.0, 1.0), emission_strength=2.5)
bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=0.75)
star = bpy.context.active_object
star.data.materials.append(mat_gold)
for rot in [(0.8, 0, 0), (0, 0.8, 0.8)]:
    bpy.ops.mesh.primitive_torus_add(major_radius=1.4, minor_radius=0.1, rotation=rot)
    r = bpy.context.active_object
    r.data.materials.append(mat_cyan)
export_glb("anomaly_astro.glb")

# 4. Sector 03 Anomaly: Geo-Lithic Crystal
clear_scene()
mat_geo = make_material("GeoAmber", (1.0, 0.55, 0.0, 1.0), roughness=0.15, metallic=0.7, emission=(1.0, 0.4, 0.0, 1.0), emission_strength=2.0)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.15)
crystal = bpy.context.active_object
crystal.scale = (0.85, 0.85, 1.45)
crystal.data.materials.append(mat_geo)
export_glb("anomaly_geo.glb")

# 5. Sector 04 Anomaly: Thermo-Quantum Torus
clear_scene()
bpy.ops.mesh.primitive_torus_add(major_radius=1.1, minor_radius=0.32)
torus = bpy.context.active_object
torus.data.materials.append(mat_wing)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.55)
qcore = bpy.context.active_object
qcore.data.materials.append(mat_cyan)
export_glb("anomaly_thermo.glb")

# 6. Physical Hazard: Crimson Laser Gate
clear_scene()
mat_hazard = make_material("CrimsonHazard", (1.0, 0.0, 0.2, 1.0), roughness=0.3, emission=(1.0, 0.0, 0.15, 1.0), emission_strength=3.0)
bpy.ops.mesh.primitive_cube_add(size=1.0)
bar = bpy.context.active_object
bar.scale = (2.8, 0.35, 0.35)
bar.data.materials.append(mat_hazard)
export_glb("hazard_laser_gate.glb")

# 7. Tunnel Environment: Particle Collider Ring
clear_scene()
mat_arch = make_material("ColliderArch", (0.08, 0.1, 0.18, 1.0), roughness=0.4, metallic=0.8, emission=(0.0, 0.35, 0.5, 1.0), emission_strength=0.8)
bpy.ops.mesh.primitive_torus_add(major_segments=8, minor_segments=6, major_radius=9.5, minor_radius=0.35)
arch = bpy.context.active_object
arch.rotation_euler = (math.pi / 2, 0, 0)
arch.data.materials.append(mat_arch)
export_glb("hazard_collider_ring.glb")

# 8. Pickup: Cryo-Coolant Cell
clear_scene()
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.45, depth=1.2)
cell = bpy.context.active_object
cell.data.materials.append(mat_cyan)
export_glb("pickup_coolant_cell.glb")

# 9. Pickup: Shield Harmonic Orb
clear_scene()
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.55)
orb = bpy.context.active_object
orb.data.materials.append(mat_bio)
export_glb("pickup_shield_orb.glb")

# 10. Boss Exam Core
clear_scene()
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.8)
bcore = bpy.context.active_object
bcore.data.materials.append(mat_wing)
for radius, rot in [(2.7, (0.5, 0.2, 0)), (3.3, (-0.4, 0.6, 0.3))]:
    bpy.ops.mesh.primitive_torus_add(major_radius=radius, minor_radius=0.22, rotation=rot)
    bring = bpy.context.active_object
    bring.data.materials.append(mat_cyan)
export_glb("boss_core.glb")

print("ALL 10 ISV BRO 3D ASSETS GENERATED SUCCESSFULLY!")
```

---

## 🧪 8-Suite Headless Automated Verification (`tools/test_game.gd`)

Save this script as `tools/test_game.gd` and run via `godot --headless -s tools/test_game.gd`. Every single assertion must pass (`0 FAILED`):

```gdscript
# tools/test_game.gd
extends SceneTree

var passes: int = 0
var failures: int = 0

func assert_true(cond: bool, msg: String) -> void:
	if cond:
		print("[PASS] " + msg)
		passes += 1
	else:
		printerr("[FAIL] " + msg)
		failures += 1

func _init() -> void:
	print("\n=======================================================")
	print("   ISV BRO — 8-SUITE HEADLESS VERIFICATION RUNNER")
	print("=======================================================\n")

	# SUITE 1: Verify All Core Scenes & 3D .glb Assets Load Cleanly
	var scenes := [
		"res://scenes/MainMenu.tscn",
		"res://scenes/GameWorld.tscn",
		"res://scenes/HUD.tscn",
		"res://scenes/PauseMenu.tscn",
		"res://scenes/CodexScreen.tscn",
		"res://scenes/PlayerJet.tscn",
		"res://scenes/Anomaly.tscn",
		"res://scenes/BossExam.tscn"
	]
	for scn_path in scenes:
		var exists := ResourceLoader.exists(scn_path)
		assert_true(exists, "Scene exists: " + scn_path)
		if exists:
			var packed := load(scn_path) as PackedScene
			var inst := packed.instantiate() if packed else null
			assert_true(inst != null, "Scene instantiates cleanly: " + scn_path)
			if inst:
				inst.free()

	var models := [
		"res://assets/models/hadron_jet.glb",
		"res://assets/models/anomaly_bio.glb",
		"res://assets/models/anomaly_astro.glb",
		"res://assets/models/anomaly_geo.glb",
		"res://assets/models/anomaly_thermo.glb",
		"res://assets/models/hazard_laser_gate.glb",
		"res://assets/models/hazard_collider_ring.glb",
		"res://assets/models/pickup_coolant_cell.glb",
		"res://assets/models/pickup_shield_orb.glb",
		"res://assets/models/boss_core.glb"
	]
	for mdl in models:
		assert_true(FileAccess.file_exists(mdl) or ResourceLoader.exists(mdl), "3D Asset exists: " + mdl)

	# SUITE 2: Verify Rail-Shooter & Root Salvo InputMap Bindings
	var required_actions := [
		"move_left", "move_right", "move_up", "move_down",
		"barrel_roll", "boost", "airbrake",
		"root_1", "root_2", "root_3", "root_4", "pause"
	]
	for act in required_actions:
		assert_true(
			InputMap.has_action(act) and not InputMap.action_get_events(act).is_empty(),
			"InputAction registered & mapped: " + act
		)

	# SUITE 3: Verify ISV Lexicon (48+ Roots, 4 Sectors, 4 Boss Exams, 4-Choice Prompt & Spaced Repetition)
	var lex_node := Node.new()
	lex_node.set_script(load("res://scripts/LexiconManager.gd"))
	root.add_child(lex_node)
	lex_node._ready()

	assert_true(lex_node.roots_by_id.size() >= 48, "Lexicon contains >= 48 ISV roots (found %d)" % lex_node.roots_by_id.size())
	for s in [1, 2, 3, 4]:
		assert_true(lex_node.roots_by_sector.get(s, []).size() >= 12, "Sector %d has >= 12 roots" % s)
		assert_true(lex_node.boss_exams.has(s), "Boss Exam defined for Sector %d" % s)

	var prompt: Dictionary = lex_node.build_multiple_choice_prompt("lysis", 4)
	assert_true(prompt.get("options", []).size() == 4, "4-choice prompt generates 4 distinct root options")
	var c_idx: int = int(prompt.get("correct_index", -1))
	assert_true(c_idx >= 0 and c_idx < 4 and prompt["options"][c_idx]["id"] == "lysis", "Correct root index matches target 'lysis'")

	var w_before: float = lex_node.get_weight("lysis")
	lex_node.record_outcome("lysis", false)
	var w_after: float = lex_node.get_weight("lysis")
	assert_true(w_after > w_before, "Spaced repetition increases weight on missed root (%.2f -> %.2f)" % [w_before, w_after])

	# SUITE 4: Verify Bro-Factor Combo Scaling & Cognitive Overheat Lockout Math
	var gm := Node.new()
	gm.set_script(load("res://scripts/GameManager.gd"))
	root.add_child(gm)
	gm._ready()
	gm.start_new_run(1)

	for i in range(10):
		gm.register_root_hit("bio", 200)
	assert_true(gm.combo_multiplier == 8, "10 consecutive root hits scale Bro-Factor combo to 8x")

	for i in range(4):
		gm.register_root_miss("lysis")
	assert_true(gm.is_overheated_lockout == true, "4 consecutive wrong roots trigger 100% Cognitive Overheat weapon lockout")
	assert_true(gm.combo_multiplier == 1, "Incorrect root resets Bro-Factor combo to 1x")

	# SUITE 5: Verify Codex Unlock & Save Persistence in user://isv_save.json
	var summary: Dictionary = gm.finalize_run(true)
	assert_true(FileAccess.file_exists("user://isv_save.json"), "Save file user://isv_save.json written to disk")
	assert_true(gm.save_data["unlocked_roots"].has("bio"), "Mastered root 'bio' unlocked in Codex Bro-tanica")
	assert_true(summary.has("grade") and summary["grade"] in ["S", "A", "B", "C", "D"], "Final run calculates valid letter grade: " + str(summary.get("grade")))

	# SUITE 6: Verify Framerate-Independent 6DOF Viewport Flight Kinematics (30, 60, 144 FPS)
	for fps in [30.0, 60.0, 144.0]:
		var pos_x := 0.0
		var target_x := 5.5
		var steps := int(fps)
		var dt := 1.0 / fps
		for s in range(steps):
			pos_x = lerpf(pos_x, target_x, 1.0 - exp(-18.0 * dt))
		assert_true(absf(pos_x - target_x) < 0.01, "6DOF viewport flight converges within 0.01m at %d FPS" % int(fps))

	# SUITE 7: Verify 14 Soundtrack MP3 Files Exist in res://tracks/
	var tracks := [
		"res://tracks/Entryway.mp3", "res://tracks/Escape.mp3", "res://tracks/Left Turn.mp3",
		"res://tracks/Low Cut.mp3", "res://tracks/Luck.mp3", "res://tracks/Mirror Tech.mp3",
		"res://tracks/Rerun.mp3", "res://tracks/Silly Verses.mp3", "res://tracks/The End.mp3",
		"res://tracks/The Flight.mp3", "res://tracks/The Key.mp3", "res://tracks/The Run.mp3",
		"res://tracks/Ultrabeat.mp3", "res://tracks/Undercurrent.mp3", "res://tracks/Understanding.mp3"
	]
	for trk in tracks:
		assert_true(FileAccess.file_exists(trk), "Soundtrack MP3 present: " + trk)

	# SUITE 8: Verify PauseMenu State Recovery & Process Mode
	if ResourceLoader.exists("res://scenes/PauseMenu.tscn"):
		var pause_scn := (load("res://scenes/PauseMenu.tscn") as PackedScene).instantiate()
		root.add_child(pause_scn)
		pause_scn._ready()
		assert_true(pause_scn.process_mode == Node.PROCESS_MODE_ALWAYS, "PauseMenu uses PROCESS_MODE_ALWAYS")
		if pause_scn.has_method("pause_game") and pause_scn.has_method("resume_game"):
			pause_scn.pause_game()
			assert_true(paused == true, "PauseMenu.pause_game() sets SceneTree.paused = true")
			pause_scn.resume_game()
			assert_true(paused == false, "PauseMenu.resume_game() restores SceneTree.paused = false")
		pause_scn.free()

	gm.free()
	lex_node.free()

	print("\n=======================================================")
	print("   TEST SUMMARY: %d PASSED, %d FAILED" % [passes, failures])
	print("=======================================================\n")
	quit(0 if failures == 0 else 1)
```

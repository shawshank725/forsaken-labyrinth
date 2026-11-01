# The Forsaken Labyrinth

A 2D dark-fantasy puzzle-platformer prototype built with **Godot 4.3**.

You wake up alone inside a trap-filled castle. Your goal is simple: find the eight lost artifacts, survive the castle's hazards, and escape through the exit before your health runs out.

> **Note:** This is my first game ever made with Godot, and it is a prototype. It is not a finished commercial release, but it is a complete short playable experience with a beginning, an objective, and an ending.

---

## Table of Contents

- [Play the Game](#play-the-game)
- [Screenshots](#screenshots)
- [Controls](#controls)
- [Gameplay](#gameplay)
- [Features](#features)
- [Technical Overview](#technical-overview)
- [Web Export and the SharedArrayBuffer Issue](#web-export-and-the-sharedarraybuffer-issue)
- [Project Structure](#project-structure)
- [Running from Source](#running-from-source)
- [Exporting the Game](#exporting-the-game)
- [Prototype Limitations](#prototype-limitations)
- [Credits](#credits)
- [License and Copyright](#license-and-copyright)

---

## Play the Game

The exported browser build is in the `game-html-build/` folder. Open `game-html-build/index.html` through a local web server, or use the Play button on the project home page (`index.html`).

A Windows desktop export is also configured in `export_presets.cfg`.

**Requirements:** a modern web browser and an internet connection for the first load. The web build is a PC-oriented game and is best played with a keyboard and mouse.

---

## Screenshots

| Main Menu | Lighting System |
| --- | --- |
| ![Main menu](images/mainmenu.PNG) | ![Lighting system](images/lights.PNG) |

![Level](images/level.PNG)

---

## Controls

| Input | Action |
| --- | --- |
| Up arrow | Jump |
| Left / Right arrows | Move |
| Down arrow | Drop through one-way platforms and climb ladders |
| Left mouse button | Interact with levers and collect items |
| Right mouse button | Teleport to a valid empty location |
| Mouse wheel | Zoom the camera in / out |
| Escape | Pause or open the pause menu |

---

## Gameplay

- **Objective:** Collect all eight artifacts, then reach the exit. The artifacts are two keys, a black stone, a wand, a sword, an armor, a shield, and the treasure. Progress is tracked in the inventory panel.
- **Health:** Health drains slowly over time, so the castle itself is a soft time limit. Traps deal additional damage. Health potions restore health.
- **Teleportation:** Right-click to teleport to an empty tile. Teleportation is limited to 450 units of distance, costs teleportation potion, and has a 20-second cooldown. It is blocked inside the trap room.
- **Teleportation potion:** Used as the resource for teleporting. Collect potions around the castle to refill it.
- **Alchemy Lab curse:** Standing in the alchemy lab drains health faster, so you cannot linger there.
- **Traps:** Saws, swinging blades, spikes, and cutters are placed throughout the castle. They test timing and reflexes.
- **Rooms:** The level is split into connected rooms, including the Entrance Hall, Kitchen, Catacombs, Prison, Guard Hall, Armory, Trap Room, Alchemy Laboratory, and Throne Room. Doors move the player between areas.
- **Final escape:** Once every artifact is collected, the exit becomes available. Reaching it plays the ending scene.

---

## Features

- 2D side-scrolling movement with idle, run, jump, fall, and death animations.
- Teleportation with distance limits, a cooldown, and a consumable potion resource.
- Health and teleportation potion bars with collectible refills.
- Eight collectible artifacts with inventory icons.
- Dynamic lighting using `CanvasModulate`, `DirectionalLight2D`, and torch lights.
- One-way platforms and climbable ladders.
- Interactive levers that change the lighting state of the room.
- Multiple trap types: saws, spikes, cutters, and swinging sword traps.
- Room-based location labels and door transitions.
- Pause menu, inventory popup, death popup, and restart / return to menu options.
- Intro story scene, help screen, credits screen, and ending screen.
- Background music and sound effects for jumping, collecting treasure, and drinking potions.

---

## Technical Overview

### Engine and rendering

- **Engine:** Godot 4.3 (standard build)
- **Renderer:** Mobile (`renderer/rendering_method="mobile"`)
- **Main scene:** `scenes/main.tscn`
- **Window:** fixed-size, non-resizable
- **Language:** GDScript
- **Audio:** a global `MusicPlayer` autoload (`Global/music_player.gd`) handles music and sound effects across scenes.

### Main systems

| System | Where it lives | How it works |
| --- | --- | --- |
| Player movement | `scripts/player.gd` | `CharacterBody2D` with gravity, jump velocity, horizontal speed, and animation state switching. |
| Level logic | `scripts/level_1.gd` | The largest script. Handles collectibles, teleportation, health and potion bars, traps, doors, levers, inventory, pause, death, and the exit condition. |
| Menus and scene flow | `scripts/main.gd`, `starting_story.gd`, `ending.gd` | Uses `change_scene_to_file` / `change_scene_to_packed` and `Tween` animations for transitions. |
| Tilemap | `scenes/tile_map.tscn`, `scripts/tile_map.gd` | Castle tiles are painted in a `TileMap`; mouse input is consumed so gameplay clicks do not leak into the tilemap. |
| Traps | `scenes/saw.tscn`, `spikes.tscn`, `cutter.tscn`, `laser.tscn`, `sword_trap.tscn` | Each trap is a reusable scene with an `Area2D` hurtbox and, where needed, an `AnimationPlayer`. |
| Lighting | `level_1.tscn`, `scenes/torch.tscn`, `torch_animated.tscn` | A dark `CanvasModulate` plus light nodes create the castle atmosphere. Torches can be toggled by the lever. |
| UI and input | `scenes/level_1.tscn`, `scripts/Control.gd` | Health bar, potion bar, dialog label, inventory, pause panel, death panel, and location labels. |

### Design approach

The project uses Godot's scene system heavily: each trap, the player, the torch, and the level are separate scenes. Reusable scenes are instanced into the level, while `level_1.gd` coordinates them through exported node references and `@onready` variables.

Most gameplay logic is event-driven through `Area2D` signals such as `body_entered`, `body_exited`, and `input_event`. Visual feedback (fades, screen shake, collectible pickup animation, location label typing) is done with `Tween`.

---

## Web Export and the SharedArrayBuffer Issue

The browser build runs Godot's threaded WebAssembly export. Threads require `SharedArrayBuffer`, and browsers only expose `SharedArrayBuffer` on pages that are **cross-origin isolated**. That means the page must be served with these HTTP headers:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

Godot 4.2 had this issue during development. The Godot contributors resolved the underlying problem upstream, and **I solved it for this project by upgrading to Godot 4.3**. The 4.3 export includes a service worker (`index.service.worker.js`) that injects the required COOP/COEP headers, and the export preset enables `variant/thread_support=true` with `progressive_web_app/ensure_cross_origin_isolation_headers=true`.

Practical consequences:

- The web build must be served over **HTTPS or localhost**. Opening `index.html` directly from disk will not work.
- Keep `index.service.worker.js` next to the exported files.
- If you host the build yourself, make sure your server does not strip the service worker or block it.
- The first load is large because the WebAssembly binary is about 47 MB and the game data pack is about 24 MB.

---

## Project Structure

```
The Forsaken Labyrinth/
|-- index.html                  Home page for the game
|-- index.css                   Styling for the home page
|-- images/                     Screenshots, icon, and site assets
|-- game-html-build/            Exported browser build (HTML, WASM, PCK)
|-- game-source-code-4.2/       Earlier Godot 4.2 iteration, kept for reference
`-- game-source-code-4.3/       Current Godot 4.3 project
    |-- project.godot           Engine and input configuration
    |-- export_presets.cfg      Web and Windows export settings
    |-- scenes/                 Levels, player, traps, menus, UI scenes
    |-- scripts/                GDScript gameplay and menu logic
    |-- assets/                 Sprites, tilesets, sounds, fonts, UI art
    |-- Global/                 MusicPlayer autoload
    `-- font settings/          Label theme / font resources
```

### Important scripts

- `scripts/player.gd` - player movement and animation.
- `scripts/level_1.gd` - main gameplay controller.
- `scripts/main.gd` - main menu buttons and scene changes.
- `scripts/starting_story.gd` - intro text reveal and skip button.
- `scripts/ending.gd` - ending text and return to menu.
- `scripts/help_scene.gd`, `scripts/credits_scene.gd` - help and credits navigation.
- `scripts/tile_map.gd`, `scripts/Control.gd` - input handling helpers.
- `Global/music_player.gd` - global audio autoload.

---

## Running from Source

1. Install **Godot 4.3** (standard version).
2. Open `game-source-code-4.3/project.godot`.
3. Let Godot import the assets on first open.
4. Press **F5** to run the project.

The main scene is `scenes/main.tscn`, so the game starts at the main menu.

If you open the 4.2 folder, use a matching 4.2 editor. The 4.3 folder is the maintained version.

---

## Exporting the Game

The project contains two export presets:

- **Web** - outputs to `../index.html` with threaded WebAssembly and PWA support.
- **Windows Desktop** - outputs a 64-bit Windows executable with the PCK embedded.

To export, install the matching export templates in Godot 4.3, open **Project > Export**, choose a preset, and export. For the web build, serve the output through a server that supports the service worker and cross-origin isolation described above.

---

## Prototype Limitations

This is a first Godot project and a prototype, so some parts are intentionally simple:

- One main level.
- Hard-coded player positions for doors and room transitions.
- No save system, settings persistence, or remappable controls.
- The sound toggle in the main menu is currently commented out.
- Desktop-first design; the web build works on PC but is not a mobile touch game.
- Some visual and audio assets are third-party packs with their own licenses.
- The web build has a long initial download because of the WebAssembly and PCK sizes.

---

## Credits

Game design, programming, and level assembly: **Shashank Verma (PixelForge Studios)**.

Art and audio assets were created by the following people and studios:

- **Ssugmi** and **RavenMore** - armory and weapon assets.
- **Lexlom** - Black Monolith artifact.
- **NVPH Studio** - alchemy set.
- **Free Game Assets (GUI, Sprite, Tilesets)** - magic potion icons.
- **UnIsTaJa** - floor lamps, candelabra, and chandeliers.
- **Nipeyo** - castle interiors.
- **Midhil [Leo Red]** - UI Lucid icons.
- **BlackSpire Studio** - medieval objects.
- **karsiori** - animated pixel art key pack.
- **Luck** - animated satyr character.
- **David G** - dungeon tileset.
- **Kenney** - fantasy UI borders.
- **GioeleFazzeri** (Pixabay) - "A Sinister Power Rising" background music.

See the individual folders under `game-source-code-4.3/assets/` for the original license and readme files.

---

## License and Copyright

Copyright Shashank Verma / PixelForge Studios 2024. All rights reserved.

The game code and original content may not be reproduced, distributed, or transmitted without prior written permission from the copyright owner. Third-party assets remain the property of their respective creators and are used under their own licenses.

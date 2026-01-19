# Flipside-Godot

A modern, open-source re-implementation of the classic Nitrome Flash game **"Flipside"** (2009) using **Godot 4**.

This project focuses on recreating the unique momentum-based physics, adhesion mechanics, and split-screen multiplayer experience of the original title using a `RigidBody2D` architecture.

## 🚧 Project Status: Phase 1 (POC)

We are currently in **Phase 1: Physics Prototype**.
The goal is to validate the vehicle architecture and wall-running mechanics before full-scale production.

- [ ] **Vehicle Physics**: Double-wheel "Dumbbell" structure (RigidBody + PinJoints).
- [ ] **Adhesion System**: Custom gravity logic based on velocity thresholds.
- [ ] **Track Generation**: Tooling to convert `Path2D` to smooth `CollisionPolygon2D`.
- [ ] **Locomotion**: Friction-based movement (Ground) & Torque control (Air).

## 🛠 Tech Stack

- **Engine**: Godot 4.x (Standard Version)
- **Language**: GDScript
- **Physics**: Godot Physics 2D (RigidBody simulation)
- **Architecture**: Component-based & Feature-based folder structure.

## 📂 Project Structure

The project follows a feature-based architecture to ensure scalability.

```text
.
├── assets/                 # Raw assets (Sprites, Audio - .gdignore recommended)
├── docs/                   # Engineering & Design Documentation
│   ├── 01_Game_Design.md   # GDD & Mechanics Rules
│   ├── 02_Architecture.md  # Physics Implementation Details
│   └── 03_Roadmap.md       # Milestones
├── src/                    # Source Code (Scenes & Scripts)
│   ├── _core/              # Autoloads & Global Managers
│   ├── components/         # Reusable behaviors (e.g., CurveGenerator)
│   ├── entities/           # Game Objects (Vehicle, Obstacles)
│   ├── levels/             # Maps & Level Building Blocks
│   │   ├── blocks/         # Modular Track Pieces
│   │   └── test/           # Physics Sandboxes (POC)
│   └── ui/                 # HUD & Interfaces
└── tools/                  # EditorScripts & Dev Tools

```

## 🚀 Getting Started

1. **Clone the repository**
```bash
git clone [https://github.com/your-username/flipside-remake.git](https://github.com/your-username/flipside-remake.git)

```


2. **Import into Godot 4**
* Launch Godot.
* "Import" -> Select the `project.godot` file.


3. **Run the POC Scene**
* Navigate to `src/levels/test/`.
* Open and run `sandbox_physics.tscn` (Filename TBD upon implementation).



## 📖 Documentation

* **[Game Design](https://www.google.com/search?q=docs/01_Game_Design.md)**: Rules, winning conditions, and mechanics.
* **[Technical Architecture](https://www.google.com/search?q=docs/02_Architecture.md)**: Detailed breakdown of the custom gravity and vehicle physics.
* **[Roadmap](https://www.google.com/search?q=docs/03_Roadmap.md)**: Development phases.

## ⚖️ License & Disclaimer

* **Code**: MIT License (Free to use and modify).
* **Assets/IP**: This is a fan recreation. The original game design, art style concepts, and "Flipside" IP belong to **Nitrome**. This project is for educational and preservation purposes.

---

# 02. Technical Architecture

## 1. 物理系統 (Physics System)
採用 **Godot RigidBody2D** 進行全物理模擬，而非 CharacterBody2D。

### A. 車輛結構 (The "Dumbbell" Model)
車輛由三個剛體與兩個關節組成：
1.  **Chassis (柄/車身)**：
    -   `RigidBody2D` (Mass: ~1.0kg)
    -   **無碰撞體積 (Collision Layer = 0)**：防止卡底盤，允許穿透尖銳地形。
    -   負責：空中姿態控制 (Torque)、攝影機錨點。
2.  **Wheels (左輪/右輪)**：
    -   `RigidBody2D` (Mass: ~0.5kg)
    -   `CollisionShape2D`: Circle.
    -   `PhysicsMaterial`: High Friction (1.0), No Bounce.
    -   負責：地面接觸、摩擦力推進。
3.  **Joints (連接)**：
    -   `PinJoint2D` (Softness: 0, Rigid).
    -   `Motor Enabled`: True (用於地面驅動)。

### B. 自定義重力演算法 (Custom Gravity)
**Implementation Pattern** (遵循 Godot 官方最佳實踐):

1.  **State Detection** (`_physics_process()`):
    -   雙輪 RayCast 向下偵測地面法線 (`n_left`, `n_right`)。
    -   計算平均法線：`TargetNormal = (n_left + n_right).normalized()`。
    -   檢查速度閾值：`is_adhered = velocity > THRESHOLD`。
    -   **Hysteresis Buffer**: 防止在閾值邊界快速抖動 (±50 px/s)。

2.  **Force Application** (`_apply_adhesion_forces()`):
    -   **IF** `is_adhered`:
        -   施加吸附力：`apply_central_force(-TargetNormal * ADHESION_FORCE)`。
        -   抵消全域重力：`apply_central_force(-gravity_vector * mass)`。
    -   **ELSE**:
        -   無動作（Godot 自動施加全域重力）。

**Why This Approach**:
-   **不使用 `gravity_scale = 0`**：避免與引擎內建計算衝突。
-   **使用 `apply_central_force()`**：在 `_physics_process()` 排隊力，下一幀物理步驟生效。
-   **不使用 `_integrate_forces()`**：因為無法從父腳本覆寫子節點的回調。

### C. 控制狀態機 (Control State Machine)
```gdscript
enum ControlState { GROUND, AIR }

GROUND Mode:
  - PinJoint2D.motor_enabled = true
  - Apply motor_target_velocity based on input
  - Friction-based propulsion via wheel rotation
  
AIR Mode:
  - PinJoint2D.motor_enabled = false
  - Apply torque to chassis for rotation control
  - Player adjusts landing angle
```

## 2. 地形系統 (Terrain System)
為了保持動量守恆，必須確保碰撞體絕對平滑。

- **方案**：`Path2D` -> `CollisionPolygon2D` (Baking)。
- **參數**：`Bake Interval` <= 2px。
- **工具**：需編寫 `@tool` 腳本自動將 Path 轉換為高精度 Polygon。

## 3. 網路/多人架構 (TBD)
- 初期 POC 採用單機雙人 (Split Screen)。
- 實作：兩個 `SubViewportContainer` 包含獨立的 `Camera2D`。

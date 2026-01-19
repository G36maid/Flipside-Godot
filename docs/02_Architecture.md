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
實作於 `_integrate_forces()`：
1.  **偵測**：雙輪 RayCast 向下偵測地面法線 (`n_left`, `n_right`)。
2.  **平均法線**：`TargetNormal = (n_left + n_right).normalized()`。
3.  **狀態機**：
    -   **IF** `Velocity > Threshold` **AND** `IsOnGround`:
        -   `GravityScale = 0` (關閉全域重力).
        -   `ApplyForce(-TargetNormal * AdhesionFactor)` (施加吸附力).
    -   **ELSE**:
        -   `GravityScale = 1` (恢復自然重力).

## 2. 地形系統 (Terrain System)
為了保持動量守恆，必須確保碰撞體絕對平滑。

- **方案**：`Path2D` -> `CollisionPolygon2D` (Baking)。
- **參數**：`Bake Interval` <= 2px。
- **工具**：需編寫 `@tool` 腳本自動將 Path 轉換為高精度 Polygon。

## 3. 網路/多人架構 (TBD)
- 初期 POC 採用單機雙人 (Split Screen)。
- 實作：兩個 `SubViewportContainer` 包含獨立的 `Camera2D`。

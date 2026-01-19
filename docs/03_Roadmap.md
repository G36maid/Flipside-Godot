# 03. Development Roadmap

## Phase 1: POC (Physics Prototype) [IN PROGRESS - 2026-01-20]
驗證核心物理的可行性。
- [x] **Project Structure**: 建立 POC 目錄結構與核心檔案。
- [x] **Global Constants**: 定義物理參數 (閾值、力量、質量)。
- [x] **Vehicle Setup**: 建立無碰撞柄+雙輪的物理結構。
- [ ] **Adhesion Logic**: 完成 `vehicle_controller.gd` 的速度吸附與掉落邏輯。
- [ ] **Input System**: 實作地面/空中輸入控制 (摩擦力 vs. 力矩)。
- [ ] **Track Gen**: 實作 Path2D 轉 CollisionPolygon2D 的工具。
- [ ] **Test**: 驗證橢圓軌道 360 度行駛不掉落。

## Phase 2: MVP (Minimum Playable)
建立最小可玩循環。
- [ ] **Input System**: 支援 P1/P2 雙人輸入映射。
- [ ] **Camera**: 實作 Split-screen 與動態縮放/旋轉（視角跟隨車頭方向）。
- [ ] **Level Elements**: 實作「減速帶」與「死亡邊界」。
- [ ] **Loop**: 起點 -> 賽道 -> 終點判定。

## Phase 3: Content & Polish
- [ ] **Visuals**: 替換幾何圖形為 Pixel Art 素材。
- [ ] **Map Editor**: 建立模組化賽道塊 (Curve, Straight, Loop)。
- [ ] **Audio**: 引擎聲與撞擊音效。

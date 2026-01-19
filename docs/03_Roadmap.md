# 03. Development Roadmap

## Phase 1: POC (Physics Prototype) [Current]
驗證核心物理的可行性。
- [ ] **Vehicle Setup**: 建立無碰撞柄+雙輪的物理結構。
- [ ] **Track Gen**: 實作 Path2D 轉 CollisionPolygon2D 的工具。
- [ ] **Adhesion Logic**: 撰寫 `_integrate_forces` 實現速度吸附與掉落。
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

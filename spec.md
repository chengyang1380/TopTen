# 腦洞量表 Top Ten - 功能規格書 (spec.md)

## 1. 模組：抽數字 (Shared Number Drawing Tool)
這是遊戲的核心工具，供所有版本共用。

### 1.1 功能需求
- **初始設定流程 (Setup Flow)**: 
  - 彈出設定對話框。
- **隱私機制 (Tap to Reveal with Custom Confirmation)**: 
  - **翻牌確認對話框**: 點擊蓋牌時，彈出自定義置中對話框。
  - **視覺區分**: 
    - 「確定揭曉」：醒目的實色按鈕。
    - 「取消」：低調的文字按鈕。
  - 玩家點擊卡片即可切換揭曉/蓋牌。

---

## 2. 模組：遊戲版本 (Game Versions)
... (保持不變)

---

## 3. UI/UX 規範 (SwiftUI)
### 3.2 抽數字畫面
- **自定義揭曉對話框**: 
  - 樣式：置中卡片，背景帶有毛玻璃/調暗效果。
  - 按鈕：Teal 色填滿按鈕 (Confirm) vs. 灰色文字按鈕 (Cancel)。
- **觸覺回饋 (Haptic Feedback)**: 彈出對話框、點擊確認時觸發。

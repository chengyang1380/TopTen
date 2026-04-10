# 腦洞量表 Top Ten - 功能規格書 (spec.md)

... (1. 抽數字模組保持不變)

## 2. 模組：題庫與持久化 (Questions & Persistence)

### 2.1 資料模型 (SwiftData Model)
- **QuestionModel**:
  - `id`: UUID (Primary Key)
  - `content`: String (題目敘述)
  - `scaleLow`: String (1 的描述)
  - `scaleHigh`: String (10 的描述)
  - `category`: String (例如："Basic", "Adventure", "NSFW", "Custom")
  - `isBuiltIn`: Bool (標記是否為系統內建題目)
  - `createdAt`: Date

### 2.2 核心流程
- **資料初始化 (Seeding)**:
  - App 首次啟動時，偵測資料庫是否為空。
  - 若為空，從內建 JSON 載入基礎題庫並存入 SwiftData。
- **隨機抽題**:
  - 支援按 `category` 進行篩選。
  - 隨機從該類別中選取一題。
- **客製化題目**:
  - 提供 API 讓使用者新增、刪除自定義題目。

---

## 3. UI/UX 規範 (SwiftUI)
...
### 3.3 遊戲分頁 (GameView)
- **題目卡片**: 位於畫面中央。
- **量表定義區**: 清楚顯示 1 與 10 的定義文字。
- **切換按鈕**: 「下一題」按鈕，觸發新的隨機抽取。

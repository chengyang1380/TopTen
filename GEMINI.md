# 腦洞量表 Top Ten - 專案憲法 (GEMINI.md)

## 1. 專案願景
本專案旨在以最先進的 Swift 技術棧（iOS 26+）打造「腦洞量表 Top Ten」數位版。強調極致的性能、安全性與 100% 的測試可靠度。

## 2. 技術棧與環境 (High-End Spec)
- **作業系統**: **iOS 26.0+** (未來前瞻版本)
- **開發語言**: **Swift 6.3+**
  - 開啟 **Strict Concurrency Checking**。
  - 核心邏輯必須完全使用 **Swift Concurrency** (async/await, Actors, TaskGroups)。
- **UI 框架**: SwiftUI (最新特性優先)
- **架構模式**: **MVVM (Model-View-ViewModel)**
  - **ViewModel**: 必須使用 `@Observable` 宏，且標記為 `@MainActor`。
  - **狀態管理**: 嚴格禁止視圖內嵌複雜邏輯，ViewModel 是唯一的真理來源 (Single Source of Truth)。

## 3. 開發規範 (核心指令)
### 3.1 嚴格遵守 TDD (Test-Driven Development)
- **測試先行**: 在實作任何 ViewModel 邏輯或 Data Model 轉換前，**必須**先撰寫測試。
- **測試框架**: **僅限使用 Swift Testing**。
  - 禁止使用 `XCTest`。
  - 善用 `@Test`、`#expect`、`@Suite` 等新語法。
- **自動化驗證**: 每次開發完成後，AI 必須執行測試並確保全數通過。

### 3.2 異步與併發規範
- **Concurrency**: 避免使用 `DispatchQueue`，優先使用 Swift 原生併發模型。
- **Actors**: 針對執行緒敏感的資源（如題目資料庫、計分器），必須使用 `actor` 確保 Thread Safety。
- **Task Management**: 正確處理 `Task` 的生命週期，確保在 View 消失時取消不必要的異步任務。

### 3.3 程式碼品質
- **SOLID 原則**: 每一行程式碼都必須具備高可測試性。
- **DI (Dependency Injection)**: 所有的 Service (如 `GameService`) 必須透過 `init` 注入，以便在測試中使用 `Mock`。

## 4. UI/UX 規範
- **風格**: 參考 `top-ten-750px.jpg`，強調現代感、高對比度與流暢動畫。
- **色彩**: 
  - **Primary**: Teal (#22808E)
  - **Secondary**: Rainbow Scale (1-10)
- **Responsive**: 必須適配所有屏幕尺寸。

## 5. 檔案結構 (嚴格執行)
- `TopTen/Models`: Pure data & Actors.
- `TopTen/ViewModels`: Business logic & State (using `@Observable`).
- `TopTen/Views`: SwiftUI components.
- `TopTen/Services`: Network/Storage protocols and implementations.
- `TopTenTests`: **Swift Testing** suites.

---
**注意**: AI 在執行任何 Directives 前，必須確保其產出的程式碼符合 Swift 6.3 的編譯要求與 Swift Testing 規範。

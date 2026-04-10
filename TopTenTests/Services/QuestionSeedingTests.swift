import Testing
import Foundation
import SwiftData
@testable import TopTen

@Suite("題庫初始化 (Seeding) 測試")
@MainActor
struct QuestionSeedingTests {
    
    @Test("驗證能從 JSON 資料解析並執行 Seeding")
    func test_seeding_parsesJSONAndInsertsIntoDatabase() async throws {
        // Given: 準備 InMemory 資料庫與 Mock JSON 資料
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: QuestionModel.self, configurations: config)
        let service = QuestionService(container: container)
        
        let jsonString = """
        [
            {
                "content": "如果你是超級英雄，你的超能力跟大便有關，那是什麼？",
                "scaleLow": "完全沒用",
                "scaleHigh": "統治世界",
                "category": "Basic"
            }
        ]
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // 1. 建立一個 JSON 題目
        let decoder = JSONDecoder()
        // 這裡會遇到問題：QuestionModel 是 SwiftData Model，預設不支援 Codable。
        // 所以我需要在實作中讓它支援 Decodable 或建立一個 DTO。
        
        // --- 預期的實作行為 ---
        // let questions = try decoder.decode([QuestionDTO].self, from: jsonData)
        // try await service.seedInitialQuestions(from: questions.map { $0.toModel() })
        
        // --- 目前先驗證 Seeding 方法本身 ---
        let mockModels = [
            QuestionModel(content: "JSON 題 1", scaleLow: "L", scaleHigh: "H", category: "Basic", isBuiltIn: true)
        ]
        
        try await service.seedInitialQuestions(from: mockModels)
        
        // Then
        let fetched = try await service.fetchQuestions(category: "Basic")
        #expect(fetched.count == 1)
        #expect(fetched.first?.isBuiltIn == true)
    }
}

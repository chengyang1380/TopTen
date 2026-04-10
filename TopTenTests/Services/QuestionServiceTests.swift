import Testing
import Foundation
import SwiftData
@testable import TopTen

@Suite("題目資料庫服務測試")
@MainActor
struct QuestionServiceTests {
    let container: ModelContainer
    let service: QuestionService
    
    init() throws {
        // 使用 InMemory 容器進行測試，確保測試間不干擾且不影響真實資料
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: QuestionModel.self, configurations: config)
        service = QuestionService(container: container)
    }
    
    @Test("驗證新增題目後能正確讀取")
    func test_addQuestion_persistsToDatabase() async throws {
        let question = QuestionModel(content: "測試題目 1", scaleLow: "低", scaleHigh: "高", category: "Basic")
        
        try await service.addQuestion(question)
        let questions = try await service.fetchQuestions(category: "Basic")
        
        #expect(questions.count == 1)
        #expect(questions.first?.content == "測試題目 1")
    }
    
    @Test("驗證分類篩選邏輯")
    func test_fetchQuestions_filtersByCategory() async throws {
        let q1 = QuestionModel(content: "基本 1", scaleLow: "L", scaleHigh: "H", category: "Basic")
        let q2 = QuestionModel(content: "冒險 1", scaleLow: "L", scaleHigh: "H", category: "Adventure")
        
        try await service.addQuestion(q1)
        try await service.addQuestion(q2)
        
        let basicOnes = try await service.fetchQuestions(category: "Basic")
        let adventureOnes = try await service.fetchQuestions(category: "Adventure")
        
        #expect(basicOnes.count == 1)
        #expect(basicOnes.first?.content == "基本 1")
        #expect(adventureOnes.count == 1)
    }
    
    @Test("驗證隨機抽牌邏輯")
    func test_fetchRandomQuestion_returnsValidData() async throws {
        let q1 = QuestionModel(content: "Q1", scaleLow: "L", scaleHigh: "H", category: "Basic")
        let q2 = QuestionModel(content: "Q2", scaleLow: "L", scaleHigh: "H", category: "Basic")
        
        try await service.addQuestion(q1)
        try await service.addQuestion(q2)
        
        let random = try await service.fetchRandomQuestion(category: "Basic")
        
        #expect(random != nil)
        #expect(["Q1", "Q2"].contains(random?.content))
    }
}

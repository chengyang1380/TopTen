import Testing
import Foundation
import SwiftData
@testable import TopTen

@Suite("遊戲分頁 (GameViewModel) 功能測試")
@MainActor
struct GameViewModelTests {
    
    @Test("驗證搜尋功能過濾清單")
    func test_filteredQuestions_appliesSearchCriteria() async throws {
        let viewModel = GameViewModel(category: "Basic")
        let q1 = QuestionModel(content: "蘋果", scaleLow: "L", scaleHigh: "H", category: "Basic")
        let q2 = QuestionModel(content: "香蕉", scaleLow: "L", scaleHigh: "H", category: "Basic")
        
        viewModel.allQuestions = [q1, q2]
        
        // 搜尋 "蘋果"
        viewModel.searchText = "蘋果"
        #expect(viewModel.filteredQuestions.count == 1)
        #expect(viewModel.filteredQuestions.first?.content == "蘋果")
    }
}
